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
import 'package:bytes_dicom/debug/test_utils.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

import 'buffer_test.dart';

void main() {
  final rng = RNG();
  const repetitions = 100;
  const min = 0;
  const max = 100;

  group('DicomReadBuffer Float32 Tests', () {

    test('DicomReadBuffer LE Simple Float32 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        final rBuf0 = getReadBufferLE(vList0);
        final out = Float32List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readFloat32();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));

        final rBuf1 = getReadBufferLE(vList0);
        final vList1 = rBuf1.readFloat32List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });

    test('DicomReadBuffer BE Simple Float32 tests', () {
      for (var i = 0; i < repetitions; i++) {
        final vList0 = rng.float32List(min, max);
        final rBuf0 = getReadBufferBE(vList0);
        final out = Float32List(vList0.length);

        for (var j = 0; j < vList0.length; j++) {
          final v = rBuf0.readFloat32();
          expect(v, equals(vList0[j]));
          out[j] = v;
        }
        expect(out, equals(vList0));

        final rBuf1 = getReadBufferBE(vList0);
        final vList1 = rBuf1.readFloat32List(vList0.length);
        expect(vList1, equals(vList0));
      }
    });
  });
}
