//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:typed_data';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/dicom_constants.dart';

/// The Interface that all DICOM Elements must implement.
abstract class ElementInterface {
  /// The number of bytes in this Element.
  int get length;

  /// Returns _true_ if _this_ is Explicit VR.
  bool get isEvr;

  /// The Tag Code for this Element
  int get code;
  /// The offset in _this_ to the VR field.
  int get vrOffset;

  /// The integer value in the VR field of _this_.
  int get vrCode;

  /// The VR index of  _this_.
  int get vrIndex;

  /// The VR identifier of  _this_.
  String get vrId;

  /// Returns the offset to the Value Field Length field.
  int get vfLengthOffset;

  /// The value of the Value Field length field.
  int get vfLengthField;

  /// The offset in _this_ to the Value Field.
  int get vfOffset;

  /// The actual number of bytes in the Value Field, i.e. _not_
  /// the value in the Value Field Length field.
  int get vfLength;

  /// Returns the last byte of the Value Field of _this_.
  int get vfBytesLast;

  /// Returns the Value Field of _this_ as [Bytes].
  Bytes get vfBytes;
}

mixin ElementMixin {
  Uint8List get buf;
  int get vfLengthField;
  int get vfOffset;
  bool get isEvr;
  int get code;
  int get vrIndex;

  int getUint8(int offset);
  Bytes asBytes(int vfOffset, int vfLength);

  /// Returns _true_ if [vfLengthField] equals [kUndefinedLength].
  bool get hasUndefinedLength => vfLengthField == kUndefinedLength;

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