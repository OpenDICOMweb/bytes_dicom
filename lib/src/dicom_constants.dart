//  Copyright (c) 2016, 2017, 2018,
//  Poplar Hill Informatics and the American College of Radiology
//  All rights reserved.
//  Use of this source code is governed by the open source license
//  that can be found in the odw/LICENSE file.
//  Primary Author: Jim Philbin <jfphilbin@gmail.edu>
//  See the AUTHORS file for other contributors.
//

/// The maximum length, in bytes, of a "short" (16-bit) Value Field.
///
/// Notes:
///     1. Short Value Fields may not have an Undefined Length
///     2. All Value Fields must contain an even number of bytes.
const int kMaxShortVFLength = 0xFFFF;


/// This is the values of a DICOM Undefined Length from a 32-bit
/// Value Field Length.
const int kUndefinedLength = 0xFFFFFFFF;

/// Returns _true_ if [i] is the DICOM undefined length value (0xFFFFFFFF).
bool hasUndefinedLength(int i) => i == kUndefinedLength;

/// The maximum length, in bytes, of a "long" (32-bit) Value Field.
///
/// Note: the values is `[kUndefinedLength] - 1` because the maximum values
/// (0xFFFFFFFF) is used to denote a Value Field with Undefined Length.
const int kMaxLongVFLength = kUndefinedLength - 1;

/// The values appended to odd length UID Value Fields to make them even length.
const int kUidPaddingChar = 0; // equal to cvt.ascii.kNull;

/// The values appended to odd length [String] Value Fields to make them
/// even length.
const int kStringPaddingChar = 32; // Equal to cvt.ascii.kSpace;

/// The values appended to odd length Uint8 Value Fields (OB, UN) to make
/// them even length.
const int kUint8PaddingValue = 0;


