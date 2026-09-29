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
    // 1. تنظيف كود الغرفة من أي مسافات بالغلط (عشان نضمن إنهم في نفس الغرفة 100%)
    final cleanRoomCode = roomCode.trim();

    // 2. توكن بصلاحيات كاملة مؤقتاً لضمان عدم حظر سيرفر LiveKit للبيانات
    final jwt = JWT({
      'name': 'Pilot_Listener_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': true, // تم تعديلها لتجنب حظر البيانات
        'canSubscribe': true,
        'canPublishData': true, // إضافة صلاحية قراءة البيانات
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomxplane != null) {
      await pilotRoomxplane!.disconnect();
    }
    pilotListenerxplane?.dispose();

    pilotRoomxplane = Room();
    pilotListenerxplane = pilotRoomxplane!.createListener();

    pilotListenerxplane!.on<DataReceivedEvent>((event) {
      try {
        final messageString = utf8.decode(event.data);
        final messageJson = jsonDecode(messageString);

        if (messageJson['target'] == 'XPLANE') {
          final action = messageJson['action'];

          // 🔥 إجبار تحديث الذاكرة عشان لو السناك بار فشل، النص في الشاشة يتغير وتتأكد إنها شغالة
          FFAppState().update(() {
            FFAppState().receivedCommand = action;
          });

          if (action == 'TEST') {
            if (onTestCommand != null) {
              // 🔥 التعديل الأهم: إجبار فلاتر إنه يشغل (السناك بار) على واجهة المستخدم الرئيسية غصب عنه!
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onTestCommand();
              });
            }
          }
        }
      } catch (e) {
        debugPrint("❌ [خطأ]: $e");
      }
    });

    await pilotRoomxplane!.connect(livekitUrl, token);
    debugPrint("✅ [الرادار] متصل بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [الرادار] فشل الاتصال: $e");
  }
}
