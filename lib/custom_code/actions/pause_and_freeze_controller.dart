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

Future pauseAndFreezeController(
  String ipAddress,
  String mode,
) async {
  // تحديد المسار (Endpoint) بناءً على نمط التحكم المطلوبة (Pause أو Freeze)
  String endpoint = '';

  if (mode.toLowerCase() == 'pause') {
    endpoint = 'toggle_pause';
  } else if (mode.toLowerCase() == 'freeze') {
    endpoint = 'toggle_freeze';
  } else {
    print("❌ خطأ: النمط غير معروف. استخدم 'pause' أو 'freeze'.");
    return;
  }

  // تجهيز رابط السيرفر
  final url = Uri.parse('http://$ipAddress:8080/$endpoint');

  try {
    // إرسال الطلب للسيرفر
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // قراءة الرد القادم من البايثون
      final responseData = jsonDecode(response.body);
      print("🕹️ Pause/Freeze Controller: ${responseData['message']}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
