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

import '/custom_code/widgets/index.dart'; // Imports other custom widgets

import 'package:livekit_client/livekit_client.dart';
import 'dart:convert';

// 👇 رجعنا تعريف المتغير هنا عشان الأكشن يقدر يشوفه ويشتغل صح
Room? globalLiveKitRoom_xplane;

Future sendLivekitCmdxplane(String commandName) async {
  // 1. التأكد إن الغرفة متصلة ومفتوحة
  if (globalLiveKitRoom_xplane == null ||
      globalLiveKitRoom_xplane!.localParticipant == null) {
    debugPrint("⚠️ لم يتم الاتصال بالغرفة بعد!");
    return;
  }

  try {
    // 2. تجهيز رسالة الأمر
    final message = jsonEncode({
      'target': 'XPLANE',
      'action': commandName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // 3. إرسال الأمر عبر كابل الاتصال المفتوح
    final data = utf8.encode(message);
    await globalLiveKitRoom_xplane!.localParticipant?.publishData(data);

    debugPrint("✅ تم إرسال الأمر بنجاح: $commandName");
  } catch (e) {
    debugPrint("❌ خطأ في إرسال الأمر: $e");
  }
}
