// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
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
