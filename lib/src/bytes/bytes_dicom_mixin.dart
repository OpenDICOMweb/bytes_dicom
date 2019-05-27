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
import 'package:bytes_dicom/src/bytes/bytes_dicom.dart';
import 'package:bytes_dicom/src/bytes/charset.dart';
import 'package:bytes_dicom/src/dicom_constants.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const int _kNull = 0;
const int _kSpace = 0x20;
const _kBackslash = 92;

/// Mixin that handles Binary Dicom padding characters.
mixin DicomBytesMixin {
  Uint8List get buf;
  int get offset;
  int get length;
  int get vfOffset;
  int get vfLengthField;
  Uint8List asUint8List([int offset = 0, int length]);

  int operator [](int offset);
  int getUint8(int offset);
  int getUint16(int offset);
  int getUint32(int offset);
  int getUint64(int offset);

  void setUint8(int offset, int value);
  void setUint16(int offset, int value);
  void setUint32(int offset, int value);
  void setUint64(int offset, int value);

  int setInt8List(int start, List<int> list, [int offset = 0, int length]);
  int setInt16List(int start, List<int> list, [int offset = 0, int length]);
  int setInt32List(int start, List<int> list, [int offset = 0, int length]);
  int setInt64List(int start, List<int> list, [int offset = 0, int length]);

  int setUint16List(int start, List<int> list, [int offset = 0, int length]);
  int setUint32List(int start, List<int> list, [int offset = 0, int length]);
  int setUint64List(int start, List<int> list, [int offset = 0, int length]);

  int setFloat32List(int start, List<double> list,
      [int offset = 0, int length]);
  int setFloat64List(int start, List<double> list,
      [int offset = 0, int length]);

  Bytes asBytes([int offset = 0, int length]);

  // **** End of Interface

//  @override
//  int get hashCode => super.hashCode;

  // Urgent is this field necessary
  /// If _true_ padding at the end of Value Fields will be ignored.
  ///
  /// _Note_: Only used by == operator.
  bool ignorePadding = true;

  int get code => getCode(0);

  /// The Element Group Field
  int get group => getUint16(_kGroupOffset);

  /// The Element _element_ Field.
  int get elt => getUint16(_kEltOffset);

  /// Returns the offset in _this_ to VR field.
  int get vrOffset => 4;

  /// The VR code of _this_.
  int get vrCode => throw UnsupportedError('Unsupported');

  /// Returns the internal VR index of _this_.
  int get vrIndex => vrIndexFromCode(vrCode);

  ///  Returns the identifier of the VR of _this_.
  String get vrId => vrIdFromIndex(vrIndex);

//  Tag get tag => Tag.lookup(code);

  /// Returns the length in bytes of _this_ Element.
  int get eLength => buf.length;

  /// Returns _true_ if [vfLengthField] equals [kUndefinedLength].
  bool get hasUndefinedLength => vfLengthField == kUndefinedLength;

  /// Returns the actual length of the Value Field.
  int get vfLength => buf.length - vfOffset;

  /// Returns the Value Field bytes.
  BytesDicomLE get vfBytes => asBytes(vfOffset, vfLength);

  /// Returns the last Uint8 element in [vfBytes], if [vfBytes]
  /// is not empty; otherwise, returns _null_.
  int get vfBytesLast {
    final len = eLength;
    return (len == 0) ? null : getUint8(len - 1);
  }

  /// Returns the Value Field as a Uint8List.
  Uint8List get vfUint8List =>
      buf.buffer.asUint8List(offset + vfOffset, vfLength);

  /// Gets the DICOM Tag Code at [offset].
  int getCode(int offset) {
    final group = getUint16(offset);
    final elt = getUint16(offset + 2);
    return (group << 16) + elt;
  }

  int getShortVLF(int offset) => getUint16(offset);

  int getLongVLF(int offset) => getUint32(offset);

/*
  /// Returns a [ByteData] that is a copy of the specified region of _this_.
  static ByteData copyBDRegion(ByteData bd, int offset, int length) {
    final len = length ?? bd.lengthInBytes;
    final _nLength = len.isOdd ? len + 1 : length;
    final bdNew = ByteData(_nLength);
    for (var i = 0, j = offset; i < len; i++, j++)
      bdNew.setUint8(i, bd.getUint8(j));
    return bdNew;
  }
*/

  Uint8List _removePadding(Uint8List list) {
    if (list.isEmpty) return list;
    final lastIndex = list.length - 1;
    final c = list[lastIndex];
    return (c == _kSpace || c == _kNull)
        ? list.buffer.asUint8List(list.offsetInBytes, lastIndex)
        : list;
  }

  String _getString(int offset, int length, bool allowInvalid, bool noPadding,
      Charset charset) {
    var list = asUint8List(offset, length ?? buf.length);
    list = noPadding ? _removePadding(list) : list;
    return list.isEmpty ? '' : charset.decode(list, allowInvalid: true);
  }

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  String getString(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          Charset charset = utf8,
          bool removePadding = false}) =>
      _getString(
          offset, length ?? buf.length, allowInvalid, removePadding, charset);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
/*
  List<String> getStringList(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\',
      Charset charset}) {
    final s = getString(
        offset: offset,
        length: length,
        allowInvalid: allowInvalid,
        charset: charset);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }
*/

/*
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
*/

  String getAscii(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool noPadding = false}) =>
      _getString(offset, length, allowInvalid, noPadding, ascii);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _ASCII_, and then _split_ing the
  /// resulting [String] using the [separator]. Also allows the
  /// removal of a padding character.
  List<String> getAsciiList(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\',
      bool noPadding = false}) {
    final s = getAscii(
        offset: offset,
        length: length,
        allowInvalid: allowInvalid,
        noPadding: noPadding);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }

  /// Returns a [String] containing a _UTF-8_ decoding of the specified region.
  /// Also, allows the removal of padding characters.
  String getUtf8(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool noPadding = false}) =>
      _getString(offset, length, allowInvalid, noPadding, utf8);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getUtf8List(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\'}) {
    final s =
        getUtf8(offset: offset, length: length, allowInvalid: allowInvalid);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }

  /// Decoding the bytes in the specified region as _Latin1_ to _latin9_
  /// characters and returns them as a [String]. Also, allows
  /// the removal of padding characters.
  String getLatin(
          {int offset = 0,
          int length,
          bool allowInvalid = true,
          bool noPadding = false}) =>
      _getString(offset, length, allowInvalid, noPadding, latin1);

  /// Returns a [List<String>]. This is done by first decoding
  /// the specified region as _UTF-8_, and then _split_ing the
  /// resulting [String] using the [separator].
  List<String> getLatinList(
      {int offset = 0,
      int length,
      bool allowInvalid = true,
      String separator = '\\'}) {
    final s =
        getLatin(offset: offset, length: length, allowInvalid: allowInvalid);
    return (s.isEmpty) ? <String>[] : s.split(separator);
  }

  // **** Primitive Setters

  /// Returns the Tag Code from _this_.
  void setCode(int code) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
  }

  void setVRCode(int vrCode) {
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
  }

  void setShortVLF(int vlf) => setUint16(6, vlf);
  void setLongVLF(int vlf) => setUint32(8, vlf);

/*
  /// Write a short EVR header.
  void evrSetShortHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
    setUint16(6, vlf);
  }
*/

/*
  /// Write a short EVR header.
  void evrSetLongHeader(int code, int vrCode, int vlf) {
    setUint16(0, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint8(4, vrCode >> 8);
    setUint8(5, vrCode & 0xFF);
    // Note: The Uint16 field at offset 6 is already zero.
    setUint32(8, vlf);
  }
*/

/*
  /// Write a short EVR header.
  void ivrSetHeader(int offset, int code, int vlf) {
    setUint16(offset, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint32(4, vlf);
  }
*/

  // **** String Setters

  /// Ascii encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. If [padChar] is not
  /// _null_ and [s].length is odd, then [padChar] is written after
  /// the code units of [s] have been written.
  int setAscii(int start, String s,
          [int offset = 0, int length, int padChar = _kSpace]) =>
      setUint8List(start, cvt.utf8.encode(s), 0, null, padChar);

  // TODO: unit test
  /// UTF-8 encodes the specified range of [s] and then writes the
  /// code units to _this_ starting at [start]. Returns the offset
  /// of the last byte + 1.
  int setUtf8(int start, String s, [int padChar = _kSpace]) =>
      setUint8List(start, cvt.utf8.encode(s), 0, null, padChar);

  /// Converts the [String]s in [sList] into a [Uint8List].
  /// Then copies the bytes into _this_ starting at
  /// [start]. If [padChar] is not _null_ and the offset of the last
  /// byte written is odd, then [padChar] is written to _this_.
  /// Returns the number of bytes written.
  int setUtf8List(int start, List<String> sList, [int padChar]) =>
      setUtf8(start, sList.join('\\'), padChar);

  /// Moves bytes from [list] to _this_. If [list].[length] is odd adds [pad]
  /// as last byte. Returns the number of bytes written.
  int setUint8List(int start, List<int> list,
      [int offset = 0, int length, int pad = _kSpace]) {
    length ??= list.length;
    for (var i = offset, j = start; i < length; i++, j++) buf[j] = list[i];
    if (length.isOdd && pad != null) {
      setUint8(length + start, pad);
//      print('setUint8List: ${length + start}');
      return length + 1;
    }
    return length;
  }

  // **** String List Setters

  /// Writes the ASCII [String]s in [sList] to _this_ starting at
  /// [start]. If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  int setAsciiList(int start, List<String> sList, [int padChar = _kSpace]) =>
      _setLatinList(start, sList, padChar, 127);

  /// Writes the LATIN [String]s in [sList] to _this_ starting at
  /// [start]. If [padChar] is not _null_ and the final offset is odd,
  /// then [padChar] is written after the other elements have been written.
  /// Returns the number of bytes written.
  /// _Note_: All latin character sets are encoded as single 8-bit bytes.
  int setLatinList(int start, List<String> sList, [int padChar = _kSpace]) =>
      _setLatinList(start, sList, padChar, 255);

  /// Copy [String]s from [sList] into _this_ separated by backslash.
  /// If [padChar] is not equal to _null_ and last character position
  /// is odd, then add [padChar] at end.
  // Note: this only works for ascii or latin
  int _setLatinList(
    int start,
    List<String> sList,
    int padChar,
    int limit,
  ) {
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

  // Urgent: are these really needed??
  void writeInt8VF(List<int> vList) => setInt8List(vfOffset, vList);
  void writeInt16VF(List<int> vList) => setInt16List(vfOffset, vList);
  void writeInt32VF(List<int> vList) => setInt32List(vfOffset, vList);
  void writeInt64VF(List<int> vList) => setInt64List(vfOffset, vList);

  void writeUint8VF(List<int> vList) =>
      setUint8List(vfOffset, vList, 0, vList.length, _kNull);
  void writeUint16VF(List<int> vList) => setUint16List(vfOffset, vList);
  void writeUint32VF(List<int> vList) => setUint32List(vfOffset, vList);
  void writeUint64VF(List<int> vList) => setUint64List(vfOffset, vList);

  void writeFloat32VF(List<double> vList) => setFloat32List(vfOffset, vList);
  void writeFloat64VF(List<double> vList) => setFloat64List(vfOffset, vList);

  void writeAsciiVF(List<String> vList, [int pad = _kSpace]) =>
      setAsciiList(vfOffset, vList, pad);
  void writeUtf8VF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8List(vfOffset, vList, pad);
  void writeTextVF(List<String> vList, [int pad = _kSpace]) =>
      setUtf8(vfOffset, vList[0], pad);

  int writeAsciiVFFast(int offset, List<String> vList, [int padChar]) {
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
// Urgent remove above if not needed

/*
  // Allows the removal of padding characters.
  Uint8List asUint8List([int offset = 0, int length, int padChar = 0]) {
    assert(padChar == null || padChar == _kSpace || padChar == _kNull);
    final len = (length ??= buf.length) - offset;
    return buf.buffer.asUint8List(buf.offsetInBytes + offset, len);
  }
*/

  @override
  String toString() => '$runtimeType: offset: $offset length: $length';

  static const int _kGroupOffset = 0;
  static const int _kEltOffset = 0;
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
