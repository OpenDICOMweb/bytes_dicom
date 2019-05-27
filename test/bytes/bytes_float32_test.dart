//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//

import 'dart:typed_data';

import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes/src/constants.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {

  final rng = RNG();
  group('BytesDicomLE Float32 Tests', () {

    test('BytesDicomLE Float32 tests', (){
      final vList0 = rng.float32List(5, 10);
      final bytes0 = BytesDicomLE.typedDataView(vList0);
      final vList1 = bytes0.asFloat32List();
      expect(vList1, equals(vList0));

      final vList2 = bytes0.getFloat32List();
      expect(vList2, equals(vList1));

      final vList3 = bytes0.asFloat32List();
      expect(vList3, equals(vList2));
    });

    //TODO: finish tests
    test('Test Float32List', () {
      const length = 10;
      const loopCount = 100;
      const vInitial = 1.234;
      final box = ByteData(kFloat32Size);

      for (var i = 0; i < loopCount; i++) {
        final a = BytesDicomLE.empty(length * kFloat32Size);
        print('a: $a');
        assert(a.length == length * kFloat32Size, true);

        var v0 = vInitial;
        for (var i = 0, j = 0; i < length; i++, j += kFloat32Size) {
          // Write to box to lose precision
          box.setFloat32(0, v0);
          final v1 = box.getFloat32(0);
          a.setFloat32(i * kFloat32Size, v1);
          print('i: $i, j: $j v: $v1, a[$i]: ${a.getFloat32(i)}');
          expect(a.getFloat32(i * kFloat32Size) == v1, true);
          v0 += .1;
        }
      }
    });
  });
}
