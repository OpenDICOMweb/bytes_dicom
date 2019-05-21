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
import 'package:bytes_dicom/src/dicom_constants.dart';
import 'package:bytes_dicom/src/bytes/dicom_bytes_mixin.dart';
import 'package:bytes_dicom/src/bytes/evr_bytes.dart';
import 'package:bytes_dicom/src/bytes/ivr_bytes.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

/// A abstract subclass of [Bytes] that supports Explicit Value
/// Representations (EVR) and Implicit Value Representations (IVR).
abstract class DicomBytesBase extends Bytes with DicomBytesMixin {
  /// Creates an empty [DicomBytesBase].
  DicomBytesBase(int length, Endian endian) : super(length, endian);

  /// Creates a [DicomBytesBase] view of [bytes].
  factory DicomBytesBase.view(Bytes bytes, int vrIndex,
          {bool isEvr = true,
          int offset = 0,
          int end,
          Endian endian = Endian.little}) =>
      (!isEvr)
          ? IvrBytes.view(bytes, offset, end, endian)
          : (isEvrLongVR(vrIndex))
              ? EvrLongBytes.view(bytes, offset, end, endian)
              : EvrShortBytes.view(bytes, offset, end, endian);

  /// Creates a [DicomBytesBase] from a copy of [bytes].
  DicomBytesBase.from(Bytes bytes, int start, int end, Endian endian)
      : super.from(bytes, start, end, endian);

  /// __For internal use only__
  DicomBytesBase.internalView(Bytes bytes,
      [int offset = 0, int end, Endian endian = Endian.little])
      : super.view(bytes, offset, end, endian);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  DicomBytesBase.typedDataView(TypedData td,
      [int offsetInBytes = 0, int lengthInBytes, Endian endian = Endian.little])
      : super.typedDataView(td, offsetInBytes, lengthInBytes, endian);

  @override
  bool operator ==(Object other) =>
      (other is DicomBytesBase && ignorePadding && _bytesEqual(this, other)) ||
      __bytesEqual(this, other, ignorePadding);

//  @override
//  int get hashCode => super.hashCode;

  // Urgent is this field necessary
  /// If _true_ padding at the end of Value Fields will be ignored.
  ///
  /// _Note_: Only used by == operator.
  bool ignorePadding = true;

  @override
  String toString() {
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

  /// Returns a [ByteData] that is a copy of the specified region of _this_.
  static ByteData copyBDRegion(ByteData bd, int offset, int length) {
    final _length = length ?? bd.lengthInBytes;
    final _nLength = _length.isOdd ? _length + 1 : length;
    final bdNew = ByteData(_nLength);
    for (var i = 0, j = offset; i < _length; i++, j++)
      bdNew.setUint8(i, bd.getUint8(j));
    return bdNew;
  }
}

/// Checks the Value Field length.
bool checkVFLengthField(int vfLengthField, int vfLength) {
  if (vfLengthField != vfLength && vfLengthField != kUndefinedLength) {
//    log.warn('** vfLengthField($vfLengthField) != vfLength($vfLength)');
    if (vfLengthField == vfLength + 1) {
      print('** vfLengthField: Odd length field: $vfLength');
      return true;
    }
    return false;
  }
  return true;
}

bool _bytesEqual(DicomBytesBase a, DicomBytesBase b) {
  final aLen = a.length;
  if (aLen != b.length) return false;
  for (var i = 0; i < aLen; i++) if (a[i] != b[i]) return false;
  return true;
}

// TODO: test performance of _uint16Equal and _uint32Equal
bool __bytesEqual(DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  final len0 = a.length;
  final len1 = b.length;
  if (len0 != len1) return false;
  if ((len0 % 4) == 0) {
    return _uint32Equal(a, b, ignorePadding);
  } else if ((len0 % 2) == 0) {
    return _uint16Equal(a, b, ignorePadding);
  } else {
    return _uint8Equal(a, b, ignorePadding);
  }
}

// Note: optimized to use 4 byte boundary
bool _uint8Equal(DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 1) {
    final x = a.buf[i];
    final y = b.buf[i];
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

// Note: optimized to use 2 byte boundary
bool _uint16Equal(DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 2) {
    final x = a.getUint16(i);
    final y = b.getUint16(i);
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

// Note: optimized to use 4 byte boundary
bool _uint32Equal(DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 4) {
    final x = a.getUint32(i);
    final y = b.getUint32(i);
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

bool _bytesMaybeNotEqual(
    int i, DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  var errorCount = 0;
  final ok = __bytesMaybeNotEqual(i, a, b, ignorePadding);
  if (!ok) {
    errorCount++;
    if (errorCount > 3) throw ArgumentError('Unequal');
    return false;
  }
  return true;
}

bool __bytesMaybeNotEqual(
    int i, DicomBytesBase a, DicomBytesBase b, bool ignorePadding) {
  if ((a[i] == 0 && b[i] == 32) || (a[i] == 32 && b[i] == 0)) {
    //  log.warn('$i ${a[i]} | ${b[i]} Padding char difference');
    return ignorePadding;
  } else {
    _warnBytes(i, a, b);
    return false;
  }
}

void _warnBytes(int i, DicomBytesBase a, DicomBytesBase b) {
  final x = a[i];
  final y = b[i];
  print('''
$i: $x | $y')
	  "${String.fromCharCode(x)}" | "${String.fromCharCode(y)}"
	    '    $a')
      '    $b')
      '    ${a.getAscii()}')
      '    ${b.getAscii()}');
''');
}
