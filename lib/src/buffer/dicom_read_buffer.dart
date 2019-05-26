// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes_buffer/bytes_buffer.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';
import 'package:bytes_dicom/src/bytes/dicom_bytes.dart';

// ignore_for_file: public_member_api_docs

/// A [BytesBuffer] for reading DicomBytes from [BytesDicomLE].
/// EVR and IVR are taken care of by the underlying [BytesDicomLE].
class DicomReadBuffer extends ReadBufferBase with ReadBufferMixin {
  /// The underlying [BytesDicomLE] for _this_.
  @override
  final BytesDicomLE bytes;
  @override
  int rIndex;
  @override
  int wIndex;

  /// Constructor
  DicomReadBuffer(this.bytes, [int offset = 0, int length])
      : rIndex = offset ?? 0,
        wIndex = length ?? bytes.length;

  /// Creates a [ReadBuffer] from another [ReadBuffer].
  DicomReadBuffer.from(DicomReadBuffer rb, [int offset = 0, int length])
      : bytes = BytesDicomLE.from(rb.bytes, offset, length),
        rIndex = offset ?? rb.bytes.offset,
        wIndex = length ?? rb.bytes.length;

  // Urgent DICOM extensions - these should go away when DicomBytes works
  int get code {
    final group = getUint16();
    final elt = getUint16();
    return (group << 16) + elt;
  }

  int get vrCode => (getUint8() << 8) + getUint8();

  int get vrIndex => vrIndexByCode8Bit[vrCode];

  /// Returns the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) =>
      (bytes.getUint16(offset) << 16) + bytes.getUint16(offset + 2);

/*
  /// Reads the DICOM Tag Code at the current [rIndex]. It does not
  /// move the [rIndex].
  int peekCode() => getCode(rIndex);
*/

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
    final v = bytes.getAscii(
        offset: rIndex,
        length: length,
        allowInvalid: allowInvalid,
        noPadding: noPadding);
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
    final v = bytes.getUtf8(
        offset: rIndex,
        length: length,
        allowInvalid: allowInvalid,
        noPadding: noPadding);
    rIndex += 4;
    return v;
  }
}
