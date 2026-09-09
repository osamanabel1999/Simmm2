// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getFlightData(String serverIp) async {
  final String cleanIp = serverIp.trim();
  final String serverUrl = 'http://$cleanIp:8080/data';

  try {
    final response = await http
        .get(Uri.parse(serverUrl))
        .timeout(const Duration(milliseconds: 1500));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // التأكد من نجاح الاستجابة واستخراج كائن data الداخلية
      if (responseData['status'] == 'success' && responseData['data'] != null) {
        final flightData = responseData['data'];
        return {
          "speed": (flightData['speed'] ?? 0.0).toDouble(),
          "altitude": (flightData['altitude'] ?? 0.0).toDouble(),
          "heading": (flightData['heading'] ?? 0.0).toDouble(),
          "latitude": (flightData['latitude'] ?? 0.0).toDouble(),
          "longitude": (flightData['longitude'] ?? 0.0).toDouble(),
          "status": "success"
        };
      }
    }

    return {
      "speed": 0.0,
      "altitude": 0.0,
      "heading": 0.0,
      "latitude": 0.0,
      "longitude": 0.0,
      "status": "error"
    };
  } catch (e) {
    return {
      "speed": 0.0,
      "altitude": 0.0,
      "heading": 0.0,
      "latitude": 0.0,
      "longitude": 0.0,
      "status": "error"
    };
  }
}
