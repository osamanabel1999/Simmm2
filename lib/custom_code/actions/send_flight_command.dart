// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> sendFlightCommand(
  String serverIp,
  String endpointName,
) async {
  final String cleanIp = serverIp.trim();
  final String cleanEndpoint = endpointName.trim();

  // التعديل هنا: خلينا الرابط ياخد اسم المسار مباشرة
  final String serverUrl = 'http://$cleanIp:8080/$cleanEndpoint';

  try {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 3)); // خليت التايم أوت 3 ثواني أضمن

    if (response.statusCode == 200) {
      final Map<String, dynamic> res = json.decode(response.body);
      debugPrint('Success: ${res['message']}');
      return res['status'] == 'success';
    } else {
      debugPrint('Server Error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    debugPrint('Command Execution Error: $e');
    return false;
  }
}
