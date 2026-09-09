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

Future groundServicesAndDoorsController(
  String ipAddress,
  String actionType,
) async {
  String endpoint = '';

  // تحديد المسار (Endpoint) بناءً على نوع الأمر المطلوب
  switch (actionType.toLowerCase()) {
    case 'main_door':
      endpoint = 'door/main';
      break;
    case 'cargo_door':
      endpoint = 'door/cargo';
      break;
    case 'service_door':
      endpoint = 'door/service';
      break;
    case 'all_doors':
      endpoint = 'doors/toggle-all';
      break;
    case 'jetway':
      endpoint = 'ground/jetway';
      break;
    default:
      print("❌ خطأ: نوع الأمر غير معروف.");
      return;
  }

  // تجهيز رابط السيرفر
  final url = Uri.parse('http://$ipAddress:8080/$endpoint');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("🚪 Ground/Door Action Success: ${responseData['message']}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
