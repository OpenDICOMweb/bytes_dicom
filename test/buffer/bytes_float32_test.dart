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
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  group('BytesDicom Float32 Tests', () {
    test('DicomReadBuffer BytesDicomLE Float32 tests', () {
      final vList0 = rng.float32List(5, 10);
      print('vList0: $vList0');
      final bytes0 = BytesDicom.typedDataView(vList0);
      final buffer0 = DicomReadBuffer(bytes0);

      final out = Float32List(vList0.length);
      for (var i = 0; i < vList0.length; i++) {
        final v = buffer0.readFloat32();
        expect(v, equals(vList0[i]));
        out[i] = v;
      }
      expect(out, equals(vList0));

      final buffer1 = DicomReadBuffer(bytes0);
      final vList2 = buffer1.readFloat32List(vList0.length);
      expect(vList2, equals(vList0));
    });

    test('DicomReadBuffer BytesDicomBE Float32 tests', () {
      final vList0 = rng.float32List(5, 10);
      print('vList0: $vList0');
      final bytes0 =
          BytesDicom.typedDataView(vList0, 0, vList0.length * 4, Endian.big);
      final buffer0 = DicomReadBuffer(bytes0);

      final out = Float32List(vList0.length);
      for (var i = 0; i < vList0.length; i++) {
        final v = buffer0.readFloat32();
        expect(v, equals(vList0[i]));
        out[i] = v;
      }
      expect(out, equals(vList0));

      final buffer1 = DicomReadBuffer(bytes0);
      final vList2 = buffer1.readFloat32List(vList0.length);
      expect(vList2, equals(vList0));
    });
  });
}
