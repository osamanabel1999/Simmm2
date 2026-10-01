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

Room? pilotRoomPosition;
EventsListener<RoomEvent>? pilotListenerPosition;

Future connectPilotPositionxplane(String roomCode) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name':
          'Pilot_Listener_Position_${DateTime.now().millisecondsSinceEpoch}',
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
      // 🔥 هوية مختلفة خاصة برادار البوزيشن فقط
      'sub': 'Pilot_Listener_Position',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomPosition != null) {
      await pilotRoomPosition!.disconnect();
    }
    pilotListenerPosition?.dispose();

    pilotRoomPosition = Room();
    pilotListenerPosition = pilotRoomPosition!.createListener();

    pilotListenerPosition!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final payload = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار البوزيشن]: استلمت رسالة: $payload");

          if (payload.contains(':')) {
            final parts = payload.split(':');
            final cmd = parts[0];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              FFAppState().update(() {
                if (cmd == 'ICAO' && parts.length > 1) {
                  FFAppState().syncIcao = parts[1];
                } else if (cmd == 'MODE' && parts.length > 1) {
                  FFAppState().syncMode = int.tryParse(parts[1]) ?? 0;
                } else if (cmd == 'RWY' && parts.length > 1) {
                  FFAppState().syncRunway = parts[1];
                } else if (cmd == 'GATE' && parts.length > 1) {
                  FFAppState().syncGate = parts[1];
                } else if (cmd == 'CHART_GATE' && parts.length > 1) {
                  FFAppState().syncChartGate = parts[1];
                } else if (cmd == 'SIM_TIME' && parts.length > 1) {
                  FFAppState().syncSimTime =
                      double.tryParse(parts[1]) ?? 43200.0;
                } else if (cmd == 'GROUND_SPEED' && parts.length > 1) {
                  FFAppState().syncGroundSpeed =
                      double.tryParse(parts[1]) ?? 1.0;
                } else if (cmd == 'SET_SPEED' && parts.length > 1) {
                  FFAppState().syncSetSpeed = double.tryParse(parts[1]) ?? 0.0;
                } else if (cmd == 'NAVAID_SEARCH' && parts.length > 1) {
                  FFAppState().syncNavaidSearch = parts[1];
                } else if (cmd == 'TELEPORT' && parts.length > 5) {
                  // استلام 5 أرقام بتوع الـ Teleport
                  FFAppState().syncTeleportRadial =
                      double.tryParse(parts[1]) ?? 0.0;
                  FFAppState().syncTeleportHdg =
                      double.tryParse(parts[2]) ?? 0.0;
                  FFAppState().syncTeleportDist =
                      double.tryParse(parts[3]) ?? 0.0;
                  FFAppState().syncTeleportAlt =
                      double.tryParse(parts[4]) ?? 0.0;
                  FFAppState().syncTeleportSpd =
                      double.tryParse(parts[5]) ?? 0.0;
                  // ضرب الأمر بتاع الـ Teleport
                  FFAppState().syncCommand =
                      'CMD_TELEPORT_EXECUTE_${DateTime.now().millisecondsSinceEpoch}';
                } else if (cmd == 'CMD' && parts.length > 1) {
                  // 🔥 التريكة هنا: بضيف الوقت للأمر عشان الـ App State دايماً يحس بتغيير وينفذ الأمر حتى لو المدرب داس على نفس الزرار مرتين ورا بعض
                  FFAppState().syncCommand =
                      '${parts[1]}_${DateTime.now().millisecondsSinceEpoch}';
                }
              });
            });
          }
        } catch (e) {
          debugPrint("❌ [رادار البوزيشن]: خطأ في فك الرسالة: $e");
        }
      }
    });

    await pilotRoomPosition!.connect(livekitUrl, token);
    debugPrint("✅ [رادار البوزيشن]: متصل ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار البوزيشن]: فشل الاتصال: $e");
  }
}
