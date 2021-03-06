//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
import 'package:core/server.dart' hide group;
import 'package:test/test.dart';

void main() {
  Server.initialize(name: 'byte_date_writer.dart', level: Level.info);

  group('ByteDataBuffer', () {

    test('Buffer Growing Test', () {
      const startSize = 1;
      const iterations = 1024 * 1;
      final wb = WriteBuffer(startSize);
      print('''
iterations: $iterations
  index: ${wb.writeIndex}
  length: ${wb.length}
  maxLength: ${wb.limit}
''');

      expect(wb.writeIndex == 0, true);
      expect(wb.length == startSize, true);
      for (var i = 0; i <= iterations - 1; i++) {
        final v = i % 127;
        wb.writeInt8(v);
      }
      print('wb: $wb}\n  length: ${wb.writeIndex}');
      expect(wb.writeIndex == iterations, true);
    });
  });
}
