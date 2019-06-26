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
import 'package:bytes_dicom/src/vr/vr_base.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';
import 'package:test_tools/tools.dart';

void main() {
  final rng = RNG();

/*
  const repetitions = 100;
  const min = 0;
  const max = 100;
*/

  group('BytesLEShortEvr Float32 Tests', () {
    test('BytesLEShortEvr Float32 tests', () {
      final vList0 = rng.float32List(5, 10);
      expect(vList0 is Float32List, isTrue);

      final u8LE = getFloat32LE(vList0);
      final bytes0 = BytesLEShortEvr.typedDataView(u8LE);
      final vList1 = bytes0.asFloat32List();
      expect(vList1, equals(vList0));

      final vList2 = bytes0.getFloat32List();
      expect(vList2, equals(vList1));

      final vList3 = bytes0.asFloat32List();
      expect(vList3, equals(vList2));
    });

    //TODO: finish tests
    test('Test Float32List', () {
      const length = 12;
      const vfLength = 4;
      const loopCount = 100;
      //   const vInitial = 1.234;
      final box = ByteData(kFloat32Size)..setFloat32(0, 1.234);
      final vInitial = box.getFloat32(0);
      print('vInitial $vInitial');

      for (var i = 0; i < loopCount; i++) {
        final a = BytesLEShortEvr.empty(length)
          ..setCode(0, 0x00080000)
          ..setVRCode(4, vrCodeByIndex[1])
          ..setShortVLF(6, vfLength);
        print('a.length: ${a.length}');
        print('a: $a');
        assert(a.length == length, true);
        // assert(a.vfLength == length * kFloat32Size, true);

        var v0 = vInitial;
        for (var i = 0, j = 0; i < length; i++, j += kFloat32Size) {
          // Write to box to lose precision
          box.setFloat32(0, v0);
          final v1 = box.getFloat32(0);
          a.setFloat32(8 + (i * kFloat32Size), v1);
          print('i: $i, j: $j v: $v1, a[$i]: ${a.getFloat32(i)}');
          expect(a.getFloat32(i * kFloat32Size) == v1, true);
          v0 += .1;
        }
      }
    });
  });
}
