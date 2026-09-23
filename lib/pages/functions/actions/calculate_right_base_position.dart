// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

dynamic calculateRightBasePosition(
  double thresholdX, // إحداثيات بداية المدرج X
  double thresholdZ, // إحداثيات بداية المدرج Z
  double runwayHeading, // اتجاه المدرج (مثلاً 045)
  double finalDistanceMeters, // مسافة الفاينل (بعد المدرج عن نقطة الالتفاف)
  double offsetDistanceMeters, // مسافة البعد العرضي (عرض الـ Base)
) {
  // 1. تحويل الزوايا لراديان
  double runwayRad = runwayHeading * (math.pi / 180.0);

  // 2. المرحلة الأولى: الرجوع للخلف (Extended Centerline)
  // دي النقطة اللي الطيارة هتكون قصادها وهي في الـ Base
  double centerX = thresholdX - (finalDistanceMeters * math.sin(runwayRad));
  double centerZ = thresholdZ + (finalDistanceMeters * math.cos(runwayRad));

  // 3. المرحلة الثانية: الإزاحة العرضية لجهة اليمين (Right Base)
  // رياضياً بنطرح الـ Cos من X والـ Sin من Z عشان نتحرك لليسار الجغرافي للمدرج
  double newX = centerX - (offsetDistanceMeters * math.cos(runwayRad));
  double newZ = centerZ - (offsetDistanceMeters * math.sin(runwayRad));

  // 4. حساب اتجاه الطائرة (Heading)
  // الطيارة في الـ Right Base لازم تكون باصة يمين عشان تدخل المدرج
  // يعني اتجاه المدرج + 90 درجة
  double aircraftHeading = (runwayHeading + 90) % 360;
  if (aircraftHeading < 0) aircraftHeading += 360;

  // 5. الارتفاع المقترح (305 متر = 1000 قدم)
  double suggestedAltitudeAGL = 305.0;

  // إرجاع النتيجة
  return {
    'new_x': newX,
    'new_z': newZ,
    'aircraft_heading': aircraftHeading,
    'suggested_altitude_agl': suggestedAltitudeAGL,
  };
}
