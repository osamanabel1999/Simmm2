// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

Future<void> runDepartureChecklist() async {
  final FlutterTts flutterTts = FlutterTts();

  // === [ تهيئة جلسة الصوت لـ iOS (وضع التشغيل فقط بدون مايك) ] ===
  if (Platform.isIOS) {
    await flutterTts.setSharedInstance(true);
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }

  // إعدادات اللغة الأساسية والانتظار حتى انتهاء النطق
  await flutterTts.setLanguage("en-US");
  await flutterTts.awaitSpeakCompletion(true);

  // قائمة Departure Checklist (بنفس العناصر والتفاصيل بالكامل)
  List<Map<String, String>> checklist = [
    {'q': 'RUNWAY AND SID', 'a': 'set'},
    {'q': 'FLAPS SETTING', 'a': 'set'},
    {'q': 'TAKE OFF SPEEDS AND THRUST', 'a': 'checked'},
    {'q': 'FCU ALTITUDE', 'a': 'set'},
  ];

  // ==========================================
  // دوال الأصوات المتعددة (Captain vs First Officer)
  // ==========================================

  // 1. صوت الكابتن (يقرأ العنصر)
  Future<void> speakCaptain(String text) async {
    await flutterTts.setPitch(1.0); // طبقة الصوت الطبيعية
    await flutterTts.setSpeechRate(0.45); // سرعة هادئة
    await flutterTts.speak(text);
  }

  // 2. صوت المساعد (يرد على العنصر)
  Future<void> speakFirstOfficer(String text) async {
    await flutterTts.setPitch(0.75); // طبقة صوت أغلظ لتمييزه
    await flutterTts.setSpeechRate(0.52); // سرعة استجابة أسرع قليلاً
    await flutterTts.speak(text);
  }

  // ==========================================
  // سيناريو التشغيل التلقائي
  // ==========================================

  // إعلان بدء القائمة
  await speakCaptain("DEPARTURE CHECK LIST");
  await Future.delayed(
      const Duration(milliseconds: 1200)); // فاصل طبيعي قبل البدء

  for (var step in checklist) {
    // 1. الكابتن ينطق السؤال
    await speakCaptain(step['q']!);

    // 2. فاصل زمني واقعي
    await Future.delayed(const Duration(milliseconds: 700));

    // 3. المساعد ينطق الإجابة
    await speakFirstOfficer(step['a']!);

    // 4. فاصل زمني قبل الانتقال للعنصر التالي
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  // إعلان انتهاء القائمة
  await speakCaptain("DEPARTURE CHECK LIST COMPLETED");
}
