// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
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
import 'package:bytes/bytes_buffer.dart';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const _kNull = 0;
const _kSpace = 32;

/// A [BytesBuffer] for reading DicomBytes from [BytesDicomLE].
/// EVR and IVR are taken care of by the underlying [BytesDicomLE].
class DicomReadBuffer extends ReadBuffer {
  /// Constructor
  DicomReadBuffer(Bytes bytes, [int offset = 0, int length])
      : super(bytes, offset, length);

  @override
  Endian get endian => bytes.endian;

  /// Returns the DICOM Tag Code for _this_.
  int get code {
    final group = getUint16();
    final elt = getUint16();
    return (group << 16) + elt;
  }

  /// Returns the VR Code for _this_.
  int get vrCode => (getUint8() << 8) + getUint8();

  /// Returns the VR Index for _this_.
  int get vrIndex => vrIndexByCode8Bit[vrCode];

  /// Returns the DICOM Tag Code at [offset].
  int getCode([int offset = 0]) =>
      (bytes.getUint16(offset) << 16) + bytes.getUint16(offset + 2);

  //Urgent move below this to DicomReadBuffer
  /// The underlying [ByteData]
  @override
  ByteData get bd => isClosed ? null : bytes.asByteData();

  /// Returns _true_ if this reader isClosed and it [isNotEmpty].
  bool get hadTrailingBytes {
    if (_isClosed) return isEmpty;
    return false;
  }

  bool _hadTrailingZeros = false;

  bool _isClosed = false;

  /// Returns _true_ if _this_ is no longer writable.
  bool get isClosed => _isClosed != null;

  /// Close _this_, i.e. make it not readable.
  ByteData close() {
    if (hadTrailingBytes)
      _hadTrailingZeros = _checkAllZeros(wIndex, bytes.length);
    final bd = bytes.asByteData(0, wIndex);
    _isClosed = true;
    return bd;
  }

  /// Returns _true_ if there are zeros in buffer after last read.
  bool get hadTrailingZeros => _hadTrailingZeros ?? false;

/* Urgent remove after all TODOs complete
  ByteData _rClose() {
    final view = asByteData(0, rIndex);
    if (isNotEmpty) {
      rError('End of Data with rIndex($rIndex) != '
          'length(${view.lengthInBytes})');
      _hadTrailingZeros = _checkAllZeros(rIndex, wIndex);
    }
    _isClosed = true;
    return view;
  }
*/

  bool _checkAllZeros(int start, int end) {
    for (var i = start; i < end; i++) if (bytes.getUint8(i) != 0) return false;
    return true;
  }

  /// Resets [rIndex] to 0.
  void get reset {
    rIndex = 0;
    _isClosed = false;
    _hadTrailingZeros = false;
  }

  /// Reads the DICOM Tag Code at the current [rIndex], and advances
  /// the [rIndex] by four _bytes.
  int readCode() {
    assert(rIndex.isEven && rHasRemaining(8), '@$rIndex : $readRemaining');
    final code = getCode(rIndex);
    rIndex += 4;
    return code;
  }

  /// Read the VR .
  int readVRCode() {
    assert(rIndex.isEven && rHasRemaining(4), '@$rIndex : $readRemaining');
    final vrCode = (bytes.getUint8(rIndex) << 8) + bytes.getUint8(rIndex + 1);
    rIndex += 2;
    return vrCode;
  }

  /// Returns the VR Index at the current [rIndex].
  int readVRIndex() => vrIndexFromCode(readVRCode());

  /// Read a short Value Field Length.
  int readShortVLF() {
    assert(rIndex.isEven && rHasRemaining(2), '@$rIndex : $readRemaining');
    final vlf = bytes.getUint16(rIndex);
    rIndex += 2;
    return vlf;
  }

  /// Read a short Value Field Length.
  int readLongVLF() {
    assert(rIndex.isEven && rHasRemaining(4), '@$rIndex : $readRemaining');
    final vlf = bytes.getUint32(rIndex);
    rIndex += 4;
    return vlf;
  }

  /// Read a String Value Field.
  @override
  String readAscii(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final len = noPadding ? _getLength(length) : length;
    final s =
        bytes.getAscii(offset: rIndex, length: len, allowInvalid: allowInvalid);
    rIndex += length;
    return s;
  }

  /// Read a String Value Field.
  @override
  String readLatin(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final len = noPadding ? _getLength(length) : length;
    final s =
        bytes.getLatin(offset: rIndex, length: len, allowInvalid: allowInvalid);
    rIndex += length;
    return s;
  }

  /// Read a String Value Field.
  @override
  String readUtf8(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final len = noPadding ? _getLength(length) : length;
    final s =
        bytes.getUtf8(offset: rIndex, length: len, allowInvalid: allowInvalid);
    rIndex += length;
    return s;
  }

  /// Read a String Value Field.
  @override
  String readString(int length,
          {bool allowInvalid = false, bool noPadding = false}) =>
      readUtf8(length, allowInvalid: allowInvalid, noPadding: noPadding);

  int _getLength(int length) {
    assert(rIndex.isEven && rHasRemaining(length), '@$rIndex : $readRemaining');
    if (length <= 0) throw ArgumentError();
    final char = bytes[rIndex + (length - 1)];
    return char == _kSpace || char == _kNull ? length - 1 : length;
  }
}
