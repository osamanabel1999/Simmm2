// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:livekit_client/livekit_client.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';

Room? pilotRoomxplane;
EventsListener<RoomEvent>? pilotListenerxplane;

Future connectPilotListenerxplane(
  String roomCode,
  Future<dynamic> Function()? onTestCommand,
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Pilot_Listener_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false,
        'canSubscribe': true,
        'canPublishData': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    // 1. تنظيف أي اتصال أو رادار قديم
    if (pilotRoomxplane != null) {
      await pilotRoomxplane!.disconnect();
    }
    pilotListenerxplane?.dispose();

    pilotRoomxplane = Room();
    pilotListenerxplane = pilotRoomxplane!.createListener();

    // 2. رادار الاستقبال المظبوط
    pilotListenerxplane!.on<DataReceivedEvent>((event) {
      debugPrint("🔥 [رادار الطيار]: التقطت إشارة في الموجة: ${event.topic}");

      // استقبال سواء بموجة cmd أو بدون موجة لضمان عدم الضياع
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final command = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار الطيار]: الكلمة هي: $command");

          if (command == 'TEST') {
            if (onTestCommand != null) {
              debugPrint("✅ [رادار الطيار]: جاري إجبار السناك بار على الظهور!");
              // 🔥 هذا السطر يجبر فلاتر على عرض السناك بار على الشاشة فوراً
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onTestCommand();
              });
            } else {
              debugPrint(
                  "⚠️ [رادار الطيار]: الكلمة وصلت بس انت مش حاطط أكشن في onTestCommand!");
            }
          }
        } catch (e) {
          debugPrint("❌ [رادار الطيار]: خطأ في قراءة الكلمة: $e");
        }
      }
    });

    await pilotRoomxplane!.connect(livekitUrl, token);
    debugPrint("✅ [رادار الطيار]: متصل ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار الطيار]: فشل الاتصال: $e");
  }
}
