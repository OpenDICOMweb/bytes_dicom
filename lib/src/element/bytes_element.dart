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
import 'package:bytes_dicom/src/element/element_interface.dart';
import 'package:bytes_dicom/src/element/bytes_element_mixin.dart';
import 'package:bytes_dicom/src/to_string_mixin.dart';
import 'package:constants/constants.dart';

/// The format of the [BytesElement].
enum BytesElementType {
  /// Little Endian Short Explicit VR
  leShortEvr,

  /// Little Endian Long Explicit VR
  leLongEvr,

  /// Big Endian Short Explicit VR
  beShortEvr,

  /// Big Endian Long Explicit VR
  beLongEvr,

  /// LE Endian Implicit VR
  leIvr
}

/// A read-only implementation of DICOM Elements based on Bytes.
///
/// [BytesElement] have the following characteristics:
///     - they are read-only
///     - they _never_ have padding characters at the end of the Value Field,
///       which in turn means they may have odd length Value Fields
///     -
abstract class BytesElement extends Bytes
    with BytesElementMixin, ToStringMixin {
  /// Returns true if _this_ has Explicit Value Representation (EVR).
  bool get isEvr;

  @override
  int get code;

  /// The integer value in the VR field of _this_.
  @override
  int get vrCode;

  /// The VR index of  _this_.
  int get vrIndex;

  /// The VR identifier of  _this_.
  String get vrId;

  /// The offset to the [vfLength] field.
  @override
  int get vfLengthOffset;

  /// The value of the Value Field length field.
  @override
  int get vfLengthField;

  /// The offset in _this_ to the Value Field.
  @override
  int get vfOffset;

  /// The actual number of bytes in the Value Field, i.e. _not_
  /// the value in the Value Field Length field.
  @override
  int get vfLength;

  /// Returns the last byte of the Value Field of _this_.
  @override
  int get vfBytesLast;

  /// Returns the Value Field of _this_ as [Bytes].
  @override
  Bytes get vfBytes;

  @override
  String toString() =>
      '$runtimeType($length) ${dcm(code)} $vrId ($vfLength) $vfBytes';

  // **** End of interface ****

  /// Creates a [BytesElement] of [type].
  static BytesElement make(
      int code, int vrCode, Bytes vfBytes, BytesElementType type) {
    switch (type) {
      case BytesElementType.leShortEvr:
        return BytesLEShortEvr.element(code, vrCode, vfBytes);
      case BytesElementType.leLongEvr:
        return BytesLELongEvr.element(code, vrCode, vfBytes);
      case BytesElementType.beShortEvr:
        return BytesBEShortEvr.element(code, vrCode, vfBytes);
      case BytesElementType.beLongEvr:
        return BytesBELongEvr.element(code, vrCode, vfBytes);
      case BytesElementType.leIvr:
        return BytesIvr.element(code, vfBytes);
      default:
        throw ArgumentError();
    }
  }
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class BytesLEShortEvr extends BytesElement
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        BytesDicomGetMixin,
        BytesDicomSetMixin,
        BytesElementMixin,
        EvrMixin,
        EvrShortBytes
    implements ElementInterface {
  @override
  Uint8List buf;

  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLEShortEvr(this.buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLEShortEvr.empty(int length) : buf = Uint8List(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : buf = bytes.getUint8List(offset, length);

  /// Creates a new [BytesLEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesLEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : buf = td.buffer.asUint8List(offset, length);

  /// Returns an [BytesLEShortEvr] created from a view of [bytes].
  factory BytesLEShortEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesLEShortEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesLEShortEvr] with an empty Value Field.
  factory BytesLEShortEvr.header(int code, int vfLength, int vrCode) {
    assert(vfLength.isEven);
    final e = BytesLEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength);
    return e;
  }

  /// Returns an [BytesLEShortEvr] created from a view
  /// of a Value Field ([vfBytes]).
  factory BytesLEShortEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesLEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class BytesLELongEvr extends BytesElement
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        BytesElementMixin,
        BytesDicomGetMixin,
        BytesDicomSetMixin,
        EvrMixin,
        EvrLongBytes
    implements ElementInterface {
  @override
  Uint8List buf;

  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesLELongEvr(this.buf);

  /// Returns an empty [BytesLEShortEvr] with length [length].
  BytesLELongEvr.empty(int length) : buf = Uint8List(length);

  /// Returns an [BytesLEShortEvr] created from [bytes].
  BytesLELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : buf = bytes.getUint8List(offset, length);

  /// Creates a new [BytesLELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesLELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : buf = td.buffer.asUint8List(offset, length);

  /// Returns an [BytesLEShortEvr] created from a view of [bytes].
  factory BytesLELongEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesLELongEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns a [BytesLELongEvr] with a header, but with an empty Value Field.
  factory BytesLELongEvr.header(int code, int vfLength, int vrCode) {
    assert(vfLength.isEven);
    final e = BytesLELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength);
    return e;
  }

  /// Creates a [BytesLELongEvr].
  factory BytesLELongEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesLELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength)
      ..setUint8List(kVFOffset, vfBytes.buf);
    print(e);
    return e;
  }

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}

/// Explicit Little Endian Element with short (16-bit) Value Field Length.
class BytesBEShortEvr extends BytesElement
    with
        BigEndianGetMixin,
        BigEndianSetMixin,
        BytesDicomGetMixin,
        BytesDicomSetMixin,
        BytesElementMixin,
        EvrMixin,
        EvrShortBytes
    implements ElementInterface {
  @override
  Uint8List buf;

  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBEShortEvr(this.buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBEShortEvr.empty(int length) : buf = Uint8List(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBEShortEvr.from(Bytes bytes, [int offset = 0, int length])
      : buf = bytes.getUint8List(offset, length);

  /// Creates a new [BytesBEShortEvr] from a [TypedData] containing
  /// the specified region.
  BytesBEShortEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : buf = td.buffer.asUint8List(offset, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesBEShortEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesBEShortEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesBEShortEvr] with an empty Value Field.
  factory BytesBEShortEvr.header(int code, int vfLength, int vrCode) {
    assert(vfLength.isEven);
    final e = BytesBEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength);
    return e;
  }

  /// Returns an [BytesBEShortEvr] created from a view
  /// of a Value Field ([vfBytes]).
  factory BytesBEShortEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesBEShortEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// The Value Field offset.
  static const int kVFOffset = 8;
}

/// Explicit Little Endian [Bytes] with long (32-bit) Value Field Length.
class BytesBELongEvr extends BytesElement
    with
        BigEndianGetMixin,
        BigEndianSetMixin,
        BytesDicomGetMixin,
        BytesDicomSetMixin,
        BytesElementMixin,
        EvrMixin,
        EvrLongBytes
    implements ElementInterface {
  @override
  Uint8List buf;

  /// Returns an [BytesLEShortEvr] containing [buf].
  BytesBELongEvr(this.buf);

  /// Returns an empty [BytesBEShortEvr] with length [length].
  BytesBELongEvr.empty(int length) : buf = Uint8List(length);

  /// Returns an [BytesBEShortEvr] created from [bytes].
  BytesBELongEvr.from(Bytes bytes, [int offset = 0, int length])
      : buf = bytes.getUint8List(offset, length);

  /// Creates a new [BytesBELongEvr] from a [TypedData] containing
  /// the specified region.
  BytesBELongEvr.typedDataView(TypedData td, [int offset = 0, int length])
      : buf = td.buffer.asUint8List(offset, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesBELongEvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesBELongEvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesBELongEvr] with an empty Value Field.
  factory BytesBELongEvr.header(int code, int vfLength, int vrCode) {
    assert(vfLength.isEven);
    final e = BytesBELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength);
    return e;
  }

  /// Creates an [BytesBELongEvr].
  factory BytesBELongEvr.element(int code, int vrCode, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    final e = BytesBELongEvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vrCode, vfLength)
      ..setUint8List(kVFOffset, vfBytes.buf);
    return e;
  }

  /// The offset to the Value Field.
  static const int kVFOffset = 12;
}

/// Implicit Little Endian [Bytes] with short (16-bit) Value Field Length.
class BytesIvr extends BytesElement
    with
        LittleEndianGetMixin,
        LittleEndianSetMixin,
        BytesDicomGetMixin,
        BytesDicomSetMixin,
        BytesElementMixin
    implements ElementInterface {
  @override
  Uint8List buf;

  /// Returns an [BytesIvr] containing [buf].
  BytesIvr(this.buf);

  /// Creates an empty [BytesIvr] of [length].
  BytesIvr.empty(int length) : buf = Uint8List(length);

  /// Create an [BytesIvr] Element from [Bytes].
  BytesIvr.from(Bytes bytes, int start, int length)
      : buf = bytes.getUint8List(start, length);

  /// Create an [BytesIvr] Element from a view of [Bytes].
  BytesIvr.typedDataView(TypedData td, [int start = 0, int length])
      : buf = td.buffer.asUint8List(start, length);

  /// Returns an [BytesBEShortEvr] created from a view of [bytes].
  factory BytesIvr.view(Bytes bytes, [int offset = 0, int length]) =>
      BytesIvr.typedDataView(bytes.asUint8List(offset, length));

  /// Returns an [BytesIvr] with an empty Value Field.
  factory BytesIvr.header(int code, int vfLength) {
    assert(vfLength.isEven);
    return BytesIvr.empty(kVFOffset + vfLength)..setHeader(code, vfLength);
  }

  /// Creates an [BytesIvr].
  factory BytesIvr.element(int code, Bytes vfBytes) {
    final vfLength = vfBytes.length;
    assert(vfLength.isEven);
    return BytesIvr.empty(kVFOffset + vfLength)
      ..setHeader(code, vfLength)
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
  /// Write an IVR header.
  void setHeader(int code, int vfLength) {
    setUint16(offset, code >> 16);
    setUint16(2, code & 0xFFFF);
    setUint32(4, vfLength);
  }

  /// The offset of the Value Field in an IVR Element
  static const int kVFOffset = 8;
}

/*
// Urgent: unit test
/// Returns a [Bytes] containing the Base64 decoding of [s].
BytesElement _stringToBytes(
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
*/
