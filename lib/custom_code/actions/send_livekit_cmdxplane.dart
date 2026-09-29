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
import 'dart:convert';

// 🔥 الصندوق السحري الموحد: بيشيل الاتصال وبيشيل كوبري الـ Logs
class SharedLiveKit {
  static Room? room;
  static void Function(String)?
      onLog; // 👈 ده الكوبري اللي هيبعت الرسايل للشاشة
}

Future sendLivekitCmdxplane(String commandName) async {
  if (SharedLiveKit.room == null ||
      SharedLiveKit.room!.localParticipant == null) {
    debugPrint("⚠️ [الأكشن الخارجي]: لم يتم الاتصال بالغرفة!");
    // إرسال اللوج للشاشة لو كانت مفتوحة
    SharedLiveKit.onLog
        ?.call("⚠️ الزرار الخارجي: مش هقدر ابعت، الغرفة مش متصلة!");
    return;
  }

  try {
    SharedLiveKit.onLog?.call("⏳ الزرار الخارجي: جاري إرسال $commandName ...");

    final data = utf8.encode(commandName);
    await SharedLiveKit.room!.localParticipant?.publishData(
      data,
      topic: 'cmd',
    );

    debugPrint("✅ [الأكشن الخارجي]: تم إرسال الأمر بنجاح: $commandName");
    SharedLiveKit.onLog?.call("🚀 الزرار الخارجي: تم طيران الأمر بنجاح!");
  } catch (e) {
    debugPrint("❌ [الأكشن الخارجي]: خطأ في الإرسال: $e");
    SharedLiveKit.onLog?.call("❌ الزرار الخارجي: فشل الإرسال!");
  }
}
