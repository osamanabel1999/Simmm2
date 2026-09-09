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

Future captainSpeakBriefing(String? textToSpeak) async {
  if (textToSpeak == null || textToSpeak.isEmpty) {
    return;
  }

  String text = textToSpeak;

  // 1. معالجة اختصارات الطيران العامة
  text = text.replaceAll(RegExp(r'\bINTL\b'), 'international');
  text = text.replaceAll('9650', 'ten kilometers or more');
  text = text.replaceAll('9999', 'ten kilometers or more');

  // 2. معالجة المدارج (Runways) مثل 5L أو 23R أو 12C
  // بيبحث عن رقم أو اتنين ملزوق فيهم حرف L أو R أو C
  text = text.replaceAllMapped(RegExp(r'\b(\d{1,2})([RLC])\b'), (match) {
    String num = match.group(1)!;
    String letter = match.group(2)!;
    String fullWord = '';
    if (letter == 'L') fullWord = ' Left';
    if (letter == 'R') fullWord = ' Right';
    if (letter == 'C') fullWord = ' Center';
    return num + fullWord;
  });

  // 3. معالجة الخمس أرقام (مثل 04500)
  // بنشيل الصفر اللي في الأول لو موجود عشان ينطق "four thousand five hundred" على بعضها
  text = text.replaceAllMapped(RegExp(r'\b0(\d{4})\b'), (match) {
    return match.group(1)!;
  });

  // 4. قراءة الـ 3 أرقام فقط "رقم رقم" (مثل 250)
  // الـ Regex ده بيتجاهل أي رقم طوله مش 3 بالظبط عشان يسيب الـ 34000 تتقري على بعضها
  text = text.replaceAllMapped(RegExp(r'(?<!\d)\d{3}(?!\d)'), (match) {
    String numStr = match.group(0)!;
    Map<String, String> digits = {
      '0': 'zero',
      '1': 'one',
      '2': 'two',
      '3': 'three',
      '4': 'four',
      '5': 'five',
      '6': 'six',
      '7': 'seven',
      '8': 'eight',
      '9': 'niner'
    };
    return numStr.split('').map((char) => digits[char]).join(' ');
  });

  // 5. إعدادات الصوت الاحترافية (Captain Style)
  FlutterTts flutterTts = FlutterTts();

  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(0.45); // سرعة هادئة وواثقة
  await flutterTts.setPitch(0.85); // صوت عميق

  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.speak(text);
}
