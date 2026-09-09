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
  // ألوان الثيم الاحترافي (Dark Aerospace Theme)
  final Color bgColor = const Color(0xFF14181B);
  final Color cardBgColor = const Color(0xFF111827);
  final Color borderColor = const Color(0xFF1E293B);

  final Color cyanAccent = const Color(0xFF00E5FF); // للأبواب الفردية
  final Color orangeAccent = const Color(0xFFFF9100); // لكل الأبواب
  final Color emeraldAccent = const Color(0xFF00E676); // لخرطوم المطار (Jetway)

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

              // شبكة زراير الأبواب
              Row(
                children: [
                  _buildServiceButton(
                    title: "MAIN DOOR",
                    subtitle: "Passenger Entry",
                    icon: Icons.meeting_room,
                    color: cyanAccent,
                    onTap: widget.onMainDoorToggle,
                  ),
                  const SizedBox(width: 16),
                  _buildServiceButton(
                    title: "CARGO DOOR",
                    subtitle: "Baggage Hold",
                    icon: Icons.inventory_2_outlined,
                    color: cyanAccent,
                    onTap: widget.onCargoDoorToggle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildServiceButton(
                    title: "SERVICE DOOR",
                    subtitle: "Catering & Supply",
                    icon: Icons.local_dining,
                    color: cyanAccent,
                    onTap: widget.onServiceDoorToggle,
                  ),
                  const SizedBox(width: 16),
                  _buildServiceButton(
                    title: "ALL DOORS",
                    subtitle: "Open / Close All",
                    icon: Icons.sync,
                    color: orangeAccent,
                    onTap: widget.onToggleAllDoors,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _buildHeaderTitle("GROUND EQUIPMENT", Icons.settings_ethernet),
              const SizedBox(height: 16),

              // زرار الـ Jetway بعرض الشاشة لشكل أفخم
              Row(
                children: [
                  _buildServiceButton(
                    title: "JETWAY BRIDGE",
                    subtitle: "Connect / Disconnect",
                    icon: Icons.link, // أيقونة آمنة وممتازة للتعبير عن الربط
                    color: emeraldAccent,
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

  // ويدجت عنوان السكشن (Sections Header)
  Widget _buildHeaderTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[300],
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

  // ويدجت الزرار الاحترافي مع تأثير الـ Glow
  Widget _buildServiceButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Future Function()? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (onTap != null) {
              await onTap();
            }
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                // توهج خفيف (Glow Effect) ورا الزرار
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
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
                    subtitle,
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
