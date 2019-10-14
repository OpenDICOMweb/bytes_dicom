//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//
import 'package:constants/constants.dart';

mixin ToStringMixin {
  int get code;
  int get vrCode;
  int get vfLengthField;
  int get vfLength;

  @override
  String toString() {
    final vrIndex = vrIndexFromCode(vrCode);
    final vrId = vrIdFromIndex(vrIndex);
    final vlf = vfLengthField;
    return '$runtimeType ${_dcm(code)} $vrId($vrIndex, ${_hex(vrCode, 4)}) '
        'vlf($vlf, ${_hex(vlf, 8)}) vfl($vfLength) ${super.toString()}';
  }

  /// Returns a [String] in DICOM Tag Code format, e.g. (gggg,eeee),
  /// corresponding to the Tag [code].
  String _dcm(int code) {
    assert(code >= 0 && code <= 0xFFFFFFFF, 'code: $code');
    return '(${_hex(code >> 16, 4)},${_hex(code & 0xFFFF, 4)})';
  }

  String _hex(int n, int width) => '${n.toRadixString(16).padLeft(width, '0')}';
}
