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

const _kNull = 0;
const _kSpace = 32;

/// A class ensures that all [Bytes] are of an even length, by adding
/// a padding character, which defaults to ' ', if necessary.
class BytesPadded extends Bytes {
  /// Creates an empty [BytesPadded] of [length] and [endian].
  BytesPadded([int length = 4096, Endian endian = Endian.little])
      : super(length, endian);

  /// Creates a [BytesPadded] from a copy of [bytes].
  BytesPadded.from(Bytes bytes,
      [int start = 0, int end, Endian endian = Endian.little])
      : super.from(bytes, start, end ?? bytes.length, endian);

  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region and [endian]ness.  [endian] defaults to [Endian.little].
  BytesPadded.typedDataView(TypedData td,
      [int offset = 0, int length, Endian endian = Endian.little])
      : super.typedDataView(td, offset, length ?? td.lengthInBytes, endian);

  @override
  String getString(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      bool removePadding = true,
      Charset charset = utf8}) {
    length ??= buf.length;
    if (length == 0) return '';
    final list = _asUint8ListForString(offset, length, removePadding);
    return charset.decode(list, allowInvalid: true);
  }

  // **** Urgent test
  // Allows the removal of padding characters.
  Uint8List _asUint8ListForString(int offset, int length, bool removePadding) {
    // length > 0
    final index = buf.offsetInBytes + offset;
    if (length > buf.lengthInBytes || length.isOdd)
      throw ArgumentError('Invalid Offset: $offset');
    var last = length;
    if (removePadding && length.isEven) {
      final c = buf[last];
      if (c == _kNull || c == _kSpace) last = length - 1;
    }
    return buf.buffer.asUint8List(index, last);
  }

  @override
  List<String> getStringList(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\',
      Charset charset = utf8,
      bool removePadding = true}) {
    final s = getString(
        offset: offset,
        length: length,
        allowInvalid: allowInvalid,
        removePadding: removePadding,
        charset: charset);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getUtf8(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool removePadding = true}) =>
      getString(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: utf8);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getUtf8List(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          String separator = '\\',
          bool removePadding = true}) =>
      getStringList(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: utf8);

  /// Returns a [String] containing an _ASCII_ decoding of the specified region.
  String getAscii(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool removePadding = true}) =>
      getString(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: ascii);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _ASCII_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getAsciiList(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          String separator = '\\',
          bool removePadding = true}) =>
      getStringList(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: ascii);

  /// Returns a [String] containing a _Latin1_ decoding of the specified region.
  String getLatin(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool removePadding = true}) =>
      getString(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: latin1);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _ASCII_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getLatinList(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          String separator = '\\',
          bool removePadding = true}) =>
      getStringList(
          offset: offset,
          length: length,
          allowInvalid: allowInvalid,
          removePadding: removePadding,
          charset: latin1);

  /// Returns [Bytes] containing the [charset] encoding of [s];
  static BytesPadded fromString(String s,
      [String padChar = ' ', Charset charset = utf8]) {
    if (s == null) return null;
    if (s.isEmpty) return Bytes.kEmptyBytes;
    return BytesPadded.typedDataView(charset.encode(_maybePad(s, padChar)));
  }

  /// Returns a [Bytes] containing [charset] code units.
  /// [charset] defaults to UTF8.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8, and returned as [Bytes].
  static BytesPadded fromStringList(List<String> vList,
          {String padChar = ' ',
          Charset charset = utf8,
          String separator = '\\'}) =>
      BytesPadded.fromString(_listToString(vList, separator), padChar, charset);

  /// Returns [Bytes] containing the UTF-8 encoding of [s];
  static BytesPadded fromUtf8(String s, [String padChar = ' ']) =>
      fromString(s, padChar, utf8);

  /// Returns a [Bytes] containing UTF-8 code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8 and returned as [Bytes].
  static BytesPadded utf8FromList(List<String> vList,
          [String separator = '\\', String padChar = ' ']) =>
      BytesPadded.fromUtf8(_listToString(vList, separator), padChar);

  /// Returns [Bytes] containing the Latin character set encoding of [s];
  static BytesPadded fromLatin(String s, [String padChar = ' ']) =>
      fromString(s, padChar, latin1);

  /// Returns a [BytesPadded] containing the ASCII encoding of [s].
  /// If [s].length is odd, [padChar] is appended to [s] before
  /// encoding it.
  static BytesPadded fromAscii(String s, [String padChar = ' ']) =>
      fromString(s, padChar, ascii);

  /// Returns a [Bytes] containing ASCII code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as ASCII, and returned as [Bytes].
  static BytesPadded asciiFromList(List<String> vList,
          [String separator = '\\', String padChar = ' ']) =>
      BytesPadded.fromAscii(_listToString(vList, separator), padChar);

  /// Returns a [Bytes] containing Latin (1 - 9) code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as UTF-8, and returned as [Bytes].
  static BytesPadded latinFromList(List<String> vList,
          [String separator = '\\', String padChar = ' ']) =>
      BytesPadded.fromLatin(_listToString(vList, separator), padChar);

  static String _maybePad(String s, String p) => s.length.isOdd ? '$s$p' : s;

  /// Returns a [Bytes] containing ASCII code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as ASCII. The result is returns as [Bytes].
  static BytesPadded fromAsciiList(List<String> vList,
          [String separator = '\\', String padChar = ' ']) =>
      vList.isEmpty
          ? Bytes.kEmptyBytes
          : BytesPadded.fromAscii(vList.join(separator), padChar);

  /// Returns a [Bytes] containing UTF-8 code units.
  ///
  /// The [String]s in [vList] are [join]ed into a single string using
  /// using [separator] (which defaults to '\') to separate them, and
  /// then they are encoded as ASCII. The result is returns as [Bytes].
  static BytesPadded fromUtf8List(List<String> vList,
          [String separator = '\\']) =>
      (vList.isEmpty)
          ? Bytes.kEmptyBytes
          : BytesPadded.fromUtf8(vList.join('\\'));
}

// TODO maxLength if for DICOM Value Field
String _listToString(List<String> vList, String separator) {
  if (vList == null) return null;
  if (vList.isEmpty) return '';
  return vList.length == 1 ? vList[0] : vList.join(separator);
}
