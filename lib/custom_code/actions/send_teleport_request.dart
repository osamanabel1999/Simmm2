// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'dart:convert';

Future sendTeleportRequest(
  String ipAddress,
  double lat,
  double lon,
  double? altitudeFt,
  double? headingDeg,
  double? speedKnots,
) async {
  // دالة مخصصة فرمتة الأرقام: بتجبر أي قيمة تيجي إنها تكون بعلامة عشرية صريحة
  double ensureDecimal(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return value as double;
  }

  // تطبيق الفرمتة الإجبارية على كل المتغيرات بلا استثناء
  final double finalLat = ensureDecimal(lat);
  final double finalLon = ensureDecimal(lon);

  // التعامل مع المتغيرات الاختيارية (لو مش فاضية، افرض عليها العلامة العشرية)
  final double? finalAlt =
      altitudeFt != null ? ensureDecimal(altitudeFt) : null;
  final double? finalHdg =
      headingDeg != null ? ensureDecimal(headingDeg) : null;
  final double? finalSpd =
      speedKnots != null ? ensureDecimal(speedKnots) : null;

  // تجهيز رابط السيرفر
  final url = Uri.parse('http://$ipAddress:8080/teleport');

  // تجهيز الـ JSON Body بالمتغيرات اللي اتفرمتت
  final Map<String, dynamic> bodyData = {
    'lat': finalLat,
    'lon': finalLon,
    if (finalAlt != null) 'altitude_ft': finalAlt,
    if (finalHdg != null) 'heading_deg': finalHdg,
    if (finalSpd != null) 'speed_knots': finalSpd,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      print("✈️ Teleport Success: ${response.body}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
