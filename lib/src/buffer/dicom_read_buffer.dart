// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
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
import 'package:bytes_buffer/bytes_buffer.dart';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/bytes/ascii.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

/// A [BytesBuffer] for reading DicomBytes from [BytesDicomLE].
/// EVR and IVR are taken care of by the underlying [BytesDicomLE].
class DicomReadBuffer extends ReadBufferBase with ReadBufferMixin {
  /// Constructor
  DicomReadBuffer(this.bytes, [int offset = 0, int length])
      : rIndex = offset ?? 0,
        wIndex = length ?? bytes.length;

/*
  /// Creates a [ReadBuffer] from another [ReadBuffer].
  DicomReadBuffer.from(DicomReadBuffer rb, [int offset = 0, int length])
      : bytes = (rb.endian == Endian.little)
      ? BytesDicomLE.from(rb.bytes, offset, length)
  : BytesDicomLE.from(rb.bytes, offset, length),
        rIndex = offset ?? rb.bytes.offset,
        wIndex = length ?? rb.bytes.length;
*/

  /// The underlying [BytesDicomLE] for _this_.
  @override
  final Bytes bytes;
  @override
  int rIndex;
  @override
  int wIndex;

  @override
  Endian get endian => bytes.endian;

  /// Returns the DICOM Tag Code for _this_.
  int get code {
    final group = getUint16();
    final elt = getUint16();
    return (group << 16) + elt;
  }

  /// Returns the VR Code for _this_.
  int get vrCode => (getUint8() << 8) + getUint8();

  /// Returns the VR Index for _this_.
  int get vrIndex => vrIndexByCode8Bit[vrCode];

  /// Returns the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) =>
      (bytes.getUint16(offset) << 16) + bytes.getUint16(offset + 2);

  /// Reads the DICOM Tag Code at the current [rIndex], and advances
  /// the [rIndex] by four _bytes.
  int readCode() {
    assert(rIndex.isEven && hasRemaining(8), '@$rIndex : $remaining');
    final code = getCode(rIndex);
    rIndex += 4;
    return code;
  }

  /// Read the VR .
  int readVRCode() {
    assert(rIndex.isEven && hasRemaining(4), '@$rIndex : $remaining');
    final vrCode = (bytes.getUint8(rIndex) << 8) + bytes.getUint8(rIndex + 1);
    rIndex += 2;
    return vrCode;
  }

  /// Returns the VR Index at the current [rIndex].
  int readVRIndex() => vrIndexFromCode(readVRCode());

  /// Read a short Value Field Length.
  int readShortVLF() {
    assert(rIndex.isEven && hasRemaining(2), '@$rIndex : $remaining');
    final vlf = bytes.getUint16(rIndex);
    rIndex += 2;
    return vlf;
  }

  /// Read a short Value Field Length.
  int readLongVLF() {
    assert(rIndex.isEven && hasRemaining(4), '@$rIndex : $remaining');
    final vlf = bytes.getUint32(rIndex);
    rIndex += 4;
    return vlf;
  }

  /// Read a short Value Field Length.
  String readAscii(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      bool noPadding = false}) {
    length ??= length;
    assert(rIndex.isEven && hasRemaining(4), '@$rIndex : $remaining');
    var len = length;
    final buf = bytes.asUint8List(offset, length);
    if (noPadding && (buf.last == kSpace || buf.last == kNull)) len--;
    final v =
        bytes.getAscii(offset: rIndex, length: len, allowInvalid: allowInvalid);
    rIndex += 4;
    return v;
  }

  /// Read a short Value Field Length.
  String readUtf8(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      bool noPadding = false}) {
    length ??= length;
    assert(rIndex.isEven && hasRemaining(4), '@$rIndex : $remaining');
    var len = length;
    final buf = bytes.asUint8List(offset, length);
    if (noPadding && (buf.last == kSpace || buf.last == kNull)) len--;
    final v = bytes.getUtf8(
        offset: rIndex,
        length: len,
        allowInvalid: allowInvalid);
    rIndex += 4;
    return v;
  }
}
