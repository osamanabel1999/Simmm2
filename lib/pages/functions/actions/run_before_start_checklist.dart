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

Future<void> runBeforeStartChecklist() async {
  // تهيئة أصوات Edge TTS للكابتن والمساعد
  final FlutterEdgeTts captainTts = FlutterEdgeTts(voice: "en-US-GuyNeural");
  final FlutterEdgeTts firstOfficerTts =
      FlutterEdgeTts(voice: "en-US-ChristopherNeural");
  final AudioPlayer audioPlayer = AudioPlayer();

  // قائمة Before Start (تم تنظيف الإجابات لتكون كلمة واحدة للنطق) - دون أي تغيير في النصوص
  List<Map<String, String>> checklist = [
    {'q': 'PARKING BRAKE', 'a': 'set'},
    {'q': 'TAKE OFF SPEEDS and THRUST', 'a': 'checked'},
    {'q': 'WINDOWS', 'a': 'closed'},
    {'q': 'BEACON', 'a': 'on'},
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
    await speakCaptain("BEFORE START CHECK LIST");
    await Future.delayed(const Duration(milliseconds: 1200));

    for (var step in checklist) {
      // 1. الكابتن ينطق السؤال
      await speakCaptain(step['q']!);

      // 2. فاصل زمني واقعي (محاكاة وقت النظر للعدادات أو المفاتيح)
      await Future.delayed(const Duration(milliseconds: 700));

      // 3. المساعد ينطق الإجابة (الرد)
      await speakFirstOfficer(step['a']!);

      // 4. فاصل زمني قبل الانتقال للعنصر التالي في القائمة
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // إعلان انتهاء القائمة
    await speakCaptain("BEFORE START CHECK LIST COMPLETED");
  } finally {
    await audioPlayer.dispose();
  }
}
