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

/// A growable DicomBytes.
class GrowableDicomBytes extends GrowableBytes with DicomWriterMixin {
  /// Creates a growable DicomBytes.
  GrowableDicomBytes([int length, Endian endian]) : super(length, endian);

  /// Returns a new [Bytes] of [length].
  GrowableDicomBytes._(int length, Endian endian) : super(length, endian);

  /// Creates a growable DicomBytes from [bytes].
  factory GrowableDicomBytes.from(Bytes bytes,
          [int offset = 0, int length, Endian endian]) =>
      GrowableDicomBytes._from(bytes, offset, length, endian);

  GrowableDicomBytes._from(Bytes bytes, int offset, int length, Endian endian)
      : super.from(bytes, offset, length, endian);

  /// Creates a growable DicomBytes from a view of [td].
  GrowableDicomBytes.typedDataView(TypedData td,
      [int offset = 0, int lengthInBytes, Endian endian])
      : super.typedDataView(td, offset, lengthInBytes, endian);
}

/// A mixin for a Dicom Writer.
mixin DicomWriterMixin {
  ByteData get bd;
// **** End of Interface

  /// Returns the Tag Code from _this_.
  void setCode(int code) {
    bd..setUint16(0, code >> 16)..setUint16(2, code & 0xFFFF);
  }

  /// Returns the VR Code from _this_.
  void setVRCode(int vrCode) {
    bd..setUint8(4, vrCode >> 8)..setUint8(5, vrCode & 0xFF);
  }

  /// Returns the short Value Length Field from _this_.
  void setShortVLF(int vlf) => bd.setUint16(6, vlf);

  /// Returns the long Value Length Field from _this_.
  void setLongVLF(int vlf) => bd.setUint32(8, vlf);

  /// Write a short EVR header.
  void evrSetShortHeader(int code, int vrCode, int vlf) {
    bd
      ..setUint16(0, code >> 16)
      ..setUint16(2, code & 0xFFFF)
      ..setUint16(4, vrCode)
      ..setUint16(6, vlf);
  }

  /// Write a short EVR header.
  void evrSetLongHeader(int code, int vrCode, int vlf) {
    bd
      ..setUint16(0, code >> 16)
      ..setUint16(2, code & 0xFFFF)
      ..setUint16(4, vrCode)
      ..setUint16(6, 0)
      ..setUint32(8, vlf);
  }

  /// Write a short EVR header.
  void ivrSetHeader(int offset, int code, int vlf) {
    bd
      ..setUint16(offset, code >> 16)
      ..setUint16(2, code & 0xFFFF)
      ..setUint32(4, vlf);
  }
}
