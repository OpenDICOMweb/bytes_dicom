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
import 'package:bytes_dicom/src/bytes/charset.dart';
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';

/*
const _kNull = 0;
const _kSpace = 32;
*/

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

/*
  /// Returns a view of the specified region of _this_.
  factory BytesDicom.view(Bytes bytes, [int offset = 0, int length]) =>
      (bytes.endian == Endian.little)
          ? BytesDicomLE.view(bytes, offset, length)
          : BytesDicomBE.view(bytes, offset, length);
*/

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

/*
  /// Returns [Bytes] containing the [charset] encoding of [s];
  factory BytesDicomLE.fromString(String s,
      [String padChar = ' ', Charset charset = utf8]) =>
      BytesDicomLE.typedDataView(charset.encode(_maybePad(s, padChar)));

  /// Returns [Bytes] containing the UTF-8 encoding of [s];
  factory BytesDicomLE.fromUtf8(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, utf8);

  /// Returns [Bytes] containing the Latin character set encoding of [s];
  factory BytesDicomLE.fromLatin(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, latin1);

  /// Returns a [BytesDicomLE] containing the ASCII encoding of [s].
  /// If [s].length is odd, [padChar] is appended to [s] before
  /// encoding it.
  factory BytesDicomLE.fromAscii(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, ascii);
*/

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

  /// Returns [Bytes] containing the [charset] encoding of [s];
  factory BytesDicomLE.fromString(String s,
          [String padChar = ' ', Charset charset = utf8]) =>
      BytesDicomLE.typedDataView(charset.encode(_maybePad(s, padChar)));

  /// Returns [Bytes] containing the UTF-8 encoding of [s];
  factory BytesDicomLE.fromUtf8(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, utf8);

  /// Returns [Bytes] containing the Latin character set encoding of [s];
  factory BytesDicomLE.fromLatin(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, latin1);

  /// Returns a [BytesDicomLE] containing the ASCII encoding of [s].
  /// If [s].length is odd, [padChar] is appended to [s] before
  /// encoding it.
  factory BytesDicomLE.fromAscii(String s, [String padChar = ' ']) =>
      BytesDicomLE.fromString(s, padChar, ascii);

  @override
  bool operator ==(Object other) =>
      (other is Bytes && ignorePadding && _bytesEqual(this, other)) ||
      __bytesEqual(this, other, ignorePadding);
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

  /// Returns [Bytes] containing the [charset] encoding of [s];
  factory BytesDicomBE.fromString(String s,
          [String padChar = ' ', Charset charset = utf8]) =>
      BytesDicomBE.typedDataView(charset.encode(_maybePad(s, padChar)));

  /// Returns [Bytes] containing the UTF-8 encoding of [s];
  factory BytesDicomBE.fromUtf8(String s, [String padChar = ' ']) =>
      BytesDicomBE.fromString(s, padChar, utf8);

  /// Returns [Bytes] containing the Latin character set encoding of [s];
  factory BytesDicomBE.fromLatin(String s, [String padChar = ' ']) =>
      BytesDicomBE.fromString(s, padChar, latin1);

  /// Returns a [BytesDicomBE] containing the ASCII encoding of [s].
  /// If [s].length is odd, [padChar] is appended to [s] before
  /// encoding it.
  factory BytesDicomBE.fromAscii(String s, [String padChar = ' ']) =>
      BytesDicomBE.fromString(s, padChar, ascii);
  @override
  bool operator ==(Object other) =>
      (other is Bytes && ignorePadding && _bytesEqual(this, other)) ||
      __bytesEqual(this, other, ignorePadding);
}

mixin DicomBytesPrimitives {
  int get vfOffset => throw UnsupportedError('Not supported.');

  int get vfLengthField => throw UnsupportedError('Not supported.');
}

String _maybePad(String s, String p) => s.length.isOdd ? '$s$p' : s;

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
