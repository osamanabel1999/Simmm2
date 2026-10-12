// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Timer? _simulatorTimer;

Future<void> startSimulatorDataFetch(String? pcIpAddress) async {
  final String input = (pcIpAddress ?? '').trim();

  if (input.isEmpty) return;

  final String normalized = input.contains('://') ? input : 'http://$input';
  final Uri parsed = Uri.parse(normalized);

  if (parsed.scheme.toLowerCase() != 'http' || parsed.host.isEmpty) return;

  final Uri endpoint = Uri(
    scheme: 'http',
    host: parsed.host,
    port: parsed.hasPort ? parsed.port : 8179,
    path: '/flightdata',
  );

  // التأكد من عدم وجود أكثر من اتصال شغال في نفس الوقت
  _simulatorTimer?.cancel();

  // جلب الداتا كل 800 ملي ثانية
  _simulatorTimer =
      Timer.periodic(const Duration(milliseconds: 800), (timer) async {
    try {
      final http.Response response = await http.get(
        endpoint,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      ).timeout(const Duration(milliseconds: 750));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded['ok'] == true) {
          // تحديث الـ App States بأسماءك وأنواعك بالظبط
          FFAppState().update(() {
            // متغيرات الـ Double
            FFAppState().currentX = (decoded['x_m'] as num?)?.toDouble() ?? 0.0;
            FFAppState().CurrentY = (decoded['y_m'] as num?)?.toDouble() ?? 0.0;
            FFAppState().currentZ = (decoded['z_m'] as num?)?.toDouble() ?? 0.0;

            FFAppState().currentLAT =
                (decoded['latitude'] as num?)?.toDouble() ?? 0.0;
            FFAppState().currentLON =
                (decoded['longitude'] as num?)?.toDouble() ?? 0.0;
            FFAppState().currentHeading =
                (decoded['heading_deg'] as num?)?.toDouble() ?? 0.0;

            // متغيرات الـ String (هنحول الأرقام لنصوص باستخدام toString)
            // لو القيمة مش موجودة هنحطها "0.0" كنص
            FFAppState().currentALT =
                decoded['altitude_ft']?.toString() ?? '0.0';
            FFAppState().currentSPD =
                decoded['indicated_airspeed_kt']?.toString() ?? '0.0';
          });
        }
      }
    } catch (e) {
      // تفادي إيقاف التطبيق لو فيه مشكلة في الشبكة
      print('Simulator Connection Error: $e');
    }
  });
}

// Action لإيقاف التحديث عند الخروج
Future<void> stopSimulatorDataFetch() async {
  _simulatorTimer?.cancel();
}
