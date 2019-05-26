//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/src/bytes/dicom_bytes_mixin.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

/// Explicit Little Endian [Bytes].
mixin EvrBytes {
  int getUint8(int offset);

  /// Returns _true_.
  bool get isEvr => true;

  // TODO replace with 16 bit version??
  int get vrCode => (getUint8(4) << 8) + getUint8(5);

  int get vrIndex => vrIndexFromCode(vrCode);

  String get vrId => vrIdFromIndex(vrIndex);



  /// The offset to the Value Field.
  static const int kVROffset = 4;
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class EvrShortLEBytes extends BytesLittleEndian with EvrBytes, DicomBytesMixin {
  /// Returns an [EvrShortLEBytes].
  EvrShortLEBytes(int length) : super.empty(length);

  /// Returns an [EvrShortLEBytes] created from [bytes].
  EvrShortLEBytes.from(Bytes bytes, [int start = 0, int end])
      : super.from(bytes, start, end);

  /// Returns an [EvrShortLEBytes] created from a view of [bytes].
  EvrShortLEBytes.view(Bytes bytes, [int start = 0, int end])
      : super.view(bytes, start, end);

  /// Returns an [EvrShortLEBytes] with an empty Value Field.
  factory EvrShortLEBytes.element(int code, int vfLength, int vrCode) {
    final e = EvrShortLEBytes(kHeaderLength + vfLength)
      ..evrSetShortHeader(code, vfLength, vrCode);
    return e;
  }

  /// Returns an [EvrShortLEBytes] created from a view
  /// of a Value Field ([vfBytes]).
  factory EvrShortLEBytes.fromVFBytes(int code, Bytes vfBytes, int vrCode) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrShortLEBytes(kHeaderLength + vfLength)
      ..evrSetShortHeader(code, vfLength, vrCode)
      ..setByteData(kVFOffset, vfBytes.bd);
    return e;
  }

  @override
  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  int get vfLengthOffset => kVFLengthOffset;

  @override
  int get vfLengthField {
    final vlf = getUint16(kVFLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  @override
  int get vfLength => buf.length - 8;

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrShortLEBytes sublist([int start = 0, int end]) =>
      EvrShortLEBytes.from(this, start, (end ?? length) - start);

  /// The Value Field Length field offset.
  static const int kVFLengthOffset = 6;

  /// The Value Field offset.
  static const int kVFOffset = 8;

  /// The header length of an [EvrShortLEBytes].
  static const int kHeaderLength = kVFOffset;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class EvrLongLEBytes extends BytesLittleEndian with EvrBytes, DicomBytesMixin {
  /// Creates an [EvrLongLEBytes] of [length].
  EvrLongLEBytes(int length) : super.empty(length);

  /// Creates an [EvrLongLEBytes] from [Bytes].
  EvrLongLEBytes.from(Bytes bytes, [int start = 0, int end])
      : super.from(bytes, start, end);

  /// Creates an [EvrLongLEBytes] from a view of [Bytes].
  EvrLongLEBytes.view(Bytes bytes, [int start = 0, int end])
      : super.view(bytes, start, end);

  /// Returns an [EvrLongLEBytes] with an empty Value Field.
  factory EvrLongLEBytes.element(int code, int vfLength, int vrCode) {
    final e = EvrLongLEBytes(kHeaderLength + vfLength)
      ..evrSetLongHeader(code, vfLength, vrCode);
    return e;
  }

  /// Creates an [EvrLongLEBytes].
  factory EvrLongLEBytes.fromVFBytes(int code, Bytes vfBytes, int vrCode) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = EvrLongLEBytes(kHeaderLength + vfLength)
      ..evrSetLongHeader(code, vfLength, vrCode)
      ..setByteData(kVFOffset, vfBytes.bd);
    return e;
  }

  @override
  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  int get vfLengthOffset => kVFLengthOffset;

  @override
  int get vfLengthField {
    final vlf = getUint32(kVFLengthOffset);
    assert(checkVFLengthField(vlf, vfLength));
    return vlf;
  }

  @override
  int get vfLength => buf.length - 12;

  /// Returns a _view_ of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  EvrLongLEBytes sublist([int start = 0, int end]) =>
      EvrLongLEBytes.from(this, start, (end ?? length) - start);

  /// The offset to the Value Field Length field.
  static const int kVFLengthOffset = 8;

  /// The offset to the Value Field.
  static const int kVFOffset = 12;

  /// The header length of an [EvrLongLEBytes].
  static const int kHeaderLength = kVFOffset;
}

