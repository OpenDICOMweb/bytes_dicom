//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';
import 'package:bytes_dicom/src/bytes/to_string_mixin.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

/// Implicit Little Endian [Bytes] with short (16-bit) Value Field Length.
class IvrBytesLE extends BytesLittleEndian with DicomBytesMixin, ToStringMixin {
  /// Creates an [IvrBytesLE] Element of length.
  IvrBytesLE(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Create an [IvrBytesLE] Element from [Bytes].
  IvrBytesLE.from(Bytes bytes, int start, int end)
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Create an [IvrBytesLE] Element from a view of [Bytes].
  IvrBytesLE.view(Bytes bytes, [int start = 0, int end])
      : assert(length.isEven),
        super.view(bytes, start, end);

  /// Returns an [IvrBytesLE] with an empty Value Field.
  factory IvrBytesLE.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    return IvrBytesLE(kVFOffset + vfLength)..setHeader(code, vfLength, vrCode);
  }

  /// Creates an [IvrBytesLE].
  factory IvrBytesLE.makeFromBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    return IvrBytesLE(kVFOffset + vfLength)
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
  IvrBytesLE sublist([int start = 0, int end]) =>
      IvrBytesLE.from(this, start, (end ?? length) - start);

  /// The offset of the Value Field in an IVR Element
  static const int kVFOffset = 8;
}
