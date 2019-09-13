import sys, os
import hashlib
from test.TestUtil import *

from .UnpackParser import VfatUnpackParser

class TestVfatUnpackParser(TestBase):
    def test_fat12_single_file_unpacked_correctly(self):
        rel_testfile = pathlib.Path('unpackers') / 'fat' / 'test.fat'
        # rel_testfile = pathlib.Path('unpackers') / 'fat' / 'test-b24.fat'
        # rel_testfile = pathlib.Path('a') / 'unpacked.mbr-partition0.part'
        self._copy_file_from_testdata(rel_testfile)
        fileresult = create_fileresult_for_path(self.unpackdir, rel_testfile,
                set())
        filesize = fileresult.filesize
        data_unpack_dir = rel_testfile.parent / 'some_dir'
        p = VfatUnpackParser(fileresult, self.scan_environment, data_unpack_dir,
                0)
        p.open()
        r = p.parse_and_unpack()
        p.close()
        self.assertTrue(r['status'])
        self.assertEqual(r['length'], filesize)
        self.assertEqual(len(r['filesandlabels']), 1)
        unpacked_path_rel = data_unpack_dir / 'hellofat.txt'
        unpacked_path_abs = self.unpackdir / unpacked_path_rel
        self.assertEqual(r['filesandlabels'][0][0], unpacked_path_rel)
        self.assertUnpackedPathExists(unpacked_path_rel)
        with open(unpacked_path_abs,"rb") as f:
            self.assertEqual(f.read(), b'hello fat\n')

    # test if extraction of file of multiple blocks went ok
    def test_fat12_multiple_blocks_unpacked_correctly(self):
        rel_testfile = pathlib.Path('unpackers') / 'fat' / 'test-fat12-multidirfile.fat'
        self._copy_file_from_testdata(rel_testfile)
        fileresult = create_fileresult_for_path(self.unpackdir, rel_testfile,
                set())
        filesize = fileresult.filesize
        data_unpack_dir = rel_testfile.parent / 'some_dir'
        p = VfatUnpackParser(fileresult, self.scan_environment, data_unpack_dir,
                0)
        p.open()
        r = p.parse_and_unpack()
        p.close()
        self.assertTrue(r['status'])
        unpacked_path_rel = data_unpack_dir / 'copying'
        unpacked_path_abs = self.unpackdir / unpacked_path_rel
        self.assertUnpackedPathExists(unpacked_path_rel)
        with open(unpacked_path_abs,"rb") as f:
            m = hashlib.md5()
            m.update(f.read())
            # compare to md5 hash of /usr/share/licenses/glibc/COPYING
            self.assertEqual(m.hexdigest(), 'b234ee4d69f5fce4486a80fdaf4a4263')

    # test if extraction of (nested) subdirectories went ok
    def test_fat12_subdirectories_unpacked_correctly(self):
        rel_testfile = pathlib.Path('unpackers') / 'fat' / 'test-fat12-multidirfile.fat'
        self._copy_file_from_testdata(rel_testfile)
        fileresult = create_fileresult_for_path(self.unpackdir, rel_testfile,
                set())
        filesize = fileresult.filesize
        data_unpack_dir = rel_testfile.parent / 'some_dir'
        p = VfatUnpackParser(fileresult, self.scan_environment, data_unpack_dir,
                0)
        p.open()
        r = p.parse_and_unpack()
        p.close()
        self.assertTrue(r['status'])
        self.assertEqual(len(r['filesandlabels']), 4)

        unpacked_path_rel = data_unpack_dir / 'subdir1.dir'
        unpacked_path_abs = self.unpackdir / unpacked_path_rel
        self.assertUnpackedPathExists(unpacked_path_rel)
        self.assertTrue(unpacked_path_abs.is_dir())

        unpacked_path_rel = data_unpack_dir / 'subdir2.dir' / 'subdir2a.dir'
        unpacked_path_abs = self.unpackdir / unpacked_path_rel
        self.assertUnpackedPathExists(unpacked_path_rel)
        self.assertTrue(unpacked_path_abs.is_dir())

        unpacked_path_rel = data_unpack_dir / 'subdir2.dir' / 'subdir2a.dir' / 'license'
        unpacked_path_abs = self.unpackdir / unpacked_path_rel
        self.assertUnpackedPathExists(unpacked_path_rel)

    # test FAT12, FAT16, FAT32
    # test LFN (long filenames)

if __name__ == '__main__':
    unittest.main()

