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

Future configuration(
  String ipAddress,
  String configType,
) async {
  // تحديد المسار (Endpoint) بناءً على نوع التهيئة المطلوبة
  String endpoint = '';

  if (configType.toLowerCase() == 'takeoff') {
    endpoint = 'set_takeoff_config';
  } else if (configType.toLowerCase() == 'landing') {
    endpoint = 'set_landing_config';
  } else {
    print("❌ خطأ: نوع التهيئة غير معروف. استخدم 'takeoff' أو 'landing'.");
    return;
  }

  // تجهيز رابط السيرفر
  final url = Uri.parse('http://$ipAddress:8080/$endpoint');

  try {
    // إرسال الطلب للسيرفر
    // لا نحتاج لإرسال body لأن كود البايثون لا يطلب بيانات إضافية
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // قراءة الرد القادم من البايثون للطباعة والتأكد
      final responseData = jsonDecode(response.body);
      print("✈️ Configuration Success: ${responseData['message']}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
