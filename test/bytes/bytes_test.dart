//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/src/bytes/bytes_padded.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();
  group('Bytes Tests', () {
    test('Test getters and initial zeros', () {
      const count = 12;

      // Check initialized with zeros
      for (var i = 0; i < count; i++) {
        final bytes = BytesPadded(count);
        expect(bytes.endian == Endian.little, true);

        expect(bytes.elementSizeInBytes == 1, true);
        print('offset: ${bytes.offset}');
        expect(bytes.offset == 0, true);
        expect(bytes.buffer == bytes.bd.buffer, true);
        expect(bytes.length == count, true);
        expect(bytes.length == bytes.length, true);

        expect(bytes.hashCode is int, true);

        for (var i = 0; i < bytes.length; i++) {
          expect(bytes[i] == 0, true);
          expect(bytes.getUint8(i) == 0, true);
        }

        for (var i = 0; i < bytes.length; i += 2) {
          expect(bytes[i] == 0, true);
          expect(bytes.getUint16(i) == 0, true);
        }
        for (var i = 0; i < bytes.length; i += 4) {
          expect(bytes[i] == 0, true);
          expect(bytes.getUint32(i) == 0, true);
        }
        for (var i = 0; i < bytes.length - 4; i += 8) {
          expect(bytes[i] == 0, true);
          expect(bytes.getUint64(i) == 0, true);
        }
        for (var i = 0; i < bytes.length; i++) {
          expect(bytes[i] == 0, true);
          expect(bytes.getInt8(i) == 0, true);
        }
        for (var i = 0; i < bytes.length; i += 2) {
          expect(bytes[i] == 0, true);
          expect(bytes.getInt16(i) == 0, true);
        }

        for (var i = 0; i < bytes.length; i += 4) {
          expect(bytes[i] == 0, true);
          expect(bytes.getInt32(i) == 0, true);
        }

        for (var i = 0; i < bytes.length - 4; i += 8) {
          expect(bytes[i] == 0, true);
          expect(bytes.getInt64(i) == 0, true);
        }

        for (var i = 0; i < bytes.length; i += 4) {
          expect(bytes[i] == 0, true);
          expect(bytes.getFloat32(i) == 0, true);
        }

        for (var i = 0; i < bytes.length - 4; i += 8) {
          expect(bytes[i] == 0, true);
          expect(bytes.getFloat64(i) == 0, true);
        }

        final bytes0 = BytesPadded.from(bytes);
        expect(bytes0.endian == Endian.little, true);

        expect(bytes0.elementSizeInBytes == 1, true);
        expect(bytes0.offset == 0, true);
        expect(bytes0.length == count, true);
        expect(bytes0.length == bytes.length, true);

        expect(bytes0.hashCode is int, true);
      }
    });

    test('Test List interface: initial zeroed, equality, hashCode', () {
      const count = 255;
      final a = BytesPadded(count);
      final b = BytesPadded(count);

      // Check initialized with zeros
      for (var i = 0; i < count; i++) {
        expect(a[i] == 0, true);
        expect(b[i] == 0, true);
        expect(a[i] == b[i], true);

        expect(a.getUint8(i) == 0, true);
        expect(b.getUint8(i) == 0, true);
        expect(a.getUint8(i) == b.getUint8(i), true);

        expect(a == b, true);
        expect(a.hashCode == b.hashCode, true);
      }

      // Check byte Setters
      for (var i = 0; i < count; i++) {
        a[i] = count;
        b[i] = count;

        expect(a[i] == count, true);
        expect(b[i] == count, true);
        expect(a[i] == b[i], true);

        expect(a.getUint8(i) == count, true);
        expect(b.getUint8(i) == count, true);
        expect(a.getUint8(i) == b.getUint8(i), true);

        expect(a == b, true);
        expect(a.hashCode == b.hashCode, true);
      }
    });

    //TODO: finish tests
    test('Test List Int16', () {
      const loopCount = 100;

      for (var i = 0; i < loopCount; i++) {
        final a = BytesPadded(0xFFFF * kInt16Size);
        assert(a.length == 0xFFFF * kInt16Size, true);

        for (var i = 0, j = -10; i <= 10; i++, j += 2) {
          a.setInt16(i * 2, j);
          print('i: $i, j: $j, v: ${a.getInt16(i)}');
          expect(a.getInt16(i * 2) == j, true);
        }
        for (var i = 0, j = -10; i <= 10; i++, j += 2) {
          print('i: $i, j: $j, v: ${a.getInt16(i)}');
          expect(a.getInt16(i * 2) == j, true);
        }
      }
    });

    test('bytes from', () {
      final list0 = rng.uint8List(1, 1);
      final bytes = BytesPadded.typedDataView(list0);
      final byteF0 = BytesPadded.from(bytes);
      expect(byteF0, equals(bytes));

      expect(byteF0.endian == Endian.little, true);
      expect(byteF0.elementSizeInBytes == 1, true);
      expect(byteF0.offset == 0, true);
      expect(byteF0.buffer == byteF0.bd.buffer, true);
      expect(byteF0.length == bytes.length, true);
      expect(byteF0.hashCode is int, true);
    });

/* Urgent implement or not
    test('bytes fromList', () {
      final list0 = rng.uint8List(1, 1);
      final byteFL0 = BytesPadded.fromList(list0);
      expect(byteFL0, equals(list0));

      expect(byteFL0.endian == Endian.little, true);
      expect(byteFL0.elementSizeInBytes == 1, true);
      expect(byteFL0.offset == 0, true);
      expect(byteFL0.buffer == byteFL0.bd.buffer, true);
      expect(byteFL0.length == list0.length, true);
      expect(byteFL0.hashCode is int, true);
    });
*/

    test('bytes fromTypedData', () {
      final list0 = rng.uint8List(1, 1);
      final byteFTD0 = BytesPadded.typedDataView(list0);
      expect(byteFTD0, equals(list0));

      expect(byteFTD0.endian == Endian.little, true);
      expect(byteFTD0.elementSizeInBytes == 1, true);
      expect(byteFTD0.offset == 0, true);
      expect(byteFTD0.buffer == byteFTD0.bd.buffer, true);
      expect(byteFTD0.length == list0.length, true);
      expect(byteFTD0.hashCode is int, true);

      final floats = <double>[0, 1, 2, 3];
      final fl32List0 = Float32List.fromList(floats);
      final fl32Bytes0 = BytesPadded.typedDataView(fl32List0);
      expect(fl32Bytes0.getFloat32(0) == fl32List0[0], true);
      expect(fl32Bytes0.getFloat32(4) == fl32List0[1], true);
      expect(fl32Bytes0.getFloat32(8) == fl32List0[2], true);
      expect(fl32Bytes0.getFloat32(12) == fl32List0[3], true);

      final fl32List1 = fl32Bytes0.asFloat32List();

      for (var i = 0; i < fl32List0.length; i++)
        expect(fl32List0[i] == fl32List1[i], true);

      // Unaligned
      final fl32b = BytesPadded(20)
        ..setFloat32(2, floats[0])
        ..setFloat32(6, floats[1])
        ..setFloat32(10, floats[2])
        ..setFloat32(14, floats[3]);
      expect(fl32b.getFloat32(2) == fl32List0[0], true);
      expect(fl32b.getFloat32(6) == fl32List0[1], true);
      expect(fl32b.getFloat32(10) == fl32List0[2], true);
      expect(fl32b.getFloat32(14) == fl32List0[3], true);

      final fl32List3 = fl32b.getFloat32List(2, 4);

      for (var i = 0; i < fl32List0.length; i++)
        expect(fl32List0[i] == fl32List3[i], true);
    });

    test('bytes fromByteData', () {
      final list0 = rng.uint8List(1, 1);
      final bd = list0.buffer.asByteData();
      final byteFD0 = BytesPadded.typedDataView(bd);
      print('byteFD0: $byteFD0');

      expect(byteFD0.endian == Endian.little, true);
      expect(byteFD0.elementSizeInBytes == 1, true);
      expect(byteFD0.offset == 0, true);
      expect(byteFD0.length == list0.length, true);
      expect(byteFD0.hashCode is int, true);
    });

/*  Urgent implement here or move DSBytes and IDSBytes to convert package
    test('DSBytes', () {
      //final vList = rng.uint16List(1, 1);
      final vList = ['1q221'];
      final vList0 = ['1q221', 'sadaq223'];
      //final bytes = BytesPadded.fromList(vList);
      final bytes = BytesPadded.asciiFromList(vList);
      final bytes0 = BytesPadded.asciiFromList(vList0);
      final dsBytes0 = RDSBytes(bytes, 0);
      final dsBytes1 = RDSBytes(bytes, 0);
      final dsBytes2 = RDSBytes(bytes0, 0);
      print('dsBytes0: $dsBytes0');

      expect(dsBytes0.hashCode == dsBytes1.hashCode, true);
      expect(dsBytes0.hashCode == dsBytes2.hashCode, false);

      expect(dsBytes0 == dsBytes1, true);
      expect(dsBytes0 == dsBytes2, false);

      expect(dsBytes0.vfBytes, equals(bytes));
      expect(dsBytes0.bytes, equals(bytes));

      expect(dsBytes0.vfLength, equals(bytes.length - 132));
      expect(dsBytes0.length, equals(bytes.length));

      expect(dsBytes0.fmiEnd == 0, true);
      expect(dsBytes0.fmiStart == 0, true);

      expect(dsBytes0.dsStart, equals(bytes.offset));
      expect(dsBytes0.dsEnd, equals(bytes.offset + bytes.length));

      expect(dsBytes0.hasPrefix, true);
      expect(dsBytes0.vfOffset == 132, true);
      expect(dsBytes0.vfLengthField, equals(bytes.length - 132));

      expect(dsBytes0.getUint8(vList0.length),
          equals(bytes.getUint8(vList0.length)));

      expect(dsBytes0.getUint16(vList0.length),
          equals(bytes.getUint16(vList0.length)));

      expect(dsBytes0.getUint32(vList.length),
          equals(bytes.getUint32(vList.length)));
    });

    test('IDSBytes', () {
      final vList = ['1q221'];
      final vList0 = ['1q221', 'sadaq223'];
      final bytes = BytesPadded.asciiFromList(vList);
      final bytes0 = BytesPadded.asciiFromList(vList0);
      final idsBytes0 = IDSBytes(bytes);
      final idsBytes1 = IDSBytes(bytes);
      final idsBytes2 = IDSBytes(bytes0);
      print('idsBytes0: $idsBytes0');

      expect(idsBytes0.hashCode == idsBytes1.hashCode, true);
      expect(idsBytes0.hashCode == idsBytes2.hashCode, false);

      expect(idsBytes0 == idsBytes1, true);
      expect(idsBytes0 == idsBytes2, false);

      expect(idsBytes0.bytes, equals(bytes));

      expect(idsBytes0.vfLength, equals(bytes.length - 8));
      expect(idsBytes0.length, equals(bytes.length));

      expect(idsBytes0.dsStart, equals(bytes.offset));
      expect(idsBytes0.dsEnd, equals(bytes.offset + bytes.length));

      expect(idsBytes0.vfOffset == 8, true);

      final list = <int>[];
      for (var i = 0; i < vList[0].length; i++) {
        final data = vList[0].codeUnitAt(i);
        list.add(data);
      }
      expect(idsBytes0.vfAsUint8List, equals(list));

      expect(idsBytes0.getUint8(vList0.length),
          equals(bytes.getUint8(vList0.length)));

      expect(idsBytes0.getUint16(vList0.length),
          equals(bytes.getUint16(vList0.length)));

      expect(idsBytes0.getUint32(vList.length),
          equals(bytes.getUint32(vList.length)));
    });
*/

  });
}
