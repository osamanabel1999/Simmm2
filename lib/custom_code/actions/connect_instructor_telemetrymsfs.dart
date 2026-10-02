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

// 🔥 تم تعديل المتغيرات لعزلها عن إكسبلين
Room? instructorTelemetryRoom_msfs;
EventsListener<RoomEvent>? instructorTelemetryListener_msfs;

Future connectInstructorTelemetrymsfs(String roomCode) async {
  // 🔥 بيانات سيرفر MSFS الجديد
  const String apiKey = 'APImhkubV5DHxkn';
  const String apiSecret = 'XBNDeehdCXt6wsfrqaD2tk6ufgBvJ2UhT859o8IcqhsA';
  const String livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';

  try {
    final cleanRoomCode = roomCode.trim();
    final jwt = JWT({
      'name': 'Instructor_Telemetry_Receiver_MSFS',
      'video': {
        'room': cleanRoomCode,
        'roomJoin': true,
        'canPublish': false, // المدرب هنا مش بيبعت داتا، هو بيستقبل بس
        'canSubscribe':
            false, // 🔥 منع السحب المزدوج للصوت/الفيديو (عشان معملش صدى صوت مع شاشة الفيديو الأساسية)
        'canPublishData': false,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': apiKey,
      'sub': 'Instructor_Telemetry_Receiver_MSFS',
    });

    final token = jwt.sign(SecretKey(apiSecret));

    // تنظيف الاتصال القديم لو عملنا ريفريش للصفحة
    if (instructorTelemetryRoom_msfs != null) {
      await instructorTelemetryRoom_msfs!.disconnect();
    }
    instructorTelemetryListener_msfs?.dispose();

    // 1. إنشاء الغرفة برمجياً بدون خطأ الباراميتر
    instructorTelemetryRoom_msfs = Room();

    instructorTelemetryListener_msfs =
        instructorTelemetryRoom_msfs!.createListener();

    // 📡 رادار التقاط الداتا اللحظي
    instructorTelemetryListener_msfs!.on<DataReceivedEvent>((event) {
      try {
        final payload = utf8.decode(event.data).trim();

        // لو الرسالة بتبدأ بـ TLM: يعني دي بيانات التليميتري بتاع الطيار
        if (payload.startsWith('TLM:')) {
          final parts = payload.split(':');

          // نتأكد إن الرسالة كاملة وفيها كل الـ 6 متغيرات
          if (parts.length >= 7) {
            final lat = double.tryParse(parts[1]) ?? 0.0;
            final lon = double.tryParse(parts[2]) ?? 0.0;
            final ias = double.tryParse(parts[3]) ?? 0.0;
            final alt = double.tryParse(parts[4]) ?? 0.0;
            final hdg = double.tryParse(parts[5]) ?? 0.0;
            final simbrief = parts[6];

            // ⚡ تحديث الـ App State فورا لتعكس الأرقام على شاشة المدرب
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FFAppState().update(() {
                // 🔥 تم تغيير أسماء المتغيرات لـ Msfs بدلاً من Xplane
                FFAppState().pilotLatMsfs = lat;
                FFAppState().pilotLonMsfs = lon;
                FFAppState().pilotIasMsfs = ias;
                FFAppState().pilotAltMsfs = alt;
                FFAppState().pilotHdgMsfs = hdg;
                FFAppState().pilotSimbriefMsfs = simbrief;
              });
            });
          }
        }
      } catch (e) {
        // يتم تجاهل الأخطاء بصمت حتى لا يتعطل الاستقبال السريع (5 مرات في الثانية)
      }
    });

    // 2. 🔥 نقل أمر autoSubscribe إلى ConnectOptions لحل الخطأ نهائياً
    await instructorTelemetryRoom_msfs!.connect(
      livekitUrl,
      token,
      connectOptions: const ConnectOptions(
        autoSubscribe: false,
      ),
    );

    debugPrint(
        "✅ [رادار استلام تليميتري MSFS]: متصل ومستعد لعرض بيانات الطيار الحية");
  } catch (e) {
    debugPrint("❌ [رادار استلام تليميتري MSFS]: فشل الاتصال: $e");
  }
}
