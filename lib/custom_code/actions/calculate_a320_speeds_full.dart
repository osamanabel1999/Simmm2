// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

Future<dynamic> calculateA320SpeedsFull(
  // تم تحويل المتغيرات إلى Nullable لتجنب الانهيار من FlutterFlow
  double? weight,
  String? flapsIndex,
  double? elevation,
  double? oat,
  double? runwayHeading,
  double? windDirection,
  double? windSpeed,
  double? runwayLength,
  double? slope,
  String? isWet,
  String? isPacksOn,
  String? antiIceIndex,
  double? cg,
  double? qnh,
) async {
  try {
    // ---------------------------------------------------------
    // 0. حماية المتغيرات (Default Values)
    // إذا أرسل FlutterFlow قيمة فارغة، سيتم استخدام هذه القيم الآمنة
    // ---------------------------------------------------------
    double w = weight ?? 60.0;
    String flaps = flapsIndex ?? "";
    double elev = elevation ?? 0.0;
    double temp = oat ?? 15.0;
    double rwyHdg = runwayHeading ?? 0.0;
    double windDir = windDirection ?? 0.0;
    double wSpeed = windSpeed ?? 0.0;
    double rwyLen = runwayLength ?? 3000.0;
    double rwySlope = slope ?? 0.0;
    String wetStatus = isWet ?? "DRY";
    String packsStatus = isPacksOn ?? "ON";
    String antiIce = antiIceIndex ?? "OFF";
    double cgValue = cg ?? 25.0;
    double qnhValue = qnh ?? 1013.25;

    // ---------------------------------------------------------
    // 1. حساب مركبة الرياح
    // ---------------------------------------------------------
    double angleDifference = windDir - rwyHdg;
    double angleInRadians = angleDifference * (math.pi / 180.0);
    double wind = wSpeed * math.cos(angleInRadians);

    // ---------------------------------------------------------
    // 2. تحويل النصوص بأمان
    // ---------------------------------------------------------
    int parsedFlaps = 0;
    if (flaps.contains('2'))
      parsedFlaps = 1;
    else if (flaps.contains('3')) parsedFlaps = 2;

    bool parsedWet = (wetStatus == 'WET');
    bool parsedPacks = (packsStatus == 'ON');

    int parsedAntiIce = 0;
    if (antiIce == 'Engine')
      parsedAntiIce = 1;
    else if (antiIce == 'Total') parsedAntiIce = 2;

    // ---------------------------------------------------------
    // 3. السرعات الأساسية
    // ---------------------------------------------------------
    double baseVr = (1.21 * (w - 50.0)) + 121.5;

    if (parsedFlaps == 1) {
      baseVr -= 4.0;
    } else if (parsedFlaps == 2) {
      baseVr -= 8.0;
    }

    double v1 = baseVr - 1.0;
    double vr = baseVr;
    double v2 = baseVr + 4.5;

    // ---------------------------------------------------------
    // 4. تصحيح البيئة والأنظمة ومركز الثقل
    // ---------------------------------------------------------
    double altCorr = (elev / 1000.0);
    double tempCorr = 0.0;
    if (temp > 15.0) {
      tempCorr = (temp - 15.0) * 0.45;
    }

    v1 += (altCorr + tempCorr);
    vr += (altCorr + tempCorr);
    v2 += (altCorr + tempCorr);

    if (parsedPacks) {
      v1 += 1.0;
      vr += 1.0;
      v2 += 1.0;
    }

    if (parsedAntiIce == 1) {
      v1 += 1.2;
      vr += 1.2;
      v2 += 1.2;
    } else if (parsedAntiIce == 2) {
      v1 += 2.5;
      vr += 2.5;
      v2 += 2.5;
    }

    if (cgValue < 26.0) {
      vr += 1.5;
      v2 += 1.0;
    } else if (cgValue > 32.0) {
      vr -= 1.0;
    }

    // ---------------------------------------------------------
    // 5. تصحيحات سرعة القرار V1
    // ---------------------------------------------------------
    if (wind > 0) {
      v1 += (wind / 10.0);
    } else if (wind < 0) {
      v1 -= (wind.abs() * 0.4);
    }

    if (rwySlope > 0) {
      v1 += (rwySlope * 0.8);
    } else if (rwySlope < 0) {
      v1 -= (rwySlope.abs() * 1.5);
    }

    if (rwyLen < 2200.0) {
      v1 -= ((2200.0 - rwyLen) / 100.0) * 1.8;
    }

    if (parsedWet) {
      v1 -= 7.0;
    }

    // ---------------------------------------------------------
    // 6. حواجز الأمان
    // ---------------------------------------------------------
    if (v1 > vr) v1 = vr;
    if (v2 < (vr + 2.0)) v2 = vr + 2.0;
    if (v1 < 105.0) v1 = 105.0;
    if (vr < 110.0) vr = 110.0;
    if (v2 < 115.0) v2 = 115.0;

    // ---------------------------------------------------------
    // 7. استدعاء الدوال الإضافية
    // ---------------------------------------------------------
    double pressureAlt = calculatePressureAltitude(elev, qnhValue);
    String flexTemp =
        calculateFlexTemp(temp, w, rwyLen, parsedWet, parsedAntiIce);
    Map<String, int> maneuveringSpeeds = calculateManeuveringSpeeds(w);

    String flapPrefix = "1";
    if (parsedFlaps == 1) {
      flapPrefix = "2";
    } else if (parsedFlaps == 2) {
      flapPrefix = "3";
    }
    String ths = "$flapPrefix/${calculateTHS(cgValue)}";
    double eoAcc = calculateEOAcc(elev);

    // ---------------------------------------------------------
    // 8. تجهيز النتيجة النهائية (Return JSON)
    // ---------------------------------------------------------
    return {
      "v1": v1.round(),
      "vr": vr.round(),
      "v2": v2.round(),
      "is_safe": (rwyLen > 1600.0) ? true : false,
      "calculation_timestamp": DateTime.now().toIso8601String(),
      "pressure_altitude": pressureAlt,
      "flex_temp": flexTemp,
      "f_speed": maneuveringSpeeds["F"],
      "s_speed": maneuveringSpeeds["S"],
      "green_dot_speed": maneuveringSpeeds["O"],
      "ths": ths,
      "eo_acc": eoAcc
    };
  } catch (e) {
    // في حالة حدوث أي خطأ برمجي غير متوقع، الكود لن ينهار
    // بل سيعيد أصفار وينقل المستخدم للصفحة الثانية بدلاً من التوقف الصامت
    print("Action Logic Error: $e");
    return {
      "v1": 0,
      "vr": 0,
      "v2": 0,
      "is_safe": false,
      "error_message": e.toString()
    };
  }
}

// الدوال المساعدة تبقى كما هي لأن القيم الممررة لها أصبحت محمية
double calculatePressureAltitude(double elevation, double qnh) {
  double pressureAlt = elevation + ((1013.25 - qnh) * 30.0);
  return (pressureAlt < 0) ? 0.0 : pressureAlt;
}

String calculateFlexTemp(
    double oat, double weight, double runwayLength, bool isWet, int antiIce) {
  double flex =
      72.0 - ((weight - 50.0) * 1.5) + ((runwayLength - 2200.0) / 200.0);
  if (isWet) flex -= 5.0;
  if (antiIce > 0) flex -= 3.0;
  if (flex > 73.0) flex = 73.0;
  if (flex <= (oat + 5.0)) {
    return "TOGA";
  }
  return "${flex.round()}°";
}

Map<String, int> calculateManeuveringSpeeds(double weight) {
  double oSpeed = (2.0 * weight) + 85.0;
  double sSpeed = (1.8 * weight) + 75.0;
  double fSpeed = (1.25 * weight) + 70.0;
  return {
    "F": fSpeed.round(),
    "S": sSpeed.round(),
    "O": oSpeed.round(),
  };
}

String calculateTHS(double cg) {
  double trimValue = (32.0 - cg) / 4.7;
  if (trimValue >= 0) {
    return "UP ${trimValue.toStringAsFixed(1)}";
  } else {
    return "DN ${trimValue.abs().toStringAsFixed(1)}";
  }
}

double calculateEOAcc(double elevation) {
  return elevation + 1500.0;
}
