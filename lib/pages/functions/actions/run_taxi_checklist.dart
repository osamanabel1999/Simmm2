// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:async';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> runTaxiChecklist() async {
  // تهيئة أصوات Edge TTS للكابتن والمساعد
  final FlutterEdgeTts captainTts = FlutterEdgeTts(voice: "en-US-GuyNeural");
  final FlutterEdgeTts firstOfficerTts =
      FlutterEdgeTts(voice: "en-US-ChristopherNeural");
  final AudioPlayer audioPlayer = AudioPlayer();

  // قائمة TAXI (تم تنظيف الردود للتنفيذ المباشر) - دون أي مساس بالنصوص
  List<Map<String, String>> checklist = [
    {'q': 'FLIGHT CONTROL', 'a': 'checked'},
    {'q': 'FLAPS SETTING', 'a': 'set'},
    {'q': 'RADAR AND PWS', 'a': 'on and auto'},
    {'q': 'ENG MODE SELECTOR', 'a': 'normal'},
    {'q': 'ECAM MEMO', 'a': 'no blue'},
    {'q': 'AUTO BRAKE', 'a': 'max'},
    {'q': 'SIGNS', 'a': 'on'},
    {'q': 'CABIN', 'a': 'ready'},
    {'q': 'FLAPS', 'a': 'take off'},
    {'q': 'TAKE OFF CONFIG', 'a': 'normal'},
  ];

  // دالة تشغيل الصوت باستخدام Edge TTS والانتظار حتى اكتمال النطق
  Future<void> playVoice(FlutterEdgeTts ttsInstance, String text) async {
    try {
      final result = await ttsInstance.synthesize(text);
      final base64Audio = base64Encode(result.audioBytes);
      final dataUrl = 'data:audio/mpeg;base64,$base64Audio';

      final completer = Completer<void>();
      late StreamSubscription subscription;

      subscription = audioPlayer.onPlayerComplete.listen((_) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await audioPlayer.play(UrlSource(dataUrl));
      await completer.future;
    } catch (e) {
      debugPrint("Edge TTS Execution Error: $e");
    }
  }

  // دوال الأصوات المتعددة (Captain vs First Officer)
  Future<void> speakCaptain(String text) async {
    await playVoice(captainTts, text);
  }

  Future<void> speakFirstOfficer(String text) async {
    await playVoice(firstOfficerTts, text);
  }

  try {
    // إعلان بدء القائمة
    await speakCaptain("TAXI CHECK LIST");
    await Future.delayed(const Duration(milliseconds: 1200));

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
    await speakCaptain("TAXI CHECK LIST COMPLETED");
  } finally {
    await audioPlayer.dispose();
  }
}
