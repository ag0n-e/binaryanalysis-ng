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
# Copyright 2018-2019 - Armijn Hemel
# Licensed under the terms of the GNU Affero General Public License
# version 3
# SPDX-License-Identifier: AGPL-3.0-only


class PickleReporter:

    def __init__(self, scanenvironment):
        self.scanenvironment = scanenvironment

    def report(self, fileresult):

        # write a pickle with output data
        # The pickle contains:
        # * all available hashes
        # * labels
        # * byte count
        # * any extra data that might have been passed around
        resultout = {}

        if hasattr(fileresult,'byte_counter'):
            resultout['bytecount'] = sorted(fileresult.byte_counter.get().items())
            # also write a file with the distribution of bytes in the scanned file
            bytescountfilename = self.scanenvironment.resultsdirectory / ("%s.bytes" % fileresult.get_hash())
            if not bytescountfilename.exists():
                bytesout = bytescountfilename.open('w')
                for by in resultout['bytecount']:
                    bytesout.write("%d\t%d\n" % by)
                bytesout.close()

