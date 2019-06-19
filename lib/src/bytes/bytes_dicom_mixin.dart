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

const _kSpace = 32;

const _kUndefinedLength = 0xFFFFFFFF;

mixin BytesDicomMixin {
  Uint8List get buf;
  int get vfOffset;
  int get vfLengthOffset;
  int get vfLength;


  int getUint16(int offset);
  bool checkVFLengthField(int vlf, int vfLength);
  Bytes asBytes([int offset, int length]);
  int setInt8List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt16List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt32List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt64List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint8List(int start, List<int> list, [int offset = 0, int length]);
  int setUint16List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint32List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint64List(int start, List<int> vList, [int offset = 0, int length]);
  int setFloat32List(int start, List<double> vList,
      [int offset = 0, int length]);
  int setFloat64List(int start, List<double> vList,
      [int offset = 0, int length]);

  int setAsciiList(int start, List<String> sList, [int padChar = _kSpace]);
  int setLatinList(int start, List<String> sList, [int padChar = _kSpace]);
  int setUtf8List(int start, List<String> sList, [int padChar]);
  int setUtf8(int start, String s, [int padChar = _kSpace]);

  /// Returns the Value Field bytes.
  Bytes get vfBytes => asBytes(vfOffset, vfLength);


  // Urgent: are these really needed??
  // Urgent: this sort of thing should be handled in bytes_buffer_dicom
  int writeInt8VF(List<int> vList) => setInt8List(vfOffset, vList);
  int writeInt16VF(List<int> vList) => setInt16List(vfOffset, vList);
  int writeInt32VF(List<int> vList) => setInt32List(vfOffset, vList);
  int writeInt64VF(List<int> vList) => setInt64List(vfOffset, vList);

  int writeUint8VF(List<int> vList) =>
      setUint8List(vfOffset, vList, 0, vList.length);
  int writeUint16VF(List<int> vList) => setUint16List(vfOffset, vList);
  int writeUint32VF(List<int> vList) => setUint32List(vfOffset, vList);
  int writeUint64VF(List<int> vList) => setUint64List(vfOffset, vList);

  int writeFloat32VF(List<double> vList) => setFloat32List(vfOffset, vList);
  int writeFloat64VF(List<double> vList) => setFloat64List(vfOffset, vList);

  int writeAsciiVF(List<String> vList, [int pad = _kSpace]) =>
      setAsciiList(vfOffset, vList, pad);
  int writeLatinVF(List<String> vList, [int pad = _kSpace]) =>
      setLatinList(vfOffset, vList, pad);
  int writeUtf8VF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8List(vfOffset, vList, pad);
  int writeTextVF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8(vfOffset, vList[0], pad);
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
/*
  Uint8List get buf;
  int get vfOffset;
  int get vfLengthOffset;

  int getUint16(int offset);
  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  bool checkVFLengthField(int vlf, int vfLength);

  int setInt8List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt16List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt32List(int start, List<int> vList, [int offset = 0, int length]);
  int setInt64List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint8List(int start, List<int> list,
      [int offset = 0, int length, int pad]);
  int setUint16List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint32List(int start, List<int> vList, [int offset = 0, int length]);
  int setUint64List(int start, List<int> vList, [int offset = 0, int length]);
  int setFloat32List(int start, List<double> vList,
      [int offset = 0, int length]);
  int setFloat64List(int start, List<double> vList,
      [int offset = 0, int length]);

  int setAsciiList(int start, List<String> sList, [int padChar = _kSpace]);
  int setUtf8List(int start, List<String> sList, [int padChar]);
  int setUtf8(int start, String s, [int padChar = _kSpace]);
*/

  int get vrOffset => 4;

  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(vrOffset) << 8) + getUint8(vrOffset + 1);

  /// Returns the internal VR index of _this_.
  int get vrIndex => vrIndexFromCode(vrCode);

  ///  Returns the identifier of the VR of _this_.
  String get vrId => vrIdFromIndex(vrIndex);

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
/*

  int get vfLengthField {
    final vlf = getUint16(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength) == true);
    return vlf;
  }

  @override
  int get vfLength => buf.length - vfOffset;

  /// Returns the Value Field bytes.
  Bytes get vfBytes => asBytes(vfOffset, vfLength);

  // Urgent: are these really needed??
  // Urgent: this sort of thing should be handled in bytes_buffer_dicom
  void writeInt8VF(List<int> vList) => setInt8List(vfOffset, vList);
  void writeInt16VF(List<int> vList) => setInt16List(vfOffset, vList);
  void writeInt32VF(List<int> vList) => setInt32List(vfOffset, vList);
  void writeInt64VF(List<int> vList) => setInt64List(vfOffset, vList);

  void writeUint8VF(List<int> vList) =>
      setUint8List(vfOffset, vList, 0, vList.length);
  void writeUint16VF(List<int> vList) => setUint16List(vfOffset, vList);
  void writeUint32VF(List<int> vList) => setUint32List(vfOffset, vList);
  void writeUint64VF(List<int> vList) => setUint64List(vfOffset, vList);

  void writeFloat32VF(List<double> vList) => setFloat32List(vfOffset, vList);
  void writeFloat64VF(List<double> vList) => setFloat64List(vfOffset, vList);

  void writeAsciiVF(List<String> vList, [int pad = _kSpace]) =>
      setAsciiList(vfOffset, vList, pad);
  void writeUtf8VF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8List(vfOffset, vList, pad);
  void writeTextVF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8(vfOffset, vList[0], pad);
*/
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
