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

Future sendMSFSCommand(
  String ipAddress,
  String eventName,
) async {
  // فتح الاتصال بالسيرفر بناءً على الرابط الظاهر في برنامج Paul Henty
  final url = 'ws://$ipAddress:2050/fsuipc/';
  final channel = IOWebSocketChannel.connect(url);

  // تجهيز الأمر بصيغة تفعيل الـ Events (مثل الـ Parking Brakes)
  // السيرفر ده بيفهم الـ "command": "post" لإرسال الأوامر للمحاكي
  var message = {
    "command": "post",
    "name": eventName,
    "value": 0 // القيمة الافتراضية لأغلب الـ Events
  };

  try {
    // إرسال الأمر بصيغة JSON
    channel.sink.add(jsonEncode(message));

    // تأخير بسيط للتأكد من وصول الأمر قبل غلق القناة
    await Future.delayed(Duration(milliseconds: 100));
  } catch (e) {
    print("Error sending command: $e");
  } finally {
    // غلق الاتصال للحفاظ على الموارد
    await channel.sink.close();
  }
}
