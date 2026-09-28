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

double calculateExactLocalY(
  double? currentLocalYMeters, // الـ Y الحالية اللي جاية من السطر 21 (بالمتر)
  String?
      currentAltitudeFeet, // التعديل: الارتفاع الحالي للطيارة من السطر 20 (بقى String)
  double?
      targetRunwayElevMeters, // ارتفاع المدرج المستهدف جاهز من الـ API (بالمتر)
) {
  // 1. حماية الكود الأساسية لو في أي قيمة مجاتش خالص
  if (currentLocalYMeters == null ||
      currentAltitudeFeet == null ||
      targetRunwayElevMeters == null) {
    return 0.0;
  }

  // 2. تحويل الارتفاع الحالي من String إلى Double بأمان
  // لو لسبب ما المتغير جواه حروف بالغلط، هياخد صفر عشان الأبلكيشن ميعملش كراش
  double parsedAltitudeFeet = double.tryParse(currentAltitudeFeet) ?? 0.0;

  // 3. تحويل الارتفاع الحالي للطيارة من فيت (Feet) إلى متر (Meters)
  double currentAltitudeMeters = parsedAltitudeFeet * 0.3048;

  // 4. حساب فرق الارتفاع الوهمي لمحرك إكس بلين
  double offset = currentLocalYMeters - currentAltitudeMeters;

  // 5. حساب الـ Y الدقيقة للمدرج المستهدف بالمتر
  double exactTargetY = targetRunwayElevMeters + offset;

  // 6. إضافة 1.5 متر (كمتوسط لارتفاع عجل الطيارة)
  return exactTargetY + 1.5;
}
