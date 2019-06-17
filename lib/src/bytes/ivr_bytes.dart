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
import 'package:bytes_dicom/src/bytes/to_string_mixin.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

/// Implicit Little Endian [Bytes] with short (16-bit) Value Field Length.
class IvrBytes extends BytesLittleEndian with DicomBytesMixin, ToStringMixin {
  /// Returns an [IvrBytes] containing [list].
  IvrBytes(Uint8List list)
      : assert(list.length.isEven),
        super(list);

  /// Creates an empty [IvrBytes] of [length].
  IvrBytes.empty(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Create an [IvrBytes] Element from [Bytes].
  IvrBytes.from(Bytes bytes, int start, int end)
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Create an [IvrBytes] Element from a view of [Bytes].
  IvrBytes.view(Bytes bytes, [int start = 0, int end])
      : assert(length.isEven),
        super.view(bytes, start, end);

  /// Returns an [IvrBytes] with an empty Value Field.
  factory IvrBytes.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    return IvrBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
  }

  /// Creates an [IvrBytes].
  factory IvrBytes.makeFromBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    return IvrBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
  }

  /// Returns _false_.
  bool get isEvr => false;
  @override
  int get vrCode => kUNCode;
  @override
  int get vrIndex => kUNIndex;

  @override
  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  int get vfLengthOffset => 4;

  @override
  int get vfLengthField {
    final vlf = getUint32(vfLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  @override
  int get vfLength => buf.length - 8;

  // TODO: make private?
  /// Write a short EVR header.
  void setHeader(int offset, int code, int vlf) {
    setUint16(offset, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint32(4, vlf);
  }

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  IvrBytes sublist([int start = 0, int end]) =>
      IvrBytes.from(this, start, (end ?? length) - start);

  /// The offset of the Value Field in an IVR Element
  static const int kVFOffset = 8;
}
