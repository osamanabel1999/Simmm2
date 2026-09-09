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

class EfbRunwayVspeedsWidget extends StatefulWidget {
  const EfbRunwayVspeedsWidget({
    Key? key,
    this.width,
    this.height,
    required this.runwayLength,
    required this.v1,
    required this.vr,
    required this.v2,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double runwayLength;
  final double v1;
  final double vr;
  final double v2;

  @override
  _EfbRunwayVspeedsWidgetState createState() => _EfbRunwayVspeedsWidgetState();
}

class _EfbRunwayVspeedsWidgetState extends State<EfbRunwayVspeedsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300, // زودنا الارتفاع لاستيعاب الخطوط المكسورة
      color: const Color(0xFF14181B),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: CustomPaint(
          painter: RunwayPainter(
            runwayLength: widget.runwayLength,
            v1: widget.v1,
            vr: widget.vr,
            v2: widget.v2,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class RunwayPainter extends CustomPainter {
  final double runwayLength;
  final double v1;
  final double vr;
  final double v2;

  RunwayPainter({
    required this.runwayLength,
    required this.v1,
    required this.vr,
    required this.v2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingX = 25.0;
    final double runwayStartX = paddingX;
    final double runwayEndX = size.width - paddingX;
    final double usableWidth = runwayEndX - runwayStartX;

    // 1. رسم خط مؤشر طول الممر
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

    final String lengthText = "${runwayLength.toInt()} M / TORA";
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

    // 2. رسم الممر وتفاصيله
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
        thresholdPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(runwayEndX - 16, runwayTop + 6 + (i * keyHeight), 12,
            keyHeight - 2),
        thresholdPaint,
      );
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

    // 3. حساب مسارات السرعات بكسرة احترافية (Dog-leg routing)
    final double maxSpeedRef = (v2 > 0) ? v2 * 1.15 : 180.0;

    double getXForSpeed(double speed) {
      final double ratio = (speed / maxSpeedRef).clamp(0.05, 0.95);
      return runwayStartX + (ratio * usableWidth);
    }

    // نقطة البداية على الممر
    final double v1StartX = getXForSpeed(v1);
    final double vrStartX = getXForSpeed(vr);
    final double v2StartX = getXForSpeed(v2);

    // المسار المكسور يمين ويسار لمنع التداخل (Offsets)
    final double v1LabelX = v1StartX - 40; // نكسر الخط 40 بيكسل شمال
    final double vrLabelX = vrStartX; // ينزل مستقيم
    final double v2LabelX = v2StartX + 40; // نكسر الخط 40 بيكسل يمين

    // مستويات متدرجة إضافية لضمان عدم التداخل نهائياً
    final double v1LabelY = runwayBottom + 45;
    final double vrLabelY = runwayBottom + 85;
    final double v2LabelY = runwayBottom + 125;

    _drawDogLegMarker(canvas, v1StartX, v1LabelX, v1LabelY, "V1", v1.toInt(),
        const Color(0xFF00E5FF), runwayTop, runwayBottom);
    _drawDogLegMarker(canvas, vrStartX, vrLabelX, vrLabelY, "VR", vr.toInt(),
        const Color(0xFF00E676), runwayTop, runwayBottom);
    _drawDogLegMarker(canvas, v2StartX, v2LabelX, v2LabelY, "V2", v2.toInt(),
        const Color(0xFFE040FB), runwayTop, runwayBottom);
  }

  void _drawDogLegMarker(
    Canvas canvas,
    double startX,
    double labelX,
    double labelY,
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

    // رسم الخط المكسور
    Path path = Path();
    path.moveTo(startX, runwayTop - 4);
    path.lineTo(startX, runwayBottom + 8); // ينزل تحت الممر شوية

    // الكسرة
    double dogLegStartY = runwayBottom + 16;
    double dogLegEndY = runwayBottom + 30;

    path.lineTo(startX, dogLegStartY);
    path.lineTo(labelX, dogLegEndY);
    path.lineTo(labelX, labelY); // النزول للمربع

    canvas.drawPath(path, linePaint);

    // سهم التأشير على الممر
    final Path arrowPath = Path()
      ..moveTo(startX, runwayBottom)
      ..lineTo(startX - 5, runwayBottom + 8)
      ..lineTo(startX + 5, runwayBottom + 8)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = color);

    // تجهيز النص والمربع
    final String text = "$label ${speedValue}KT";
    final TextSpan span = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
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

    // المربع هيكون متسنتر على نهاية الخط المكسور (labelX, labelY)
    final Rect badgeRect = Rect.fromCenter(
      center: Offset(labelX, labelY),
      width: badgeWidth,
      height: badgeHeight,
    );

    // رسم المربع
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

    // رسم النص داخل المربع
    tp.paint(canvas, Offset(labelX - (tp.width / 2), labelY - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant RunwayPainter oldDelegate) {
    return oldDelegate.runwayLength != runwayLength ||
        oldDelegate.v1 != v1 ||
        oldDelegate.vr != vr ||
        oldDelegate.v2 != v2;
  }
}
