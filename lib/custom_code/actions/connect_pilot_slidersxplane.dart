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

Room? pilotRoomSliders;
EventsListener<RoomEvent>? pilotListenerSliders;

Future connectPilotSlidersxplane(
  String roomCode,
  // 🔥 الحل هنا: ضفنا اسم (fuelValue) جنب كل double عشان فلاتر فلو يقرأه
  Future<dynamic> Function(double fuelValue)? fuelTotal,
  Future<dynamic> Function(double fuelValue)? fuelCenter,
  Future<dynamic> Function(double fuelValue)? fuelLInner,
  Future<dynamic> Function(double fuelValue)? fuelRInner,
  Future<dynamic> Function(double fuelValue)? fuelLOut,
  Future<dynamic> Function(double fuelValue)? fuelROuter,
) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Pilot_Listener_Sliders_${DateTime.now().millisecondsSinceEpoch}',
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

    if (pilotRoomSliders != null) {
      await pilotRoomSliders!.disconnect();
    }
    pilotListenerSliders?.dispose();

    pilotRoomSliders = Room();
    pilotListenerSliders = pilotRoomSliders!.createListener();

    pilotListenerSliders!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final payload = utf8.decode(event.data).trim();

          // الرادار ده مش بيشتغل غير لو الرسالة فيها علامة (:)
          if (payload.contains(':')) {
            final parts = payload.split(':');
            final command = parts[0];
            final value = double.tryParse(parts[1]) ?? 0.0;

            debugPrint(
                "🎯 [رادار السلايدر]: استلمت أمر: $command بقيمة $value");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (command == 'FUEL_TOTAL' && fuelTotal != null)
                fuelTotal(value);
              else if (command == 'FUEL_CENTER' && fuelCenter != null)
                fuelCenter(value);
              else if (command == 'FUEL_L_INNER' && fuelLInner != null)
                fuelLInner(value);
              else if (command == 'FUEL_R_INNER' && fuelRInner != null)
                fuelRInner(value);
              else if (command == 'FUEL_L_OUT' && fuelLOut != null)
                fuelLOut(value);
              else if (command == 'FUEL_R_OUTER' && fuelROuter != null)
                fuelROuter(value);
            });
          }
        } catch (e) {
          debugPrint("❌ [رادار السلايدر]: خطأ في القراءة: $e");
        }
      }
    });

    await pilotRoomSliders!.connect(livekitUrl, token);
    debugPrint("✅ [رادار السلايدر]: متصل ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار السلايدر]: فشل الاتصال: $e");
  }
}
