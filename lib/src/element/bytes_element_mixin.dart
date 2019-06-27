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
import 'package:bytes_dicom/src/element/element_interface.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const _kUndefinedLength = 0xFFFFFFFF;

mixin BytesElementMixin {
  /// The underlying [Uint8List] for _this_.
  Uint8List get buf;

  /// The offset in _this_ to the VR field.
  int get vfOffset;

  /// Returns the offset to the Value Field Length field.
  int get vfLengthOffset;

  /// Returns the Value length field of _this_.
  int get vfLengthField;
  int getUint8(int offset);
  int getUint16(int offset);
  void setUint16(int offset, int value);
  int getUint32(int offset);
  Bytes asBytes([int offset, int length]);
  Uint8List getUint8List([int offset = 0, int length]);

  // **** end of interface

  // **** Getters

  /// The DICOM Tag Code of _this_.
  int get code => getUint16(0) << 16 + getUint16(2);

  /// The DICOM Tag Code of _this_.
  set code(int code) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
  }

  /// The Element Group Field
  int get group => getUint16(0);

  /// The Element _element_ Field.
  int get elt => getUint16(2);

  /// Returns _true_ if [vfLengthField] equals the DICOM
  /// Undefined Length value (0xFFFFFFFF).
  bool get hasUndefinedLength => vfLengthField == _kUndefinedLength;

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
  void setUint16(int offset, int value);
  void setHeader(int code, int vrCode, int vfLength);

  // **** End of interface

  bool get isEvr => true;
  int get vrOffset => 4;

  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(4) << 8) + getUint8(5);

  set vrCode(int value) {
    setUint8(4, value >> 8);
    setUint8(5, value & 0xFF);
  }

  /// Returns the internal VR index of _this_.
  int get vrIndex => vrIndexFromCode(vrCode);

  ///  Returns the identifier of the VR of _this_.
  String get vrId => vrIdFromIndex(vrIndex);

  void setElement(int code, int vrCode, Uint8List vf) {
    final length = vf.length;
    assert(length == vfOffset + length);
    setHeader(code, vrCode, length);
    _setValueField(vf, vfOffset, buf);
  }
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
mixin EvrShortBytes implements ElementInterface {
  void operator []=(int i, int value);
  int getUint16(int offset);
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
  int get vfLengthOffset => 6;

  /// The offset to the Value Field
  @override
  int get vfOffset => kVFOffset;

  /// Returns the Value length field of _this_.
  @override
  int get vfLengthField {
    final vlf = getUint16(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  /// Write a short EVR header.
  void setHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
    setUint16(vfLengthOffset, vlf);
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;

}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
mixin EvrLongBytes implements ElementInterface {
  int getUint32(int offset);
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

  /// Returns the Value length field of _this_.
  @override
  int get vfLengthField {
    final vlf = getUint32(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

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
  Uint8List get buf;
  int getUint32(int offset);
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
  int get vfLengthOffset => 4;

  /// The offset to the Value Field
  @override
  int get vfOffset => kVFOffset;

  /// Returns the Value length field of _this_.
  @override
  int get vfLengthField {
    final vlf = getUint32(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  /// Set an IVR header.
  void setHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint32(6, vlf);
  }

  /// Set an IVR Element
  void setElement(int code, int vrCode, Uint8List vf) {
    final length = vf.length;
    assert(length == vfOffset + length);
    setHeader(code, vrCode, length);
    _setValueField(vf, vfOffset, buf);
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Checks the Value Field length.
bool checkVFLengthField(int vfLengthField, int vfLength) {
  if (vfLengthField != vfLength && vfLengthField != _kUndefinedLength) {
    if (vfLengthField == vfLength + 1) {
      print('** vfLengthField: Odd length field: $vfLength');
      return true;
    }
    return false;
  }
  return true;
}

/// Sets the Value Field Length field for an Element to [vf].
void _setValueField(Uint8List vf, int vfOffset, Uint8List buf) {
  for (var i = 0, j = vfOffset; i < vf.length; i++, j++) buf[j] = vf[i];
}