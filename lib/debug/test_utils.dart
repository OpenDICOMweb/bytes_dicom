// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Original author: Jim Philbin <jfphilbin@gmail.edu> -
// See the AUTHORS file for other contributors.
//
import 'dart:typed_data';

import 'package:bytes_dicom/bytes_dicom.dart';

// ignore: public_member_api_docs

DicomReadBuffer getReadBuffer(TypedData td, [String type = 'LE']) {
  switch (type) {
    case 'LE': return getReadBufferLE(td);
    case 'BE': return getReadBufferBE(td);
    default: throw ArgumentError();
    }
}

DicomReadBuffer getReadBufferLE(TypedData td) {
//  print('vList1 $td');
  final bytes = BytesDicomLE.typedDataView(td);
//  print('bytes: $bytes');
  final rBuf = DicomReadBuffer(bytes);
//  print('rBuf: $rBuf');
  return rBuf;
}

DicomReadBuffer getReadBufferBE(TypedData td) {
//  print('td: $td');
  final bytes = BytesDicomBE.typedDataView(td);
//  print('bytes: $bytes');
  final rBuf = DicomReadBuffer(bytes);
//  print('rBuf: $rBuf');
  return rBuf;
}

DicomWriteBuffer getWriteBuffer(TypedData td, [String type = 'LE']) {
  switch (type) {
    case 'LE': return getWriteBufferLE(td);
    case 'BE': return getWriteBufferBE(td);
    default: throw ArgumentError();
  }
}

DicomWriteBuffer getWriteBufferLE(TypedData td) {
//  print('vList1 $td');
  final bytes = BytesDicomLE.typedDataView(td);
//  print('bytes: $bytes');
  final rBuf = DicomWriteBuffer(bytes);
//  print('rBuf: $rBuf');
  return rBuf;
}

DicomWriteBuffer getWriteBufferBE(TypedData td) {
//  print('td: $td');
  final bytes = BytesDicomBE.typedDataView(td);
//  print('bytes: $bytes');
  final rBuf = DicomWriteBuffer(bytes);
//  print('rBuf: $rBuf');
  return rBuf;
}

