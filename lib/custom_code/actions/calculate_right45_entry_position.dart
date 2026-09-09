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

dynamic calculateRight45EntryPosition(
  double thresholdX, // إحداثيات بداية المدرج X
  double thresholdZ, // إحداثيات بداية المدرج Z
  double runwayHeading, // اتجاه المدرج (مثلاً 045)
  double
      midDownwindDistance, // المسافة الموازية لنقطة الالتقاء (مثلاً 3 ميل لورا)
  double offsetDistanceMeters, // عرض الـ Pattern (البعد عن المدرج)
  double entryLegLength, // طول ضلع الدخلة (أنت بعيد قد إيه عن الـ Downwind)
) {
  // 1. تحويل الزاوية لراديان
  double runwayRad = runwayHeading * (math.pi / 180.0);

  // 2. تحديد نقطة الالتقاء على الـ Downwind (Merge Point)
  // بما أنه Right Pattern، بنرجع لورا وبعدين نخرج "شمال" جغرافياً (نطرح Offset)
  double mergeX = thresholdX -
      (midDownwindDistance * math.sin(runwayRad)) -
      (offsetDistanceMeters * math.cos(runwayRad));
  double mergeZ = thresholdZ +
      (midDownwindDistance * math.cos(runwayRad)) -
      (offsetDistanceMeters * math.sin(runwayRad));

  // 3. حساب زاوية الدخول (Entry Heading)
  // الـ Downwind هو (Runway + 180)، والدخلة 45 درجة من الخارج لنمط اليمين
  // إذن الزاوية هي (Runway + 180 - 45) = (Runway + 135)
  double entryHeading = (runwayHeading + 135) % 360;
  if (entryHeading < 0) entryHeading += 360;
  double entryRad = entryHeading * (math.pi / 180.0);

  // 4. حساب نقطة البداية (Starting Point)
  // بنتحرك "عكس" اتجاه الدخول من نقطة الالتقاء باستخدام نفس منطق الـ Backward
  double newX = mergeX - (entryLegLength * math.sin(entryRad));
  double newZ = mergeZ + (entryLegLength * math.cos(entryRad));

  // 5. الارتفاع القياسي للدخول (1000 قدم AGL)
  double suggestedAltitudeAGL = 305.0;

  return {
    'new_x': newX,
    'new_z': newZ,
    'aircraft_heading': entryHeading,
    'suggested_altitude_agl': suggestedAltitudeAGL,
    'merge_point_x': mergeX,
    'merge_point_z': mergeZ,
  };
}
