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

class BriefingPageWidget extends StatefulWidget {
  const BriefingPageWidget({
    Key? key,
    this.width,
    this.height,
    // ==========================================
    // Parameters - Departure (مطار المغادرة)
    // ==========================================
    this.departureRwyCode,
    this.departureSidCode,
    this.departureWxCat,
    this.departureVisibility,
    this.departureWind,
    this.departureV1Speed,
    this.departureVrSpeed,
    this.departureV2Speed,
    this.departureEtow,
    this.departureMtow,
    // ==========================================
    // Parameters - Arrival (مطار الوصول)
    // ==========================================
    this.arrivalRwyCode,
    this.arrivalStarCode,
    this.arrivalWxCat,
    this.arrivalVisibility,
    this.arrivalWind,
    this.arrivalVrefSpeed,
    this.arrivalFlapsSetting,
    this.arrivalRwyLength,
    this.arrivalElw,
    this.arrivalMlw,
    // ==========================================
    // Actions - Voice Briefing (أوامر تشغيل الصوت)
    // ==========================================
    this.onStartDepartureBriefing,
    this.onStartArrivalBriefing,
  }) : super(key: key);

  final double? width;
  final double? height;

  final String? departureRwyCode;
  final String? departureSidCode;
  final String? departureWxCat;
  final String? departureVisibility;
  final String? departureWind;
  final String? departureV1Speed;
  final String? departureVrSpeed;
  final String? departureV2Speed;
  final String? departureEtow;
  final String? departureMtow;

  final String? arrivalRwyCode;
  final String? arrivalStarCode;
  final String? arrivalWxCat;
  final String? arrivalVisibility;
  final String? arrivalWind;
  final String? arrivalVrefSpeed;
  final String? arrivalFlapsSetting;
  final String? arrivalRwyLength;
  final String? arrivalElw;
  final String? arrivalMlw;

  // المتغيرات الخاصة بالضغط على الزراير (محفوظة بالكامل)
  final Future Function()? onStartDepartureBriefing;
  final Future Function()? onStartArrivalBriefing;

  @override
  State<BriefingPageWidget> createState() => _BriefingPageWidgetState();
}

class _BriefingPageWidgetState extends State<BriefingPageWidget> {
  // ============================================================
  // ألوان التصميم الموحدة الجديدة (نفس الكود اللي فات بالمللي)
  // ============================================================
  final Color bgColor = const Color(0xFF0B111A); // الخلفية اللي ورا خالص
  final Color cardColor = const Color(0xFF101923); // خلفية الكونتينرات الكبيرة
  final Color blockColor =
      const Color(0xFF0B111A); // خلفية المربعات الصغيرة والزراير
  final Color accentColor =
      const Color(0xFF639DF0); // لون زرار الـ ATIS الأزرق الشيك
  final Color textLabelColor = const Color(0xFF8B949E); // لون النصوص الرمادية
  final Color textValueColor = const Color(0xFFE5E7EB); // لون النصوص البيضاء
  final Color panelBorder = const Color(0xFF26364D); // حواف الكونتينر الموحدة

  // تصميم مربع البيانات (تم توحيد الحواف والخلفية)
  Widget _buildDataBlock(String label, String? value) {
    final displayValue = (value != null && value.isNotEmpty) ? value : "---";

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: panelBorder, width: 1.0), // حواف موحدة
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textLabelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: TextStyle(
                color: textValueColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // تصميم زرار الصوت الجديد (تم توحيده مع تصميم زرار الـ ATIS)
  Widget _buildActionButton(
      String title, IconData icon, Future Function()? action) {
    return InkWell(
      onTap: () {
        if (action != null) {
          action();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: panelBorder, width: 1.0), // حواف موحدة
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // رأس القسم (Title)
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 1,
            color: panelBorder,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // ==========================================
            // كارت مطار المغادرة (DEPARTURE)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border:
                    Border.all(color: panelBorder, width: 1.0), // حواف موحدة
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader(
                      "DEPARTURE BRIEFING", Icons.flight_takeoff_rounded),
                  const SizedBox(height: 24),

                  // الصف الأول للمغادرة
                  Row(
                    children: [
                      _buildDataBlock("RWY", widget.departureRwyCode),
                      _buildDataBlock("SID", widget.departureSidCode),
                      _buildDataBlock("WX CAT", widget.departureWxCat),
                      _buildDataBlock("VIS", widget.departureVisibility),
                      _buildDataBlock("WIND", widget.departureWind),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // الصف الثاني للمغادرة
                  Row(
                    children: [
                      _buildDataBlock("V1", widget.departureV1Speed),
                      _buildDataBlock("VR", widget.departureVrSpeed),
                      _buildDataBlock("V2", widget.departureV2Speed),
                      _buildDataBlock("ETOW", widget.departureEtow),
                      _buildDataBlock("MTOW", widget.departureMtow),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // زر الأكشن للمغادرة
                  _buildActionButton(
                    "START DEPARTURE AUDIO",
                    Icons.volume_up,
                    widget.onStartDepartureBriefing,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // كارت مطار الوصول (ARRIVAL)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border:
                    Border.all(color: panelBorder, width: 1.0), // حواف موحدة
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader(
                      "ARRIVAL BRIEFING", Icons.flight_land_rounded),
                  const SizedBox(height: 24),

                  // الصف الأول للوصول
                  Row(
                    children: [
                      _buildDataBlock("RWY", widget.arrivalRwyCode),
                      _buildDataBlock("STAR", widget.arrivalStarCode),
                      _buildDataBlock("WX CAT", widget.arrivalWxCat),
                      _buildDataBlock("VIS", widget.arrivalVisibility),
                      _buildDataBlock("WIND", widget.arrivalWind),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // الصف الثاني للوصول
                  Row(
                    children: [
                      _buildDataBlock("VREF", widget.arrivalVrefSpeed),
                      _buildDataBlock("FLAPS", widget.arrivalFlapsSetting),
                      _buildDataBlock("LENGTH", widget.arrivalRwyLength),
                      _buildDataBlock("ELW", widget.arrivalElw),
                      _buildDataBlock("MLW", widget.arrivalMlw),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // زر الأكشن للوصول
                  _buildActionButton(
                    "START ARRIVAL AUDIO",
                    Icons.volume_up,
                    widget.onStartArrivalBriefing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
