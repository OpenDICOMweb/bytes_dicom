//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

mixin BytesDicomGetMixin {
  Uint8List get buf;
  int getUint8(int offset);
  int getUint16(int offset);
  int getUint32(int offset);
  Uint8List getUint8List([int offset = 0, int length]);

  // **** get methods
  /// Gets the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) =>
      getUint16(offset) << 16 + getUint16(offset + 2);

  /// Returns the value in the VR field of _this_.
  int getVRCode([int offset = 0]) =>
      getUint8(offset + 4) << 8 + getUint8(offset + 5);

  /// Returns the value of the Value Field Length for a short Element.
  int getShortVLF([int offset = 6]) => getUint16(offset);

  /// Returns the value of the Value Field Length for a long Element.
  int getLongVLF([int offset = 8]) => getUint32(offset);

  /// Returns the value of the Value Field for a short Element.
  Uint8List getShortVF([int offset = 8, int length]) =>
      getUint8List(offset, length ?? buf.length);

  /// Returns the value of the Value Field for a long Element.
  Uint8List getLongVF([int offset = 12, int length]) =>
      getUint8List(offset, length ??= buf.length);
}

mixin BytesDicomSetMixin {
  Uint8List get buf;
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);

  // **** set methods

  /// The DICOM Tag Code of _this_.
  set code(int code) => setCode(0, code);

  /// Sets the _code_ of _this_ to [code].
  void setCode(int offset, int code) {
    setUint16(offset, code >> 16);
    setUint16(offset + 2, code & 0xFFFF);
  }

  /// Sets the VR field of _this_ to [vrCode].
  void setVRCode(int offset, int vrCode) {
    setUint8(offset, vrCode >> 8);
    setUint8(offset + 1, vrCode & 0xFF);
  }

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setShortVLF(int offset, int vlf) => setUint16(offset, vlf);

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setLongVLF(int offset, int vlf) => setUint32(offset, vlf);

  /// Sets the Value Field for a short Element to [vf].
  void setShortVF(Uint8List vf) => _setValueField(vf, 8);

  /// Sets the Value Field L for a long Element to [vf].
  void setLongVF(Uint8List vf) => _setValueField(vf, 12);

  /// Sets the Value Field Length field for an Element to [vf].
  void _setValueField(Uint8List vf, int vfOffset) {
    for (var i = 0, j = vfOffset; i < vf.length; i++, j++) buf[j] = vf[i];
  }
}
