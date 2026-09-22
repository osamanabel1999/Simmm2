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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

// --- ألوان EFB الاحترافية (حسب طلبك) ---
const Color efbBg = Color(0xFF0B111A);
const Color efbCard = Color(0xFF101923);
const Color efbBorder = Color(0xFF26364D);
const Color efbTextMuted = Color(0xFF8B949E);
const Color efbAccent = Color(0xFF639DF0);
const Color efbWhite = Color(0xFFFFFFFF);

// --- ألوان الحالات والتحذيرات (Smart Limits) ---
const Color cDanger = Color(0xFFFF5252);
const Color cWarn = Color(0xFFFFD740);
const Color cSafe = Color(0xFF69F0AE);

class EfbFlightPlanScreen extends StatefulWidget {
  final double? width;
  final double? height;

  // الـ 5 Parameters المطلوبة بدقة
  final String pilotId;
  final double currentLat;
  final double currentLon;
  final Future<dynamic> Function() onDepartureAtisPressed;
  final Future<dynamic> Function() onArrivalAtisPressed;

  const EfbFlightPlanScreen({
    Key? key,
    this.width,
    this.height,
    required this.pilotId,
    required this.currentLat,
    required this.currentLon,
    required this.onDepartureAtisPressed,
    required this.onArrivalAtisPressed,
  }) : super(key: key);

  @override
  State<EfbFlightPlanScreen> createState() => _EfbFlightPlanScreenState();
}

class _EfbFlightPlanScreenState extends State<EfbFlightPlanScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = "";
  Map<String, dynamic>? _ofpData;

  // للتحكم في الأقسام القابلة للتوسعة (Expandable)
  bool _isRouteExpanded = false;
  bool _isDepNotamExpanded = false;
  bool _isArrNotamExpanded = false;

  // أنيميشن النقطة النشطة (الرادار)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fetchSimBriefData(); // تحميل الداتا فوراً بناءً على الآيدي
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- 1. جلب بيانات SimBrief ---
  Future<void> _fetchSimBriefData() async {
    if (widget.pilotId.isEmpty) {
      setState(() {
        _errorMessage = "Pilot ID is missing.";
        _isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse(
          "https://www.simbrief.com/api/xml.fetcher.php?username=${widget.pilotId}&json=1");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Error') {
          setState(() {
            _errorMessage = data['fetch']['status'] ?? "SimBrief Error";
            _isLoading = false;
          });
        } else {
          setState(() {
            _ofpData = data;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to connect to SimBrief (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error or invalid data format.";
        _isLoading = false;
      });
    }
  }

  // --- دوال مساعدة (لنسخ النصوص وفتح الروابط) ---
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text("$label Copied!", style: const TextStyle(color: efbWhite)),
          backgroundColor: efbBorder,
          duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Could not open link", style: TextStyle(color: efbWhite)),
            backgroundColor: cDanger),
      );
    }
  }

  // --- 2. التصميم الرئيسي للشاشة (3 أعمدة للأيباد) ---
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: efbBg,
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: efbAccent))
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(_errorMessage,
                        style: const TextStyle(
                            color: cDanger,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)))
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العمود الأول: الأوقات، الأوزان، الوقود
                Expanded(
                  flex: 3,
                  child: ListView(
                    children: [
                      _buildTimesCard(),
                      const SizedBox(height: 12),
                      _buildSmartWeightsCard(),
                      const SizedBox(height: 12),
                      _buildFuelBreakdownCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // العمود الثاني: المسار، الطقس، النوتام
                Expanded(
                  flex: 4,
                  child: ListView(
                    children: [
                      _buildRouteAndEnvCard(),
                      const SizedBox(height: 12),
                      _buildStepClimbsCard(),
                      const SizedBox(height: 12),
                      _buildWeatherNotamCard("DEPARTURE", _ofpData?['origin']),
                      const SizedBox(height: 12),
                      _buildWeatherNotamCard(
                          "ARRIVAL", _ofpData?['destination']),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // العمود الثالث: سجل الملاحة الحي (Navlog)
                Expanded(
                  flex: 3,
                  child: _buildLiveNavlogCard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. بناء الأقسام (Widgets) ---

  Widget _buildHeader() {
    final gen = _ofpData?['general'];
    final origin = _ofpData?['origin']?['icao_code'] ?? "---";
    final dest = _ofpData?['destination']?['icao_code'] ?? "---";
    final callsign = "${gen?['icao_airline']}${gen?['flight_number']}";
    final acType = gen?['aircraft'] ?? "---";

    // روابط استخراج الخطة
    final prefileVatsim =
        "https://my.vatsim.net/pilots/flightplan"; // يحتاج بناء دقيق لو أردت، وضعنا الرابط العام كمثال
    final prefileIvao = "https://fpl.ivao.aero/flight-plans/create";
    final pdfUrl =
        "https://www.simbrief.com/ofp/flightplans/${gen?['c_ofp_id']}_pdf.pdf";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: efbCard,
        border: Border(bottom: BorderSide(color: efbBorder, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$callsign • $acType",
                  style: const TextStyle(
                      color: efbTextMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(origin,
                      style: const TextStyle(
                          color: efbAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.flight_takeoff,
                          color: efbTextMuted, size: 24)),
                  Text(dest,
                      style: const TextStyle(
                          color: efbAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderBtn(
                  "PDF OFP", Icons.picture_as_pdf, () => _launchUrl(pdfUrl)),
              const SizedBox(width: 8),
              _buildHeaderBtn("VATSIM", Icons.network_check,
                  () => _launchUrl(prefileVatsim)),
              const SizedBox(width: 8),
              _buildHeaderBtn(
                  "IVAO", Icons.network_wifi, () => _launchUrl(prefileIvao)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderBtn(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: efbWhite),
      label: Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          backgroundColor: efbBorder, foregroundColor: efbWhite, elevation: 0),
    );
  }

  Widget _buildTimesCard() {
    final times = _ofpData?['times'];
    return _buildCardWrapper(
      title: "TIMES & SCHEDULE",
      child: Column(
        children: [
          _buildInfoRow("STD (Sched Dep)", _formatTime(times?['sched_out'])),
          _buildInfoRow("ETD (Est Dep)", _formatTime(times?['est_out'])),
          const Divider(color: efbBorder, height: 16),
          _buildInfoRow("STA (Sched Arr)", _formatTime(times?['sched_in'])),
          _buildInfoRow("ETA (Est Arr)", _formatTime(times?['est_in'])),
          const Divider(color: efbBorder, height: 16),
          _buildInfoRow("Block Time", _formatDuration(times?['est_block'])),
          _buildInfoRow(
              "Air Time", _formatDuration(times?['est_time_enroute'])),
        ],
      ),
    );
  }

  Widget _buildSmartWeightsCard() {
    final w = _ofpData?['weights'];

    // قيم فعلية
    double zfw = double.tryParse(w?['est_zfw']?.toString() ?? "0") ?? 0;
    double tow = double.tryParse(w?['est_tow']?.toString() ?? "0") ?? 0;
    double law = double.tryParse(w?['est_ldw']?.toString() ?? "0") ?? 0;

    // حدود أقصى
    double mzfw = double.tryParse(w?['max_zfw']?.toString() ?? "1") ?? 1;
    double mtow = double.tryParse(w?['max_tow']?.toString() ?? "1") ?? 1;
    double mlaw = double.tryParse(w?['max_ldw']?.toString() ?? "1") ?? 1;

    return _buildCardWrapper(
      title: "SMART WEIGHTS & PAYLOAD",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PAX: ${w?['pax_count'] ?? '0'}",
                  style: const TextStyle(
                      color: efbWhite, fontWeight: FontWeight.bold)),
              Text("CARGO: ${w?['cargo'] ?? '0'} KG",
                  style: const TextStyle(
                      color: efbWhite, fontWeight: FontWeight.bold)),
              Text("PAYLOAD: ${w?['payload'] ?? '0'} KG",
                  style: const TextStyle(
                      color: efbWhite, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeightProgressBar("ZFW", zfw, mzfw),
          const SizedBox(height: 12),
          _buildWeightProgressBar("TOW", tow, mtow),
          const SizedBox(height: 12),
          _buildWeightProgressBar("LAW", law, mlaw),
        ],
      ),
    );
  }

  Widget _buildWeightProgressBar(String label, double actual, double max) {
    double percentage = (actual / max).clamp(0.0, 1.0);
    Color barColor = cSafe; // أخضر افتراضي
    if (percentage > 0.98)
      barColor = cDanger; // تجاوز أو قريب جداً من الخطر
    else if (percentage > 0.90) barColor = cWarn; // تحذير

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: efbTextMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            Text("${actual.toInt()} / ${max.toInt()} KG",
                style: TextStyle(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
                height: 10,
                decoration: BoxDecoration(
                    color: efbBg, borderRadius: BorderRadius.circular(5))),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: barColor, borderRadius: BorderRadius.circular(5))),
            ),
            // مؤشر الحد الأقصى
            Positioned(
              right: 0,
              child: Container(width: 2, height: 10, color: efbWhite),
            )
          ],
        )
      ],
    );
  }

  Widget _buildFuelBreakdownCard() {
    final f = _ofpData?['fuel'];
    double trip = double.tryParse(f?['enroute_burn']?.toString() ?? "0") ?? 0;
    double cont = double.tryParse(f?['contingency']?.toString() ?? "0") ?? 0;
    double alt = double.tryParse(f?['alternate_burn']?.toString() ?? "0") ?? 0;
    double res = double.tryParse(f?['reserve']?.toString() ?? "0") ?? 0;
    double taxi = double.tryParse(f?['taxi']?.toString() ?? "0") ?? 0;
    double extra = double.tryParse(f?['extra']?.toString() ?? "0") ?? 0;
    double block =
        double.tryParse(f?['plan_ramp']?.toString() ?? "1") ?? 1; // إجمالي

    return _buildCardWrapper(
      title: "ADVANCED FUEL BREAKDOWN",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("BLOCK FUEL: ${block.toInt()} KG",
                style: const TextStyle(
                    color: efbWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          // الشريط الملون
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                _buildFuelSegment(
                    trip, block, const Color(0xFF42A5F5)), // أزرق (Trip)
                _buildFuelSegment(cont, block, cWarn), // أصفر (Contingency)
                _buildFuelSegment(alt, block, cSafe), // أخضر (Alternate)
                _buildFuelSegment(res, block, cDanger), // أحمر (Reserve)
                _buildFuelSegment(
                    taxi, block, Colors.purpleAccent), // بنفسجي (Taxi)
                _buildFuelSegment(extra, block, efbTextMuted), // رمادي (Extra)
              ],
            ),
          ),
          const SizedBox(height: 12),
          // مفتاح الألوان (Legend)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendDot(const Color(0xFF42A5F5), "TRIP: ${trip.toInt()}"),
              _buildLegendDot(cWarn, "CONT: ${cont.toInt()}"),
              _buildLegendDot(cSafe, "ALTN: ${alt.toInt()}"),
              _buildLegendDot(cDanger, "RESV: ${res.toInt()}"),
              _buildLegendDot(Colors.purpleAccent, "TAXI: ${taxi.toInt()}"),
              if (extra > 0)
                _buildLegendDot(efbTextMuted, "EXTRA: ${extra.toInt()}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFuelSegment(double amount, double total, Color color) {
    if (amount <= 0) return const SizedBox();
    return Expanded(
      flex: (amount * 1000).toInt(), // تكبير الرقم لضبط النسبة في الـ flex
      child: Container(height: 16, color: color),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: efbTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRouteAndEnvCard() {
    final gen = _ofpData?['general'];
    String route = gen?['route'] ?? "NO ROUTE DATA";

    return _buildCardWrapper(
      title: "ROUTE & ENVIRONMENT",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ATC ROUTE CLEARANCE",
                  style: TextStyle(
                      color: efbTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.copy, color: efbAccent, size: 18),
                  onPressed: () => _copyToClipboard(route, "ATC Route"),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: efbBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: efbBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                      color: efbWhite,
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'monospace'),
                  maxLines: _isRouteExpanded ? null : 2,
                  overflow: _isRouteExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (route.length > 80) // إظهار زر Expand لو المسار طويل
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isRouteExpanded = !_isRouteExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          _isRouteExpanded ? "SHOW LESS" : "EXPAND ROUTE",
                          style: const TextStyle(
                              color: efbAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("COST INDEX", "CI ${gen?['costindex'] ?? '-'}"),
              _buildInfoColumn(
                  "AVG WIND", _ofpData?['weather']?['avg_wind_comp'] ?? "---"),
              _buildInfoColumn(
                  "ISA DEV", _ofpData?['weather']?['isa_deviation'] ?? "---"),
              _buildInfoColumn(
                  "TROPOPAUSE", _ofpData?['weather']?['tropopause'] ?? "---"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStepClimbsCard() {
    final steps = _ofpData?['stepclimbs']?['step'];
    if (steps == null) return const SizedBox(); // إخفاء لو مفيش ستيبس

    // معالجة إذا كانت نقطة واحدة (Map) أو عدة نقاط (List)
    List<dynamic> stepList = steps is List ? steps : [steps];

    return _buildCardWrapper(
      title: "STEP CLIMBS PROFILE",
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stepList.length,
          itemBuilder: (context, index) {
            final step = stepList[index];
            return Row(
              children: [
                Tooltip(
                  message:
                      "Fix: ${step['name']}\nWind: ${step['wind_dir']}/${step['wind_spd']}",
                  textStyle: const TextStyle(
                      color: efbBg, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                      color: efbWhite, borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_circle_up,
                          color: efbAccent, size: 20),
                      const SizedBox(height: 4),
                      Text(
                          "FL${(int.tryParse(step['level'].toString()) ?? 0) ~/ 100}",
                          style: const TextStyle(
                              color: efbWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(step['name'].toString(),
                          style: const TextStyle(
                              color: efbTextMuted, fontSize: 10)),
                    ],
                  ),
                ),
                if (index < stepList.length - 1)
                  Container(
                    width: 40,
                    height: 2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    color: efbBorder,
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherNotamCard(String type, dynamic airportData) {
    if (airportData == null) return const SizedBox();

    final icao = airportData['icao_code'];
    final metar = airportData['metar'] ?? "No METAR available";
    final taf = airportData['taf'] ?? "No TAF available";
    final atis = airportData['atis'] ?? "No D-ATIS available";
    final notam = airportData['notam'] ?? "No NOTAMs available";

    bool isDep = type == "DEPARTURE";
    bool isExpanded = isDep ? _isDepNotamExpanded : _isArrNotamExpanded;

    return _buildCardWrapper(
      title: "$type WEATHER & NOTAM ($icao)",
      actionWidget: ElevatedButton.icon(
        // ربط الزراير بالـ Parameters المطلوبة
        onPressed:
            isDep ? widget.onDepartureAtisPressed : widget.onArrivalAtisPressed,
        icon: const Icon(Icons.volume_up, size: 14, color: efbWhite),
        label: const Text("ATIS AUDIO", style: TextStyle(fontSize: 10)),
        style: ElevatedButton.styleFrom(
            backgroundColor: efbAccent,
            minimumSize: const Size(0, 24),
            padding: const EdgeInsets.symmetric(horizontal: 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextReport("METAR", metar),
          const SizedBox(height: 8),
          _buildTextReport("TAF", taf),
          const SizedBox(height: 8),
          _buildTextReport("D-ATIS", atis),
          const SizedBox(height: 12),

          // قسم النوتام القابل للتوسعة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: efbBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cWarn.withOpacity(0.5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("NOTAMs",
                        style: TextStyle(
                            color: cWarn,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    IconButton(
                        icon: const Icon(Icons.copy,
                            color: efbTextMuted, size: 16),
                        onPressed: () =>
                            _copyToClipboard(notam, "$icao NOTAMs"),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notam
                      .toString()
                      .replaceAll(RegExp(r'\n+'), '\n\n'), // تنسيق النوتام
                  style: const TextStyle(
                      color: efbWhite, fontSize: 12, fontFamily: 'monospace'),
                  maxLines: isExpanded ? null : 3,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isDep)
                        _isDepNotamExpanded = !_isDepNotamExpanded;
                      else
                        _isArrNotamExpanded = !_isArrNotamExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        isExpanded ? "COLLAPSE NOTAMs" : "EXPAND NOTAMs",
                        style: const TextStyle(
                            color: cWarn,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextReport(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: efbAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _copyToClipboard(text, label),
              child: const Icon(Icons.copy, color: efbTextMuted, size: 14),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(text,
            style: const TextStyle(
                color: efbWhite, fontSize: 12, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildLiveNavlogCard() {
    final navlog = _ofpData?['navlog']?['fix'];
    if (navlog == null)
      return const Center(
          child: Text("No Navlog Data", style: TextStyle(color: efbWhite)));

    List<dynamic> fixes = navlog is List ? navlog : [navlog];

    // تحديد النقطة النشطة برمجياً (أقرب نقطة للطائرة)
    int activeIndex = _calculateActiveWaypointIndex(fixes);

    return _buildCardWrapper(
      title: "LIVE MASTER NAVLOG",
      child: Expanded(
        child: ListView.builder(
          itemCount: fixes.length,
          itemBuilder: (context, index) {
            final fix = fixes[index];
            bool isPassed = index < activeIndex;
            bool isActive = index == activeIndex;
            bool isFuture = index > activeIndex;

            // تحديد ألوان وحالات العناصر
            Color textColor =
                isPassed ? efbTextMuted.withOpacity(0.5) : efbWhite;
            TextDecoration decoration =
                isPassed ? TextDecoration.lineThrough : TextDecoration.none;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رسم الخط الزمني
                Column(
                  children: [
                    Container(
                        width: 2,
                        height: 16,
                        color:
                            isPassed ? efbBorder : efbAccent.withOpacity(0.5)),
                    if (isActive)
                      FadeTransition(
                        opacity: _pulseAnimation,
                        child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                                color: efbAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: efbAccent, blurRadius: 10)
                                ])),
                      )
                    else
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isPassed ? efbBg : efbBorder,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isPassed ? efbBorder : efbWhite, width: 2),
                        ),
                      ),
                    Container(
                        width: 2,
                        height: 40,
                        color:
                            isPassed ? efbBorder : efbAccent.withOpacity(0.5)),
                  ],
                ),
                const SizedBox(width: 12),
                // بيانات النقطة
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(fix['ident'] ?? "UNK",
                                style: TextStyle(
                                    color: isActive ? efbAccent : textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: decoration)),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: efbAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: efbAccent)),
                                  child: const Text("ACTIVE",
                                      style: TextStyle(
                                          color: efbAccent,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold))),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "FL${(int.tryParse(fix['altitude_feet']?.toString() ?? "0") ?? 0) ~/ 100}",
                                style:
                                    TextStyle(color: textColor, fontSize: 12)),
                            Text("DTG: ${fix['distance_to_dest'] ?? '0'} NM",
                                style:
                                    TextStyle(color: textColor, fontSize: 12)),
                            Text("EFOB: ${fix['fuel_plan_on_board'] ?? '0'} T",
                                style: TextStyle(
                                    color: isActive ? cSafe : textColor,
                                    fontSize: 12,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // --- دوال رياضية للرادار ---
  int _calculateActiveWaypointIndex(List<dynamic> fixes) {
    // نبحث عن أقرب نقطة للطائرة لتكون هي النقطة النشطة
    if (widget.currentLat == 0 && widget.currentLon == 0)
      return 0; // حماية لو لم يرسل المحاكي داتا بعد

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < fixes.length; i++) {
      double fixLat =
          double.tryParse(fixes[i]['pos_lat']?.toString() ?? "0") ?? 0;
      double fixLon =
          double.tryParse(fixes[i]['pos_long']?.toString() ?? "0") ?? 0;

      double dist = _haversineDistance(
          widget.currentLat, widget.currentLon, fixLat, fixLon);
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double r = 3440.065; // نصف قطر الأرض بالميل البحري (NM)
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final double c = 2 * math.asin(math.sqrt(a));
    return r * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;

  // --- دوال بناء الـ UI العامة ---

  Widget _buildCardWrapper(
      {required String title, required Widget child, Widget? actionWidget}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: efbCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: efbBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: efbAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              if (actionWidget != null) actionWidget,
            ],
          ),
          const Divider(color: efbBorder, height: 20, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: efbTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(
                  color: efbWhite,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: efbTextMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: efbWhite, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "--:--";
    int ts = int.tryParse(timestamp.toString()) ?? 0;
    if (ts == 0) return "--:--";
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}Z";
  }

  String _formatDuration(dynamic secondsStr) {
    int seconds = int.tryParse(secondsStr?.toString() ?? "0") ?? 0;
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }
}
