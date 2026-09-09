// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_tts/flutter_tts.dart';

Future speakText(String? textToSpeak) async {
  // تعريف كائن النطق
  FlutterTts flutterTts = FlutterTts();

  // التأكد إن النص مش فاضي قبل النطق
  if (textToSpeak != null && textToSpeak.isNotEmpty) {
    // إعدادات الصوت (اختياري)
    await flutterTts.setLanguage("en-US"); // خليها en-US للـ Checklist الطيران
    await flutterTts.setPitch(1.0); // درجة الصوت
    await flutterTts.setSpeechRate(0.5); // سرعة الكلام (0.5 مناسبة جداً)

    // تنفيذ النطق
    await flutterTts.speak(textToSpeak);
  }
}
