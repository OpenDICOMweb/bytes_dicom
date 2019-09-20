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
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';

const _kNull = 0;
const _kSpace = 32;

/// A class that implements Byte related methods that are specific to DICOM.
abstract class BytesDicom extends Bytes
    with BytesDicomGetMixin, BytesDicomSetMixin {
  @override
  Uint8List buf;

  // **** End of interface

  /// Creates a new [BytesDicomLE] from [buf].
  factory BytesDicom(Uint8List buf, [Endian endian = Endian.little]) =>
      (endian == Endian.little) ? BytesDicomLE(buf) : BytesDicomBE(buf);

  BytesDicom._(this.buf);

  /// Creates an empty [BytesDicomBE] of [length] and [endian].
  BytesDicom._empty(int length) : buf = Uint8List(length);

  /// Creates a [BytesDicomBE] from a copy of [bytes].
  BytesDicom._from(Bytes bytes, [int offset = 0, int length])
      : buf = bytes.getUint8List(offset, length ?? bytes.length);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesDicom._typedDataView(TypedData td, [int offset = 0, int length])
      : buf = td.buffer.asUint8List(offset, length ?? td.lengthInBytes);

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

  /// Creates a new [BytesDicom] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  factory BytesDicom.typedDataView(TypedData td,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesDicomLE.typedDataView(td, offset, length)
          : BytesDicomBE.typedDataView(td, offset, length);

  @override
  bool operator ==(Object other) =>
      (other is Bytes && noPadding && _bytesEqual(this, other)) ||
      __bytesEqual(this, other, noPadding);

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  // **** String get methods
  // Urgent: this may not be needed once DicomReadBuffer removes padding

  /// Returns a [String] containing an _ASCII_ decoding of the specified
  /// region of _this_.
  @override
  String getAscii([int offset = 0, int length]) =>
      super.getAscii(offset, _getLength(offset, length));

  /// Returns a [List<String>] containing an _ASCII_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  @override
  List<String> getAsciiList(
          [int offset = 0, int length, String separator = '\\']) =>
      super.getAsciiList(offset, _getLength(offset, length), '\\');

  /// Returns a [String] containing an _Latin_ decoding of the specified
  /// region of _this_. If the specified region ends in a space or null byte,
  /// remove it from the result.
  @override
  String getLatin([int offset = 0, int length]) =>
      super.getLatin(offset, _getLength(offset, length));

  /// Returns a [List<String>] containing an _LATIN_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  @override
  List<String> getLatinList(
          [int offset = 0, int length, String separator = '\\']) =>
      super.getLatinList(offset, _getLength(offset, length), '\\');

  /// Returns a [String] containing an _UTF-8_ decoding of the specified
  /// region of _this_. If the specified region ends in a space or null byte,
  /// remove it from the result.
  @override
  String getUtf8([int offset = 0, int length]) =>
      super.getUtf8(offset, _getLength(offset, length));

  /// Returns a [List<String>] containing an _UTF8_ decoding of the specified
  /// region of _this_, which is then _split_ using [separator].
  @override
  List<String> getUtf8List(
          [int offset = 0, int length, String separator = '\\']) =>
      super.getUtf8List(offset, _getLength(offset, length), '\\');

  /// Returns a [String] containing a decoding of the specified region.
  /// If [decoder] is not specified, it defaults to _UTF-8_.
  @override
  String getString([int offset = 0, int length, Decoder decoder]) =>
      super.getString(offset, _getLength(offset, length), decoder);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region using [decoder], and then _split_ing the
  /// resulting [String] using the [separator] character.
  @override
  List<String> getStringList(
          [int offset = 0,
          int length,
          Decoder decoder,
          String separator = '\\']) =>
      getStringList(offset, _getLength(offset, length), decoder, '\\');

  /// Removes any padding chars from _this_ and returns the length of _this_.
  int _getLength([int offset = 0, int length]) {
    length ??= buf.length;
    assert(length >= 0 && offset + length <= buf.length);
    if (length == 0 || length.isOdd) return length;
    final lastIndex = offset + length - 1;
    final c = buf[lastIndex];
    return (c == _kSpace || c == _kNull) ? length - 1 : length;
  }

  // **** String set methods
  // Urgent: these may not be needed once DicomWriteBuffer adds padding.

  // TODO: unit test
  /// Ascii encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start].
  ///
  /// If [padChar] is not
  /// _null_ and [s].length is odd, then [padChar] is written after
  /// the code units of [s] have been written.
  @override
  int setAscii(int start, String s, [int padChar = _kSpace]) =>
      _setStringBytes(start, cvt.ascii.encode(s), padChar);

  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start].
  ///
  /// If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  @override
  int setAsciiList(int start, List<String> sList,
          [String separator = '\\', int padChar = _kSpace]) =>
      _setLatinList(start, sList, 127, padChar);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  @override
  int setLatin(int start, String s, [String separator = '\\']) =>
      _setStringBytes(start, cvt.latin1.encode(s), _kSpace);

  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start]. If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  @override
  int setLatinList(int start, List<String> sList,
          [String separator = '\\', int padChar = _kSpace]) =>
      _setLatinList(start, sList, 255, _kSpace);

  /// Copy [String]s from [sList] into _this_ separated by backslash.
  /// If [padChar] is not equal to _null_ and last character position
  /// is odd, then add [padChar] at end.
  // Note: this only works for Ascii or latin character sets
  int _setLatinList(
    int start,
    List<String> sList,
    int limit,
    int padChar,
  ) {
    const _kBackslash = 92;
    assert(padChar == _kSpace || padChar == _kNull);
    if (sList.isEmpty) return 0;
    final last = sList.length - 1;
    var k = start;

    for (var i = 0; i < sList.length; i++) {
      final s = sList[i];
      for (var j = 0; j < s.length; j++) {
        final c = s.codeUnitAt(j);
        if (c > limit)
          throw ArgumentError('Character code $c is out of range $limit');
        setUint8(k++, s.codeUnitAt(j));
      }
      if (i != last) setUint8(k++, _kBackslash);
    }
    if (k.isOdd && padChar != null) setUint8(k++, padChar);
    return k - start;
  }

  // TODO: unit test
  /// UTF-8 encodes [s] and then writes the code units to _this_
  /// starting at [start]. Returns the offset of the last byte + 1.
  @override
  int setUtf8(int start, String s, [int padChar = _kSpace]) {
    final list = cvt.utf8.encode(s);
    return _setStringBytes(start, list, padChar);
  }

  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start].
  ///
  /// If [padChar] is not _null_ and the offset of the last
  /// byte written is odd, then [padChar] is written to _this_.
  /// Returns the number of bytes written.
  @override
  int setUtf8List(int start, List<String> sList,
          [String separator = '\\', int padChar = _kSpace]) =>
      setUtf8(start, sList.join('\\'), padChar);

  /// Moves bytes from [list] to _this_. If [list].[length] is odd adds [pad]
  /// as last byte. Returns the number of bytes written.
  int _setStringBytes(int start, Uint8List list, [int pad = _kSpace]) {
    final length = list.length;
    for (var i = offset, j = start; i < length; i++, j++) buf[j] = list[i];
    if (length.isOdd && pad != null) {
      final end = offset + length;
      if (end > buf.length) throw ArgumentError();
      buf[end] = pad;
      return length + 1;
    }
    return length;
  }

  // TODO fix to use Latin
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  ///
  /// Note: Currently only encodes Latin1.
  @override
  void setString(int start, String s, [Encoder encoder]) =>
      _setStringBytes(start, encoder(s));

  // Urgent is this useful is it faster
  /// Writes the Ascii encoding of [vList] into the Value Field of _this_.
  int writeAsciiVFFast(int offset, List<String> vList, [int padChar]) {
    const _kBackslash = 92;
    var index = offset;
    if (vList.isEmpty) return index;
    final last = vList.length - 1;
    for (var i = 0; i < vList.length; i++) {
      final s = vList[i];
      for (var j = 0; j < s.length; j++) setUint8(index, s.codeUnitAt(i));
      if (i != last) {
        setUint8(index++, _kBackslash);
      } else {
        if (index.isOdd && padChar != null) setUint8(index++, padChar);
      }
    }
    return index;
  }

//  @override
//  String toString() => '$runtimeType: offset: $offset length: $length $buf';

  /// If _true_ then a padding character is added, when an odd length [String]
  /// is read or when an odd length [String] is written.
  static bool noPadding = true;

  /// A [BytesDicom] with length 0.
  static BytesDicom kEmpty = Bytes.kEmptyBytes;

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicom fromAscii(String s,
          [int maxLength, String padChar = ' ']) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, cvt.ascii.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesDicom fromAsciiList(List<String> list,
          [int maxLength, String padChar = ' ']) =>
      _listToBytes(list, maxLength, padChar, cvt.ascii.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicom fromLatin(String s,
          [int maxLength, String padChar = ' ']) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, cvt.ascii.encode);

  /// Returns a [Bytes] containing the Latin encoding of [list].
  static BytesDicom fromLatinList(List<String> list,
          [int maxLength, String padChar = ' ']) =>
      _listToBytes(list, maxLength, padChar, cvt.ascii.encode);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicom fromUtf8(String s, [int maxLength, String padChar = ' ']) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, cvt.utf8.encode);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesDicom fromUtf8List(List<String> list,
          [int maxLength, String padChar = ' ']) =>
      _listToBytes(list, maxLength, padChar, cvt.ascii.encode);

  /// Returns a [Uint8List] corresponding to a binary Value Field.
  static Bytes fromTextList(Iterable<String> list) {
    if (list.isEmpty) return BytesDicom.kEmpty;
    if (list.length != 1) throw ArgumentError('Text has only one value:$list');
    return fromUtf8List(list);
  }

  // Urgent: unit test
  /// Returns a [Bytes] containing the Utf8 decoding of [s].
  static BytesDicom fromString(String s,
          [int maxLength,
          String padChar = ' ',
          Uint8List Function(String s) decoder]) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, decoder);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesDicom fromStringList(List<String> list,
          [int maxLength,
          String padChar = ' ',
          Uint8List Function(String s) decoder]) =>
      _listToBytes(list, maxLength, padChar, decoder);

  // Urgent: unit test
  /// Returns a [Bytes] containing the Base64 decoding of [s].
  static BytesDicom fromBase64(String s,
          [int maxLength, String padChar = ' ']) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, cvt.ascii.encode);
}

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
class BytesDicomLE extends BytesDicom
    with LittleEndianGetMixin, LittleEndianSetMixin {
  /// Creates a new [BytesDicomLE] from [buf].
  BytesDicomLE(Uint8List buf) : super._(buf);

  /// Creates an empty [BytesDicomLE] of [length] and [endian].
  BytesDicomLE.empty([int length = 4096]) : super._empty(length);

  /// Creates a [BytesDicomLE] from a copy of [bytes].
  BytesDicomLE.from(Bytes bytes, [int offset = 0, int length])
      : super._(bytes.getUint8List(offset, length ?? bytes.length));

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesDicomLE.typedDataView(TypedData td, [int offset = 0, int length])
      : super._typedDataView(td, offset, length ?? td.lengthInBytes);

  /// Returns _true_.
  bool get isEvr => true;
}

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
class BytesDicomBE extends BytesDicom
    with BigEndianGetMixin, BigEndianSetMixin {
  /// Creates a new [BytesDicomBE] from [buf].
  BytesDicomBE(Uint8List buf) : super._(buf);

  /// Creates an empty [BytesDicomBE] of [length] and [endian].
  BytesDicomBE.empty([int length = 4096]) : super._(Uint8List(length));

  /// Creates a [BytesDicomBE] from a copy of [bytes].
  BytesDicomBE.from(Bytes bytes, [int offset = 0, int length])
      : super._(bytes.getUint8List(offset, length ?? bytes.length));

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesDicomBE.typedDataView(TypedData td, [int offset = 0, int length])
      : super._(td.buffer.asUint8List(offset, length ?? td.lengthInBytes));

  /// Returns _false_.
  bool get isEvr => false;
}

// Urgent: unit test
/// Returns a [Bytes] containing the Base64 decoding of [s].
BytesDicom _stringToBytes(String s, int maxLength, String padChar,
    Uint8List Function(String s) decoder) {
  if (s.isEmpty) return Bytes.kEmptyBytes;
  var bList = decoder(s);
  if (padChar != null) {
    final bLength = bList.length;
    if (bLength.isOdd && padChar != null) {
      // Performance: It would be good to eliminate this copy
      final nList = Uint8List(bLength + 1);
      for (var i = 0; i < bLength - 1; i++) nList[i] = bList[i];
      nList[bLength] = padChar.codeUnitAt(0);
      bList = nList;
    }
  }
  return BytesDicomLE.typedDataView(bList, 0, bList.length);
}

/// Returns a [Bytes] containing a decoding of [list].
Bytes _listToBytes(List<String> list, int maxLength, String padChar,
    Uint8List Function(String s) decoder) {
  final s = list.join('\\').trimLeft();
  return _stringToBytes(s, maxLength, padChar, decoder);
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
  for (var i = 0; i < a.length; i++) {
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
