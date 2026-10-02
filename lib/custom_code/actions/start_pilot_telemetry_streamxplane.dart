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

Room? telemetryRoomxplane;
Timer? telemetryTimerxplane;

Future startPilotTelemetryStreamxplane(String roomCode) async {
  const String apiKey = 'API5SxFp3ddtWz9';
  const String apiSecret = 'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';
  const String livekitUrl = 'wss://simulator-station-ham7e1yr.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Pilot_Telemetry_Sender',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // منع إرسال المايك/الكاميرا
        'canSubscribe': false, // منع سحب باقة المدرب
        'canPublishData': true, // 🔥 السماح بإرسال الداتا فقط
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Telemetry_Sender', // هوية مستقلة لرادار البث
    });

    final token = jwt.sign(SecretKey(apiSecret));

    // تنظيف أي اتصال أو تايمر قديم لو عملنا ريفريش
    telemetryTimerxplane?.cancel();
    if (telemetryRoomxplane != null) {
      await telemetryRoomxplane!.disconnect();
    }

    // 1. إنشاء الغرفة بشكل مباشر بدون أخطاء باراميترات
    telemetryRoomxplane = Room();

    // 2. تطبيق منع استقبال الصوت والفيديو داخل connectOptions بالشكل الصحيح لمكتبة LiveKit Dart
    await telemetryRoomxplane!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );
    debugPrint(
        "✅ [رادار بث التليميتري]: متصل ومستعد لإرسال الداتا الحية للمدرب");

    // 🔥 التايمر السحري: يشتغل كل 200 مللي ثانية (5 مرات في الثانية)
    telemetryTimerxplane =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (telemetryRoomxplane?.localParticipant == null) return;

      // 1. سحب البيانات من الـ App States الأصلية مع تصحيح حرف c في currentLAT
      final double lat = FFAppState().currentLAT ?? 0.0;
      final double lon = FFAppState().currentLON ?? 0.0;

      // السرعة والارتفاع جايين String فبنحولهم لـ Double
      final double ias = double.tryParse(FFAppState().currentSPD ?? '0') ?? 0.0;
      final double alt = double.tryParse(FFAppState().currentALT ?? '0') ?? 0.0;

      // الاتجاه هنحوله تحسباً لأي اختلاف في النوع
      final double hdg =
          double.tryParse(FFAppState().currentHeading?.toString() ?? '0') ??
              0.0;

      // السيمبريف جاي Integer فبنحوله لـ String
      final String simbrief = FFAppState().SimbreifID?.toString() ?? '';

      // 2. ضغط البيانات في سطر واحد قصير لتقليل الحجم لأقصى درجة (TLM = Telemetry)
      final String payload =
          "TLM:${lat.toStringAsFixed(5)}:${lon.toStringAsFixed(5)}:${ias.toStringAsFixed(1)}:${alt.toStringAsFixed(0)}:${hdg.toStringAsFixed(1)}:$simbrief";

      try {
        // 3. إرسال البيانات ببروتوكول UDP السريع جداً بدون Delay
        await telemetryRoomxplane!.localParticipant!.publishData(
          utf8.encode(payload),
          reliable:
              false, // 🔥 السر هنا: false يعني ابعت بسرعة الطلقة ومتستناش تأكيد استلام
        );
      } catch (e) {
        // تجاهل أي خطأ مؤقت في الإرسال عشان التايمر ميتوقفش
      }
    });
  } catch (e) {
    debugPrint("❌ [رادار بث التليميتري]: فشل الاتصال: $e");
  }
}
