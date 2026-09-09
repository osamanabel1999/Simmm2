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

import 'dart:math' as math;

class PushbackController extends StatefulWidget {
  const PushbackController({
    Key? key,
    this.width,
    this.height,
    required this.onConnect,
    required this.onDisconnect,
    required this.onStop,
    required this.onStraight,
    required this.onTailLeft,
    required this.onTailRight,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Future Function() onConnect;
  final Future Function() onDisconnect;
  final Future Function() onStop;
  final Future Function() onStraight;
  final Future Function() onTailLeft;
  final Future Function() onTailRight;

  @override
  _PushbackControllerState createState() => _PushbackControllerState();
}

class _PushbackControllerState extends State<PushbackController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding:
              const EdgeInsets.all(12.0), // تقليل الحواف قليلاً لزيادة المساحة
          child: Column(
            children: [
              // الهيدر العلوي: الأزرار الرئيسية موزعة بالتساوي (لا يوجد Heading لتفادي الـ Overflow)
              _buildTopBar(),
              const SizedBox(height: 12),
              // أزرار التحكم بالتوجيه موزعة بالتساوي
              _buildSteeringButtonsRow(),
              const SizedBox(height: 12),
              // شاشة الملاحة ورسم الطائرات الثلاث والأسهم الخضراء
              Expanded(
                child: _buildInteractiveDeck(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: _buildHeaderActionButton(
            label: "CONNECT",
            icon: Icons.link,
            color: const Color(0xFF10B981),
            onTap: widget.onConnect,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHeaderActionButton(
            label: "DISCONNECT",
            icon: Icons.link_off,
            color: const Color(0xFFF59E0B),
            onTap: widget.onDisconnect,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildHeaderActionButton(
            label: "STOP",
            icon: Icons.stop_circle,
            color: const Color(0xFFEF4444),
            onTap: widget.onStop,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Future Function() onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async => await onTap(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.7), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteeringButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSteerButton(
            title: "TAIL LEFT",
            subtitle: "FACE RIGHT",
            icon: Icons.turn_left,
            color: const Color(0xFF00FF88),
            onTap: widget.onTailLeft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSteerButton(
            title: "STRAIGHT",
            subtitle: "PUSHBACK",
            icon: Icons.arrow_downward,
            color: const Color(0xFF00FF88),
            onTap: widget.onStraight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSteerButton(
            title: "TAIL RIGHT",
            subtitle: "FACE LEFT",
            icon: Icons.turn_right,
            color: const Color(0xFF00FF88),
            onTap: widget.onTailRight,
          ),
        ),
      ],
    );
  }

  Widget _buildSteerButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Future Function() onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async => await onTap(),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF131C2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveDeck() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // شبكة خلفية رادار
            Positioned.fill(
              child: CustomPaint(
                painter: RadarGridPainter(),
              ),
            ),
            // خطوط التوجيه الخضراء المضيئة
            Positioned.fill(
              child: CustomPaint(
                painter: GuidanceLinesPainter(
                  lineGlowColor: const Color(0xFF00FF88),
                ),
              ),
            ),
            // الطائرات الثلاث
            LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                final double h = constraints.maxHeight;
                // تكبير الطائرة قليلاً لتوضيح التفاصيل
                final double planeSize =
                    math.min(w * 0.28, h * 0.55).clamp(80.0, 150.0);

                return Stack(
                  children: [
                    // الطائرة اليسرى
                    Positioned(
                      left: w * 0.20 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: _buildPlaneItem(
                        angle: -0.45,
                        size: planeSize,
                        label: "TAIL LEFT",
                        onTap: widget.onTailLeft,
                      ),
                    ),
                    // الطائرة الوسطى
                    Positioned(
                      left: w * 0.50 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: _buildPlaneItem(
                        angle: 0.0,
                        size: planeSize,
                        label: "STRAIGHT",
                        onTap: widget.onStraight,
                      ),
                    ),
                    // الطائرة اليمنى
                    Positioned(
                      left: w * 0.80 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: _buildPlaneItem(
                        angle: 0.45,
                        size: planeSize,
                        label: "TAIL RIGHT",
                        onTap: widget.onTailRight,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaneItem({
    required double angle,
    required double size,
    required String label,
    required Future Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async => await onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: angle,
            child: CustomPaint(
              size: Size(size, size),
              painter: AirlinerPainter(
                // تم التغيير لمجسم الطائرة المدنية الجديد
                bodyColor: const Color(0xFF0F172A),
                glowColor: const Color(0xFF00FF88),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF00FF88).withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسم شبكة الرادار الخلفية
class RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double stepY = size.height / 8;
    for (double y = stepY; y < size.height; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double stepX = size.width / 8;
    for (double x = stepX; x < size.width; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// رسم خطوط المسار الفسفورية المضيئة والأسهم
class GuidanceLinesPainter extends CustomPainter {
  final Color lineGlowColor;

  GuidanceLinesPainter({this.lineGlowColor = const Color(0xFF00FF88)});

  @override
  void paint(Canvas canvas, Size size) {
    final double startX = size.width / 2;
    final double startY = size.height * 0.05;

    final double leftX = size.width * 0.20;
    final double centerX = size.width * 0.50;
    final double rightX = size.width * 0.80;
    final double endY = size.height * 0.65;

    final linePaint = Paint()
      ..color = lineGlowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final glowPaint = Paint()
      ..color = lineGlowColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    _drawArrowPath(canvas, Offset(startX, startY), Offset(leftX, endY),
        linePaint, glowPaint, lineGlowColor);
    _drawArrowPath(canvas, Offset(startX, startY), Offset(centerX, endY),
        linePaint, glowPaint, lineGlowColor);
    _drawArrowPath(canvas, Offset(startX, startY), Offset(rightX, endY),
        linePaint, glowPaint, lineGlowColor);
  }

  void _drawArrowPath(Canvas canvas, Offset p1, Offset p2, Paint linePaint,
      Paint glowPaint, Color color) {
    canvas.drawLine(p1, p2, glowPaint);
    canvas.drawLine(p1, p2, linePaint);

    final double angle = (p2 - p1).direction;
    final double arrowLength = 12.0;
    final double arrowAngle = math.pi / 6;

    final Path arrowPath = Path();
    arrowPath.moveTo(p2.dx, p2.dy);
    arrowPath.lineTo(
      p2.dx - arrowLength * math.cos(angle - arrowAngle),
      p2.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    arrowPath.lineTo(
      p2.dx - arrowLength * math.cos(angle + arrowAngle),
      p2.dy - arrowLength * math.sin(angle + arrowAngle),
    );
    arrowPath.close();

    final arrowFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, glowPaint);
    canvas.drawPath(arrowPath, arrowFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// رسم مجسم طائرة A320/B737 الدقيق جداً
class AirlinerPainter extends CustomPainter {
  final Color bodyColor;
  final Color glowColor;

  AirlinerPainter({
    this.bodyColor = const Color(0xFF0F172A),
    this.glowColor = const Color(0xFF00FF88),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    final fillPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final glowLinePaint = Paint()
      ..color = glowColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // 1. الأجنحة (Swept Wings)
    final wingsPath = Path();
    // الجناح الأيمن
    wingsPath.moveTo(cx + w * 0.05, h * 0.38); // بداية الجناح من الجسم
    wingsPath.lineTo(cx + w * 0.48, h * 0.62); // طرف الجناح الأمامي (عوجة)
    wingsPath.lineTo(cx + w * 0.45, h * 0.68); // طرف الجناح الخلفي
    wingsPath.lineTo(cx + w * 0.05, h * 0.58); // عودة للجسم
    // الجناح الأيسر
    wingsPath.moveTo(cx - w * 0.05, h * 0.38);
    wingsPath.lineTo(cx - w * 0.48, h * 0.62);
    wingsPath.lineTo(cx - w * 0.45, h * 0.68);
    wingsPath.lineTo(cx - w * 0.05, h * 0.58);

    _drawShape(canvas, wingsPath, fillPaint, outlinePaint, glowLinePaint);

    // 2. الجناح الخلفي (Horizontal Stabilizer)
    final tailWingsPath = Path();
    // الأيمن
    tailWingsPath.moveTo(cx + w * 0.03, h * 0.86);
    tailWingsPath.lineTo(cx + w * 0.22, h * 0.94);
    tailWingsPath.lineTo(cx + w * 0.20, h * 0.98);
    tailWingsPath.lineTo(cx + w * 0.02, h * 0.94);
    // الأيسر
    tailWingsPath.moveTo(cx - w * 0.03, h * 0.86);
    tailWingsPath.lineTo(cx - w * 0.22, h * 0.94);
    tailWingsPath.lineTo(cx - w * 0.20, h * 0.98);
    tailWingsPath.lineTo(cx - w * 0.02, h * 0.94);

    _drawShape(canvas, tailWingsPath, fillPaint, outlinePaint, glowLinePaint);

    // 3. المحركات (Engines) - بارزة أسفل الجناحين بلمسة واقعية
    final rightEngine = RRect.fromLTRBR(
      cx + w * 0.15,
      h * 0.38,
      cx + w * 0.21,
      h * 0.50,
      const Radius.circular(4),
    );
    final leftEngine = RRect.fromLTRBR(
      cx - w * 0.21,
      h * 0.38,
      cx - w * 0.15,
      h * 0.50,
      const Radius.circular(4),
    );

    canvas.drawRRect(rightEngine, glowLinePaint);
    canvas.drawRRect(rightEngine, fillPaint);
    canvas.drawRRect(rightEngine, outlinePaint);

    canvas.drawRRect(leftEngine, glowLinePaint);
    canvas.drawRRect(leftEngine, fillPaint);
    canvas.drawRRect(leftEngine, outlinePaint);

    // 4. هيكل الطائرة الرئيسي (Fuselage)
    final bodyPath = Path();
    bodyPath.moveTo(cx, h * 0.05); // مقدمة الطائرة (Radome)
    bodyPath.cubicTo(cx + w * 0.08, h * 0.06, cx + w * 0.10, h * 0.15,
        cx + w * 0.09, h * 0.25); // انحناء المقدمة الأيمن
    bodyPath.lineTo(cx + w * 0.09, h * 0.80); // خط الجسم الأيمن المستقيم
    bodyPath.cubicTo(cx + w * 0.09, h * 0.92, cx + w * 0.03, h * 0.98, cx,
        h * 1.0); // ذيل الطائرة الأيمن (APU cone)

    bodyPath.cubicTo(cx - w * 0.03, h * 0.98, cx - w * 0.09, h * 0.92,
        cx - w * 0.09, h * 0.80); // ذيل الطائرة الأيسر
    bodyPath.lineTo(cx - w * 0.09, h * 0.25); // خط الجسم الأيسر المستقيم
    bodyPath.cubicTo(cx - w * 0.10, h * 0.15, cx - w * 0.08, h * 0.06, cx,
        h * 0.05); // انحناء المقدمة الأيسر
    bodyPath.close();

    _drawShape(canvas, bodyPath, fillPaint, outlinePaint, glowLinePaint);

    // 5. زجاج قمرة القيادة (Cockpit Windows)
    final cockpitPath = Path();
    cockpitPath.moveTo(cx - w * 0.05, h * 0.14);
    cockpitPath.quadraticBezierTo(cx, h * 0.10, cx + w * 0.05, h * 0.14);
    cockpitPath.lineTo(cx + w * 0.03, h * 0.17);
    cockpitPath.quadraticBezierTo(cx, h * 0.14, cx - w * 0.03, h * 0.17);
    cockpitPath.close();

    final cockpitPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(cockpitPath, cockpitPaint);
  }

  void _drawShape(
      Canvas canvas, Path path, Paint fill, Paint outline, Paint glow) {
    canvas.drawPath(path, glow);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
