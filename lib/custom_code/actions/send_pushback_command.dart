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

Future sendPushbackCommand(
  String ipAddress,
  String action,
) async {
  final cleanIp = ipAddress.trim();
  final cleanAction = action.trim().toLowerCase();

  final url = Uri.parse('http://$cleanIp:8080/pushback/$cleanAction');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('error')) {
        print("⚠️ Pushback Warning: ${responseData['error']}");
      } else {
        print("🚜 Pushback Success: ${responseData['message']}");
      }
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
