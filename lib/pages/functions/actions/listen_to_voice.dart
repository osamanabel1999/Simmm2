// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

Future<String?> listenToVoice(String? targetWord) async {
  stt.SpeechToText speech = stt.SpeechToText();
  bool available = await speech.initialize();

  if (!available) return "error";

  final completer = Completer<String>();
  String recognizedText = "";

  // بنجهز الكلمة اللي المساعد هيدور عليها (وبنخليها حروف صغيرة عشان المقارنة)
  String target = targetWord?.toLowerCase().trim() ?? "";

  await speech.listen(
    onResult: (val) {
      recognizedText = val.recognizedWords.toLowerCase();

      // الذكاء هنا: لو لقط الكلمة المطلوبة في وسط أي كلام، بيقفل فوراً ويرجعها هي بس!
      if (target.isNotEmpty && recognizedText.contains(target)) {
        if (!completer.isCompleted) {
          speech.stop();
          completer.complete(target); // بيرجع الكلمة المطلوبة صافية
        }
      }
      // لو سكت والموبايل اعتبر إنك خلصت كلام
      else if (val.finalResult) {
        if (!completer.isCompleted) {
          speech.stop();
          completer.complete(recognizedText.trim());
        }
      }
    },
    listenFor: Duration(seconds: 5), // قللنا الوقت لـ 5 ثواني عشان يبقى أسرع
    pauseFor: Duration(seconds: 2), // لو سكت ثانيتين المايك يقفل لوحده
    listenMode: stt
        .ListenMode.confirmation, // المود ده أذكى وأسرع في لقط الكلمات القصيرة
    cancelOnError: true,
  );

  // لو الوقت خلص خالص
  Timer(Duration(seconds: 5), () {
    if (!completer.isCompleted) {
      speech.stop();
      completer.complete(recognizedText.trim());
    }
  });

  return completer.future;
}
