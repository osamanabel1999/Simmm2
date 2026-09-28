// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

Future<dynamic> calculateVelocityVectorsXPlane(
  double? targetSpeedKnots,
  double? headingDegrees,
) async {
  // حماية من القيم الفارغة: لو مفيش مدخلات يرجع أصفار
  if (targetSpeedKnots == null || headingDegrees == null) {
    return {
      'vx': 0.0,
      'vy': 0.0,
      'vz': 0.0,
    };
  }

  // 1. تحويل السرعة من عقدة (Knots) إلى متر/ثانية
  final double speedMs = targetSpeedKnots * 0.514444;

  // 2. تحويل زاوية الاتجاه من درجات إلى راديان
  final double headingRad = headingDegrees * (math.pi / 180.0);

  // 3. حساب متجهات الاندفاع على المحاور
  final double vx = speedMs * math.sin(headingRad);
  final double vy = 0.0; // طيران أفقي مستقر
  final double vz =
      -speedMs * math.cos(headingRad); // سالب لأن الشمال في X-Plane سالب

  // إرجاع القيم الثلاثة
  return {
    'vx': vx,
    'vy': vy,
    'vz': vz,
  };
}
