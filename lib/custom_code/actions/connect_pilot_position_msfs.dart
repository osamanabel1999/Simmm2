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

Room? pilotRoomPositionMsfs;
EventsListener<RoomEvent>? pilotListenerPositionMsfs;

Future connectPilotPositionMsfs(String roomCode) async {
  // 🔥 مفاتيح سيرفر MSFS الجديد والموثوق
  const String apiKey = 'APIA87Lpk5cmUMP';
  const String apiSecret = 'aYWjjLKISVk663H7fYEBsx9cX69NTlg2er0oxtISsRD';
  const String livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name':
          'Pilot_Listener_Position_MSFS_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // منع الإرسال
        'canSubscribe':
            false, // 🔥 منع استقبال الصوت والصورة لتوفير الباقة 100%
        'canPublishData': true, // مسموح بالداتا فقط
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      // 🔥 هوية مختلفة خاصة برادار البوزيشن الخاص بـ MSFS
      'sub': 'Pilot_Listener_Position_MSFS',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomPositionMsfs != null) {
      await pilotRoomPositionMsfs!.disconnect();
    }
    pilotListenerPositionMsfs?.dispose();

    // إنشاء الغرفة
    pilotRoomPositionMsfs = Room();
    pilotListenerPositionMsfs = pilotRoomPositionMsfs!.createListener();

    pilotListenerPositionMsfs!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final payload = utf8.decode(event.data).trim();
          debugPrint("🎯 [رادار بوزيشن MSFS]: استلمت رسالة: $payload");

          if (payload.contains(':')) {
            final parts = payload.split(':');
            final cmd = parts[0];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              FFAppState().update(() {
                // 🔥 ربطنا الاستقبال بالـ App States الجديدة بتاعت MSFS
                if (cmd == 'ICAO' && parts.length > 1) {
                  FFAppState().syncIcaoMsfs = parts[1];
                } else if (cmd == 'MODE' && parts.length > 1) {
                  FFAppState().syncModeMsfs = int.tryParse(parts[1]) ?? 0;
                } else if (cmd == 'RWY' && parts.length > 1) {
                  FFAppState().syncRunwayMsfs = parts[1];
                } else if (cmd == 'GATE' && parts.length > 1) {
                  FFAppState().syncGateMsfs = parts[1];
                } else if (cmd == 'CHART_GATE' && parts.length > 1) {
                  FFAppState().syncChartGateMsfs = parts[1];
                } else if (cmd == 'SET_SPEED' && parts.length > 1) {
                  FFAppState().syncSetSpeedMsfs =
                      double.tryParse(parts[1]) ?? 0.0;
                } else if (cmd == 'NAVAID_SEARCH' && parts.length > 1) {
                  FFAppState().syncNavaidSearchMsfs = parts[1];
                } else if (cmd == 'TELEPORT' && parts.length > 5) {
                  // استلام 5 أرقام بتوع الـ Teleport
                  FFAppState().syncTeleportRadialMsfs =
                      double.tryParse(parts[1]) ?? 0.0;
                  FFAppState().syncTeleportHdgMsfs =
                      double.tryParse(parts[2]) ?? 0.0;
                  FFAppState().syncTeleportDistMsfs =
                      double.tryParse(parts[3]) ?? 0.0;
                  FFAppState().syncTeleportAltMsfs =
                      double.tryParse(parts[4]) ?? 0.0;
                  FFAppState().syncTeleportSpdMsfs =
                      double.tryParse(parts[5]) ?? 0.0;
                  // ضرب الأمر بتاع الـ Teleport
                  FFAppState().syncCommandMsfs =
                      'CMD_TELEPORT_EXECUTE_${DateTime.now().millisecondsSinceEpoch}';
                } else if (cmd == 'CMD' && parts.length > 1) {
                  // التريكة عشان ينفذ الأمر كل مرة
                  FFAppState().syncCommandMsfs =
                      '${parts[1]}_${DateTime.now().millisecondsSinceEpoch}';
                }
              });
            });
          }
        } catch (e) {
          debugPrint("❌ [رادار بوزيشن MSFS]: خطأ في فك الرسالة: $e");
        }
      }
    });

    await pilotRoomPositionMsfs!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );

    debugPrint("✅ [رادار بوزيشن MSFS]: متصل ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار بوزيشن MSFS]: فشل الاتصال: $e");
  }
}
