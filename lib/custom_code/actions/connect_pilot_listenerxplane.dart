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
    // 1. توليد التوكن للطيار (مسموح له بالاستماع للغرفة)
    final jwt = JWT({
      'name': 'Pilot_Listener_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': roomCode,
        'roomJoin': true,
        'canPublish': false,
        'canSubscribe': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    // 2. تنظيف أي اتصال أو رادار قديم منعاً للتداخل
    if (pilotRoomxplane != null) {
      await pilotRoomxplane!.disconnect();
    }
    pilotListenerxplane?.dispose();

    pilotRoomxplane = Room();

    // 3. إنشاء الرادار بالطريقة الرسمية الصحيحة المعتمدة في LiveKit Flutter
    pilotListenerxplane = pilotRoomxplane!.createListener();

    // الاستماع الحقيقي المعتمد لبيانات الـ Data Channels
    pilotListenerxplane!.on<DataReceivedEvent>((event) {
      try {
        final messageString = utf8.decode(event.data);
        debugPrint("📡 [الرادار استقبل بيانات]: $messageString");

        final messageJson = jsonDecode(messageString);

        if (messageJson['target'] == 'XPLANE') {
          final action = messageJson['action'];
          debugPrint("🎯 [تم مطابقة الهدف XPLANE] والأمر هو: $action");

          if (action == 'TEST') {
            if (onTestCommand != null) {
              onTestCommand(); // 🔥 تنفيذ الضغطة الوهمية وإظهار السناك بار
              debugPrint("🔥 [تم تنفيذ الضغطة الوهمية بنجاح!]");
            } else {
              debugPrint(
                  "⚠️ [تنبيه] الأمر TEST وصل، لكن مفيش أكشن مربوط في onTestCommand!");
            }
          }
        }
      } catch (e) {
        debugPrint("❌ [خطأ في قراءة البيانات الواردة]: $e");
      }
    });

    // 4. الاتصال الفعلي بالغرفة
    await pilotRoomxplane!.connect(livekitUrl, token);
    debugPrint("✅ [الرادار] الطيار متصل بنجاح بغرفة: $roomCode");
  } catch (e) {
    debugPrint("❌ [الرادار] فشل الاتصال: $e");
  }
}
