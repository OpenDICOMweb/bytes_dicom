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
import 'package:bytes_dicom/src/bytes/element_interface.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const _kUndefinedLength = 0xFFFFFFFF;

mixin BytesDicomMixin {
  Uint8List get buf;
  int get vfOffset;
  int get vfLengthOffset;
  int getUint8(int offset);
  int getUint32(int offset);
  bool checkVFLengthField(int vlf, int vfLength);
  Bytes asBytes([int offset, int length]);

  // **** End of interface

  /// Returns _true_ if [vfLengthField] equals the DICOM
  /// Undefined Length value (0xFFFFFFFF).
  bool get hasUndefinedLength => vfLengthField == _kUndefinedLength;

  /// Returns the Value length field of _this_.
  int get vfLengthField {
    final vlf = getUint32(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  /// Returns the actual length of the Value Field.
  int get vfLength => buf.length - vfOffset;

  /// Returns the Value Field bytes.
  Bytes get vfBytes => asBytes(vfOffset, vfLength);

  /// Returns the Value Field as a Uint8List.
  Uint8List get vfUint8List =>
      buf.buffer.asUint8List(buf.offsetInBytes + vfOffset, vfLength);

  /// Returns the last Uint8 element in [vfBytes], if [vfBytes]
  /// is not empty; otherwise, returns _null_.
  int get vfBytesLast {
    final len = buf.length;
    return (len == 0) ? null : getUint8(len - 1);
  }
}

mixin EvrMixin {
  Uint8List get buf;
  int get vfOffset;
  int get vfLengthOffset;
  int getUint8(int offset);
  void setUint8(int offset, int value);
  int getUint32(int offset);
  void setUint16(int offset, int value);
  bool checkVFLengthField(int vlf, int vfLength);
  Bytes asBytes([int offset, int length]);

  // **** End of interface

  bool get isEvr => true;
  int get vrOffset => 4;

  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(vrOffset) << 8) + getUint8(vrOffset + 1);

  /// Returns the internal VR index of _this_.
  int get vrIndex => vrIndexFromCode(vrCode);

  ///  Returns the identifier of the VR of _this_.
  String get vrId => vrIdFromIndex(vrIndex);
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
mixin EvrShortBytes implements ElementInterface {
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
  int get vfLengthOffset => 6;

  /// The offset to the Value Field
  @override
  int get vfOffset => kVFOffset;

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
mixin EvrLongBytes implements ElementInterface {
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
  int get vfLengthOffset => 8;

  /// The offset to the Value Field
  @override
  int get vfOffset => kVFOffset;

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

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
mixin IvrBytes implements ElementInterface {
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
  int get vfLengthOffset => 4;

  /// The offset to the Value Field
  @override
  int get vfOffset => kVFOffset;

  /// Write a short EVR header.
  void setHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint32(6, vlf);
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

mixin ToStringMixin {
  int get code;
  int get vrCode;
  int get vfLengthField;
  int get vfLength;

  @override
  String toString() {
    final vrIndex = vrIndexFromCode(vrCode);
    final vrId = vrIdFromIndex(vrIndex);
    final vlf = vfLengthField;
    return '$runtimeType ${_dcm(code)} $vrId($vrIndex, ${_hex(vrCode, 4)}) '
        'vlf($vlf, ${_hex(vlf, 8)}) vfl($vfLength) ${super.toString()}';
  }

  /// Returns a [String] in DICOM Tag Code format, e.g. (gggg,eeee),
  /// corresponding to the Tag [code].
  String _dcm(int code) {
    assert(code >= 0 && code <= 0xFFFFFFFF, 'code: $code');
    return '(${_hex(code >> 16, 4)},${_hex(code & 0xFFFF, 4)})';
  }

  String _hex(int n, int width) => '${n.toRadixString(16).padLeft(width, '0')}';
}
