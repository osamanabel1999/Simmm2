// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

import 'dart:math' as math;

Future<dynamic> calculateXPlanePosition(
  double curLat,
  double curLon,
  double curX,
  double curZ,
  double tarLat,
  double tarLon,
) async {
  // ثوابت WGS84 الدقيقة جداً
  const double a = 6378137.0; // نصف قطر الأرض عند الاستواء
  const double e2 = 0.00669437999014; // مربع الانحراف المركزي
  const double pi = 3.14159265358979323846;

  // تحويل خط العرض الحالي لراديان للحسابات المثلثية
  double radLat = curLat * (pi / 180.0);
  double sinLat = math.sin(radLat);
  double cosLat = math.cos(radLat);

  // حساب معامل التصحيح لتقوس الأرض عند خط العرض الحالي
  double denom = 1.0 - (e2 * sinLat * sinLat);

  // حساب الأمتار لكل درجة عرض (M) وأمتار لكل درجة طول (N)
  double m = (a * (1.0 - e2) / (math.pow(denom, 1.5))) * (pi / 180.0);
  double n = (a / math.sqrt(denom)) * cosLat * (pi / 180.0);

  // حساب الفرق بين النقطة الحالية والمستهدفة
  double deltaLat = tarLat - curLat;
  double deltaLon = tarLon - curLon;

  // تحويل فرق الدرجات إلى أمتار (X و Z)
  // X يزيد شرقاً | Z ينقص شمالاً (نظام إحداثيات X-Plane)
  double targetX = curX + (deltaLon * n);
  double targetZ = curZ - (deltaLat * m);

  // إرجاع النتيجة كـ JSON لسهولة الربط في FlutterFlow
  return {
    'x': targetX,
    'z': targetZ,
  };
}
