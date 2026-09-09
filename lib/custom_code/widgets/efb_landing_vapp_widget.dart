// Automatic FlutterFlow imports
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui' as ui;

class EfbLandingVappWidget extends StatefulWidget {
  const EfbLandingVappWidget({
    Key? key,
    this.width,
    this.height,
    required this.runwayLength,
    required this.vapp,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double runwayLength;
  final double vapp; // سرعة الهبوط VAPP

  @override
  _EfbLandingVappWidgetState createState() => _EfbLandingVappWidgetState();
}

class _EfbLandingVappWidgetState extends State<EfbLandingVappWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 180, // قللنا الارتفاع شوية لإن مفيش مستويات كتير
      color: const Color(0xFF14181B), // نفس لون الخلفية الموحد
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: CustomPaint(
          painter: LandingRunwayPainter(
            runwayLength: widget.runwayLength,
            vapp: widget.vapp,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class LandingRunwayPainter extends CustomPainter {
  final double runwayLength;
  final double vapp;

  LandingRunwayPainter({
    required this.runwayLength,
    required this.vapp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingX = 25.0;
    final double runwayStartX = paddingX;
    final double runwayEndX = size.width - paddingX;
    final double usableWidth = runwayEndX - runwayStartX;

    // -------------------------------------------------------------
    // 1. رسم خط مؤشر طول الممر (Runway Length)
    // -------------------------------------------------------------
    final double dimY = 22.0;
    final Paint dimPaint = Paint()
      ..color = const Color(0xFF4A6572)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(runwayStartX, dimY), Offset(runwayEndX, dimY), dimPaint);
    canvas.drawLine(Offset(runwayStartX, dimY - 6),
        Offset(runwayStartX, dimY + 6), dimPaint);
    canvas.drawLine(
        Offset(runwayEndX, dimY - 6), Offset(runwayEndX, dimY + 6), dimPaint);

    final String lengthText =
        "${runwayLength.toInt()} M / LDA"; // في الهبوط يفضل استخدام LDA
    final TextSpan dimSpan = TextSpan(
      text: lengthText,
      style: const TextStyle(
        color: Color(0xFF8B9BB4),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
    final TextPainter dimPainter = TextPainter(
      text: dimSpan,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final double dimTextX = (size.width - dimPainter.width) / 2;
    final Rect dimBgRect = Rect.fromLTWH(
      dimTextX - 8,
      dimY - (dimPainter.height / 2) - 2,
      dimPainter.width + 16,
      dimPainter.height + 4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(dimBgRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF14181B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(dimBgRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFF2C384A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    dimPainter.paint(canvas, Offset(dimTextX, dimY - dimPainter.height / 2));

    // -------------------------------------------------------------
    // 2. رسم الممر وتفاصيله (Runway Body)
    // -------------------------------------------------------------
    final double runwayTop = 55.0;
    final double runwayHeight = 44.0;
    final double runwayBottom = runwayTop + runwayHeight;
    final Rect runwayRect =
        Rect.fromLTRB(runwayStartX, runwayTop, runwayEndX, runwayBottom);

    final Paint asphaltPaint = Paint()..color = const Color(0xFF212529);
    canvas.drawRect(runwayRect, asphaltPaint);

    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(runwayStartX, runwayTop),
        Offset(runwayEndX, runwayTop), borderPaint);
    canvas.drawLine(Offset(runwayStartX, runwayBottom),
        Offset(runwayEndX, runwayBottom), borderPaint);

    final Paint centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0;

    double dashX = runwayStartX + 35;
    const double dashWidth = 12.0;
    const double dashSpace = 8.0;
    final double centerY = runwayTop + (runwayHeight / 2);

    while (dashX < runwayEndX - 35) {
      canvas.drawLine(
        Offset(dashX, centerY),
        Offset(
            (dashX + dashWidth > runwayEndX - 35)
                ? runwayEndX - 35
                : dashX + dashWidth,
            centerY),
        centerLinePaint,
      );
      dashX += dashWidth + dashSpace;
    }

    final Paint thresholdPaint = Paint()..color = Colors.white.withOpacity(0.9);
    const int keysCount = 6;
    final double keyHeight = (runwayHeight - 12) / keysCount;

    for (int i = 0; i < keysCount; i++) {
      canvas.drawRect(
          Rect.fromLTWH(runwayStartX + 4, runwayTop + 6 + (i * keyHeight), 12,
              keyHeight - 2),
          thresholdPaint);
      canvas.drawRect(
          Rect.fromLTWH(runwayEndX - 16, runwayTop + 6 + (i * keyHeight), 12,
              keyHeight - 2),
          thresholdPaint);
    }

    final double aimingWidth = 20.0;
    final double aimingHeight = 8.0;
    canvas.drawRect(
        Rect.fromLTWH(runwayStartX + (usableWidth * 0.18), runwayTop + 5,
            aimingWidth, aimingHeight),
        thresholdPaint);
    canvas.drawRect(
        Rect.fromLTWH(runwayStartX + (usableWidth * 0.18),
            runwayBottom - 5 - aimingHeight, aimingWidth, aimingHeight),
        thresholdPaint);
    canvas.drawRect(
        Rect.fromLTWH(runwayEndX - (usableWidth * 0.18) - aimingWidth,
            runwayTop + 5, aimingWidth, aimingHeight),
        thresholdPaint);
    canvas.drawRect(
        Rect.fromLTWH(runwayEndX - (usableWidth * 0.18) - aimingWidth,
            runwayBottom - 5 - aimingHeight, aimingWidth, aimingHeight),
        thresholdPaint);

    // -------------------------------------------------------------
    // 3. رسم مؤشر سرعة الهبوط (VAPP)
    // -------------------------------------------------------------
    final double maxSpeedRef =
        (vapp > 0) ? vapp * 1.3 : 180.0; // لضبط مكانها بشكل مناسب على الممر
    final double ratio = (vapp / maxSpeedRef).clamp(0.1, 0.9);
    final double vappX = runwayStartX + (ratio * usableWidth);

    _drawSingleMarker(canvas, vappX, "VAPP", vapp.toInt(),
        const Color(0xFFFFB300), runwayTop, runwayBottom);
  }

  void _drawSingleMarker(
    Canvas canvas,
    double x,
    String label,
    int speedValue,
    Color color,
    double runwayTop,
    double runwayBottom,
  ) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // خط مستقيم يقطع الممر
    canvas.drawLine(
        Offset(x, runwayTop - 4), Offset(x, runwayBottom + 20), linePaint);

    // سهم التأشير
    final Path arrowPath = Path()
      ..moveTo(x, runwayBottom)
      ..lineTo(x - 5, runwayBottom + 8)
      ..lineTo(x + 5, runwayBottom + 8)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = color);

    // تجهيز المربع والنص
    final double badgeY = runwayBottom + 35;
    final String text = "$label ${speedValue}KT";

    final TextSpan span = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final double badgeWidth = tp.width + 16;
    final double badgeHeight = tp.height + 8;

    final Rect badgeRect = Rect.fromCenter(
      center: Offset(x, badgeY),
      width: badgeWidth,
      height: badgeHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF1E2429),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    tp.paint(canvas, Offset(x - (tp.width / 2), badgeY - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant LandingRunwayPainter oldDelegate) {
    return oldDelegate.runwayLength != runwayLength || oldDelegate.vapp != vapp;
  }
}
