// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'dart:convert';

Future patternTeleporter(
  String ipAddress,
  double thresholdLat,
  double thresholdLon,
  double runwayHeading,
  double airportElevation,
  String position,
  double? customSpeed,
) async {
  final url = Uri.parse('http://$ipAddress:8080/teleport_to_pattern');

  // تجهيز الـ JSON Body بالبيانات المطابقة لنموذج Pydantic في البايثون
  final Map<String, dynamic> bodyData = {
    'threshold_lat': thresholdLat,
    'threshold_lon': thresholdLon,
    'runway_heading': runwayHeading,
    'airport_elevation': airportElevation,
    'position': position,
    if (customSpeed != null) 'custom_speed': customSpeed,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("✈️ Pattern Teleport Success: ${responseData['message']}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
