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

// 🔥 تم تغيير أسماء المتغيرات لضمان العزل التام عن سيرفر إكسبلين
Room? pilotRoomSliders_msfs;
EventsListener<RoomEvent>? pilotListenerSliders_msfs;

Future connectPilotSlidersmsfs(
  String roomCode,
  // 🔥 تم تقليل السلايدرات إلى 4 فقط (توتال، سنتر، يمين، يسار) كما طلبت لـ MSFS
  Future<dynamic> Function(double fuelValue)? fuelTotal,
  Future<dynamic> Function(double fuelValue)? fuelCenter,
  Future<dynamic> Function(double fuelValue)? fuelLeft,
  Future<dynamic> Function(double fuelValue)? fuelRight,
) async {
  // 🔥 بيانات سيرفر MSFS الجديد لضمان مضاعفة الليمت
  const String apiKey = 'APIA87Lpk5cmUMP';
  const String apiSecret = 'aYWjjLKISVk663H7fYEBsx9cX69NTlg2er0oxtISsRD';
  const String livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name':
          'Pilot_Listener_Sliders_MSFS_${DateTime.now().millisecondsSinceEpoch}',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // منع الإرسال
        'canSubscribe':
            false, // 🔥 منع استقبال الصوت والصورة (توفير الباقة 100%)
        'canPublishData': true, // مسموح بالداتا فقط
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Pilot_Listener_Sliders_MSFS',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    if (pilotRoomSliders_msfs != null) {
      await pilotRoomSliders_msfs!.disconnect();
    }
    pilotListenerSliders_msfs?.dispose();

    // 1. إنشاء الغرفة برمجياً بدون خطأ الباراميتر
    pilotRoomSliders_msfs = Room();

    pilotListenerSliders_msfs = pilotRoomSliders_msfs!.createListener();

    pilotListenerSliders_msfs!.on<DataReceivedEvent>((event) {
      if (event.topic == 'cmd' || event.topic == null) {
        try {
          final payload = utf8.decode(event.data).trim();

          // الرادار ده مش بيشتغل غير لو الرسالة فيها علامة (:)
          if (payload.contains(':')) {
            final parts = payload.split(':');
            final command = parts[0];
            final value = double.tryParse(parts[1]) ?? 0.0;

            debugPrint(
                "🎯 [رادار سلايدر MSFS]: استلمت أمر: $command بقيمة $value");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 🔥 توجيه الأوامر للـ 4 سلايدرات فقط
              if (command == 'FUEL_TOTAL' && fuelTotal != null) {
                fuelTotal(value);
              } else if (command == 'FUEL_CENTER' && fuelCenter != null) {
                fuelCenter(value);
              } else if (command == 'FUEL_LEFT' && fuelLeft != null) {
                fuelLeft(value);
              } else if (command == 'FUEL_RIGHT' && fuelRight != null) {
                fuelRight(value);
              }
            });
          }
        } catch (e) {
          debugPrint("❌ [رادار سلايدر MSFS]: خطأ في القراءة: $e");
        }
      }
    });

    // 2. 🔥 تطبيق الحماية الفعلية ومنع استقبال أي فيديو أو صوت هنا
    await pilotRoomSliders_msfs!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );

    debugPrint(
        "✅ [رادار سلايدر MSFS]: متصل داتا فقط ومستعد بغرفة: $cleanRoomCode");
  } catch (e) {
    debugPrint("❌ [رادار سلايدر MSFS]: فشل الاتصال: $e");
  }
}
