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

class AircraftServicesWidget extends StatefulWidget {
  const AircraftServicesWidget({
    Key? key,
    this.width,
    this.height,
    this.onMainDoorToggle,
    this.onCargoDoorToggle,
    this.onServiceDoorToggle,
    this.onToggleAllDoors,
    this.onJetwayToggle,
  }) : super(key: key);

  final double? width;
  final double? height;

  // الـ Parameters الخمسة المستقلة الخاصة بأوامر البايثون
  final Future Function()? onMainDoorToggle;
  final Future Function()? onCargoDoorToggle;
  final Future Function()? onServiceDoorToggle;
  final Future Function()? onToggleAllDoors;
  final Future Function()? onJetwayToggle;

  @override
  _AircraftServicesWidgetState createState() => _AircraftServicesWidgetState();
}

class _AircraftServicesWidgetState extends State<AircraftServicesWidget> {
  // ============================================================
  // ألوان الثيم الاحترافي الموحدة (EFB Dark Theme)
  // ============================================================
  final Color bgColor = const Color(0xFF0B111A); // الخلفية اللي بره خالص
  final Color cardBgColor = const Color(0xFF101923); // خلفية الكونتينر والزراير
  final Color borderColor = const Color(0xFF26364D); // لون الحواف الموحد
  final Color blueAccent =
      const Color(0xFF639DF0); // اللون الأزرق الشيك لكل الأيقونات والتوهج

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitle("AIRCRAFT DOORS CONTROL", Icons.door_sliding),
              const SizedBox(height: 16),

              // شبكة زراير الأبواب (تم استخدام الزرار التفاعلي الموحد)
              Row(
                children: [
                  AnimatedServiceButton(
                    title: "MAIN DOOR",
                    subtitle: "Passenger Entry",
                    icon: Icons.meeting_room,
                    color: blueAccent,
                    cardBgColor: cardBgColor,
                    onTap: widget.onMainDoorToggle,
                  ),
                  const SizedBox(width: 16),
                  AnimatedServiceButton(
                    title: "CARGO DOOR",
                    subtitle: "Baggage Hold",
                    icon: Icons.inventory_2_outlined,
                    color: blueAccent,
                    cardBgColor: cardBgColor,
                    onTap: widget.onCargoDoorToggle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedServiceButton(
                    title: "SERVICE DOOR",
                    subtitle: "Catering & Supply",
                    icon: Icons.local_dining,
                    color: blueAccent,
                    cardBgColor: cardBgColor,
                    onTap: widget.onServiceDoorToggle,
                  ),
                  const SizedBox(width: 16),
                  AnimatedServiceButton(
                    title: "ALL DOORS",
                    subtitle: "Open / Close All",
                    icon: Icons.sync,
                    color: blueAccent,
                    cardBgColor: cardBgColor,
                    onTap: widget.onToggleAllDoors,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _buildHeaderTitle("GROUND EQUIPMENT", Icons.settings_ethernet),
              const SizedBox(height: 16),

              // زرار الـ Jetway بعرض الشاشة
              Row(
                children: [
                  AnimatedServiceButton(
                    title: "JETWAY BRIDGE",
                    subtitle: "Connect / Disconnect",
                    icon: Icons.link,
                    color: blueAccent,
                    cardBgColor: cardBgColor,
                    onTap: widget.onJetwayToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت عنوان السكشن
  Widget _buildHeaderTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: blueAccent, size: 20), // تم توحيد اللون
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: blueAccent, // تم توحيد اللون
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: borderColor,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// كلاس منفصل للزرار لعمل الـ Animation والـ Glow Effect عند الضغط
// ============================================================
class AnimatedServiceButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color cardBgColor;
  final Future Function()? onTap;

  const AnimatedServiceButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.cardBgColor,
    this.onTap,
  }) : super(key: key);

  @override
  _AnimatedServiceButtonState createState() => _AnimatedServiceButtonState();
}

class _AnimatedServiceButtonState extends State<AnimatedServiceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) async {
          setState(() => _isPressed = false);
          if (widget.onTap != null) {
            await widget.onTap!();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0, // تصغير الزرار عند الضغط
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.color
                      .withOpacity(0.05) // تغيير بسيط في الخلفية عند الضغط
                  : widget.cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withOpacity(_isPressed ? 0.6 : 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isPressed ? 0.2 : 0.08),
                  blurRadius: _isPressed ? 18 : 12,
                  spreadRadius: _isPressed ? 2 : 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(_isPressed ? 0.25 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
