import inspect
import pkgutil

from TestUtil import *

from Unpacker import *

import bangsignatures
import bangandroid
import bangmedia
import bangfilesystems
import bangunpack
import importlib

import parsers
from UnpackParser import UnpackParser


def _get_unpackers_recursive(parent_module_path):
    unpackers = []
    for m in pkgutil.iter_modules([parent_module_path]):
        try:
            module_name = 'parsers.{}.UnpackParser'.format(m.name)
            module = importlib.import_module(module_name)
            for name, member in inspect.getmembers(module):
                if inspect.isclass(member) and issubclass(member, UnpackParser):
                    unpackers.append(member)
        except ModuleNotFoundError as e:
            pass
        unpackers.extend(_get_unpackers_recursive(
                os.path.join(parent_module_path, m.name)))
    return unpackers


def get_unpackers():
    unpackers = _get_unpackers_recursive(os.path.dirname(parsers.__file__))
    print(unpackers)
    return unpackers

    functions = []
    for m in bangandroid, bangfilesystems, bangmedia, bangunpack:
        functions += [(name, func) for name, func in
                      inspect.getmembers(m, inspect.isfunction)
                      if name.startswith('unpack')]
    return dict(functions)

_unpackers = get_unpackers()

def get_unpackers_for_extension(ext):
    return [ u for u in _unpackers if u.is_valid_extension(ext) ]

def get_unpackers_for_file(unpackername, f):
    ext = pathlib.Path(f).suffix
    # ext = os.path.splitext(f)[1]
    
    for unpacker in get_unpackers_for_extension(ext):
        yield unpacker
    return

    print('unpackername', unpackername)
    try:
        yield bangsignatures.signaturetofunction[unpackername]
    except KeyError:
        pass

    for signature, prettyname in bangsignatures.signatureprettyprint.items():
        if prettyname == unpackername:
            try:
                yield bangsignatures.signaturetofunction[signature]
            except KeyError:
                pass
            try:
                yield bangsignatures.textonlyfunctions[prettyname]
            except KeyError:
                pass
    try:
        prettyname = bangsignatures.extensionprettyprint[ext]
        yield bangsignatures.textonlyfunctions[prettyname]
    except KeyError:
        pass

    try:
        yield bangsignatures.textonlyfunctions[unpackername]
    except KeyError:
        pass

def is_prefix(pref, full):
    cp = os.path.commonprefix((pref, full))
    return cp == pref

class TestUnpackResult(TestBase):
    def test_unpackdata_for_all_unpackers(self):
        unpackers = get_unpackers()
        for f, u in self.walk_available_files_with_unpackers():
            try:
                del unpackers[u.__name__]
            except KeyError as e:
                pass
        print("no tests for:")
        print("\n".join([u for u in unpackers]))
        # for all testdatafiles
        self.assertEqual(unpackers, {})

    def walk_available_files_with_unpackers(self):
        testfilesdir = self.testdata_dir / 'unpackers'
        for dirpath, dirnames, filenames in os.walk(testfilesdir):
            unpackername = os.path.basename(dirpath)
            for f in filenames:
                # relativename = os.path.join(dirpath,f)[len(self.testdata_dir)+1:]
                relativename = pathlib.Path(dirpath).relative_to(self.testdata_dir) / f
                for unpacker in get_unpackers_for_file(unpackername, f):
                    yield str(relativename), unpacker

    def test_unpackresult_has_correct_filenames(self):
        unpacker = Unpacker(self.unpackdir)
        skipfiles = [
            'unpackers/zip/test-add-random-data.zip',
            'unpackers/zip/test-data-replaced-in-middle.zip',
            'unpackers/zip/test-prepend-random-data.zip',
            # 'unpackers/squashfs/test-add-random-data.sqsh',
            # 'unpackers/squashfs/test-cut-data-from-end-add-random.sqsh',
            # 'unpackers/squashfs/test-cut-data-from-end.sqsh',
            # 'unpackers/squashfs/test-data-replaced-in-middle.sqsh',
            ]
        for fn, unpackparser in sorted(set(self.walk_available_files_with_unpackers())):
            if fn in skipfiles:
                # print('skip file', fn)
                continue
            # print('TestUnpackResult::before', os.getcwd())
            self._copy_file_from_testdata(fn)
            unpacker.make_data_unpack_directory(fn, unpackparser.__name__)
            fileresult = create_fileresult_for_path(self.unpackdir, pathlib.Path(fn))
            unpackresult = unpackparser.parse_and_unpack(fileresult, self.scan_environment, 0, unpacker.get_data_unpack_directory())
            # print('TestUnpackResult::after', os.getcwd())

            try:
                # all paths in unpackresults are relative to unpackdir
                for unpackedfile, unpackedlabel in unpackresult['filesandlabels']:
                    self.assertFalse(
                        is_prefix(str(self.unpackdir), unpackedfile)
                        , f"absolute path in unpackresults: {unpackedfile}")

                    self.assertTrue(
                        is_prefix(
                            unpacker.get_data_unpack_directory(),
                            unpackedfile),
                        f"unpackedfile {unpackedfile} not in dataunpackdirectory {unpacker.get_data_unpack_directory()}"
                        )

                    self.assertTrue(
                        is_prefix(
                            unpacker.get_data_unpack_directory(),
                            os.path.normpath(unpackedfile)),
                        f"unpackedfile {os.path.normpath(unpackedfile)} not in dataunpackdirectory {unpacker.get_data_unpack_directory()}"
                        )

                    unpackedfile_full = self.scan_environment.unpack_path(unpackedfile)
                    self.assertTrue(os.path.exists(unpackedfile_full), f"path {unpackedfile_full} does not exist!")

            except KeyError as e:
                pass
            finally:
                # print("TestUnpackResult::remove data unpack directory")
                unpacker.remove_data_unpack_directory_tree()

    def todo_test_unpackers_throw_exceptions(self):
        unpackers = get_unpackers()
        # feed a zero length file
        fn = "/dev/null"
        name = "null"
        self._copy_file_from_testdata(fn, name)
        fileresult = create_fileresult_for_path(self.unpackdir, pathlib.Path(name))
        self.assertEqual(str(fileresult.filename), name)
        # unpackresult = unpacker(fileresult, self.scan_environment, 0, self.unpackdir)
        for unpackername in sorted(unpackers.keys()):
            unpackparser = unpackers[unpackername]
            unpackresult = unpackparser.parse_and_unpack(fileresult, self.scan_environment, 0, self.unpackdir)

if __name__ == "__main__":
    unittest.main()
