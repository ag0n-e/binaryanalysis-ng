meta:
  id: elf
  title: Executable and Linkable Format
  application: SVR4 ABI and up, many *nix systems
  xref:
    justsolve: Executable_and_Linkable_Format
    mime:
      - application/x-elf
      - application/x-coredump
      - application/x-executable
      - application/x-object
      - application/x-sharedlib
    pronom:
      - fmt/688 # 32bit Little Endian
      - fmt/689 # 32bit Big Endian
      - fmt/690 # 64bit Little Endian
      - fmt/691 # 64bit Big Endian
    wikidata: Q1343830
  tags:
    - executable
    - linux
  license: CC0-1.0
  ks-version: 0.9
doc-ref:
  - https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=HEAD
  - https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html
  - https://docs.oracle.com/cd/E37838_01/html/E36783/glcfv.html
seq:
  - id: magic
    -orig-id: e_ident[EI_MAG0]..e_ident[EI_MAG3]
    size: 4
    contents: [0x7f, "ELF"]
    doc: File identification, must be 0x7f + "ELF".
  - id: bits
    -orig-id: e_ident[EI_CLASS]
    type: u1
    enum: bits
    doc: |
      File class: designates target machine word size (32 or 64
      bits). The size of many integer fields in this format will
      depend on this setting.
  - id: endian
    -orig-id: e_ident[EI_DATA]
    type: u1
    enum: endian
    doc: Endianness used for all integers.
  - id: ei_version
    -orig-id: e_ident[EI_VERSION]
    type: u1
    valid: 1
    doc: ELF header version.
  - id: abi
    -orig-id: e_ident[EI_OSABI]
    type: u1
    enum: os_abi
    doc: |
      Specifies which OS- and ABI-related extensions will be used
      in this ELF file.
  - id: abi_version
    type: u1
    doc: |
      Version of ABI targeted by this ELF file. Interpretation
      depends on `abi` attribute.
  - id: pad
    size: 7
  - id: header
    type: endian_elf
instances:
  sh_idx_lo_reserved:
    -orig-id: SHN_LORESERVE
    value: 0xff00
  sh_idx_lo_proc:
    -orig-id: SHN_LOPROC
    value: 0xff00
  sh_idx_hi_proc:
    -orig-id: SHN_HIPROC
    value: 0xff1f
  sh_idx_lo_os:
    -orig-id: SHN_LOOS
    value: 0xff20
  sh_idx_hi_os:
    -orig-id: SHN_HIOS
    value: 0xff3f
  sh_idx_hi_reserved:
    -orig-id: SHN_HIRESERVE
    value: 0xffff
types:
  phdr_type_flags:
    params:
      - id: value
        type: u4
    instances:
      read:
        value: value & 0x04 != 0
      write:
        value: value & 0x02 != 0
      execute:
        value: value & 0x01 != 0
      mask_proc:
        value: value & 0xf0000000 != 0
  section_header_flags:
    params:
      - id: value
        type: u4
    instances:
      write:
        value: value & 0x01 != 0
        doc: "writable"
      alloc:
        value: value & 0x02 != 0
        doc: "occupies memory during execution"
      exec_instr:
        value: value & 0x04 != 0
        doc: "executable"
      merge:
        value: value & 0x10 != 0
        doc: "might be merged"
      strings:
        value: value & 0x20 != 0
        doc: "contains nul-terminated strings"
      info_link:
        value: value & 0x40 != 0
        doc: "'sh_info' contains SHT index"
      link_order:
        value: value & 0x80 != 0
        doc: "preserve order after combining"
      os_non_conforming:
        value: value & 0x100 != 0
        doc: "non-standard OS specific handling required"
      group:
        value: value & 0x200 != 0
        doc: "section is member of a group"
      tls:
        value: value & 0x400 != 0
        doc: "section hold thread-local data"
      ordered:
        value: value & 0x04000000 != 0
        doc: "special ordering requirement (Solaris)"
      exclude:
        value: value & 0x08000000 != 0
        doc: "section is excluded unless referenced or allocated (Solaris)"
      mask_os:
        value: value & 0x0ff00000 != 0
        doc: "OS-specific"
      mask_proc:
        value: value & 0xf0000000 != 0
        doc: "Processor-specific"
  dt_flag_1_values:
    params:
      - id: value
        type: u4
    instances:
      now:
        value: value & 0x00000001 != 0
        doc: "Set RTLD_NOW for this object."
      rtld_global:
        value: value & 0x00000002 != 0
        doc: "Set RTLD_GLOBAL for this object."
      group:
        value: value & 0x00000004 != 0
        doc: "Set RTLD_GROUP for this object."
      nodelete:
        value: value & 0x00000008 != 0
        doc: "Set RTLD_NODELETE for this object."
      loadfltr:
        value: value & 0x00000010 != 0
        doc: "Trigger filtee loading at runtime."
      initfirst:
        value: value & 0x00000020 != 0
        doc: "Set RTLD_INITFIRST for this object"
      noopen:
        value: value & 0x00000040 != 0
        doc: "Set RTLD_NOOPEN for this object."
      origin:
        value: value & 0x00000080 != 0
        doc: "$ORIGIN must be handled."
      direct:
        value: value & 0x00000100 != 0
        doc: "Direct binding enabled."
      trans:
        value: value & 0x00000200 != 0
      interpose:
        value: value & 0x00000400 != 0
        doc: "Object is used to interpose."
      nodeflib:
        value: value & 0x00000800 != 0
        doc: "Ignore default lib search path."
      nodump:
        value: value & 0x00001000 != 0
        doc: "Object can't be dldump'ed."
      confalt:
        value: value & 0x00002000 != 0
        doc: "Configuration alternative created."
      endfiltee:
        value: value & 0x00004000 != 0
        doc: "Filtee terminates filters search."
      dispreldne:
        value: value & 0x00008000 != 0
        doc: "Disp reloc applied at build time."
      disprelpnd:
        value: value & 0x00010000 != 0
        doc: "Disp reloc applied at run-time."
      nodirect:
        value: value & 0x00020000 != 0
        doc: "Object has no-direct binding."
      ignmuldef:
        value: value & 0x00040000 != 0
      noksyms:
        value: value & 0x00080000 != 0
      nohdr:
        value: value & 0x00100000 != 0
      edited:
        value: value & 0x00200000 != 0
        doc: "Object is modified after built."
      noreloc:
        value: value & 0x00400000 != 0
      symintpose:
        value: value & 0x00800000 != 0
        doc: "Object has individual interposers."
      globaudit:
        value: value & 0x01000000 != 0
        doc: "Global auditing required."
      singleton:
        value: value & 0x02000000 != 0
        doc: "Singleton symbols are used."
      stub:
        value: value & 0x04000000 != 0
      pie:
        value: value & 0x08000000 != 0
  endian_elf:
    meta:
      endian:
        switch-on: _root.endian
        cases:
          'endian::le': le
          'endian::be': be
    seq:
      - id: e_type
        type: u2
        enum: obj_type
      - id: machine
        type: u2
        enum: machine
      - id: e_version
        type: u4
      # e_entry
      - id: entry_point
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_phoff
      - id: program_header_offset
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_shoff
      - id: section_header_offset
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_flags
      - id: flags
        size: 4
      # e_ehsize
      - id: e_ehsize
        type: u2
      # e_phentsize
      - id: program_header_entry_size
        type: u2
      # e_phnum
      - id: qty_program_header
        type: u2
      # e_shentsize
      - id: section_header_entry_size
        type: u2
      # e_shnum
      - id: qty_section_header
        type: u2
      # e_shstrndx
      - id: section_names_idx
        type: u2
    types:
      # Elf(32|64)_Phdr
      program_header:
        seq:
          # p_type
          - id: type
            type: u4
            enum: ph_type
          # p_flags
          - id: flags64
            type: u4
            if: _root.bits == bits::b64
          # p_offset
          - id: offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_vaddr
          - id: vaddr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_paddr
          - id: paddr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_filesz
          - id: filesz
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_memsz
          - id: memsz
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_flags
          - id: flags32
            type: u4
            if: _root.bits == bits::b32
          # p_align
          - id: align
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          flags_obj:
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': phdr_type_flags(flags32)
                'bits::b64': phdr_type_flags(flags64)
            -webide-parse-mode: eager
        -webide-representation: "{type} - f:{flags_obj:flags} (o:{offset}, s:{filesz:dec})"
      section_header:
        -orig-id: Elf(32|64)_Shdr
        seq:
          - id: ofs_name
            -orig-id: sh_name
            type: u4
          - id: type
            -orig-id: sh_type
            type: u4
            enum: sh_type
          - id: flags
            -orig-id: sh_flags
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: addr
            -orig-id: sh_addr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: ofs_body
            -orig-id: sh_offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: len_body
            -orig-id: sh_size
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: linked_section_idx
            -orig-id: sh_link
            type: u4
          - id: info
            -orig-id: sh_info
            size: 4
          - id: align
            -orig-id: sh_addralign
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: entry_size
            -orig-id: sh_entsize
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          body:
            io: _root._io
            pos: ofs_body
            size: len_body
            type:
              switch-on: type
              cases:
                'sh_type::dynamic': dynamic_section
                'sh_type::strtab': strings_struct
                'sh_type::dynsym': dynsym_section
                'sh_type::symtab': dynsym_section
                'sh_type::note': note_section
                'sh_type::rel': relocation_section(false)
                'sh_type::rela': relocation_section(true)
            if: type != sh_type::nobits
          linked_section:
            value: _root.header.section_headers[linked_section_idx]
            if: |
              linked_section_idx != section_header_idx_special::undefined.to_i
              and linked_section_idx < _root.header.qty_section_header
            doc: may reference a later section header, so don't try to access too early (use only lazy `instances`)
            doc-ref: https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.sheader.html#sh_link
          name:
            io: _root.header.section_names._io
            pos: ofs_name
            type: strz
            encoding: ASCII
            -webide-parse-mode: eager
          flags_obj:
            type: section_header_flags(flags)
            -webide-parse-mode: eager
        -webide-representation: "{name} ({type}) - f:{flags_obj:flags} (o:{offset}, s:{size:dec})"
      strings_struct:
        seq:
          - id: entries
            type: strz
            repeat: eos
            encoding: ASCII
      dynamic_section:
        seq:
          - id: entries
            type: dynamic_section_entry
            repeat: eos
        instances:
          is_string_table_linked:
            value: _parent.linked_section.type == sh_type::strtab
      dynamic_section_entry:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch5.dynamic.html#dynamic_section
        -webide-representation: "{tag_enum}: {value_or_ptr} {value_str} {flag_1_values:flags}"
        seq:
          - id: tag
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: value_or_ptr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          tag_enum:
            value: tag
            enum: dynamic_array_tags
          flag_1_values:
            type: dt_flag_1_values(value_or_ptr)
            if: "tag_enum == dynamic_array_tags::flags_1"
            -webide-parse-mode: eager
          value_str:
            io: _parent._parent.linked_section.body.as<strings_struct>._io
            pos: value_or_ptr
            type: strz
            encoding: ASCII
            if: is_value_str and _parent.is_string_table_linked
            -webide-parse-mode: eager
          is_value_str:
            value: |
              value_or_ptr != 0 and (
                tag_enum == dynamic_array_tags::needed or
                tag_enum == dynamic_array_tags::soname or
                tag_enum == dynamic_array_tags::rpath or
                tag_enum == dynamic_array_tags::runpath or
                tag_enum == dynamic_array_tags::sunw_auxiliary or
                tag_enum == dynamic_array_tags::sunw_filter or
                tag_enum == dynamic_array_tags::auxiliary or
                tag_enum == dynamic_array_tags::filter or
                tag_enum == dynamic_array_tags::config or
                tag_enum == dynamic_array_tags::depaudit or
                tag_enum == dynamic_array_tags::audit
              )
      dynsym_section:
        seq:
          - id: entries
            type: dynsym_section_entry
            repeat: eos
        instances:
          is_string_table_linked:
            value: _parent.linked_section.type == sh_type::strtab
      dynsym_section_entry:
        -orig-id:
          - Elf32_Sym
          - Elf64_Sym
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.symtab.html
        -webide-representation: 'v:{value} s:{size:dec} t:{type} b:{bind} vis:{visibility} i:{sh_idx:dec}[={sh_idx_special}] n:{name}'
        seq:
          - id: ofs_name
            -orig-id: st_name
            type: u4

          - id: value_b32
            type: u4
            if: _root.bits == bits::b32
          - id: size_b32
            type: u4
            if: _root.bits == bits::b32

          - id: bind
            -orig-id: ELF32_ST_BIND(st_info)
            type: b4
            enum: symbol_binding
          - id: type
            -orig-id: ELF32_ST_TYPE(st_info)
            type: b4
            enum: symbol_type
          - id: other
            type: u1
            doc: don't read this field, access `visibility` instead
          - id: sh_idx
            -orig-id: st_shndx
            type: u2
            doc: section header index

          - id: value_b64
            type: u8
            if: _root.bits == bits::b64
          - id: size_b64
            type: u8
            if: _root.bits == bits::b64
        instances:
          value:
            value: |
              _root.bits == bits::b32 ? value_b32 :
              _root.bits == bits::b64 ? value_b64 :
              0
          size:
            value: |
              _root.bits == bits::b32 ? size_b32 :
              _root.bits == bits::b64 ? size_b64 :
              0
          name:
            io: _parent._parent.linked_section.body.as<strings_struct>._io
            pos: ofs_name
            type: strz
            encoding: ASCII
            if: ofs_name != 0 and _parent.is_string_table_linked
            -webide-parse-mode: eager
          visibility:
            value: other & 0x03
            enum: symbol_visibility
          sh_idx_special:
            value: sh_idx
            enum: section_header_idx_special
          is_sh_idx_reserved:
            value: |
              sh_idx >= _root.sh_idx_lo_reserved and
              sh_idx <= _root.sh_idx_hi_reserved
          is_sh_idx_proc:
            value: |
              sh_idx >= _root.sh_idx_lo_proc and
              sh_idx <= _root.sh_idx_hi_proc
          is_sh_idx_os:
            value: |
              sh_idx >= _root.sh_idx_lo_os and
              sh_idx <= _root.sh_idx_hi_os
      note_section:
        seq:
          - id: entries
            type: note_section_entry
            repeat: eos
      note_section_entry:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-18048.html
          # The following source claims that note's `name` and `descriptor` should be padded
          # to 8 bytes in 64-bit ELFs, not always to 4 - although this seems to be an idea of
          # the original spec, it did not catch on in the real world and most implementations
          # always use 4-byte alignment - see
          # <https://fa.linux.kernel.narkive.com/2Za5xb58/patch-01-02-elf-always-define-elf-addr-t-in-linux-elf-h#post13>
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch5.pheader.html#note_section
        seq:
          - id: len_name
            type: u4
          - id: len_descriptor
            type: u4
          - id: type
            type: u4
          - id: name
            size: len_name
            terminator: 0
            doc: |
              Although the ELF specification seems to hint that the `note_name` field
              is ASCII this isn't the case for Linux binaries that have a
              `.gnu.build.attributes` section.
            doc-ref: https://fedoraproject.org/wiki/Toolchain/Watermark#Proposed_Specification_for_non-loaded_notes
          - id: name_padding
            size: -len_name % 4
          - id: descriptor
            size: len_descriptor
          - id: descriptor_padding
            size: -len_descriptor % 4
      relocation_section:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-54839.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.reloc.html
        params:
          - id: has_addend
            type: bool
        seq:
          - id: entries
            type: relocation_section_entry
            repeat: eos
      relocation_section_entry:
        seq:
          - id: offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: info
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: addend
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': s4
                'bits::b64': s8
            if: _parent.has_addend
    instances:
      program_headers:
        pos: program_header_offset
        size: program_header_entry_size
        type: program_header
        repeat: expr
        repeat-expr: qty_program_header
      section_headers:
        pos: section_header_offset
        size: section_header_entry_size
        type: section_header
        repeat: expr
        repeat-expr: qty_section_header
      section_names:
        pos: section_headers[section_names_idx].ofs_body
        size: section_headers[section_names_idx].len_body
        type: strings_struct
        if: |
          section_names_idx != section_header_idx_special::undefined.to_i
          and section_names_idx < _root.header.qty_section_header
enums:
  # EI_CLASS
  bits:
    # ELFCLASS32
    1: b32
    # ELFCLASS64
    2: b64
  # EI_DATA
  endian:
    # ELFDATA2LSB
    1: le
    # ELFDATA2MSB
    2: be
  os_abi:
    0: system_v
    1: hp_ux
    2: netbsd
    3: gnu
    6: solaris
    7: aix
    8: irix
    9: freebsd
    0xa: tru64 # Compaq TRU64 UNIX
    0xb: modesto # Novell Modesto
    0xc: openbsd
    0xd: openvms
    0xe: nsk # Hewlett-Packard Non-Stop Kernel
    0xf: aros # Amiga Research OS
    0x10: fenixos # The FenixOS highly scalable multi-core OS
    0x11: cloudabi # Nuxi CloudABI
    0x12: openvos # Stratus Technologies OpenVOS
  # e_type
  obj_type:
    # ET_NONE
    0: no_file_type
    # ET_REL
    1: relocatable
    # ET_EXEC
    2: executable
    # ET_DYN
    3: shared
    # ET_CORE
    4: core
  machine:
    0x00:
      id: no_machine
      doc: No machine
    0x01:
      id: m32
      doc: AT&T WE 32100
    0x02:
      id: sparc
      doc: Sun SPARC
    0x03:
      id: x86
      doc: Intel 80386
    0x04:
      id: m68k
      doc: Motorola m68k family
    0x05:
      id: m88k
      doc: Motorola m88k family
    0x06:
      id: iamcu
      doc: Intel MCU
    0x07:
      id: i860
      doc: Intel 80860
    0x08:
      id: mips
      doc: MIPS R3000 big-endian
    0x09:
      id: s370
      doc: IBM System/370
    0x0a:
      id: mips_rs3_le
      doc: MIPS R3000 little-endian
    0x0f:
      id: parisc
      doc: HPPA
    0x11:
      id: vpp500
      doc: Fujitsu VPP500
    0x12:
      id: v8plus
      doc: Sun's "v8plus"
    0x13:
      id: i960
      doc: Intel 80960
    0x14:
      id: powerpc
      doc: PowerPC
    0x15:
      id: powerpc64
      doc: PowerPC 64-bit
    0x16:
      id: s390
      doc: IBM S390
    0x17:
      id: spu
      doc: IBM SPU/SPC
    0x24:
      id: v800
      doc: NEC V800 series
    0x25:
      id: fr20
      doc: Fujitsu FR20
    0x26:
      id: rh32
      doc: TRW RH-32
    0x27:
      id: rce
      doc: Motorola RCE
    0x28:
      id: arm
      doc: ARM
    0x29:
      id: alpha
      doc: Digital Alpha
    0x2a:
      id: superh
      doc: Hitachi SH
    0x2b:
      id: sparcv9
      doc: SPARC v9 64-bit
    0x2c:
      id: tricore
      doc: Siemens Tricore
    0x2d:
      id: arc
      doc: Argonaut RISC Core
    0x2e:
      id: h8_300
      doc: Hitachi H8/300
    0x2f:
      id: h8_300h
      doc: Hitachi H8/300H
    0x30:
      id: h8s
      doc: Hitachi H8S
    0x31:
      id: h8_500
      doc: Hitachi H8/500
    0x32:
      id: ia_64
      doc: Intel IA64
    0x33:
      id: mips_x
      doc: Stanford MIPS-X
    0x34:
      id: coldfire
      doc: Motorola Coldfire
    0x35:
      id: m68hc12
      doc: Motorola M68HC12
    0x36:
      id: mma
      doc: Fujitsu MMA Multimedia Accelerator
    0x37:
      id: pcp
      doc: Siemens PCP
    0x38:
      id: ncpu
      doc: Sony nCPU embedded RISC
    0x39:
      id: ndr1
      doc: Denso NDR1 microprocessor
    0x3a:
      id: starcore
      doc: Motorola Star*Core processor
    0x3b:
      id: me16
      doc: Toyota ME16 processor
    0x3c:
      id: st100
      doc: STMicroelectronic ST100 processor
    0x3d:
      id: tiny
      doc: Advanced Logic Corp. Tinyj emb.fam
    0x3e:
      id: x86_64
      doc: AMD x86-64 architecture
    0x3f:
      id: pdsp
      doc: Sony DSP Processor
    0x40:
      id: pdp10
      doc: Digital PDP-10
    0x41:
      id: pdp11
      doc: Digital PDP-11
    0x42:
      id: fx66
      doc: Siemens FX66 microcontroller
    0x43:
      id: st9plus
      doc: STMicroelectronics ST9+ 8/16 microcontroller
    0x44:
      id: st7
      doc: STmicroelectronics ST7 8 bit microcontroller
    0x45:
      id: mc68hc16
      doc: Motorola MC68HC16 microcontroller
    0x46:
      id: mc68hc11
      doc: Motorola MC68HC11 microcontroller
    0x47:
      id: mc68hc08
      doc: Motorola MC68HC08 microcontroller
    0x48:
      id: mc68hc05
      doc: Motorola MC68HC05 microcontroller
    0x49:
      id: svx
      doc: Silicon Graphics SVx
    0x4a:
      id: st19
      doc: STMicroelectronics ST19 8 bit microcontroller
    0x4b:
      id: vax
      doc: Digital VAX
    0x4c:
      id: cris
      doc: CRIS, Axis Communications 32-bit embedded processor
    0x4d:
      id: javelin
      doc: Javelin, Infineon Technologies 32-bit embedded processor
    0x4e:
      id: firepath
      doc: Firepath, Element 14 64-bit DSP Processor
    0x4f:
      id: zsp
      doc: ZSP, LSI Logic 16-bit DSP Processor
    0x50:
      id: mmix
      doc: Donald Knuth's educational 64-bit proc
    0x51:
      id: huany
      doc: Harvard University machine-independent object files
    0x52:
      id: prism
      doc: SiTera Prism
    0x53:
      id: avr
      doc: Atmel AVR 8-bit microcontroller
    0x54:
      id: fr30
      doc: Fujitsu FR30
    0x55:
      id: d10v
      doc: Mitsubishi D10V
    0x56:
      id: d30v
      doc: Mitsubishi D30V
    0x57:
      id: v850
      doc: NEC v850
    0x58:
      id: m32r
      doc: Mitsubishi M32R
    0x59:
      id: mn10300
      doc: Matsushita MN10300
    0x5a:
      id: mn10200
      doc: Matsushita MN10200
    0x5b:
      id: picojava
      doc: picoJava
    0x5c:
      id: openrisc
      doc: OpenRISC 32-bit embedded processor
    0x5d:
      id: arc_compact
      doc: ARC International ARCompact
    0x5e:
      id: xtensa
      doc: Tensilica Xtensa Architecture
    0x5f:
      id: videocore
      doc: Alphamosaic VideoCore
    0x60:
      id: tmm_gpp
      doc: Thompson Multimedia General Purpose Proc
    0x61:
      id: ns32k
      doc: National Semi. 32000
    0x62:
      id: tpc
      doc: Tenor Network TPC
    0x63:
      id: snp1k
      doc: Trebia SNP 1000
    0x64:
      id: st200
      doc: STMicroelectronics ST200
    0x65:
      id: ip2k
      doc: Ubicom IP2xxx
    0x66:
      id: max
      doc: MAX processor
    0x67:
      id: compact_risc
      doc: National Semi. CompactRISC
    0x68:
      id: f2mc16
      doc: Fujitsu F2MC16
    0x69:
      id: msp430
      doc: Texas Instruments msp430
    0x6a:
      id: blackfin
      doc: Analog Devices Blackfin DSP
    0x6b:
      id: se_c33
      doc: Seiko Epson S1C33 family
    0x6c:
      id: sep
      doc: Sharp embedded microprocessor
    0x6d:
      id: arca
      doc: Arca RISC
    0x6e:
      id: unicore
      doc: PKU-Unity & MPRC Peking Uni. mc series
    0x6f:
      id: excess
      doc: eXcess configurable CPU
    0x70:
      id: dxp
      doc: Icera Semi. Deep Execution Processor
    0x71:
      id: altera_nios2
      doc: Altera Nios II
    0x72:
      id: crx
      doc: National Semi. CompactRISC CRX
    0x73:
      id: xgate
      doc: Motorola XGATE
    0x74:
      id: c166
      doc: Infineon C16x/XC16x
    0x75:
      id: m16c
      doc: Renesas M16C
    0x76:
      id: dspic30f
      doc: Microchip Technology dsPIC30F
    0x77:
      id: freescale_ce
      doc: Freescale Communication Engine RIS
    0x78:
      id: m32c
      doc: Renesas M32C
    0x83:
      id: tsk3000
      doc: Altium TSK3000
    0x84:
      id: rs08
      doc: Freescale RS08
    0x85:
      id: sharc
      doc: Analog Devices SHARC family
    0x86:
      id: ecog2
      doc: Cyan Technology eCOG2
    0x87:
      id: score7
      doc: Sunplus S+core7 RISC
    0x88:
      id: dsp24
      doc: New Japan Radio (NJR) 24-bit DSP
    0x89:
      id: videocore3
      doc: Broadcom VideoCore III
    0x8a:
      id: latticemico32
      doc: RISC for Lattice FPGA
    0x8b:
      id: se_c17
      doc: Seiko Epson C17
    0x8c:
      id: ti_c6000
      doc: Texas Instruments TMS320C6000 DSP
    0x8d:
      id: ti_c2000
      doc: Texas Instruments TMS320C2000 DSP
    0x8e:
      id: ti_c5500
      doc: Texas Instruments TMS320C55x DSP
    0x8f:
      id: ti_arp32
      doc: Texas Instruments App. Specific RISC
    0x90:
      id: ti_pru
      doc: Texas Instruments Prog. Realtime Unit
    0xa0:
      id: mmdsp_plus
      doc: STMicroelectronics 64bit VLIW DSP
    0xa1:
      id: cypress_m8c
      doc: Cypress M8C
    0xa2:
      id: r32c
      doc: Renesas R32C
    0xa3:
      id: trimedia
      doc: NXP Semi. TriMedia
    0xa4:
      id: qdsp6
      doc: Qualcomm DSP6/Hexagon
    0xa5:
      id: i8051
      doc: Intel 8051 and variants
    0xa6:
      id: stxp7x
      doc: STMicroelectronics STxP7x
    0xa7:
      id: nds32
      doc: Andes Tech. compact code emb. RISC
    0xa8:
      id: ecog1x
      doc: Cyan Technology eCOG1X
    0xa9:
      id: maxq30
      doc: Dallas Semi. MAXQ30 microcontroller
    0xaa:
      id: ximo16
      doc: New Japan Radio (NJR) 16-bit DSP
    0xab:
      id: manik
      doc: M2000 Reconfigurable RISC
    0xac:
      id: craynv2
      doc: Cray NV2 vector architecture
    0xad:
      id: rx
      doc: Renesas RX
    0xae:
      id: metag
      doc: Imagination Tech. META
    0xaf:
      id: mcst_elbrus
      doc: MCST Elbrus
    0xb0:
      id: ecog16
      doc: Cyan Technology eCOG16
    0xb1:
      id: cr16
      doc: National Semi. CompactRISC CR16
    0xb2:
      id: etpu
      doc: Freescale Extended Time Processing Unit
    0xb3:
      id: sle9x
      doc: Infineon Tech. SLE9X
    0xb4:
      id: l10m
      doc: Intel L10M
    0xb5:
      id: k10m
      doc: Intel K10M
    0xb7:
      id: aarch64
      doc: ARM AARCH64
    0xb9:
      id: avr32
      doc: Atmel 32-bit microprocessor
    0xba:
      id: stm8
      doc: STMicroelectronics STM8
    0xbb:
      id: tile64
      doc: Tilera TILE64
    0xbc:
      id: tilepro
      doc: Tilera TILEPro
    0xbd:
      id: microblaze
      doc: Xilinx MicroBlaze
    0xbe:
      id: cuda
      doc: NVIDIA CUDA
    0xbf:
      id: tilegx
      doc: Tilera TILE-Gx
    0xc0:
      id: cloudshield
      doc: CloudShield
    0xc1:
      id: corea_1st
      doc: KIPO-KAIST Core-A 1st generation
    0xc2:
      id: corea_2nd
      doc: KIPO-KAIST Core-A 2nd generation
    0xc3:
      id: arcv2
      doc: Synopsys ARCv2 ISA
    0xc4:
      id: open8
      doc: Open8 RISC
    0xc5:
      id: rl78
      doc: Renesas RL78
    0xc6:
      id: videocore5
      doc: Broadcom VideoCore V
    0xc7:
      id: renesas_78kor
      doc: Renesas 78KOR
    0xc8:
      id: freescale_56800ex
      doc: Freescale 56800EX DSC
    0xc9:
      id: ba1
      doc: Beyond BA1
    0xca:
      id: ba2
      doc: Beyond BA2
    0xcb:
      id: xcore
      doc: XMOS xCORE
    0xcc:
      id: mcip_pic
      doc: Microchip 8-bit PIC(r)
    0xcd:
      id: intelgt
      doc: Intel Graphics Technology
    0xd2:
      id: km32
      doc: KM211 KM32
    0xd3:
      id: kmx32
      doc: KM211 KMX32
    0xd4:
      id: kmx16
      doc: KM211 KMX16
    0xd5:
      id: kmx8
      doc: KM211 KMX8
    0xd6:
      id: kvarc
      doc: KM211 KVARC
    0xd7:
      id: cdp
      doc: Paneve CDP
    0xd8:
      id: coge
      doc: Cognitive Smart Memory Processor
    0xd9:
      id: cool
      doc: Bluechip CoolEngine
    0xda:
      id: norc
      doc: Nanoradio Optimized RISC
    0xdb:
      id: csr_kalimba
      doc: CSR Kalimba
    0xdc:
      id: z80
      doc: Zilog Z80
    0xdd:
      id: visum
      doc: Controls and Data Services VISIUMcore
    0xde:
      id: ft32
      doc: FTDI Chip FT32
    0xdf:
      id: moxie
      doc: Moxie processor
    0xe0:
      id: amdgpu
      doc: AMD GPU
    0xf3:
      id: riscv
      doc: RISC-V
    0xf7:
      id: bpf
      doc: Linux BPF -- in-kernel virtual machine
    0xfc:
      id: csky
      doc: C-SKY
  ph_type:
    0: null_type
    1: load
    2: dynamic
    3: interp
    4: note
    5: shlib
    6: phdr
    7: tls
    # 0x60000000: lo_os
    0x65041580: pax_flags
    # 0x6fffffff: hi_os
    # 0x70000000: lo_proc
    0x70000001: arm_exidx
    # 0x7fffffff: hi_proc
    0x6474e550: gnu_eh_frame
    0x6474e551: gnu_stack
    0x6474e552: gnu_relro
    0x6474e553: gnu_property
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
  # https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L377-L462
  sh_type:
    0: null_type
    1: progbits
    2: symtab
    3: strtab
    4: rela
    5: hash
    6: dynamic
    7: note
    8: nobits
    9: rel
    10: shlib
    11: dynsym
    14: init_array
    15: fini_array
    16: preinit_array
    17: group
    18: symtab_shndx
    # 0x60000000: lo_os
    # 0x6fffffef: lo_sunw
    0x6fffffec:
      id: sunw_symnsort
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffed:
      id: sunw_phname
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffee:
      id: sunw_ancillary
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffef: sunw_capchain
    0x6ffffff0: sunw_capinfo
    0x6ffffff1: sunw_symsort
    0x6ffffff2: sunw_tlssort
    0x6ffffff3: sunw_ldynsym
    0x6ffffff4: sunw_dof
    0x6ffffff5: sunw_cap
    # 0x6ffffff5: gnu_attributes
    0x6ffffff6: sunw_signature
    # 0x6ffffff6: gnu_hash
    # 0x6ffffff7: gnu_liblist
    0x6ffffff7: sunw_annotate
    0x6ffffff8: sunw_debugstr
    0x6ffffff9: sunw_debug
    0x6ffffffa: sunw_move
    0x6ffffffb: sunw_comdat
    0x6ffffffc: sunw_syminfo
    0x6ffffffd: sunw_verdef
    # 0x6ffffffd: gnu_verdef
    0x6ffffffe: sunw_verneed
    # 0x6ffffffe: gnu_verneed
    0x6fffffff: sunw_versym
    # 0x6fffffff: gnu_versym
    # 0x6fffffff: hi_sunw
    # 0x6fffffff: hi_os
    # 0x70000000: lo_proc
    0x70000000: sparc_gotdata
    0x70000001: amd64_unwind
    # 0x70000001: arm_exidx
    0x70000002: arm_preemptmap
    0x70000003: arm_attributes
    0x70000004:
      id: arm_debugoverlay
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L425
    0x70000005:
      id: arm_overlaysection
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L426
    # 0x7fffffff: hi_proc
    # 0x80000000: lo_user
    # 0xffffffff: hi_user
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter7-27
  symbol_visibility:
    0: default
    1: internal
    2: hidden
    3: protected
    4: exported
    5: singleton
    6: eliminate
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter6-tbl-21
  symbol_binding:
    0:
      id: local
      doc: not visible outside the object file containing their definition
    1:
      id: global_symbol
      -affected-by: 90
      doc: |
        visible to all object files being combined

        As of KSC 0.9, this enum key can't be called `global` because it would
        cause a syntax error in Python (it is a keyword).
    2:
      id: weak
      doc: like `symbol_binding::global_symbol`, but their definitions have lower precedence
    # 10: lo_os
    10:
      id: os10
      doc: reserved for operating system-specific semantics
    11:
      id: os11
      doc: reserved for operating system-specific semantics
    12:
      id: os12
      doc: reserved for operating system-specific semantics
    # 12: hi_os
    # 13: lo_proc
    13:
      id: proc13
      doc: reserved for processor-specific semantics
    14:
      id: proc14
      doc: reserved for processor-specific semantics
    15:
      id: proc15
      doc: reserved for processor-specific semantics
    # 15: hi_proc
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter6-tbl-22
  symbol_type:
    0: no_type
    1:
      id: object
      doc: associated with a data object, such as a variable, an array, and so on
    2:
      id: func
      doc: associated with a function or other executable code
    3:
      id: section
      doc: associated with a section
    4:
      id: file
      doc: symbol's name gives the name of the source file associated with the object file
    5:
      id: common
      doc: labels an uninitialized common block
    6:
      id: tls
      doc: specifies a thread-local storage entity
    8:
      id: relc
      doc: complex relocation expression
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1009
    9:
      id: srelc
      doc: signed complex relocation expression
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1010
    # 10: lo_os
    10:
      id: gnu_ifunc
      doc: |
        reserved for OS-specific semantics

        `STT_GNU_IFUNC` is a GNU extension to ELF format that adds support for "indirect functions"
    11:
      id: os11
      doc: reserved for OS-specific semantics
    12:
      id: os12
      doc: reserved for OS-specific semantics
    # 12: hi_os
    # 13: lo_proc
    13:
      id: proc13
      doc: reserved for processor-specific semantics
    14:
      id: proc14
      doc: reserved for processor-specific semantics
    15:
      id: proc15
      doc: reserved for processor-specific semantics
    # 15: hi_proc
  # https://docs.oracle.com/cd/E23824_01/html/819-0690/chapter6-94076.html#chapter6-tbl-16
  # see also `_root.sh_idx_*` instances
  section_header_idx_special:
    0:
      id: undefined
      -orig-id: SHN_UNDEF
    # 0xff00: lo_reserve
    # 0xff00: lo_proc
    0xff00: before
    0xff01: after
    0xff02: amd64_lcommon
    # 0xff1f: hi_proc
    # 0xff20: lo_os
    # 0xff3f: lo_sunw
    0xff3f: sunw_ignore
    # 0xff3f: hi_sunw
    # 0xff3f: hi_os
    0xfff1: abs
    0xfff2: common
    0xffff: xindex
    # 0xffff: hi_reserve
  # https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html#OSLLGchapter6-tbl-52
  # https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=HEAD#l853
  dynamic_array_tags:
    0: "null"            # Marks end of dynamic section
    1: needed            # Name of needed library
    2: pltrelsz          # Size in bytes of PLT relocs
    3: pltgot            # Processor defined value
    4: hash              # Address of symbol hash table
    5: strtab            # Address of string table
    6: symtab            # Address of symbol table
    7: rela              # Address of Rela relocs
    8: relasz            # Total size of Rela relocs
    9: relaent           # Size of one Rela reloc
    10: strsz            # Size of string table
    11: syment           # Size of one symbol table entry
    12: init             # Address of init function
    13: fini             # Address of termination function
    14: soname           # Name of shared object
    15: rpath            # Library search path (deprecated)
    16: symbolic         # Start symbol search here
    17: rel              # Address of Rel relocs
    18: relsz            # Total size of Rel relocs
    19: relent           # Size of one Rel reloc
    20: pltrel           # Type of reloc in PLT
    21: debug            # For debugging; unspecified
    22: textrel          # Reloc might modify .text
    23: jmprel           # Address of PLT relocs
    24: bind_now         # Process relocations of object
    25: init_array       # Array with addresses of init fct
    26: fini_array       # Array with addresses of fini fct
    27: init_arraysz     # Size in bytes of DT_INIT_ARRAY
    28: fini_arraysz     # Size in bytes of DT_FINI_ARRAY
    29: runpath          # Library search path
    30: flags            # Flags for the object being loaded
    # 32: encoding  # special value (marker):
                    # Values `v >= ::encoding and v < ::lo_os` follow the rules
                    # for the interpretation of the d_un union as follows:
                    # even number == 'd_ptr', odd number == 'd_val' or none
                    # <https://github.com/tianocore/edk2-archive/blob/072289f45c/ArmPlatformPkg/Library/ArmShellCmdRunAxf/elf_common.h#L336-L340>
    32: preinit_array    # Array with addresses of preinit fct
    33: preinit_arraysz  # Size in bytes of DT_PREINIT_ARRAY
    34: symtab_shndx     # Address of SYMTAB_SHNDX section
    # 0x6000000d: lo_os
    0x6000000d: sunw_auxiliary
    0x6000000e:
      id: sunw_rtldinf
      doc-ref:
        - https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=libphobos/libdruntime/core/sys/solaris/sys/link.d;h=d9d47c0914;hb=HEAD#l76
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/uts/common/sys/link.h#L135
    0x6000000f:
      id: sunw_filter
      doc: |
        Note: <https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html#OSLLGchapter6-tbl-52>
        states that `DT_SUNW_FILTER` has the value `0x6000000e`, but this is
        apparently only a human error - that would make the value collide with
        the previous one (`DT_SUNW_RTLDINF`) and there is not even a single
        source supporting this other than verbatim copies of the same table.
      doc-ref:
        - https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=libphobos/libdruntime/core/sys/solaris/sys/link.d;h=d9d47c0914;hb=HEAD#l77
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/uts/common/sys/link.h#L136
    0x60000010: sunw_cap
    0x60000011: sunw_symtab
    0x60000012: sunw_symsz
    # 0x60000013: sunw_encoding  # DT_* encoding rules apply again for values
                                 # `v >= ::sunw_encoding and v < ::hi_os` (see
                                 # `::encoding` description)
    0x60000013: sunw_sortent
    0x60000014: sunw_symsort
    0x60000015: sunw_symsortsz
    0x60000016: sunw_tlssort
    0x60000017: sunw_tlssortsz
    0x60000018: sunw_capinfo
    0x60000019: sunw_strpad
    0x6000001a: sunw_capchain
    0x6000001b: sunw_ldmach
    0x6000001c: sunw_symtab_shndx
    0x6000001d: sunw_capchainent
    0x6000001e: sunw_deferred
    0x6000001f: sunw_capchainsz
    0x60000020: sunw_phname
    0x60000021: sunw_parent
    0x60000023: sunw_sx_aslr
    0x60000025: sunw_relax
    0x60000027: sunw_kmod
    0x60000029: sunw_sx_nxheap
    0x6000002b: sunw_sx_nxstack
    0x6000002d: sunw_sx_adiheap
    0x6000002f: sunw_sx_adistack
    0x60000031: sunw_sx_ssbd
    0x60000032: sunw_symnsort
    0x60000033: sunw_symnsortsz
    # 0x6ffff000: hi_os
    # 0x6ffffd00: val_rng_lo  # Values `v >= ::val_rng_lo and v < ::val_rng_hi`
                              # use the 'd_val' field of the dynamic structure
    0x6ffffdf4:
      id: gnu_flags_1
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1091
    0x6ffffdf5: gnu_prelinked   # Prelinking timestamp
    0x6ffffdf6: gnu_conflictsz  # Size of conflict section
    0x6ffffdf7: gnu_liblistsz   # Size of library list
    0x6ffffdf8: checksum
    0x6ffffdf9: pltpadsz
    0x6ffffdfa: moveent
    0x6ffffdfb: movesz
    0x6ffffdfc: feature_1       # Feature selection (DTF_*).
    0x6ffffdfd: posflag_1       # Flags for DT_* entries, effecting the following DT_* entry.
    0x6ffffdfe: syminsz         # Size of syminfo table (in bytes)
    0x6ffffdff: syminent        # Entry size of syminfo
    # 0x6ffffdff: val_rng_hi
    # 0x6ffffe00: addr_rng_lo  # Values `v >= ::addr_rng_lo and v < ::addr_rng_hi`
                               # use the 'd_ptr' field of the dynamic structure
    0x6ffffef5: gnu_hash
    0x6ffffef6: tlsdesc_plt
    0x6ffffef7: tlsdesc_got
    0x6ffffef8: gnu_conflict
    0x6ffffef9: gnu_liblist
    0x6ffffefa: config
    0x6ffffefb: depaudit
    0x6ffffefc: audit
    0x6ffffefd: pltpad
    0x6ffffefe: movetab
    0x6ffffeff: syminfo
    # 0x6ffffeff: addr_rng_hi
    0x6ffffff0: versym
    0x6ffffff9: relacount
    0x6ffffffa: relcount
    0x6ffffffb: flags_1
    0x6ffffffc: verdef
    0x6ffffffd: verdefnum
    0x6ffffffe: verneed
    0x6fffffff: verneednum
    # 0x70000000: lo_proc
    0x70000001:
      id: sparc_register
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L634-L635
    0x07000001:
      id: deprecated_sparc_register
      doc: |
        DT_SPARC_REGISTER was originally assigned 0x7000001. It is processor
        specific, and should have been in the range DT_LOPROC-DT_HIPROC
        instead of here. When the error was fixed,
        DT_DEPRECATED_SPARC_REGISTER was created to maintain backward
        compatability.
      doc-ref:
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/cmd/sgs/libconv/common/dynamic.c#L522-L528
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L634-L635
    0x7ffffffd: auxiliary
    0x7ffffffe: used
    0x7fffffff: filter
    # 0x7fffffff: hi_proc
