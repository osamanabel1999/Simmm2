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

dynamic calculateLeftDownwindPosition(
  double thresholdX, // إحداثيات بداية المدرج X (مثلاً بداية 05)
  double thresholdZ, // إحداثيات بداية المدرج Z
  double runwayHeading, // اتجاه المدرج (مثلاً 045)
  double forwardDistanceMeters, // المسافة اللي هتطلعها "لقدام" ناحية مدرج 23
  double offsetDistanceMeters, // العرض (البعد الجانبي عن المدرج)
) {
  // 1. تحويل الزاوية لراديان
  double runwayRad = runwayHeading * (math.pi / 180.0);

  // 2. المرحلة الأولى: التحرك للأمام (في اتجاه الـ Runway Heading)
  // عشان نطلع قدام في إكسبلين: بنجمع Sin للـ X ونطرح Cos من الـ Z
  // ده عكس الـ Backward اللي كان بيطرح Sin ويجمع Cos
  double centerX = thresholdX + (forwardDistanceMeters * math.sin(runwayRad));
  double centerZ = thresholdZ - (forwardDistanceMeters * math.cos(runwayRad));

  // 3. المرحلة الثانية: الإزاحة الجانبية (The Offset) لجهة اليسار
  // بما أنه Left Downwind، الطيارة بتكون "شمال" المدرج بالنسبة للطيار
  // بنطرح Cos من الـ X ونطرح Sin من الـ Z عشان نضمن مكانها الصح
  double newX = centerX - (offsetDistanceMeters * math.cos(runwayRad));
  double newZ = centerZ - (offsetDistanceMeters * math.sin(runwayRad));

  // 4. حساب اتجاه الطائرة (Heading)
  // بما إنك في Downwind، فإنت طاير عكس اتجاه الهبوط تماماً
  double aircraftHeading = (runwayHeading + 180) % 360;
  if (aircraftHeading < 0) aircraftHeading += 360;

  // 5. الارتفاع القياسي (1000 قدم = 305 متر AGL)
  double suggestedAltitudeAGL = 305.0;

  return {
    'new_x': newX,
    'new_z': newZ,
    'aircraft_heading': aircraftHeading,
    'suggested_altitude_agl': suggestedAltitudeAGL,
  };
}
