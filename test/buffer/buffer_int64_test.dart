//  Copyright (c) 208, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes_dicom/debug/test_utils.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  final max = rng.nextUint8;

  group('Bytes Int64 Tests', () {

    test('DicomReadBuffer BytesDicomLE Int64 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.int64List(min, max);
        final rBuf0 = getReadBufferLE(vList0);
        final out = Int64List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readInt64();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));

        final rBuf1 = getReadBufferLE(vList0);
        final vList1 = rBuf1.readInt64List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });

    test('DicomReadBuffer BytesDicomBE Int64 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.int64List(min, max);
        final bd = ByteData(vList0.length * 8);
        for (var j = 0; j < vList0.length; j++) {
          print('vList0[$i] ${vList0[i]}');
          bd.setInt64(j, vList0[i], Endian.big);
        }
        final rBuf0 = getReadBufferBE(bd);

        final out = Int64List(vList0.length);
        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readInt64();
          print('        v $v');
          print('vList0[$j] ${vList0[j]}');
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));

        final rBuf1 = getReadBufferBE(vList0);
        final vList1 = rBuf1.readInt64List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });
}
