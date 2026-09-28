// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
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
import 'package:flutter_svg/flutter_svg.dart'; // ضروري لعرض الطيارة الجديدة

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
  // ألوان التصميم الموحدة الجديدة
  final Color bgColor = const Color(0xFF0B111A); // الخلفية اللي بره خالص
  final Color cardColor =
      const Color(0xFF101923); // خلفية الكروت والمنطقة اللي تحت
  final Color panelBorder = const Color(0xFF26364D); // لون الحواف الموحد
  final Color blueAccent = const Color(0xFF639DF0); // اللون الأزرق الشيك الجديد

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: bgColor, // تم توحيد اللون
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: panelBorder, width: 2), // تم توحيد الحواف
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // الهيدر العلوي
              _buildTopBar(),
              const SizedBox(height: 12),
              // أزرار التحكم بالتوجيه موزعة بالتساوي (مع الإيفكت الجديد)
              _buildSteeringButtonsRow(),
              const SizedBox(height: 12),
              // شاشة الملاحة ورسم الطائرات الثلاث
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
          child: AnimatedSteerButton(
            title: "TAIL LEFT",
            subtitle: "FACE RIGHT",
            icon: Icons.turn_left,
            color: blueAccent, // اللون الأزرق الموحد
            onTap: widget.onTailLeft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSteerButton(
            title: "STRAIGHT",
            subtitle: "PUSHBACK",
            icon: Icons.arrow_downward,
            color: blueAccent, // اللون الأزرق الموحد
            onTap: widget.onStraight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSteerButton(
            title: "TAIL RIGHT",
            subtitle: "FACE LEFT",
            icon: Icons.turn_right,
            color: blueAccent, // اللون الأزرق الموحد
            onTap: widget.onTailRight,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveDeck() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, // تم توحيد اللون
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorder, width: 1.5), // تم توحيد الحواف
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // شبكة الرادار اتشالت بناءً على طلبك

            // خطوط التوجيه المضيئة (باللون الأزرق الجديد)
            Positioned.fill(
              child: CustomPaint(
                painter: GuidanceLinesPainter(
                  lineGlowColor: blueAccent,
                ),
              ),
            ),
            // الطائرات الثلاث
            LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                final double h = constraints.maxHeight;
                // تظبيط حجم الطيارة عشان متخبطش في الخطوط أو في بعضها
                final double planeSize =
                    math.min(w * 0.26, h * 0.50).clamp(70.0, 130.0);

                return Stack(
                  children: [
                    // الطائرة اليسرى (باصة شوية للشمال)
                    Positioned(
                      left: w * 0.20 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: AnimatedPlaneItem(
                        angle: -0.45, // الميل لليسار
                        size: planeSize,
                        label: "TAIL LEFT",
                        color: blueAccent,
                        onTap: widget.onTailLeft,
                      ),
                    ),
                    // الطائرة الوسطى (استريت باصة لقدام)
                    Positioned(
                      left: w * 0.50 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: AnimatedPlaneItem(
                        angle: 0.0, // استريت
                        size: planeSize,
                        label: "STRAIGHT",
                        color: blueAccent,
                        onTap: widget.onStraight,
                      ),
                    ),
                    // الطائرة اليمنى (باصة شوية لليمين)
                    Positioned(
                      left: w * 0.80 - planeSize / 2,
                      top: h * 0.72 - planeSize / 2,
                      child: AnimatedPlaneItem(
                        angle: 0.45, // الميل لليمين
                        size: planeSize,
                        label: "TAIL RIGHT",
                        color: blueAccent,
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
}

// ============================================================
// كلاس زرار التوجيه اللي بيعمل (Effect) عند الضغط
// ============================================================
class AnimatedSteerButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Future Function() onTap;

  const AnimatedSteerButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedSteerButtonState createState() => _AnimatedSteerButtonState();
}

class _AnimatedSteerButtonState extends State<AnimatedSteerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0, // تصغير الزرار عند الضغط
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.color.withOpacity(0.2) // بينور خفيف عند الضغط
                : const Color(0xFF0B111A), // لون خلفية الزرار
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: widget.color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isPressed ? 0.4 : 0.1),
                blurRadius: _isPressed ? 12 : 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 22),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.title,
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
                  widget.subtitle,
                  style: TextStyle(
                    color: widget.color,
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
}

// ============================================================
// كلاس الطيارة الـ SVG اللي بتعمل (Effect) عند الضغط مع ظبط الزوايا
// ============================================================
class AnimatedPlaneItem extends StatefulWidget {
  final double angle;
  final double size;
  final String label;
  final Color color;
  final Future Function() onTap;

  const AnimatedPlaneItem({
    Key? key,
    required this.angle,
    required this.size,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedPlaneItemState createState() => _AnimatedPlaneItemState();
}

class _AnimatedPlaneItemState extends State<AnimatedPlaneItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0, // تصغير الطيارة خفيف عند الضغط
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.color
                              .withOpacity(0.5), // هالة مضيئة عند الضغط
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Transform.rotate(
                // 🚀 السر هنا: بنضيف 180 درجة (math.pi) عشان نعدل الشقلبة بتاعة اللينك الأصلي
                angle: widget.angle + math.pi,
                child: SvgPicture.network(
                  'https://upload.wikimedia.org/wikipedia/commons/7/7e/Boeing_737-800_silhouette.svg',
                  width: widget.size * 0.65, // تصغير النسبة عشان متخبطش في الخط
                  height: widget.size * 0.65,
                  colorFilter: ColorFilter.mode(
                    widget.color,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.color.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// رسم خطوط المسار المضيئة (تم تعديل اللون ليتطابق مع الأزرق الشيك)
// ============================================================
class GuidanceLinesPainter extends CustomPainter {
  final Color lineGlowColor;

  GuidanceLinesPainter({required this.lineGlowColor});

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
