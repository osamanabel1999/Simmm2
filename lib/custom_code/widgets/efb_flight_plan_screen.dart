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

// --- ألوان EFB الاحترافية ---
const Color efbBg = Color(0xFF0B111A);
const Color efbCard = Color(0xFF101923);
const Color efbBorder = Color(0xFF26364D);
const Color efbTextMuted = Color(0xFF8B949E);
const Color efbAccent = Color(0xFF639DF0);
const Color efbWhite = Color(0xFFFFFFFF);

// --- ألوان الحالات والتحذيرات ---
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

  bool _isRouteExpanded = false;
  bool _isDepNotamExpanded = false;
  bool _isArrNotamExpanded = false;

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

    _fetchSimBriefData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- 1. جلب بيانات SimBrief ---
  Future<void> _fetchSimBriefData() async {
    String cleanId = widget.pilotId.trim();

    if (cleanId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "No Pilot ID provided. Please connect your SimBrief account.";
        _ofpData = null;
        _isLoading = false;
      });
      return;
    }

    try {
      // اللينك الصريح بناءً على طلبك (userid فقط)
      final url = Uri.parse(
          "https://www.simbrief.com/api/xml.fetcher.php?userid=${Uri.encodeComponent(cleanId)}&json=1");
      final response = await http.get(url);

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = "SimBrief returned invalid JSON format.";
          _ofpData = null;
          _isLoading = false;
        });
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 400) {
        if (data is! Map ||
            data['general'] == null ||
            data['general'] is! Map ||
            data['general']['icao_airline'] == null) {
          String apiError =
              (data is Map && data['fetch'] != null && data['fetch'] is Map)
                  ? (data['fetch']['status']?.toString() ??
                      "No active flight plan found.")
                  : "No active flight plan found.";

          if (!mounted) return;
          setState(() {
            _errorMessage = "SimBrief Alert: $apiError";
            _ofpData = null;
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _ofpData = data;
            _errorMessage = "";
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              "Connection Error (${response.statusCode}). Showing empty layout.";
          _ofpData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Network timeout or parsing error. Showing empty layout.";
        _ofpData = null;
        _isLoading = false;
      });
    }
  }

  // --- دوال مساعدة ---
  void _copyToClipboard(String text, String label) {
    if (text == "---" || text.isEmpty) return;
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

  // --- 2. التصميم الرئيسي للشاشة ---
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: efbBg,
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: efbAccent))
            : Column(
                children: [
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: cDanger.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: efbWhite, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_errorMessage,
                                  style: const TextStyle(
                                      color: efbWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                        ],
                      ),
                    ),
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Expanded(
                            flex: 4,
                            child: ListView(
                              children: [
                                _buildRouteAndEnvCard(),
                                const SizedBox(height: 12),
                                _buildStepClimbsCard(),
                                const SizedBox(height: 12),
                                _buildWeatherNotamCard(
                                    "DEPARTURE", _ofpData?['origin']),
                                const SizedBox(height: 12),
                                _buildWeatherNotamCard(
                                    "ARRIVAL", _ofpData?['destination']),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildLiveNavlogCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildHomeIndicator(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
      ),
    );
  }

  // --- 3. بناء الأقسام ---

  Widget _buildHeader() {
    final Map? gen = _ofpData?['general'] is Map ? _ofpData!['general'] : null;

    // تأمين الـ Type Casting تماماً بإستخدام ?.toString()
    final String origin = (_ofpData?['origin'] is Map)
        ? (_ofpData!['origin']['icao_code']?.toString() ?? "---")
        : "---";
    final String dest = (_ofpData?['destination'] is Map)
        ? (_ofpData!['destination']['icao_code']?.toString() ?? "---")
        : "---";

    final String airline = gen?['icao_airline']?.toString() ?? "";
    final String fltNum = gen?['flight_number']?.toString() ?? "";
    final String callsign =
        "$airline$fltNum".trim().isNotEmpty ? "$airline$fltNum" : "---";

    final String acType = gen?['aircraft']?.toString() ?? "---";

    const String prefileVatsim = "https://my.vatsim.net/pilots/flightplan";
    const String prefileIvao = "https://fpl.ivao.aero/flight-plans/create";
    final String pdfUrl = gen != null
        ? "https://www.simbrief.com/ofp/flightplans/${gen['c_ofp_id']}_pdf.pdf"
        : "https://www.simbrief.com";

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
    final Map? times = _ofpData?['times'] is Map ? _ofpData!['times'] : null;
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
    final Map? w = _ofpData?['weights'] is Map ? _ofpData!['weights'] : null;

    double zfw = double.tryParse(w?['est_zfw']?.toString() ?? "0") ?? 0;
    double tow = double.tryParse(w?['est_tow']?.toString() ?? "0") ?? 0;
    double law = double.tryParse(w?['est_ldw']?.toString() ?? "0") ?? 0;

    double mzfw = double.tryParse(w?['max_zfw']?.toString() ?? "1") ?? 1;
    double mtow = double.tryParse(w?['max_tow']?.toString() ?? "1") ?? 1;
    double mlaw = double.tryParse(w?['max_ldw']?.toString() ?? "1") ?? 1;

    if (mzfw <= 0) mzfw = 1;
    if (mtow <= 0) mtow = 1;
    if (mlaw <= 0) mlaw = 1;

    return _buildCardWrapper(
      title: "SMART WEIGHTS & PAYLOAD",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PAX: ${w?['pax_count']?.toString() ?? '---'}",
                  style: const TextStyle(
                      color: efbWhite, fontWeight: FontWeight.bold)),
              Text("CARGO: ${w?['cargo']?.toString() ?? '---'} KG",
                  style: const TextStyle(
                      color: efbWhite, fontWeight: FontWeight.bold)),
              Text("PAYLOAD: ${w?['payload']?.toString() ?? '---'} KG",
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
    double percentage = max == 1 ? 0 : (actual / max).clamp(0.0, 1.0);
    if (percentage.isNaN || percentage.isInfinite) percentage = 0.0;

    Color barColor = cSafe;
    if (percentage > 0.98)
      barColor = cDanger;
    else if (percentage > 0.90) barColor = cWarn;

    String actualStr = actual == 0 ? "---" : actual.toInt().toString();
    String maxStr = max == 1 ? "---" : max.toInt().toString();

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
            Text("$actualStr / $maxStr KG",
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
                width: double.infinity,
                decoration: BoxDecoration(
                    color: efbBg, borderRadius: BorderRadius.circular(5))),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: barColor, borderRadius: BorderRadius.circular(5))),
            ),
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
    final Map? f = _ofpData?['fuel'] is Map ? _ofpData!['fuel'] : null;
    double trip = double.tryParse(f?['enroute_burn']?.toString() ?? "0") ?? 0;
    double cont = double.tryParse(f?['contingency']?.toString() ?? "0") ?? 0;
    double alt = double.tryParse(f?['alternate_burn']?.toString() ?? "0") ?? 0;
    double res = double.tryParse(f?['reserve']?.toString() ?? "0") ?? 0;
    double taxi = double.tryParse(f?['taxi']?.toString() ?? "0") ?? 0;
    double extra = double.tryParse(f?['extra']?.toString() ?? "0") ?? 0;
    double block = double.tryParse(f?['plan_ramp']?.toString() ?? "0") ?? 0;

    String blockStr = block == 0 ? "---" : block.toInt().toString();

    return _buildCardWrapper(
      title: "ADVANCED FUEL BREAKDOWN",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("BLOCK FUEL: $blockStr KG",
                style: const TextStyle(
                    color: efbWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (block == 0)
                  Expanded(child: Container(height: 16, color: efbBg)),
                _buildFuelSegment(trip, const Color(0xFF42A5F5)),
                _buildFuelSegment(cont, cWarn),
                _buildFuelSegment(alt, cSafe),
                _buildFuelSegment(res, cDanger),
                _buildFuelSegment(taxi, Colors.purpleAccent),
                _buildFuelSegment(extra, efbTextMuted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendDot(const Color(0xFF42A5F5),
                  "TRIP: ${trip == 0 ? '---' : trip.toInt()}"),
              _buildLegendDot(
                  cWarn, "CONT: ${cont == 0 ? '---' : cont.toInt()}"),
              _buildLegendDot(cSafe, "ALTN: ${alt == 0 ? '---' : alt.toInt()}"),
              _buildLegendDot(
                  cDanger, "RESV: ${res == 0 ? '---' : res.toInt()}"),
              _buildLegendDot(Colors.purpleAccent,
                  "TAXI: ${taxi == 0 ? '---' : taxi.toInt()}"),
              if (extra > 0)
                _buildLegendDot(efbTextMuted, "EXTRA: ${extra.toInt()}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFuelSegment(double amount, Color color) {
    if (amount <= 0) return const SizedBox();
    int flexVal = (amount * 10).toInt();
    if (flexVal <= 0) flexVal = 1;

    return Expanded(
      flex: flexVal,
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
    final Map? gen = _ofpData?['general'] is Map ? _ofpData!['general'] : null;
    final String route = gen?['route']?.toString() ?? "---";
    final Map? weather =
        _ofpData?['weather'] is Map ? _ofpData!['weather'] : null;

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
                if (route.length > 80)
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
              _buildInfoColumn(
                  "COST INDEX",
                  gen != null && gen['costindex'] != null
                      ? "CI ${gen['costindex']}"
                      : "---"),
              _buildInfoColumn(
                  "AVG WIND", weather?['avg_wind_comp']?.toString() ?? "---"),
              _buildInfoColumn(
                  "ISA DEV", weather?['isa_deviation']?.toString() ?? "---"),
              _buildInfoColumn(
                  "TROPOPAUSE", weather?['tropopause']?.toString() ?? "---"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStepClimbsCard() {
    final dynamic steps = (_ofpData != null && _ofpData!['stepclimbs'] is Map)
        ? _ofpData!['stepclimbs']['step']
        : null;

    if (steps == null) {
      return _buildCardWrapper(
        title: "STEP CLIMBS PROFILE",
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("No Step Climbs Planned",
              style:
                  TextStyle(color: efbTextMuted, fontWeight: FontWeight.bold)),
        ),
      );
    }

    List<dynamic> stepList = steps is List ? steps : [steps];

    return _buildCardWrapper(
      title: "STEP CLIMBS PROFILE",
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stepList.length,
          itemBuilder: (context, index) {
            final Map? step = stepList[index] is Map ? stepList[index] : null;
            if (step == null) return const SizedBox();

            return Row(
              children: [
                Tooltip(
                  message:
                      "Fix: ${step['name']?.toString() ?? '---'}\nWind: ${step['wind_dir']?.toString() ?? '---'}/${step['wind_spd']?.toString() ?? '---'}",
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
                          "FL${(int.tryParse(step['level']?.toString() ?? "0") ?? 0) ~/ 100}",
                          style: const TextStyle(
                              color: efbWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(step['name']?.toString() ?? "---",
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

  Widget _buildWeatherNotamCard(String type, dynamic airportDataRaw) {
    final Map? airportData = airportDataRaw is Map ? airportDataRaw : null;
    final String icao = airportData?['icao_code']?.toString() ?? "---";
    final String metar = airportData?['metar']?.toString() ?? "---";
    final String taf = airportData?['taf']?.toString() ?? "---";
    final String atis = airportData?['atis']?.toString() ?? "---";

    // --- الحل الجذري لمشكلة النوتام اللي ظهرت في الـ JSON بتاعك ---
    String notamStr = "---";
    if (airportData != null && airportData['notam'] != null) {
      if (airportData['notam'] is List) {
        List notamList = airportData['notam'] as List;
        notamStr = notamList.map((n) {
          if (n is Map)
            return n['notam_raw']?.toString() ??
                n['notam_text']?.toString() ??
                n.toString();
          return n.toString();
        }).join("\n\n---\n\n");
      } else {
        notamStr = airportData['notam'].toString();
      }
    }

    bool isDep = type == "DEPARTURE";
    bool isExpanded = isDep ? _isDepNotamExpanded : _isArrNotamExpanded;

    return _buildCardWrapper(
      title: "$type WEATHER & NOTAM ($icao)",
      actionWidget: ElevatedButton.icon(
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
                            _copyToClipboard(notamStr, "$icao NOTAMs"),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notamStr.replaceAll(RegExp(r'\n+'), '\n\n'),
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
    final dynamic navlogRaw = (_ofpData != null && _ofpData!['navlog'] is Map)
        ? _ofpData!['navlog']['fix']
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: efbCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: efbBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("LIVE MASTER NAVLOG",
              style: TextStyle(
                  color: efbAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const Divider(color: efbBorder, height: 20, thickness: 1),
          Expanded(
            child: navlogRaw == null
                ? const Center(
                    child: Text("---",
                        style: TextStyle(color: efbTextMuted, fontSize: 18)))
                : _buildNavlogList(navlogRaw is List ? navlogRaw : [navlogRaw]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavlogList(List<dynamic> fixes) {
    int activeIndex = _calculateActiveWaypointIndex(fixes);

    return ListView.builder(
      itemCount: fixes.length,
      itemBuilder: (context, index) {
        final Map? fix = fixes[index] is Map ? fixes[index] : null;
        if (fix == null) return const SizedBox();

        bool isPassed = index < activeIndex;
        bool isActive = index == activeIndex;

        Color textColor = isPassed ? efbTextMuted.withOpacity(0.5) : efbWhite;
        TextDecoration decoration =
            isPassed ? TextDecoration.lineThrough : TextDecoration.none;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                    width: 2,
                    height: 16,
                    color: isPassed ? efbBorder : efbAccent.withOpacity(0.5)),
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
                    color: isPassed ? efbBorder : efbAccent.withOpacity(0.5)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fix['ident']?.toString() ?? "UNK",
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
                            style: TextStyle(color: textColor, fontSize: 12)),
                        Text(
                            "DTG: ${fix['distance_to_dest']?.toString() ?? '0'} NM",
                            style: TextStyle(color: textColor, fontSize: 12)),
                        Text(
                            "EFOB: ${fix['fuel_plan_on_board']?.toString() ?? '0'} T",
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
    );
  }

  int _calculateActiveWaypointIndex(List<dynamic> fixes) {
    if (fixes.isEmpty || (widget.currentLat == 0 && widget.currentLon == 0))
      return 0;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < fixes.length; i++) {
      if (fixes[i] is! Map) continue;
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
    const double r = 3440.065;
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
    if (timestamp == null) return "---";
    int ts = int.tryParse(timestamp.toString()) ?? 0;
    if (ts == 0) return "---";
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}Z";
  }

  String _formatDuration(dynamic secondsStr) {
    if (secondsStr == null) return "---";
    int seconds = int.tryParse(secondsStr.toString()) ?? 0;
    if (seconds == 0) return "---";
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  Widget _buildHomeIndicator({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
        alignment: Alignment.center,
        child: Container(
          width: 130,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
