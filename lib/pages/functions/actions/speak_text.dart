// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
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
