// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> runAfterLandingChecklist() async {
  // تهيئة أصوات Edge TTS للكابتن والمساعد
  final FlutterEdgeTts captainTts = FlutterEdgeTts(voice: "en-US-GuyNeural");
  final FlutterEdgeTts firstOfficerTts =
      FlutterEdgeTts(voice: "en-US-ChristopherNeural");
  final AudioPlayer audioPlayer = AudioPlayer();

  // قائمة After Landing Checklist
  List<Map<String, String>> checklist = [
    {'q': 'RADAR AND P W S', 'a': 'OFF'},
  ];

  // دالة تشغيل الصوت باستخدام Edge TTS والانتظار حتى انتهاء النطق
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

  // دوال الحوار (Captain vs First Officer)
  Future<void> speakCaptain(String text) async {
    await playVoice(captainTts, text);
  }

  Future<void> speakFirstOfficer(String text) async {
    await playVoice(firstOfficerTts, text);
  }

  try {
    // إعلان بدء القائمة
    await speakCaptain("AFTER LANDING CHECKLIST");
    await Future.delayed(const Duration(milliseconds: 800));

    for (var step in checklist) {
      // 1. الكابتن ينطق السؤال
      await speakCaptain(step['q']!);

      // 2. فاصل زمني واقعي
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. المساعد ينطق الإجابة
      await speakFirstOfficer(step['a']!);

      // 4. فاصل زمني قبل العنصر التالي
      await Future.delayed(const Duration(milliseconds: 700));
    }

    // إعلان انتهاء القائمة
    await speakCaptain("AFTER LANDING CHECKLIST COMPLETED");
  } finally {
    await audioPlayer.dispose();
  }
}
