//  Copyright (c) 208, 2017, 2018,
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
//  group('Bytes Float Tests', () {

  test('Basic Int8 tests', () {
    final vList0 = rng.int8List(5, 10);
    print('vList0: $vList0');
    final bytes0 = BytesLEShortEvr.typedDataView(vList0);
    final vList1 = bytes0.asInt8List();
    expect(vList1, equals(vList0));
    print('vList1: $vList1');
    final vList2 = bytes0.getInt8List();
    print('vList2: $vList2');
    expect(vList2, equals(vList1));
    final vList3 = bytes0.asInt8List();
    print('vList3: $vList3');
    expect(vList3, equals(vList0));
    expect(vList3, equals(vList2));
    final bytes1 = BytesLEShortEvr.typedDataView(vList0);
    final vList4 = bytes1.asInt8List();
    expect(vList4, equals(vList3));
  });

  test('Int8 tests', () {
    final vList0 = rng.int8List(5, 10);
    print('vList0: $vList0');
    expect(vList0 is Int8List, true);

    final bytes0 = BytesLEShortEvr.typedDataView(vList0);
    print('bytes0: $bytes0');
    expect(bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

    final vList1 = bytes0.getInt8List();
    print('vList1: $vList1');
    expect(vList1, equals(vList0));

    final bytes1 = BytesLEShortEvr.typedDataView(vList1);
    expect(bytes1.length, equals(vList1.length * vList1.elementSizeInBytes));

    final vList2 = bytes1.asInt8List();
    print('vList2: $vList2');
    expect(vList2, equals(vList0));
    expect(vList2, equals(vList1));

    final bytes2 = BytesLEShortEvr.typedDataView(vList2);
    print('bytes2: $bytes2');
    expect(bytes2.length, equals(vList2.length * vList2.elementSizeInBytes));

    for (var i = 0; i < vList0.length; i++) {
      expect(vList2[i], equals(vList0[i]));
      expect(vList2[i], equals(vList1[i]));
    }

    for (var i = 0; i < vList0.length; i++) {
      expect(bytes2[i], equals(bytes0[i]));
      expect(bytes2[i], equals(bytes1[i]));
    }

    final bytes3 = bytes2.sublist(0);
    print('bytes3: $bytes3');
    final bytes4 = bytes2.asBytes();
    print('bytes4: $bytes4');

    expect(bytes1 == bytes0, true);
    expect(bytes2 == bytes1, true);
    expect(bytes3 == bytes2, true);
    expect(bytes4 == bytes3, true);
  });

  test('Int8 asInt8List tests', () {
    const count = 10;
    for (var k = 1; k < count; k++) {
      final vList0 = rng.int8List(k, count);
      print('$k: vList0:(${vList0.length}) $vList0');
      expect(vList0 is Int8List, true);

      final bytes0 = BytesLEShortEvr.typedDataView(vList0);
      print('$k: bytes0: $bytes0');
      expect(bytes0.buffer == vList0.buffer, true);
      expect(bytes0.length, equals(vList0.length));

/*
      final vList1 = bytes0.buf.buffer.asInt8List();
      expect(vList1, equals(vList0));
      for (var i = 0; i < vList0.length; i++)
        expect(vList1[i], equals(vList0[i]));
*/

      for (var i = 0; i < bytes0.length + 1; i++) {
        final bytes1 = BytesLEShortEvr(vList0.buffer.asUint8List());
        expect(bytes0 == bytes1, true);
        print('i: $i length ${vList0.length - i}');
        final bytes2 = bytes1.sublist(i, vList0.length);
        expect(bytes2.buffer != vList0.buffer, true);
        print('bytes2: $bytes2');
        print('buf2: ${bytes2.buf}');
        final bytes3 = bytes0.asBytes(0, vList0.length - i);
        print('bytes3: $bytes3');
        print('buf3: ${bytes3.buf}');
        expect(bytes3.buffer != bytes2.buffer, true);
        expect(bytes3.length == bytes2.length, true);

        final j = i;
        print('j: $j mid ${bytes0.length - j} length ${bytes0.length}');

        final vList2 = bytes0.asInt8List(j, vList0.length - i);
        print('vList2: $vList2');
        final bytes4 = BytesLEShortEvr.typedDataView(vList2);
        print('Bytes4: $bytes4');
        print('buf4: ${bytes4.buf}');
        expect(bytes4 == bytes2, true);
        expect(bytes4 != bytes3, true);
        expect(bytes4.buffer == vList0.buffer, true);
        expect(bytes4.buffer == bytes0.buffer, true);

        final vList3 = bytes0.asInt8List(0, vList0.length - i);
        print('vList3: $vList3');
        expect(vList3.length, equals(bytes4.length));
        expect(bytes4.buffer == vList0.buffer, true);
        expect(vList3.buffer == bytes0.buffer, true);
      }
    }
  });

  test('Int8 sublist tests', () {
    const count = 10;
    for (var k = 0; k < count; k++) {
      final vList0 = rng.int8List(k, count);
      print('$k: vList0:(${vList0.length}) $vList0');
      expect(vList0 is Int8List, true);

      final bytes0 = BytesLEShortEvr.typedDataView(vList0);
      print('$k: bytes0: $bytes0');
      expect(bytes0.buffer == vList0.buffer, true);
      expect(bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

      for (var i = 0; i < vList0.length + 1; i++) {
        print('i: $i length ${vList0.length - i}');
        final vList1 = vList0.sublist(i, vList0.length);
        expect(vList1.buffer != vList0.buffer, true);
        print('vList1: $vList1');
        final vList2 = vList0.sublist(0, vList0.length - i);
        expect(vList2.buffer != vList0.buffer, true);
        print('vList2: $vList2');

        final j = i;
        print('j: $j mid ${bytes0.length - j} length ${bytes0.length}');
        final bytes1 = bytes0.sublist(j, bytes0.length);
        expect(bytes1.buffer != vList0.buffer, true);

        print('bytes1: $bytes1');
        final bytes2 = bytes0.sublist(0, bytes0.length - j);
        print('bytes2: $bytes2');
        expect(bytes2.buffer != vList0.buffer, true);

        final vList3 = bytes1.asInt8List();
        print('vList3: $vList3');
        expect(vList3, equals(vList1));
        expect(vList3.buffer == bytes1.buffer, true);

        final vList4 = bytes2.asInt8List();
        print('vList4: $vList4');
        expect(vList4, equals(vList2));
        expect(vList4.buffer == bytes2.buffer, true);

        final bytes3 = bytes0.sublist(j, bytes0.length);
        print('bytes3: $bytes3');
        expect(bytes3, equals(bytes1));
        expect(bytes3.buffer != bytes0.buffer, true);

        final bytes4 = bytes0.sublist(0, bytes0.length - j);
        print('bytes4: $bytes4');
        expect(bytes4, equals(bytes4));
        expect(bytes4.buffer != bytes0.buffer, true);
      }
    }
  });

  test('Int8 view tests', () {
    const count = 10;
    for (var k = 0; k < count; k++) {
      final vList0 = rng.int8List(k, count);
      print('$k: vList0:(${vList0.length}) $vList0');
      expect(vList0 is Int8List, true);

      final bytes0 = BytesLEShortEvr.typedDataView(vList0);
      print('bytes0: $bytes0');
      expect(bytes0.buffer == vList0.buffer, true);
      expect(bytes0.length, equals(vList0.length * vList0.elementSizeInBytes));

      for (var i = 0; i < vList0.length + 1; i++) {
        final j = i;
        print('i: $i offset $j length ${vList0.length - i}');
        final vList1 = Int8List.view(vList0.buffer, j, vList0.length - i);
        expect(vList1.buffer == vList0.buffer, true);
        print('vList1: $vList1');
        final vList2 = Int8List.view(vList0.buffer, 0, vList0.length - i);
        print('vList2: $vList2');
        expect(vList2.buffer == vList0.buffer, true);

        print('j: $j mid ${bytes0.length - j} length ${bytes0.length}');
        final bytes1 = bytes0.asBytes(j, bytes0.length - j);
        expect(bytes1.buffer == vList0.buffer, true);
        expect(bytes1.buffer == bytes0.buffer, true);

        print('bytes1: $bytes1');
        final bytes2 = bytes0.asBytes(0, bytes0.length - j);
        print('bytes2: $bytes2');
        expect(bytes2.buffer == vList0.buffer, true);
        expect(bytes1.buffer == bytes0.buffer, true);

        final bytes3 = bytes0.asBytes(j, bytes0.length - j);
        print('bytes3: $bytes3');
        expect(bytes3, equals(bytes1));
        expect(bytes3.buffer == vList0.buffer, true);
        expect(bytes1.buffer == bytes0.buffer, true);

        final bytes4 = bytes0.asBytes(0, bytes0.length - j);
        print('bytes4: $bytes4');
        expect(bytes4, equals(bytes4));
        expect(bytes4.buffer == vList0.buffer, true);
        expect(bytes1.buffer == bytes0.buffer, true);
      }
    }
  });
  // });
}
