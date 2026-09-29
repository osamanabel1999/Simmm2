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

import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions

import 'package:livekit_client/livekit_client.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';

Room? pilotRoomxplane;

Future connectPilotListenerxplane(
  String roomCode,
  Future<dynamic> Function()? onTestCommand, // 👈 دي الإيد الخفية اللي هتدوس
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final jwt = JWT({
      'name': 'Pilot_Listener',
      'video': {
        'room': roomCode,
        'roomJoin': true,
        'canPublish': false,
        'canSubscribe': false,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    pilotRoomxplane = Room();
    final listener = pilotRoomxplane!.createListener();

    listener.on<DataReceivedEvent>((event) {
      final messageString = utf8.decode(event.data);
      final messageJson = jsonDecode(messageString);

      if (messageJson['target'] == 'XPLANE') {
        final action = messageJson['action'];

        // 👇 هنا بنقوله لو الأمر اللي وصل اسمه TEST، نفذ الأكشنز بتاعة الزرار
        if (action == 'TEST') {
          if (onTestCommand != null) {
            onTestCommand(); // 🔥 تنفيذ الضغطة الوهمية
          }
        }
      }
    });

    await pilotRoomxplane!.connect(livekitUrl, token);
    debugPrint("✅ رادار الطيار متصل بغرفة: $roomCode");
  } catch (e) {
    debugPrint("❌ فشل اتصال رادار الطيار: $e");
  }
}
