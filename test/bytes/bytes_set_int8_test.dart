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

  group('ByteWriter', () {

    test('Bytes write Int8 Test', () {
      const startSize = 1;
      const iterations = 1024 * 1;
      final bytes = BytesDicomLE.empty(startSize);
      print('''
iterations: $iterations
  index: ${bytes.offset}
  length: ${bytes.length}
''');

      expect(bytes.offset == 0, true);
      expect(bytes.length == startSize, true);
      for (var i = 0; i <= iterations - 1; i++) {
        final v = i % 127;
        bytes.setInt8(i, v);
        final x = bytes.getInt8(i);
        expect(v == x, true);
      }
      expect(bytes.length == iterations, true);
    });
  });
}
