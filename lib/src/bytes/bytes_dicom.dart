//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:bytes/bytes.dart';
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
abstract class BytesDicom extends Bytes
    with DicomBytesPrimitives, DicomBytesMixin {
  @override
  Endian get endian;

  /// Creates a new [BytesDicomLE] from [buf].
  factory BytesDicom(Uint8List buf, [Endian endian = Endian.little]) =>
      (endian == Endian.little) ? BytesDicomLE(buf) : BytesDicomBE(buf);

  /// Creates a new [Bytes] containing [length] elements.
  /// [length] defaults to [kDefaultLength] and [endian] defaults
  /// to [Endian.little].
  factory BytesDicom.empty(
          [int length = kDefaultLength, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesDicomLE.empty(length)
          : BytesDicomBE.empty(length);

  /// Creates a new [Bytes] from [bytes] containing the specified region
  /// and [endian]ness. [endian] defaults to [bytes].[endian].
  factory BytesDicom.from(Bytes bytes,
      [int offset = 0, int length, Endian endian]) {
    endian ??= bytes.endian;
    return (endian == Endian.little)
        ? BytesDicomLE.from(bytes, offset, length)
        : BytesDicomBE.from(bytes, offset, length);
  }

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  factory BytesDicom.typedDataView(TypedData td,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesDicomLE.typedDataView(td, offset, length)
          : BytesDicomBE.typedDataView(td, offset, length);

  @override
  bool operator ==(Object other) =>
      (other is Bytes && ignorePadding && _bytesEqual(this, other)) ||
          __bytesEqual(this, other, ignorePadding);


  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  @override
  String getAscii(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      bool noPadding = false});

  @override
  String getUtf8(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      bool noPadding = false});

  @override
  String toString() => '$runtimeType: offset: $offset length: $length';

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicomLE fromAscii(String s, [String padChar = ' ']) =>
      _stringToBytes(s, cvt.ascii.encode, padChar);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicomLE fromLatin(String s, [String padChar = ' ']) =>
      _stringToBytes(s, cvt.latin1.encode, padChar);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicomLE fromUtf8(String s, [String padChar = ' ']) =>
      _stringToBytes(s, cvt.utf8.encode, padChar);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicomLE fromString(String s, [String padChar = ' ']) =>
      fromUtf8(s, padChar);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Base64 decoding of [s].
  static BytesDicomLE fromBase64(String s, [String padChar = ' ']) =>
      _stringToBytes(s, cvt.base64.decode, padChar);
}

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
class BytesDicomLE extends BytesLittleEndian
    with DicomBytesPrimitives, DicomBytesMixin {
  /// Creates a new [BytesDicomLE] from [buf].
  BytesDicomLE(Uint8List buf) : super(buf);

  /// Creates an empty [BytesDicomLE] of [length] and [endian].
  BytesDicomLE.empty([int length = 4096]) : super.empty(length);

  /// Creates a [BytesDicomLE] from a copy of [bytes].
  BytesDicomLE.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesDicomLE.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length ?? td.lengthInBytes);

}

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
class BytesDicomBE extends BytesBigEndian
    with DicomBytesPrimitives, DicomBytesMixin {
  /// Creates a new [BytesDicomBE] from [buf].
  BytesDicomBE(Uint8List buf) : super(buf);

  /// Creates an empty [BytesDicomBE] of [length] and [endian].
  BytesDicomBE.empty([int length = 4096]) : super.empty(length);

  /// Creates a [BytesDicomBE] from a copy of [bytes].
  BytesDicomBE.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesDicomBE.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length ?? td.lengthInBytes);
}

mixin DicomBytesPrimitives {
  int get vfOffset => throw UnsupportedError('Not supported.');

  int get vfLengthField => throw UnsupportedError('Not supported.');
}

// Urgent: unit test
/// Returns a [Bytes] containing the Base64 decoding of [s].
BytesDicomLE _stringToBytes(
    String s, Uint8List decoder(String s), String padChar) {
  if (s.isEmpty) return Bytes.kEmptyBytes;
  var bList = decoder(s);
  if (padChar != null) {
    final bLength = bList.length;
    if (bLength.isOdd && padChar != null) {
      // Performance: It would be good to eliminate this copy
      final nList = Uint8List(bLength + 1);
      for (var i = 0; i < bLength - 1; i++)
        nList[i] = bList[i];
      nList[bLength] = padChar.codeUnitAt(0);
      bList = nList;
    }
  }
  return Bytes.typedDataView(bList);
}

bool _bytesEqual(Bytes a, Bytes b) {
  final aLen = a.length;
  if (aLen != b.length) return false;
  for (var i = 0; i < aLen; i++) if (a[i] != b[i]) return false;
  return true;
}

// TODO: test performance of _uint16Equal and _uint32Equal
bool __bytesEqual(Bytes a, Bytes b, bool ignorePadding) {
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
bool _uint8Equal(Bytes a, Bytes b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 1) {
    final x = a.buf[i];
    final y = b.buf[i];
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

// Note: optimized to use 2 byte boundary
bool _uint16Equal(Bytes a, Bytes b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 2) {
    final x = a.getUint16(i);
    final y = b.getUint16(i);
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

// Note: optimized to use 4 byte boundary
bool _uint32Equal(Bytes a, Bytes b, bool ignorePadding) {
  for (var i = 0; i < a.length; i += 4) {
    final x = a.getUint32(i);
    final y = b.getUint32(i);
    if (x != y) return _bytesMaybeNotEqual(i, a, b, ignorePadding);
  }
  return true;
}

bool _bytesMaybeNotEqual(int i, Bytes a, Bytes b, bool ignorePadding) {
  var errorCount = 0;
  final ok = __bytesMaybeNotEqual(i, a, b, ignorePadding);
  if (!ok) {
    errorCount++;
    if (errorCount > 3) throw ArgumentError('Unequal');
    return false;
  }
  return true;
}

bool __bytesMaybeNotEqual(int i, Bytes a, Bytes b, bool ignorePadding) {
  if ((a[i] == 0 && b[i] == 32) || (a[i] == 32 && b[i] == 0)) {
    //  log.warn('$i ${a[i]} | ${b[i]} Padding char difference');
    return ignorePadding;
  } else {
    _warnBytes(i, a, b);
    return false;
  }
}

void _warnBytes(int i, Bytes a, Bytes b) {
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
