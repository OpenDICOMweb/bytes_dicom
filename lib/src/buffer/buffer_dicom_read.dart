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

import 'package:bytes/bytes_buffer.dart';
import 'package:bytes_dicom/bytes_dicom.dart';
import 'package:bytes_dicom/src/vr/vr_base.dart';

const _kNull = 0;
const _kSpace = 32;

/// A [BytesBuffer] for reading DicomBytes from [BytesDicomLE].
/// EVR and IVR are taken care of by the underlying [BytesDicomLE].
class DicomReadBuffer extends BytesBufferBase with ReadBufferMixin {
  @override
  BytesDicom bytes;
  @override
  int rIndex;
  @override
  int get wIndex => bytes.length;

  /// Constructor
  DicomReadBuffer(BytesDicom bytes, [int offset = 0, int length])
      : bytes =
            BytesDicom.typedDataView(bytes.buf, offset, length, bytes.endian),
        rIndex = 0;

  /// Returns the DICOM Tag Code for _this_.
  int get code => bytes.getCode(rIndex);

  /// Returns the VR Code for _this_.
  int get vrCode => bytes.getCode(rIndex);

  /// Returns the VR Index for _this_.
  int get vrIndex => vrIndexByCode8Bit[vrCode];

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
    final code = bytes.getCode(rIndex);
    rIndex += 4;
    return code;
  }

  /// Read the VR .
  int readVRCode() {
    assert(rIndex.isEven && rHasRemaining(4), '@$rIndex : $readRemaining');
    final vrCode = bytes.getVRCode(rIndex);
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

  /// Gets the Uint32 value at [rIndex], compares it with [target] and
  /// returns the result.
  bool getUint32AndCompare(int target) => target == bytes.getUint32(rIndex);

  /// Read a String Value Field as ASCII.
  @override
  String readAscii(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final s = bytes.getAscii(rIndex, _getLength(length, noPadding));
    rIndex += length;
    return s;
  }

  /// Read a String Value Field as Latin(n).
  @override
  String readLatin(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final s = bytes.getLatin(rIndex, _getLength(length, noPadding));
    rIndex += length;
    return s;
  }

  /// Read a String Value Field as UTF-8.
  @override
  String readUtf8(int length,
      {bool allowInvalid = true, bool noPadding = true}) {
    final s = bytes.getUtf8(rIndex, _getLength(length, noPadding));
    rIndex += length;
    return s;
  }

  /// Read a String Value Field.
  @override
  String readString(int length,
          {bool allowInvalid = false, bool noPadding = false}) =>
      readUtf8(length, noPadding: noPadding);

  // Urgent: decide if DicomReadBuffer should handle padding!
  int _getLength(int length, bool noPadding) {
    if (length < 0) throw ArgumentError('length must be non-negative');
    if (length == 0 || noPadding == true) return length;
    final c = bytes[rIndex + (length - 1)];
    return c == _kSpace || c == _kNull ? length - 1 : length;
  }
}
