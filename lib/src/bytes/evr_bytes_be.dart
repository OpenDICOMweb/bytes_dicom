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
import 'package:bytes_dicom/src/bytes/evr_bytes_mixin.dart';
import 'package:bytes_dicom/src/bytes/to_string_mixin.dart';

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class EvrShortBEBytes extends BytesBigEndian
    with DicomBytesMixin, EvrShortBytes, ToStringMixin {

  /// Returns an empty [EvrShortBEBytes] with length [length].
  EvrShortBEBytes.empty(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Returns an [EvrShortBEBytes] created from [bytes].
  EvrShortBEBytes.from(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Returns an [EvrShortBEBytes] created from a view of [bytes].
  EvrShortBEBytes.view(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.view(bytes, start, end);

  /// Returns an [EvrShortBEBytes] with an empty Value Field.
  factory EvrShortBEBytes.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = EvrShortBEBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Returns an [EvrShortBEBytes] created from a view
  /// of a Value Field ([vfBytes]).
  factory EvrShortBEBytes.fromVFBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrShortBEBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrShortBEBytes sublist([int start = 0, int end]) =>
      EvrShortBEBytes.from(this, start, (end ?? length) - start);

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class EvrLongBEBytes extends BytesBigEndian
    with DicomBytesMixin, EvrLongBytes, ToStringMixin {
  /// Returns an [EvrLongBEBytes] containing [list].
  EvrLongBEBytes(Uint8List list)
      : assert(list.length.isEven),
        super(list);

  /// Returns an empty [EvrLongBEBytes] with length [length].
  EvrLongBEBytes.empty(int length)
      : assert(length.isEven),
        super.empty(length);

  /// Creates an [EvrLongBEBytes] from [Bytes].
  EvrLongBEBytes.from(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.from(bytes, start, end);

  /// Creates an [EvrLongBEBytes] from a view of [Bytes].
  EvrLongBEBytes.view(Bytes bytes, [int start = 0, int end])
      : assert(bytes.length.isEven),
        super.view(bytes, start, end);

  /// Returns an [EvrLongBEBytes] with an empty Value Field.
  factory EvrLongBEBytes.element(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = EvrLongBEBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Creates an [EvrLongBEBytes].
  factory EvrLongBEBytes.fromVFBytes(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrLongBEBytes.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrLongBEBytes sublist([int start = 0, int end]) =>
      EvrLongBEBytes.from(this, start, (end ?? length) - start);

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}
