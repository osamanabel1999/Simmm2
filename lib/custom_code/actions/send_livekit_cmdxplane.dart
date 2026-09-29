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

// 👇 السطر ده هو اللي هيخرس الكومبايلر ويشيل الـ 3 إيرورات فوراً
Room? globalLiveKitRoom_xplane;

Future sendLivekitCmdxplane(String commandName) async {
  if (globalLiveKitRoom_xplane == null ||
      globalLiveKitRoom_xplane!.localParticipant == null) {
    debugPrint("⚠️ لم يتم الاتصال بالغرفة!");
    return;
  }

  try {
    final data = utf8.encode(commandName);
    await globalLiveKitRoom_xplane!.localParticipant?.publishData(
      data,
      topic: 'cmd',
    );
    debugPrint("✅ تم إرسال الأمر بنجاح: $commandName");
  } catch (e) {
    debugPrint("❌ خطأ في الإرسال: $e");
  }
}
