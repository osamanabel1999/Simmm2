// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'dart:math' as math;

dynamic calculateBaseLegPosition(
  double thresholdX, // إحداثيات بداية المدرج X
  double thresholdZ, // إحداثيات بداية المدرج Z
  double runwayHeading, // اتجاه المدرج (مثلاً 045)
  double finalDistanceMeters, // مسافة الفاينل (بعد المدرج عن نقطة الالتفاف)
  double offsetDistanceMeters, // مسافة البعد العرضي عن المدرج
  bool isLeftBase, // هل هو Left Base؟
) {
  // 1. تحويل الزوايا لراديان
  double runwayRad = runwayHeading * (math.pi / 180.0);

  // 2. التحرك للخلف من بداية المدرج (Extended Centerline)
  // نفس معادلتك السابقة اللي بتطرح Sin لـ X وتجمع Cos لـ Z
  double centerX = thresholdX - (finalDistanceMeters * math.sin(runwayRad));
  double centerZ = thresholdZ + (finalDistanceMeters * math.cos(runwayRad));

  // 3. التحرك عرضياً للوصول لموقع الـ Base
  // لو Left Base: الطيارة على يمين المدرج (بالنسبة للي باصص للمدرج)، يعني بنزود 90 درجة
  // لو Right Base: الطيارة على شمال المدرج، يعني بنطرح 90 درجة
  double newX, newZ, aircraftHeading;

  if (isLeftBase) {
    // الطيارة هتكون في الـ Base باصة ناحية الشمال عشان تدخل الفاينل
    aircraftHeading = (runwayHeading - 90) % 360;
    if (aircraftHeading < 0) aircraftHeading += 360;

    // الإزاحة العرضية (Perpendicular Offset)
    newX = centerX + (offsetDistanceMeters * math.cos(runwayRad));
    newZ = centerZ + (offsetDistanceMeters * math.sin(runwayRad));
  } else {
    // الطيارة هتكون في الـ Base باصة ناحية اليمين عشان تدخل الفاينل
    aircraftHeading = (runwayHeading + 90) % 360;

    // الإزاحة العرضية العكسية
    newX = centerX - (offsetDistanceMeters * math.cos(runwayRad));
    newZ = centerZ - (offsetDistanceMeters * math.sin(runwayRad));
  }

  // 4. حساب الارتفاع المقترح (بناءً على 1000 قدم Standard AGL)
  // الـ 1000 قدم تساوي تقريباً 305 متر
  double suggestedAltitudeAGL = 305.0;

  return {
    'new_x': newX,
    'new_z': newZ,
    'aircraft_heading': aircraftHeading,
    'suggested_altitude_agl': suggestedAltitudeAGL,
    'debug_center_x': centerX,
    'debug_center_z': centerZ
  };
}
