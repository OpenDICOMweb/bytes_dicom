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
import 'package:bytes_dicom/src/bytes/element_interface.dart';
import 'package:bytes_dicom/src/bytes/bytes_dicom_mixin.dart';
import 'package:bytes_dicom/src/dicom_constants.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const _kNull = 0;
const _kSpace = 32;

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
///
/// Note: This class handles all byte related methods that are special to
/// DICOM.
abstract class BytesDicom extends Bytes {
  @override
  Uint8List buf;

  // **** End of interface

  /// Creates a new [BytesDicomLE] from [buf].
  factory BytesDicom(Uint8List buf, [Endian endian = Endian.little]) =>
      (endian == Endian.little) ? BytesDicomLE(buf) : BytesDicomBE(buf);

  BytesDicom._(this.buf) : assert(buf.length.isEven);

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

  @override
  bool operator ==(Object other) =>
      (other is Bytes && noPadding && _bytesEqual(this, other)) ||
      __bytesEqual(this, other, noPadding);

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  /// The DICOM Tag Code of _this_.
  int get code => getCode(0);

  /// The Element Group Field
  int get group => getUint16(0);

  /// The Element _element_ Field.
  int get elt => getUint16(2);

  /// Returns the last Uint8 element in Value Field, if Value Field
  /// is not empty; otherwise, returns _null_.
  int get vfBytesLast => (length == 0) ? null : getUint8(length - 1);

  // **** get methods
  /// Gets the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) =>
      getUint16(offset) << 16 + getUint16(offset + 2);

  /// Returns the value in the VR field of _this_.
  int getVRCode([int offset = 0]) =>
      getUint8(offset + 4) << 8 + getUint8(offset + 5);

  /// Returns the value of the Value Field Length for a short Element.
  int getShortVLF([int offset = 6]) => getUint16(offset);

  /// Returns the value of the Value Field Length for a long Element.
  int getLongVLF([int offset = 8]) => getUint32(offset);

  /// Returns the value of the Value Field for a short Element.
  Uint8List getShortVF([int offset = 8, int length]) =>
      getUint8List(offset, length ?? buf.length);

  /// Returns the value of the Value Field for a long Element.
  Uint8List getLongVF([int offset = 12, int length]) =>
      getUint8List(offset, length ??= buf.length);

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

  int _getLength([int offset = 0, int length]) {
    length ??= buf.length;
    assert(length.isEven && length > 0);
    assert(offset + length < buf.length);
    final lastIndex = offset + length - 1;
    final c = buf[lastIndex];
    return (c == _kSpace || c == _kNull) ? length - 1 : length;
  }

  // **** set methods

  /// Sets the _code_ of _this_ to [code].
  void setCode(int offset, int code) {
    setUint16(offset, code >> 16);
    setUint16(offset + 2, code & 0xFFFF);
  }

  /// Sets the VR field of _this_ to [vrCode].
  void setVRCode(int offset, int vrCode) {
    setUint8(offset, vrCode >> 8);
    setUint8(offset + 1, vrCode & 0xFF);
  }

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setShortVLF(int offset, int vlf) => setUint16(offset, vlf);

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setLongVLF(int offset, int vlf) => setUint32(offset, vlf);

  /// Sets the Value Field for a short Element to [vf].
  void setShortVF(Uint8List vf) => _setValueField(vf, 8);

  /// Sets the Value Field L for a long Element to [vf].
  void setLongVF(Uint8List vf) => _setValueField(vf, 12);

  /// Sets the Value Field Length field for an Element to [vf].
  void _setValueField(Uint8List vf, int vfOffset) {
    for (var i = 0, j = vfOffset; i < vf.length; i++, j++) buf[j] = vf[i];
  }

  // **** String set methods

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

  /// Checks the Value Field length.
  bool checkVFLengthField(int vfLengthField, int vfLength) {
    if (vfLengthField != vfLength && vfLengthField != kUndefinedLength) {
      if (vfLengthField == vfLength + 1) {
        print('** vfLengthField: Odd length field: $vfLength');
        return true;
      }
      return false;
    }
    return true;
  }

  @override
  String toString() => '$runtimeType: offset: $offset length: $length';

  /// If _true_ then a padding character is added, when an odd length [String]
  /// is read or when an odd length [String] is written.
  static bool noPadding = false;

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
          [int maxLength, String padChar = ' ', Uint8List decoder(String s)]) =>
      _stringToBytes(s, maxLength ?? s.length, padChar, decoder);

  /// Returns a [Bytes] containing the ASCII encoding of [list].
  static BytesDicom fromStringList(List<String> list,
          [int maxLength, String padChar = ' ', Uint8List decoder(String s)]) =>
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
      : super._(td.buffer.asUint8List(
            td.offsetInBytes + offset, length ?? td.lengthInBytes));

  /// Returns _true_.
  bool get isEvr => true;
}

mixin BytesElement {
  bool get isEvr;
  int get code;
  int get vrCode;
  int get vrIndex;
  int get vfLengthOffset;
  int get vfLengthField;
  int get vfLength;
  int get vfOffset;
  Bytes get vfBytes;
  int get length;
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class BytesLEShortEvr extends BytesDicom
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        EvrShortBytes,
        BytesDicomMixin,
        EvrMixin,
        ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLEShortEvr(Uint8List buf) : super._(buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLEShortEvr.empty(int length) : super._empty(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : super._from(bytes, offset, length);

  /// Creates a new [BytesLEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesLEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super._typedDataView(td, offset, length);

  /// Returns an [BytesLEShortEvr] created from a view of [bytes].
  factory BytesLEShortEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesLEShortEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesLEShortEvr] with an empty Value Field.
  factory BytesLEShortEvr.header(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = BytesLEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Returns an [BytesLEShortEvr] created from a view
  /// of a Value Field ([vfBytes]).
  factory BytesLEShortEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesLEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a copy of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  BytesLEShortEvr sublist([int start = 0, int end]) =>
      BytesLEShortEvr.from(this, start, (end ?? length) - start);

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class BytesLELongEvr extends BytesDicom
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        EvrLongBytes,
        BytesDicomMixin,
        EvrMixin,
        ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLELongEvr(Uint8List buf) : super._(buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLELongEvr.empty(int length) : super._empty(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : super._from(bytes, offset, length);

  /// Creates a new [BytesLELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesLELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super._typedDataView(td, offset, length);

  /// Returns an [BytesLEShortEvr] created from a view of [bytes].
  factory BytesLELongEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesLELongEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns a [BytesLELongEvr] with a header, but with an empty Value Field.
  factory BytesLELongEvr.header(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = BytesLELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Creates a [BytesLELongEvr].
  factory BytesLELongEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesLELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a copy of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  BytesLELongEvr sublist([int start = 0, int end]) =>
      BytesLELongEvr.from(this, start, (end ?? length) - start);

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
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

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class BytesBEShortEvr extends BytesDicom
    with
        BigEndianGetMixin,
        BigEndianSetMixin,
        EvrShortBytes,
        BytesDicomMixin,
        EvrMixin,
        ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBEShortEvr(Uint8List buf) : super._(buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBEShortEvr.empty(int length) : super._empty(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : super._from(bytes, offset, length);

  /// Creates a new [BytesBEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesBEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super._typedDataView(td, offset, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesBEShortEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesBEShortEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesBEShortEvr] with an empty Value Field.
  factory BytesBEShortEvr.header(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = BytesBEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Returns an [BytesBEShortEvr] created from a view
  /// of a Value Field ([vfBytes]).
  factory BytesBEShortEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesBEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a copy of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  BytesBEShortEvr sublist([int start = 0, int end]) =>
      BytesBEShortEvr.from(this, start, (end ?? length) - start);

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class BytesBELongEvr extends BytesDicom
    with
        BigEndianGetMixin,
        BigEndianSetMixin,
        EvrLongBytes,
        BytesDicomMixin,
        EvrMixin,
        ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBELongEvr(Uint8List buf) : super._(buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBELongEvr.empty(int length) : super._empty(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : super._from(bytes, offset, length);

  /// Creates a new [BytesBELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesBELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super._typedDataView(td, offset, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesBELongEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesBELongEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesBELongEvr] with an empty Value Field.
  factory BytesBELongEvr.header(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    final e = BytesBELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
    return e;
  }

  /// Creates an [BytesBELongEvr].
  factory BytesBELongEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesBELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// Returns a copy of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  BytesBELongEvr sublist([int start = 0, int end]) =>
      BytesBELongEvr.from(this, start, (end ?? length) - start);

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}

/// Implicit Little Endian [Bytes] with short (16-bit) Value Field Length.
class BytesIvr extends BytesDicom
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        BytesDicomMixin,
        ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesIvr] containing [buf].
  BytesIvr(Uint8List buf) : super._(buf);

  /// Creates an empty [BytesIvr] of [length].
  BytesIvr.empty(int length) : super._empty(length);

  /// Create an [BytesIvr] Element from [Bytes].
  BytesIvr.from(Bytes bytes, int start, int length)
      : super._from(bytes, start, length);

  /// Create an [BytesIvr] Element from a view of [Bytes].
  BytesIvr.typedDataView(TypedData td, [int start = 0, int length])
      : super._typedDataView(td, start, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesIvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesIvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesIvr] with an empty Value Field.
  factory BytesIvr.header(int code, int vrCode, int vfLength) {
    assert(vfLength.isEven);
    return BytesIvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode);
  }

  /// Creates an [BytesIvr].
  factory BytesIvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    return BytesIvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength, vrCode)
      ..setUint8List(kVFOffset, vfBytes.buf);
  }

  /// Returns _false_.
  @override
  bool get isEvr => false;
  @override
  int get vrOffset => throw UnsupportedError('VR not supported');
  @override
  int get vrCode => kUNCode;
  @override
  int get vrIndex => kUNIndex;
  @override
  String get vrId => 'UN';
  @override
  int get vfOffset => kVFOffset;

  /// The byte offset from the beginning of the Element
  /// to the Value Length Field.
  @override
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

  /// Returns a copy of _this_ containing the bytes from [start] inclusive
  /// to [end] exclusive. If [end] is omitted, the [length] of _this_ is used.
  /// An error occurs if [start] is outside the range 0 .. [length],
  /// or if [end] is outside the range [start] .. [length].
  @override
  BytesIvr sublist([int start = 0, int end]) =>
      BytesIvr.from(this, start, (end ?? length) - start);

  /// The offset of the Value Field in an IVR Element
  static const int kVFOffset = 8;
}

// Urgent: unit test
/// Returns a [Bytes] containing the Base64 decoding of [s].
BytesDicom _stringToBytes(
    String s, int maxLength, String padChar, Uint8List decoder(String s)) {
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
  return Bytes.typedDataView(bList);
}

/// Returns a [Bytes] containing a decoding of [list].
Bytes _listToBytes(List<String> list, int maxLength, String padChar,
    Uint8List decoder(String s)) {
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
