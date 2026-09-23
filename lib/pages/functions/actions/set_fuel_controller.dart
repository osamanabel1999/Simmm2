// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'dart:convert';

Future setFuelController(
  String ipAddress,
  double centerPct,
  double leftPct,
  double rightPct,
) async {
  final url = Uri.parse(
      'http://$ipAddress:8080/fuel/set?center_pct=$centerPct&left_pct=$leftPct&right_pct=$rightPct');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("⛽ Fuel Set Success: ${responseData['message']}");
    } else {
      print("❌ Server Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("❌ Network Error: $e");
  }
}
