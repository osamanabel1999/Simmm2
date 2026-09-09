import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';

bool? isValidLocalIP(String ipAddress) {
  bool isValidLocalIP(String ipAddress) {
    // الكود ده بيفلتر الأرقام ويتأكد إنها على صيغة شبكة واي فاي محلية
    RegExp regExp = RegExp(
        r'^(192\.168|10|172\.(1[6-9]|2[0-9]|3[0-1]))\.\d{1,3}\.\d{1,3}$');
    return regExp.hasMatch(ipAddress);
  }
}
