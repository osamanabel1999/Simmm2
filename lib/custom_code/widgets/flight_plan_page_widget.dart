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

import 'package:flutter/services.dart';

class FlightPlanPageWidget extends StatefulWidget {
  const FlightPlanPageWidget({
    Key? key,
    this.width,
    this.height,
    // ==========================================
    // Parameters (المتغيرات لربطها بالـ API)
    // ==========================================
    this.routeTitle, // المتغير الخاص بـ (HECA -> OEJN)
    this.callsign,
    this.departure,
    this.arrival,
    this.alternate,
    this.aircraftType,
    this.altitude,
    this.airTime,
    this.distance,
    this.averageWind,
    this.cruise,
    this.departureMetar,
    this.departureTaf,
    this.arrivalMetar,
    this.arrivalTaf,
    this.departureNotamCode, // المتغير الخاص بكلمة (HECA) في النوتام
    this.departureNotam, // المتغير الخاص بالنص نفسه بتاع نوتام المغادرة
    this.arrivalNotamCode, // المتغير الخاص بكلمة (OEJN) في النوتام
    this.arrivalNotam, // المتغير الخاص بالنص نفسه بتاع نوتام الوصول

    // ==========================================
    // Actions (أوامر الضغط)
    // ==========================================
    this.onRouteTap, // الأكشن لما تدوس على مسار الرحلة
    this.onListenDepartureAtis, // أكشن زرار الـ ATIS للمغادرة
    this.onListenArrivalAtis, // أكشن زرار الـ ATIS للوصول
  }) : super(key: key);

  final double? width;
  final double? height;

  final String? routeTitle;
  final String? callsign;
  final String? departure;
  final String? arrival;
  final String? alternate;
  final String? aircraftType;
  final String? altitude;
  final String? airTime;
  final String? distance;
  final String? averageWind;
  final String? cruise;

  final String? departureMetar;
  final String? departureTaf;
  final String? arrivalMetar;
  final String? arrivalTaf;

  final String? departureNotamCode;
  final String? departureNotam;
  final String? arrivalNotamCode;
  final String? arrivalNotam;

  final Future Function()? onRouteTap;
  final Future Function()? onListenDepartureAtis;
  final Future Function()? onListenArrivalAtis;

  @override
  State<FlightPlanPageWidget> createState() => _FlightPlanPageWidgetState();
}

class _FlightPlanPageWidgetState extends State<FlightPlanPageWidget>
    with TickerProviderStateMixin {
  // متغيرات للتحكم في فتح وقفل النصوص الطويلة (الحركة الصايعة)
  bool isDepAirportExpanded = false;
  bool isArrAirportExpanded = false;
  bool isDepNotamExpanded = false;
  bool isArrNotamExpanded = false;

  // الألوان مطابقة للصورة باحترافية
  final Color bgColor = const Color(0xFF0F1115);
  final Color cardColor = const Color(0xFF15191E);
  final Color greenAccent = const Color(0xFF88C782);
  final Color blueAccent = const Color(0xFF639DF0);
  final Color labelColor = const Color(0xFF8B949E);
  final Color valueColor = const Color(0xFFE5E7EB);
  final Color buttonBgColor = const Color(0xFF212C45);

  // دالة النسخ مع السناك بار
  void _copyToClipboard(String text, String sectionName) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$sectionName copied successfully!',
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: cardColor, // تم تغييره للون الخلفية الغامق
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
      );
    }
  }

  // بناء عنصر بيانات صغير (زي الـ Callsign وغيرها)
  Widget _buildGridItem(String label, String? value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: labelColor, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                      color: labelColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value ?? "--",
              style: TextStyle(
                  color: valueColor, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // بناء الكروت الكبيرة اللي بتفتح وتقفل (النوتام والميتار)
  Widget _buildExpandableCard({
    required String title,
    required IconData titleIcon,
    required String content,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Title + Copy Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(titleIcon, color: blueAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                        color: blueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "COPY",
                    style: TextStyle(
                        color: blueAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Content with Animation (الحركة الصايعة)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.isEmpty ? "No data available." : content,
                  style:
                      TextStyle(color: labelColor, fontSize: 13, height: 1.5),
                  maxLines: isExpanded ? null : 4,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (content.length > 150) // إظهار الزرار لو النص طويل بس
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onToggle,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          isExpanded ? "- LESS" : "+ MORE",
                          style: TextStyle(
                              color: const Color(0xFF9C27B0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تجميع الميتار والتاف في نص واحد
    String combinedDepWeather =
        "${widget.departureMetar ?? ''}\n${widget.departureTaf ?? ''}".trim();
    String combinedArrWeather =
        "${widget.arrivalMetar ?? ''}\n${widget.arrivalTaf ?? ''}".trim();

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // Section 1: FLIGHT INFO
            // ==========================================
            Row(
              children: [
                Icon(Icons.flight, color: greenAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  "FLIGHT INFO",
                  style: TextStyle(
                      color: greenAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مسار الرحلة قابل للضغط
                  InkWell(
                    onTap: widget.onRouteTap,
                    child: Text(
                      widget.routeTitle ??
                          "HECA \u2192 OEJN", // سهم شيك بدل الشرطة
                      style: TextStyle(
                          color: blueAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildGridItem(
                          "CALLSIGN", widget.callsign, Icons.sensors),
                      _buildGridItem(
                          "DEPARTURE", widget.departure, Icons.flight_takeoff),
                      _buildGridItem(
                          "ARRIVAL", widget.arrival, Icons.flight_land),
                      _buildGridItem(
                          "ALTERNATE", widget.alternate, Icons.alt_route),
                      _buildGridItem("AIRCRAFT TYPE", widget.aircraftType,
                          Icons.airplanemode_active),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // Section 2: FLIGHT PLAN SUMMARY
            // ==========================================
            Row(
              children: [
                Icon(Icons.description, color: greenAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  "FLIGHT PLAN SUMMARY",
                  style: TextStyle(
                      color: greenAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  _buildGridItem("ALTITUDE", widget.altitude, Icons.height),
                  _buildGridItem("AIR TIME", widget.airTime, Icons.access_time),
                  _buildGridItem("DISTANCE", widget.distance, Icons.sync_alt),
                  _buildGridItem("AVERAGE WIND", widget.averageWind, Icons.air),
                  _buildGridItem("CRUISE", widget.cruise, Icons.speed),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // Section 3: Expandable Cards (Weather & NOTAMs)
            // ==========================================

            // Departure Airport Weather
            _buildExpandableCard(
              title: "DEPARTURE AIRPORT",
              titleIcon: Icons.flight_takeoff,
              content: combinedDepWeather,
              isExpanded: isDepAirportExpanded,
              onToggle: () =>
                  setState(() => isDepAirportExpanded = !isDepAirportExpanded),
              onCopy: () =>
                  _copyToClipboard(combinedDepWeather, "Departure Weather"),
            ),

            // Arrival Airport Weather
            _buildExpandableCard(
              title: "ARRIVAL AIRPORT",
              titleIcon: Icons.flight_land,
              content: combinedArrWeather,
              isExpanded: isArrAirportExpanded,
              onToggle: () =>
                  setState(() => isArrAirportExpanded = !isArrAirportExpanded),
              onCopy: () =>
                  _copyToClipboard(combinedArrWeather, "Arrival Weather"),
            ),

            // Departure NOTAM
            _buildExpandableCard(
              title: "${widget.departureNotamCode ?? 'DEP'} NOTAM",
              titleIcon: Icons.my_location,
              content: widget.departureNotam ?? "",
              isExpanded: isDepNotamExpanded,
              onToggle: () =>
                  setState(() => isDepNotamExpanded = !isDepNotamExpanded),
              onCopy: () => _copyToClipboard(
                  widget.departureNotam ?? "", "Departure NOTAM"),
            ),

            // Arrival NOTAM
            _buildExpandableCard(
              title: "${widget.arrivalNotamCode ?? 'ARR'} NOTAM",
              titleIcon: Icons.location_on,
              content: widget.arrivalNotam ?? "",
              isExpanded: isArrNotamExpanded,
              onToggle: () =>
                  setState(() => isArrNotamExpanded = !isArrNotamExpanded),
              onCopy: () =>
                  _copyToClipboard(widget.arrivalNotam ?? "", "Arrival NOTAM"),
            ),

            const SizedBox(height: 8),

            // ==========================================
            // Section 4: ATIS Buttons
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onListenDepartureAtis,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: buttonBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up, color: blueAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Listen to Departure ATIS",
                            style: TextStyle(
                                color: blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: widget.onListenArrivalAtis,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: buttonBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up, color: blueAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Listen to Arrival ATIS",
                            style: TextStyle(
                                color: blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
