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
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
mixin EvrShortBytes {
  Uint8List get buf;
  int getUint8(int offset);
  int getUint16(int offset);
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  bool get isEvr => true;

  int get vrOffset => 4;
  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(vrOffset) << 8) + getUint8(vrOffset + 1);

  /// The offset to the Value Field
  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  int get vfLengthOffset => 6;

  /// The offset in _this_ to the Value Field Length field.
  int get vfLengthField {
    final vlf = getUint16(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength) == true);
    return vlf;
  }

  int get vfLength => buf.length - vfOffset;

  // TODO: make private?
  /// Write a short EVR header.
  void setHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
    setUint16(6, vlf);
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
mixin EvrLongBytes {
  Uint8List get buf;
  int getUint8(int offset);
  int getUint32(int offset);
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);

  /// Returns _true_.
  bool get isEvr => true;

  int get vrOffset => 4;
  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(vrOffset) << 8) + getUint8(vrOffset + 1);

  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  int get vfLengthOffset => 8;

  int get vfLengthField {
    final vlf = getUint32(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength) == true);
    return vlf;
  }

  int get vfLength => buf.length - kVFOffset;

  // TODO: make private
  /// Write a short EVR header.
  void setHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
    // Note: The Uint16 field at offset 6 is already zero.
    setUint32(8, vlf);
  }

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}
