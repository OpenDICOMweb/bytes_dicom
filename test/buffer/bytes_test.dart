//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/bytes/charset.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {

  final rng = RNG();

  group('Bytes Tests', () {
    test('DicomReadBuffer', () {
      final vList0 = ['1q221', 'sadaq223'];
      final s = vList0.join('\\');
      final bytes0 = BytesDicomLE.fromAscii(s);
      final dReadBuffer0 = DicomReadBuffer(bytes0);
      print('dReadBuffer0:$dReadBuffer0');

      expect(dReadBuffer0.bytes.buf.buffer == bytes0.buffer, true);
      expect(dReadBuffer0.bytes == bytes0, true);
      expect(dReadBuffer0.length == bytes0.length, true);
      expect(
          dReadBuffer0.bytes.buf.buffer.lengthInBytes ==
              bytes0.buffer.lengthInBytes,
          true);
      expect(dReadBuffer0.rIndex == 0, true);
      expect(dReadBuffer0.wIndex == bytes0.length, true);

      print('dReadBuffer0.readCode(): ${dReadBuffer0.readCode()}');
    });

    test('ReadBuffer', () {
      final vList0 = rng.uint8List(1, 10);
      final bytes = BytesDicomLE.typedDataView(vList0);
      final readBuffer0 = DicomReadBuffer(bytes);
      print('readBuffer0: $readBuffer0');

      expect(readBuffer0.rIndex == bytes.offset, true);
      expect(readBuffer0.wIndex == bytes.length, true);
      expect(
          readBuffer0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          true);
      expect(readBuffer0.offset == bytes.offset, true);
      expect(readBuffer0.bytes == bytes, true);

      final readBuffer1 = DicomReadBuffer(Bytes.fromList(vList0));
      print('readBuffer1: $readBuffer1');

      expect(readBuffer1.rIndex == bytes.offset, true);
      expect(readBuffer1.wIndex == bytes.length, true);
      expect(
          readBuffer1.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          true);
      expect(readBuffer1.offset == bytes.offset, true);
      expect(readBuffer1.bytes == bytes, true);
    });

    test('DicomReadBuffer.from', () {
      final vList0 = rng.uint8List(1, 10);
      final bytes = BytesDicomLE.typedDataView(vList0);
      final readBuffer0 = DicomReadBuffer(bytes);
      print('DicomReadBuffer0: $readBuffer0');

      expect(readBuffer0.rIndex == bytes.offset, true);
      expect(readBuffer0.wIndex == bytes.length, true);
      expect(
          readBuffer0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          true);
      expect(readBuffer0.offset == bytes.offset, true);
      expect(readBuffer0.bytes == bytes, true);

      final from0 = DicomReadBuffer(readBuffer0.bytes);
      print('ReadBuffer.from: $from0');

      expect(from0.rIndex == bytes.offset, true);
      expect(from0.wIndex == bytes.length, true);
      expect(
          from0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0], true);
      expect(from0.offset == bytes.offset, true);
      expect(from0.bytes == bytes, true);
    });

    test('DicomReadBuffer readAscii', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint8List(1, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final readAscii0 = readBuffer0.readAscii(length: vList0.length);
        print('readAscii: $readAscii0');
        expect(readAscii0 == ascii.decode(vList0), true);
      }
    });

    test('ReadBuffer readUtf8', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint8List(1, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final readUtf80 = readBuffer0.readUtf8(length: vList0.length);
        print('readUtf8: $readUtf80');
        expect(readUtf80 == utf8.decode(vList0), true);
      }
    });

    test('ReadBuffer readUint8List', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint8List(1, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final v = readBuffer0.readUint8List(vList0.length);
        print('readUtf8: $v');
        expect(v, equals(vList0));
      }
    });

    test('ReadBuffer readUint16List', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint16List(1, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final v = readBuffer0.readUint16List(vList0.length);
        print('readUtf16: $v');
        expect(v, equals(vList0));
      }
    });

    test('ReadBuffer readUint32List', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint16List(1, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final v = readBuffer0.readUint32List(vList0.length);
        print('readUint32: $v');
        expect(v, equals(vList0));
      }
    });
  });
}
