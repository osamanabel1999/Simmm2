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
import 'dart:async';

Room? telemetryRoom_msfs;
Timer? telemetryTimer_msfs;

Future startPilotTelemetryStreammsfs(String roomCode) async {
  const String apiKey = 'APImhkubV5DHxkn';
  const String apiSecret = 'XBNDeehdCXt6wsfrqaD2tk6ufgBvJ2UhT859o8IcqhsA';
  const String livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Pilot_Telemetry_Sender_MSFS',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false,
        'canSubscribe': false,
        'canPublishData': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Telemetry_Sender_MSFS',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    telemetryTimer_msfs?.cancel();
    if (telemetryRoom_msfs != null) {
      await telemetryRoom_msfs!.disconnect();
    }

    telemetryRoom_msfs = Room();

    await telemetryRoom_msfs!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );
    debugPrint("✅ [رادار بث تليميتري MSFS]: متصل ومستعد لإرسال الداتا");

    telemetryTimer_msfs =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (telemetryRoom_msfs?.localParticipant == null) return;

      // 🔥 تم تعديل الأسماء لتتوافق مع شروط FlutterFlow (بدون _)
      final double lat = FFAppState().currentLatMsfs ?? 0.0;
      final double lon = FFAppState().currentLonMsfs ?? 0.0;

      final double ias =
          double.tryParse(FFAppState().currentSpdMsfs ?? '0') ?? 0.0;
      final double alt =
          double.tryParse(FFAppState().currentAltMsfs ?? '0') ?? 0.0;

      final double hdg =
          double.tryParse(FFAppState().currentHeadingMsfs?.toString() ?? '0') ??
              0.0;

      final String simbrief = FFAppState().simbriefIdMsfs?.toString() ?? '';

      final String payload =
          "TLM:${lat.toStringAsFixed(5)}:${lon.toStringAsFixed(5)}:${ias.toStringAsFixed(1)}:${alt.toStringAsFixed(0)}:${hdg.toStringAsFixed(1)}:$simbrief";

      try {
        await telemetryRoom_msfs!.localParticipant!.publishData(
          utf8.encode(payload),
          reliable: false,
        );
      } catch (e) {
        // تجاهل أخطاء الإرسال المؤقتة
      }
    });
  } catch (e) {
    debugPrint("❌ [رادار بث تليميتري MSFS]: فشل الاتصال: $e");
  }
}
