//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

//import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();

  group('Bytes Tests', () {
    test('DicomReadBuffer', () {
      final vList0 = ['1q221', 'sadaq223'];
      final s = vList0.join('\\');
      final bytes0 = BytesDicom.fromAscii(s);
      print('bytes0 $bytes0');
      final dReadBuffer0 = DicomReadBuffer(bytes0);
      print('dReadBuffer0:$dReadBuffer0');
      print('dReadBuffer0.bytes:${dReadBuffer0.bytes}');

      print('buffer0:${dReadBuffer0.bytes.buf.buffer.hashCode}');
      print(' bytes0:${bytes0.buf.buffer.hashCode}');

      expect(dReadBuffer0.bytes.buf.buffer == bytes0.buf.buffer, isTrue);
      expect(dReadBuffer0.bytes == bytes0, isTrue);
      expect(dReadBuffer0.length == bytes0.length, isTrue);
      expect(
          dReadBuffer0.bytes.buf.buffer.lengthInBytes ==
              bytes0.buffer.lengthInBytes,
          true);
      expect(dReadBuffer0.rIndex == 0, isTrue);
      expect(dReadBuffer0.wIndex == bytes0.length, isTrue);

      print('dReadBuffer0.readCode(): ${dReadBuffer0.readCode()}');
    });

    test('ReadBuffer', () {
      final vList0 = rng.uint8List(1, 10);
      final bytes = BytesDicomLE.typedDataView(vList0);
      final readBuffer0 = DicomReadBuffer(bytes);
      print('readBuffer0: $readBuffer0');

      expect(readBuffer0.rIndex == bytes.offset, isTrue);
      expect(readBuffer0.wIndex == bytes.length, isTrue);
      expect(
          readBuffer0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          true);
      expect(readBuffer0.offset == bytes.offset, isTrue);
      expect(readBuffer0.bytes == bytes, isTrue);

      final readBuffer1 = DicomReadBuffer(BytesDicom.typedDataView(vList0));
      print('readBuffer1: $readBuffer1');

      expect(readBuffer1.rIndex == bytes.offset, isTrue);
      expect(readBuffer1.wIndex == bytes.length, isTrue);
      expect(
          readBuffer1.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          true);
      expect(readBuffer1.offset == bytes.offset, isTrue);
      expect(readBuffer1.bytes == bytes, isTrue);
    });

    test('DicomReadBuffer.from', () {
      final vList0 = rng.uint8List(1, 10);
      final bytes = BytesDicom.typedDataView(vList0);
      print('bytes: $bytes');
      final readBuffer0 = DicomReadBuffer(bytes);
      print('readBuffer0.bytes: ${readBuffer0.bytes}');
      print('raadBuffer0: $readBuffer0');

      expect(readBuffer0.rIndex == bytes.offset, isTrue);
      expect(readBuffer0.wIndex == bytes.length, isTrue);
      expect(
          readBuffer0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          isTrue);
      expect(readBuffer0.offset == bytes.offset, isTrue);
      expect(readBuffer0.bytes == bytes, isTrue);

      final from0 = DicomReadBuffer(readBuffer0.bytes);
      print('ReadBuffer.from: $from0');

      expect(from0.rIndex == bytes.offset, isTrue);
      expect(from0.wIndex == bytes.length, isTrue);
      expect(from0.bytes.buf.buffer.asUint8List().elementAt(0) == vList0[0],
          isTrue);
      expect(from0.offset == bytes.offset, isTrue);
      expect(from0.bytes == bytes, isTrue);
    });

    test('ReadBuffer readUint8List', () {
      for (var i = 1; i < 10; i++) {
        final vList0 = rng.uint8List(0, i);
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
        final vList0 = rng.uint16List(0, i);
        final bytes = BytesDicomLE.typedDataView(vList0);
        final readBuffer0 = DicomReadBuffer(bytes);
        print('readBuffer0: $readBuffer0');

        final v = readBuffer0.readUint16List(vList0.length);
        print('readUtf16: $v');
        expect(v, equals(vList0));
      }
    });

    test('ReadBuffer readUint32List', () {
      for (var i = 0; i < 100; i++) {
        final vList0 = rng.uint32List(0, i);
        final rBuf = getReadBuffer(vList0);
        final v = rBuf.readUint32List(vList0.length);
        print('readUint32: $v');
        expect(v, equals(vList0));
      }
    });

    test('ReadBuffer readUtf8', () {
      final vList0 = Uint8List(0);
      final rBuf = getReadBuffer(vList0);
      final s = rBuf.readUtf8(vList0.length);
      print('readUtf8: "$s"');
      expect(s.isEmpty, isTrue);

      for (var i = 2; i < 10; i += 2) {
        final vList1 = rng.utf8Bytes(2, i);
        final rBuf = getReadBuffer(vList1);
        final s = rBuf.readUtf8(vList1.length);
        print('readUtf8: "$s"');
        expect(s.isNotEmpty, isTrue);
      }
    });

    test('ReadBuffer readAscii', () {
      final vList0 = Uint8List(0);
      final rBuf = getReadBuffer(vList0);
      final s = rBuf.readAscii(vList0.length);
      print('readAscii: "$s"');
      expect(s.isEmpty, isTrue);

      for (var i = 2; i < 10; i += 2) {
        final vList1 = rng.asciiBytes(2, i);
        final rBuf = getReadBuffer(vList1);
        final s = rBuf.readAscii(vList1.length);
        print('readAscii: "$s"');
        expect(s.isNotEmpty, isTrue);
      }
    });

    test('ReadBuffer readLatin', () {
      final vList0 = Uint8List(0);
      final rBuf = getReadBuffer(vList0);
      final s = rBuf.readLatin(vList0.length);
      print('readLatin: "$s"');
      expect(s.isEmpty, isTrue);

      for (var i = 2; i < 10; i += 2) {
        final vList1 = rng.latinBytes(2, i);
        final rBuf = getReadBuffer(vList1);
        final s = rBuf.readLatin(vList1.length);
        print('readLatin: "$s"');
        expect(s.isNotEmpty, isTrue);
      }
    });
  });
}

DicomReadBuffer getReadBuffer(TypedData td) {
  print('vList1 $td');
  final bytes = BytesDicomLE.typedDataView(td);
//  print('bytes: $bytes');
  final rBuf = DicomReadBuffer(bytes);
//  print('rBuf: $rBuf');
  return rBuf;
}
