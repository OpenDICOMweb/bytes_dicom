//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes_dicom/bytes_dicom.dart';

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
