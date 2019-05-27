//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:test/test.dart';

void main() {
  group('Byte Dicom Writer', () {
    test('BytesDicomLE write Int8 Test', () {
      const startSize = 1;
      const iterations = 1024;

      // All BytesDicomLE must be even length
      for (var i = 0; i <= iterations - 1; i += 2) {
        final bytes = BytesDicomLE.empty(i);
        expect(bytes.offset == 0, true);
        expect(bytes.length == i, true);
        print('''
iterations: $iterations
  index: ${bytes.offset}
  length: ${bytes.length}
''');
        for (var j = startSize; j < bytes.length; j++) {
          final v = i % 127;
          bytes.setInt8(j, v);
          final x = bytes.getInt8(j);
          expect(v == x, true);
        }
      }
    });

    test('BytesDicomBE write Int8 Test', () {
      const startSize = 1;
      const iterations = 1024;

      // All BytesDicomBE must be even length
      for (var i = 0; i <= iterations - 1; i += 2) {
        final bytes = BytesDicomBE.empty(i);
        expect(bytes.offset == 0, true);
        expect(bytes.length == i, true);
        print('''
iterations: $iterations
  index: ${bytes.offset}
  length: ${bytes.length}
''');
        for (var j = startSize; j < bytes.length; j++) {
          final v = i % 127;
          bytes.setInt8(j, v);
          final x = bytes.getInt8(j);
          expect(v == x, true);
        }
      }
    });
  });
}
