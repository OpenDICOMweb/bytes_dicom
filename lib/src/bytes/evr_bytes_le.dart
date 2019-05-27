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
import 'package:bytes_dicom/src/bytes/evr_bytes_mixin.dart';

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class EvrShortLEBytes extends BytesLittleEndian
    with DicomBytesMixin, EvrShortBytesMixin, ToStringMixin {
  /// Returns an [EvrShortLEBytes].
  EvrShortLEBytes(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Returns an [EvrShortLEBytes] created from [bytes].
  EvrShortLEBytes.from(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Returns an [EvrShortLEBytes] created from a view of [bytes].
  EvrShortLEBytes.view(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.view(bytes, start, end);

  /// Returns an [EvrShortLEBytes] with an empty Value Field.
  factory EvrShortLEBytes.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = EvrShortLEBytes(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Returns an [EvrShortLEBytes] created from a view
  /// of a Value Field ([vfBytes]).
  factory EvrShortLEBytes.fromVFBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrShortLEBytes(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrShortLEBytes sublist([int start = 0, int end]) =>
      EvrShortLEBytes.from(this, start, (end ?? length) - start);

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class EvrLongLEBytes extends BytesLittleEndian
    with DicomBytesMixin, EvrLongBytesMixin, ToStringMixin {
  /// Creates an [EvrLongLEBytes] of [length].
  EvrLongLEBytes(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Creates an [EvrLongLEBytes] from [Bytes].
  EvrLongLEBytes.from(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Creates an [EvrLongLEBytes] from a view of [Bytes].
  EvrLongLEBytes.view(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.view(bytes, start, end);

  /// Returns an [EvrLongLEBytes] with an empty Value Field.
  factory EvrLongLEBytes.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = EvrLongLEBytes(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Creates an [EvrLongLEBytes].
  factory EvrLongLEBytes.fromVFBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrLongLEBytes(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrLongLEBytes sublist([int start = 0, int end]) =>
      EvrLongLEBytes.from(this, start, (end ?? length) - start);

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}
