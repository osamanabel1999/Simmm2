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
// بنستورد الأكشن الأولاني عشان نستخدم الغرفة اللي هو فتحها وميضربش إيرور!
import '/custom_code/actions/send_livekit_cmdxplane.dart' as main_sender;

Future sendLivekitSliderxplane(String commandName, double sliderValue) async {
  if (main_sender.globalLiveKitRoom_xplane == null ||
      main_sender.globalLiveKitRoom_xplane!.localParticipant == null) {
    debugPrint("⚠️ [سلايدر]: لم يتم الاتصال بالغرفة!");
    // 🔥 طباعة الخطأ على الشاشة
    if (main_sender.globalLiveKitLog_xplane != null) {
      main_sender
          .globalLiveKitLog_xplane!("⚠️ السلايدر: لم يتم الاتصال بالغرفة!");
    }
    return;
  }

  try {
    // دمج الكلمة مع الرقم باستخدام نقطتين (مثال: FUEL_CENTER:75.5)
    final dataString = "$commandName:$sliderValue";

    // 🔥 طباعة جاري الإرسال على الشاشة
    if (main_sender.globalLiveKitLog_xplane != null) {
      main_sender.globalLiveKitLog_xplane!("⏳ جاري إرسال: $dataString ...");
    }

    final data = utf8.encode(dataString);

    await main_sender.globalLiveKitRoom_xplane!.localParticipant?.publishData(
      data,
      topic: 'cmd',
    );

    debugPrint("✅ [سلايدر]: تم إرسال القيمة بنجاح: $dataString");
    // 🔥 طباعة نجاح الإرسال على الشاشة
    if (main_sender.globalLiveKitLog_xplane != null) {
      main_sender.globalLiveKitLog_xplane!("🚀 تم تحديث الوقود بنجاح!");
    }
  } catch (e) {
    debugPrint("❌ [سلايدر]: خطأ في الإرسال: $e");
    // 🔥 طباعة الفشل على الشاشة
    if (main_sender.globalLiveKitLog_xplane != null) {
      main_sender.globalLiveKitLog_xplane!("❌ فشل إرسال قيمة الوقود!");
    }
  }
}
