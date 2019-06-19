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

/* TODO delete is no usages
  /// Creates a new [Bytes] from a [TypedData] containing the specified
  /// region (from offset of length) and [endian]ness.
  /// [endian] defaults to [Endian.little].
  factory BytesDicom.typedDataView(TypedData td,
          [int offset = 0, int length, Endian endian = Endian.little]) =>
      (endian == Endian.little)
          ? BytesDicomLE.typedDataView(td, offset, length)
          : BytesDicomBE.typedDataView(td, offset, length);
*/

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

  /// Gets the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) {
    final group = getUint16(offset);
    final elt = getUint16(offset + 2);
    return (group << 16) + elt;
  }

  /// Sets the _code_ of _this_ to [code].
  void setCode(int offset, int code) {
    setUint16(offset, code >> 16);
    setUint16(offset + 2, code & 0xFFFF);
  }

  /// Returns the value in the VR field of _this_.
  void getVRCode([int offset = 0]) =>
      getUint8(offset + 4) << 8 + getUint8(offset + 5);

  /// Sets the VR field of _this_ to [vrCode].
  void setVRCode(int offset, int vrCode) {
    setUint8(offset, vrCode >> 8);
    setUint8(offset + 1, vrCode & 0xFF);
  }

  /// Returns the value of the Value Field Length for a short Element.
  int getShortVLF([int offset = 6]) => getUint16(offset);

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setShortVLF(int offset, int vlf) => setUint16(offset, vlf);

  /// Returns the value of the Value Field Length for a long Element.
  int getLongVLF([int offset = 8]) => getUint32(offset);

  /// Sets the Value Field Length field for a short Element to [vlf].
  void setLongVLF(int offset, int vlf) => setUint32(offset, vlf);

  /// Returns the value of the Value Field for a short Element.
  Uint8List getShortValueField([int offset = 8, int length]) =>
      getUint8List(offset, length ?? buf.length);

  /// Sets the Value Field for a short Element to [vf].
  void setShortValueField(Uint8List vf) => _setValueField(vf, 8);

  /// Returns the value of the Value Field for a long Element.
  Uint8List getLongValueField([int offset = 12, int length]) =>
      getUint8List(offset, length ??= buf.length);

  /// Sets the Value Field L for a long Element to [vf].
  void setLongValueField(Uint8List vf) => _setValueField(vf, 12);

  /// Sets the Value Field Length field for an Element to [vf].
  void _setValueField(Uint8List vf, int vfOffset) {
    for (var i = 0, j = vfOffset; i < vf.length; i++, j++) buf[j] = vf[i];
  }

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

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class BytesLEShortEvr extends BytesDicomLE
    with EvrShortBytes, BytesDicomMixin, EvrMixin, ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLEShortEvr(Uint8List buf) : super(buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLEShortEvr.empty(int length) : super.empty(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [BytesLEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesLEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length);

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
class BytesLELongEvr extends BytesDicomLE
    with EvrLongBytes, BytesDicomMixin, EvrMixin, ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLELongEvr(Uint8List buf) : super(buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLELongEvr.empty(int length) : super.empty(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [BytesLELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesLELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length);

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
class BytesBEShortEvr extends BytesDicomBE
    with EvrShortBytes, BytesDicomMixin, EvrMixin, ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBEShortEvr(Uint8List buf) : super(buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBEShortEvr.empty(int length) : super.empty(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [BytesBEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesBEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length);

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
class BytesBELongEvr extends BytesDicomBE
    with EvrLongBytes, BytesDicomMixin, EvrMixin, ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBELongEvr(Uint8List buf) : super(buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBELongEvr.empty(int length) : super.empty(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : super.from(bytes, offset, length);

  /// Creates a new [BytesBELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesBELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : super.typedDataView(td, offset, length);

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
class BytesIvr extends BytesDicomLE
    with BytesDicomMixin, ToStringMixin
    implements ElementInterface {
  /// Returns an [BytesIvr] containing [buf].
  BytesIvr(Uint8List buf) : super(buf);

  /// Creates an empty [BytesIvr] of [length].
  BytesIvr.empty(int length) : super.empty(length);

  /// Create an [BytesIvr] Element from [Bytes].
  BytesIvr.from(Bytes bytes, int start, int length)
      : super.from(bytes, start, length);

  /// Create an [BytesIvr] Element from a view of [Bytes].
  BytesIvr.typedDataView(TypedData td, [int start = 0, int length])
      : super.typedDataView(td, start, length);

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
