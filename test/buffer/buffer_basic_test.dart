//  Copyright (c) 208, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes_dicom/debug/test_utils.dart';
import 'package:rng/rng.dart';
import 'package:test/test.dart';

void main() {
  final rng = RNG();

  group('DicomReadBuffer Basic Tests', () {
    test('DicomReadBuffer LE Basic', () {
      final vList0 = rng.int8List();
      final rBuf = getReadBufferLE(vList0);
      final bytes = rBuf.bytes;
      expect(rBuf.bytes.buf.buffer == bytes.buffer, true);
      expect(rBuf.bytes == bytes, true);
      expect(rBuf.length == bytes.length, true);
      expect(rBuf.rIndex == 0, true);
      expect(rBuf.wIndex == bytes.length, true);
    });

    test('DicomReadBuffer BE Basic', () {
      final vList0 = rng.int8List();
      final rBuf = getReadBufferBE(vList0);
      final bytes = rBuf.bytes;
      expect(rBuf.bytes.buf.buffer == bytes.buffer, true);
      expect(rBuf.bytes == bytes, true);
      expect(rBuf.length == bytes.length, true);
      expect(rBuf.rIndex == 0, true);
      expect(rBuf.wIndex == bytes.length, true);
    });

  });

  group('DicomWriteBuffer Basic Tests', () {
    test('DicomWriteBuffer LE Basic', () {
      final vList0 = rng.int8List();
      final wBuf = getWriteBufferLE(vList0);
      final bytes = wBuf.bytes;
      expect(wBuf.bytes.buf.buffer == bytes.buffer, true);
      expect(wBuf.bytes == bytes, true);
      expect(wBuf.length == bytes.length, true);
      expect(wBuf.rIndex == 0, true);
      expect(wBuf.wIndex == 0, true);
    });

    test('DicomWriteBuffer BE Basic', () {
      final vList0 = rng.int8List();
      final wBuf = getWriteBufferBE(vList0);
      final bytes = wBuf.bytes;
      expect(wBuf.bytes.buf.buffer == bytes.buffer, true);
      expect(wBuf.bytes == bytes, true);
      expect(wBuf.length == bytes.length, true);
      expect(wBuf.rIndex == 0, true);
      expect(wBuf.wIndex == 0, true);
    });

  });
}
