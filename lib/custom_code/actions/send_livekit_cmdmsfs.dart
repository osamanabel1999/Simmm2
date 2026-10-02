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

// 🔥 المتغيرات بتتعرف هنا، والويجيت هو اللي هييجي يملاها
Room? globalLiveKitRoom_msfs;
void Function(String)? globalLiveKitLog_msfs;

Future sendLivekitCmdmsfs(String commandName) async {
  if (globalLiveKitRoom_msfs == null ||
      globalLiveKitRoom_msfs!.localParticipant == null) {
    debugPrint("⚠️ [الأكشن الخارجي]: لم يتم الاتصال بالغرفة!");
    if (globalLiveKitLog_msfs != null) {
      globalLiveKitLog_msfs!("⚠️ الأكشن: مش هقدر ابعت، الغرفة مش متصلة!");
    }
    return;
  }

  try {
    if (globalLiveKitLog_msfs != null) {
      globalLiveKitLog_msfs!("⏳ جاري إرسال $commandName ...");
    }

    final data = utf8.encode(commandName);
    await globalLiveKitRoom_msfs!.localParticipant?.publishData(
      data,
      topic: 'cmd',
    );

    debugPrint("✅ [الأكشن الخارجي]: تم إرسال الأمر بنجاح: $commandName");
    if (globalLiveKitLog_msfs != null) {
      globalLiveKitLog_msfs!("🚀 تم طيران الأمر بنجاح!");
    }
  } catch (e) {
    debugPrint("❌ [الأكشن الخارجي]: خطأ في الإرسال: $e");
    if (globalLiveKitLog_msfs != null) {
      globalLiveKitLog_msfs!("❌ فشل الإرسال!");
    }
  }
}
