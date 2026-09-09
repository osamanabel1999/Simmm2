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
import 'package:flutter/material.dart'; // تم تصحيح هذا السطر
import 'dart:math' as math;

dynamic calculateRightDownwindPosition(
  double thresholdX, // إحداثيات بداية المدرج X
  double thresholdZ, // إحداثيات بداية المدرج Z
  double runwayHeading, // اتجاه المدرج (مثلاً 050)
  double forwardDistanceMeters, // المسافة لقدام ناحية نهاية الممر
  double offsetDistanceMeters, // العرض (البعد الجانبي عن المدرج)
) {
  // 1. تحويل الزاوية لراديان
  double runwayRad = runwayHeading * (math.pi / 180.0);

  // 2. المرحلة الأولى: التحرك للأمام (Forward)
  // X بنجمع Sin والـ Z بنطرح Cos عشان تطلع قدام المدرج
  double centerX = thresholdX + (forwardDistanceMeters * math.sin(runwayRad));
  double centerZ = thresholdZ - (forwardDistanceMeters * math.cos(runwayRad));

  // 3. المرحلة الثانية: الإزاحة الجانبية (Offset) لجهة اليمين جغرافياً
  // بنجمع (+) في الـ X والـ Z عشان تروح "يمين" الممر
  double newX = centerX + (offsetDistanceMeters * math.cos(runwayRad));
  double newZ = centerZ + (offsetDistanceMeters * math.sin(runwayRad));

  // 4. حساب اتجاه الطائرة (Heading)
  // عكس اتجاه المدرج تماماً (Downwind)
  double aircraftHeading = (runwayHeading + 180) % 360;
  if (aircraftHeading < 0) aircraftHeading += 360;

  // 5. الارتفاع القياسي (1000 قدم)
  double suggestedAltitudeAGL = 305.0;

  return {
    'new_x': newX,
    'new_z': newZ,
    'aircraft_heading': aircraftHeading,
    'suggested_altitude_agl': suggestedAltitudeAGL,
  };
}
