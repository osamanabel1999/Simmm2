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

bool isAnyTelemetryActive(
  String? speed,
  String? altitude,
  double? heading,
  double? latitude,
  double? longitude,
) {
  double speedVal = double.tryParse(speed ?? '') ?? 0.0;
  double altVal = double.tryParse(altitude ?? '') ?? 0.0;
  double headVal = heading ?? 0.0;
  double latVal = latitude ?? 0.0;
  double longVal = longitude ?? 0.0;

  return speedVal > 0 || altVal > 0 || headVal > 0 || latVal > 0 || longVal > 0;
}
