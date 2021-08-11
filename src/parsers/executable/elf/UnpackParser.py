# Binary Analysis Next Generation (BANG!)
#
# This file is part of BANG.
#
# BANG is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License, version 3,
# as published by the Free Software Foundation.
#
# BANG is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License, version 3, along with BANG.  If not, see
# <http://www.gnu.org/licenses/>
#
# Copyright Armijn Hemel
# Licensed under the terms of the GNU Affero General Public License
# version 3
# SPDX-License-Identifier: AGPL-3.0-only


import os
import binascii
from UnpackParser import WrappedUnpackParser
from bangunpack import unpack_elf
from UnpackParser import UnpackParser, check_condition
from UnpackParserException import UnpackParserException
from kaitaistruct import ValidationNotEqualError
from kaitaistruct import UndecidedEndiannessError
from . import elf


#class ElfUnpackParser(UnpackParser):
class ElfUnpackParser(WrappedUnpackParser):
    extensions = []
    signatures = [
        (0, b'\x7f\x45\x4c\x46')
    ]
    pretty_name = 'elf'

    def unpack_function(self, fileresult, scan_environment, offset, unpack_dir):
        return unpack_elf(fileresult, scan_environment, offset, unpack_dir)

    def parse(self):
        self.chunknames = set()
        try:
            self.data = elf.Elf.from_io(self.infile)

            # calculate size, also read all the data to catch EOF
            phoff = self.data.header.program_header_offset
            self.unpacked_size = phoff
            for header in self.data.header.program_headers:
                self.unpacked_size = max(self.unpacked_size, phoff + header.offset + header.filesz)

            # TODO: Qualcomm DSP6 (Hexagon) files, as found on many
            # Android devices.

            # typically the section header is at the end of the ELF file
            shoff = self.data.header.section_header_offset
            self.unpacked_size = max(self.unpacked_size, shoff + self.data.header.qty_section_header
                                     * self.data.header.section_header_entry_size)
            for header in self.data.header.section_headers:
                self.unpacked_size = max(self.unpacked_size, header.ofs_body + header.len_body)

                # ugly ugly hack to work around situations on Android where
                # ELF files have been split into individual sections and all
                # offsets are wrong.
                if header.type == elf.Elf.ShType.note:
                    for entry in header.body.entries:
                        pass
        except (Exception, ValidationNotEqualError, UndecidedEndiannessError) as e:
            raise UnpackParserException(e.args)

    def calculate_unpacked_size(self):
        pass

    def set_metadata_and_labels(self):
        """sets metadata and labels for the unpackresults"""
        labels = [ 'elf' ]
        metadata = {}
        string_cutoff_length = 4

        if self.data.bits == elf.Elf.Bits.b32:
            metadata['bits'] = 32
        elif self.data.bits == elf.Elf.Bits.b64:
            metadata['bits'] = 64

        # store the endianness
        if self.data.endian == elf.Elf.Endian.le:
            metadata['endian'] = 'little'
        elif self.data.endian == elf.Elf.Endian.be:
            metadata['endian'] = 'big'

        # store the ELF version
        metadata['version'] = self.data.ei_version

        # store the type of ELF file
        if self.data.header.e_type == elf.Elf.ObjType.no_file_type:
            metadata['type'] = None
        elif self.data.header.e_type == elf.Elf.ObjType.relocatable:
            metadata['type'] = 'relocatable'
        elif self.data.header.e_type == elf.Elf.ObjType.executable:
            metadata['type'] = 'executable'
        elif self.data.header.e_type == elf.Elf.ObjType.shared:
            metadata['type'] = 'shared'
        elif self.data.header.e_type == elf.Elf.ObjType.core:
            metadata['type'] = 'core'
        else:
            metadata['type'] = 'processor specific'

        # store the machine type, both numerical and pretty printed
        metadata['machine_name'] = self.data.header.machine.name
        metadata['machine'] = self.data.header.machine.value

        metadata['security'] = []
        if self.data.header.section_names is not None:
            metadata['section_names'] = self.data.header.section_names.entries

        # keep track of whether or not GNU_RELRO has been set
        seen_relro = False

        for header in self.data.header.program_headers:
            if header.type == elf.Elf.PhType.gnu_relro:
                metadata['security'].append('relro')
                seen_relro = True
            elif header.type == elf.Elf.PhType.gnu_stack:
                # check to see if NX is set
                if not header.flags_obj.execute:
                    metadata['security'].append('nx')
            elif header.type == elf.Elf.PhType.pax_flags:
                metadata['security'].append('pax')

        # store the data normally extracted using for example 'strings'
        data_strings = []

        # store dependencies (empty for statically linked binaries)
        needed = []

        # store dynamic symbols (empty for statically linked binaries)
        dynamic_symbols = []

        # store information about notes
        notes = []

        # store symbols (empty for most binaries, except for
        # non-stripped binaries)
        symbols = []

        # store RPATH and RUNPATH. Both could be present in a binary
        rpath = ''
        runpath = ''

        # shared object name (for libraries)
        soname = ''

        # only look at a few interesting sections. This should be expanded.
        rodata_sections = ['.rodata', '.rodata.str1.1', '.rodata.str1.4',
                           '.rodata.str1.8', '.rodata.cst4', '.rodata.cst8',
                           '.rodata.cst16', 'rodata']

        # process the various section headers
        is_dynamic_elf = False
        for header in self.data.header.section_headers:
            if header.name in ['.modinfo', '__ksymtab_strings']:
                labels.append('linuxkernelmodule')
            elif header.name in ['oat_patches', '.text.oat_patches', '.dex']:
                labels.append('oat')
                labels.append('android')
            elif header.name in ['.guile.procprops', '.guile.frame-maps',
                                 '.guile.arities.strtab', '.guile.arities',
                                 '.guile.docstrs.strtab', '.guile.docstrs']:
                labels.append('guile')

            if header.type == elf.Elf.ShType.dynamic:
                if header.name == '.dynamic':
                    for entry in header.body.entries:
                        if entry.tag_enum == elf.Elf.DynamicArrayTags.needed:
                            needed.append(entry.value_str)
                        elif entry.tag_enum == elf.Elf.DynamicArrayTags.rpath:
                            rpath = entry.value_str
                        elif entry.tag_enum == elf.Elf.DynamicArrayTags.runpath:
                            runpath = entry.value_str
                        elif entry.tag_enum == elf.Elf.DynamicArrayTags.soname:
                            soname = entry.value_str
                        elif entry.tag_enum == elf.Elf.DynamicArrayTags.flags_1:
                            # check for position independent code
                            if entry.flag_1_values.pie:
                                metadata['security'].append('pie')
                            # check for bind_now
                            if entry.flag_1_values.now:
                                if seen_relro:
                                    metadata['security'].append('full relro')
                                else:
                                    metadata['security'].append('partial relro')
                        elif entry.tag_enum == elf.Elf.DynamicArrayTags.flags:
                            # TODO: check for bind_now here as well
                            pass
            elif header.type == elf.Elf.ShType.symtab:
                if header.name == '.symtab':
                    for entry in header.body.entries:
                        symbol = {}
                        if entry.name == None:
                            symbol['name'] = ''
                        else:
                            symbol['name'] = entry.name
                        symbol['type'] = entry.type.name
                        symbol['binding'] = entry.bind.name
                        symbol['visibility'] = entry.visibility.name
                        symbol['section_index'] = entry.sh_idx
                        symbol['size'] = entry.size
                        symbols.append(symbol)
            elif header.type == elf.Elf.ShType.dynsym:
                if header.name == '.dynsym':
                    for entry in header.body.entries:
                        symbol = {}
                        if entry.name == None:
                            symbol['name'] = ''
                        else:
                            symbol['name'] = entry.name
                        symbol['type'] = entry.type.name
                        symbol['binding'] = entry.bind.name
                        symbol['visibility'] = entry.visibility.name
                        symbol['section_index'] = entry.sh_idx
                        symbol['size'] = entry.size
                        symbols.append(symbol)
                        dynamic_symbols.append(symbol)

            elif header.type == elf.Elf.ShType.progbits:
                # process the various progbits sections here
                if header.name == '.comment':
                    # comment, typically in binaries that have
                    # not been stripped.
                    try:
                        comment = list(filter(lambda x: x != b'', header.body.split(b'\x00')))[0].decode()
                        metadata['comment'] = comment
                    except:
                        pass
                elif header.name == '.gcc_except_table':
                    # debug information from GCC
                    pass
                elif header.name == '.gnu_debugdata':
                    # debug data, often compressed
                    pass
                elif header.name == '.gnu_debuglink':
                    # https://sourceware.org/gdb/onlinedocs/gdb/Separate-Debug-Files.html
                    link_name = header.body.split(b'\x00', 1)[0].decode()
                    link_crc = header.body[-4:]
                    metadata['gnu debuglink'] = link_name
                elif header.name in rodata_sections:
                    for s in header.body.split(b'\x00'):
                        if len(s) < string_cutoff_length:
                            continue
                        try:
                            data_strings.append(s.decode())
                        except:
                            pass
                    # some Qt binaries use the Qt resource system,
                    # containing images, text, etc.
                    # Sometimes these end up in an ELF section.
                    if b'qrc:/' in header.body:
                        pass
                elif header.name == '.gopclntab':
                    # https://medium.com/walmartglobaltech/de-ofuscating-golang-functions-93f610f4fb76
                    pass
                elif header.name == '.gosymtab':
                    # Go symbol table
                    pass
                elif header.name.startswith('.gresource.'):
                    # GNOME/glib GVariant database
                    pass
                elif header.name == '.interp':
                    # store the location of the dynamic linker
                    metadata['linker'] = header.body.split(b'\x00', 1)[0].decode()
                elif header.name == '.itablink':
                    # Go
                    pass
                elif header.name == '.noptrdata':
                    # Go pointer free data
                    pass
                elif header.name == '.qml_compile_hash':
                    pass
                elif header.name == '.qtmetadata':
                    pass
                elif header.name == '.qtmimedatabase':
                    # data, in possibly zstd/gzip compressed
                    pass
                elif header.name == '.qtversion':
                    pass
                elif header.name == '.tm_clone_table':
                    # something related to transactional memory
                    # http://gcc.gnu.org/wiki/TransactionalMemory
                    pass
                elif header.name == '.typelink':
                    # Go
                    pass
                elif header.name == '.VTGData':
                    # VirtualBox tracepoint generated data
                    # https://www.virtualbox.org/browser/vbox/trunk/include/VBox/VBoxTpG.h
                    pass
                elif header.name == '.VTGPrLc':
                    pass
            if header.type == elf.Elf.ShType.dynamic:
                is_dynamic_elf = True
                for entry in header.body.entries:
                    pass
            elif header.type == elf.Elf.ShType.strtab:
                for entry in header.body.entries:
                    pass
            elif header.type == elf.Elf.ShType.dynsym:
                for entry in header.body.entries:
                    pass
            elif header.type == elf.Elf.ShType.note:
                if header.name == '.note.go.buildid':
                    labels.append('go')

                # Although not common notes sections can be merged
                # with eachother. Example: .notes in Linux kernel images
                for entry in header.body.entries:
                    notes.append((entry.name.decode(), entry.type))
                    if entry.name == b'GNU' and entry.type == 1:
                        # https://raw.githubusercontent.com/wiki/hjl-tools/linux-abi/linux-abi-draft.pdf
                        # normally in .note.ABI.tag
                        major_version = int.from_bytes(entry.descriptor[4:8],
                                                       byteorder=metadata['endian'])
                        patchlevel = int.from_bytes(entry.descriptor[8:12],
                                                    byteorder=metadata['endian'])
                        sublevel = int.from_bytes(entry.descriptor[12:],
                                                  byteorder=metadata['endian'])
                        metadata['linux_version'] = (major_version, patchlevel, sublevel)
                    elif entry.name == b'GNU' and entry.type == 3:
                        # normally in .note.gnu.build-id
                        buildid = binascii.hexlify(entry.descriptor).decode()
                        metadata['build-id'] = buildid
                        if len(buildid) == 40:
                            metadata['build-id hash'] = 'sha1'
                        elif len(buildid) == 32:
                            metadata['build-id hash'] = 'md5'
                    elif entry.name == b'GNU' and entry.type == 4:
                        # normally in .note.gnu.gold-version
                        metadata['gold-version'] = entry.descriptor.split(b'\x00', 1)[0].decode()
                    elif entry.name == b'GNU' and entry.type == 5:
                        # normally in .note.gnu.property
                        pass
                    elif entry.name == b'Go' and entry.type == 4:
                        # normally in .note.go.buildid
                        # there are four hashes concatenated
                        # https://golang.org/pkg/cmd/internal/buildid/#FindAndHash
                        pass
                    elif entry.name == b'Crashpad' and entry.type == 0x4f464e49:
                        # https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/master/util/misc/elf_note_types.h
                        pass
                    elif entry.name == b'stapsdt' and entry.type == 3:
                        # SystemTap probe descriptors
                        labels.append('SystemTap')
                    elif entry.name == b'Linux':
                        # .note.Linux as seen in some Linux kernel modules
                        labels.append('linux kernel')
                        if entry.type == 0x100:
                            # LINUX_ELFNOTE_BUILD_SALT
                            # see BUILD_SALT in init/Kconfig
                            try:
                                metadata['kernel build id salt'] = entry.descriptor.decode()
                            except:
                                pass
                        elif entry.type == 0x101:
                            # LINUX_ELFNOTE_LTO_INFO
                            pass
                    elif entry.name == b'FreeBSD':
                        labels.append('freebsd')
                    elif entry.name == b'OpenBSD':
                        labels.append('openbsd')
                    elif entry.name == b'NetBSD':
                        # https://www.netbsd.org/docs/kernel/elf-notes.html
                        labels.append('netbsd')
                    elif entry.name == b'Android' and entry.type == 1:
                        # https://android.googlesource.com/platform/ndk/+/master/parse_elfnote.py
                        labels.append('android')
                        metadata['android ndk'] = int.from_bytes(entry.descriptor, byteorder='little')
                    elif entry.name == b'Xen':
                        # http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/include/public/elfnote.h;h=181cbc4ec71c4af298e40c3604daff7d3b48d52f;hb=HEAD
                        # .note.Xen in FreeBSD kernel
                        # .notes in Linux kernel)
                        labels.append('xen')

        metadata['dynamic_symbols'] = dynamic_symbols
        metadata['needed'] = needed
        metadata['notes'] = notes
        metadata['rpath'] = rpath
        metadata['runpath'] = runpath
        metadata['soname'] = soname
        metadata['strings'] = data_strings
        metadata['symbols'] = symbols

        if is_dynamic_elf:
            labels.append('dynamic')
        else:
            labels.append('static')

        self.unpack_results.set_metadata(metadata)
        self.unpack_results.set_labels(labels)
