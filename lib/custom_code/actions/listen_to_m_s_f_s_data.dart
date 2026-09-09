// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:web_socket_channel/io.dart';
import 'dart:convert';

Future listenToMSFSData(String ipAddress) async {
  // التعديل هنا: استخدام المسار الصحيح للسيرفر اللي إنت مسطبه
  final url = 'ws://$ipAddress:2050/fsuipc/';
  final channel = IOWebSocketChannel.connect(url);

  channel.stream.listen((message) {
    try {
      final data = jsonDecode(message);

      // السيرفر ده بيبعت البيانات في العادة جوه "offsets" أو بشكل مباشر
      // هنا بنحدث الـ App State بناءً على القيم اللي راجعة
      FFAppState().update(() {
        // الارتفاع
        if (data['name'] == 'Altitude') {
          FFAppState().msfsaltitude = (data['value'] as num).toDouble();
        }

        // السرعة
        if (data['name'] == 'Airspeed') {
          FFAppState().msfsairspeed = (data['value'] as num).toDouble();
        }

        // الاتجاه
        if (data['name'] == 'Heading') {
          FFAppState().msfsheading = (data['value'] as num).toDouble();
        }

        // خط العرض
        if (data['name'] == 'Latitude') {
          FFAppState().msfslatitude = (data['value'] as num).toDouble();
        }

        // خط الطول
        if (data['name'] == 'Longitude') {
          FFAppState().msfslongitude = (data['value'] as num).toDouble();
        }
      });
    } catch (e) {
      print("JSON Parsing Error: $e");
    }
  }, onError: (error) {
    print("WebSocket Connection Error: $error");
  }, onDone: () {
    print("WebSocket Connection Closed");
  });
}
