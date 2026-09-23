// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Automatic FlutterFlow imports أو أي منصة مشابهة
import 'dart:math' as math;

dynamic moveAircraftBackward(
  double currentX,
  double currentZ,
  double heading,
  double distanceMeters,
) {
  /// 1. تحويل الزاوية (Heading) من درجات إلى راديان لأن دوال الـ math بتتعامل بالراديان
  double headingRadians = heading * (math.pi / 180.0);

  /// 2. حساب الإحداثيات الجديدة بناءً على المسافة بالخلف
  /// - بالنسبة لـ X: بنطرح لأن الرجوع للخلف عكس اتجاه الـ Heading
  /// - بالنسبة لـ Z: بنجمع لأن الرجوع للخلف بيزود الإزاحة نحو الجنوب
  double newX = currentX - (distanceMeters * math.sin(headingRadians));
  double newZ = currentZ + (distanceMeters * math.cos(headingRadians));

  /// 3. إرجاع النتيجة كـ JSON عشان تقدر تستخدمها بسهولة في باقي التطبيق
  return {
    'new_x': newX,
    'new_z': newZ,
  };
}
