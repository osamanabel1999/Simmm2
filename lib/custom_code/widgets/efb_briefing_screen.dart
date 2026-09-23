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
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';

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
const Color cWeather = Color(0xFF18FFFF);

class EfbBriefingScreen extends StatefulWidget {
  final double? width;
  final double? height;
  final String pilotId;

  const EfbBriefingScreen({
    Key? key,
    this.width,
    this.height,
    required this.pilotId,
  }) : super(key: key);

  @override
  State<EfbBriefingScreen> createState() => _EfbBriefingScreenState();
}

class _EfbBriefingScreenState extends State<EfbBriefingScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = "";
  Map<String, dynamic>? _ofpData;

  // --- Toggle State ---
  bool _isDepartureTab = true;

  // --- Audio & TTS Variables ---
  final FlutterEdgeTts _edgeTts = FlutterEdgeTts(voice: "en-US-GuyNeural");
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _cleanDepAudioText = "";
  String _cleanArrAudioText = "";

  bool _isAudioReady = false;
  bool _isPlaying = false;

  // --- Animations ---
  late AnimationController _windAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // --- Departure Computed Variables ---
  double depHeadwind = 0;
  double depCrosswind = 0;
  bool depIsCrosswindRight = true;
  int depThreatCount = 0;
  List<Widget> depThreatBadges = [];
  List<String> depThreatNames = [];

  // --- Arrival Computed Variables ---
  double arrHeadwind = 0;
  double arrCrosswind = 0;
  bool arrIsCrosswindRight = true;
  int arrThreatCount = 0;
  List<Widget> arrThreatBadges = [];
  List<String> arrThreatNames = [];

  @override
  void initState() {
    super.initState();
    _windAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fetchSimBriefData();
  }

  @override
  void dispose() {
    _windAnimationController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchSimBriefData() async {
    String cleanId = widget.pilotId.trim();
    if (cleanId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "No Pilot ID provided.";
        _isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse(
          "https://www.simbrief.com/api/xml.fetcher.php?userid=${Uri.encodeComponent(cleanId)}&json=1");
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = json.decode(response.body);
        if (data is! Map || data['general'] == null) {
          if (!mounted) return;
          setState(() {
            _errorMessage = "No active flight plan found for this ID.";
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _ofpData = Map<String, dynamic>.from(data);
            _errorMessage = "";
            _isLoading = false;
          });

          // تشغيل المحركات بطريقة آمنة
          _analyzeDepDataAndBuildTEM();
          _buildDepScriptAndPrepareAudio();

          _analyzeArrDataAndBuildTEM();
          _buildArrScriptAndPrepareAudio();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = "Connection Error (${response.statusCode}).";
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Parsing Error: $e\n$stackTrace");
      if (!mounted) return;
      setState(() {
        // لو حصلت مصيبة في البيانات هيقولك عليها بدل ما يقول "نت"
        _errorMessage = "Data Parsing Error: $e";
        _isLoading = false;
      });
    }
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // =========================================================================
  // ====================== محرك حسابات المغادرة =============================
  // =========================================================================
  void _analyzeDepDataAndBuildTEM() {
    if (_ofpData == null) return;

    final gen = _ofpData!['general'] ?? {};
    final origin = _ofpData!['origin'] ?? {};
    final wghts = _ofpData!['weights'] ?? {};

    // المعالجة الآمنة للرقم الخاص بالمدرج (حتى لو قيمته null)
    String rwyRaw = origin['plan_rwy']?.toString() ?? "36";
    String rwyStr = rwyRaw.replaceAll(RegExp(r'[A-Za-z]'), '');
    if (rwyStr.isEmpty) rwyStr = "36";
    double rwyHdg = (double.tryParse(rwyStr) ?? 36) * 10;

    double windDir = 0;
    double windSpd = 0;
    String metar = origin['metar']?.toString() ?? "";

    RegExp windRegex = RegExp(r'\b(\d{3})(\d{2,3})(?:G\d{2,3})?KT\b');
    Match? match = windRegex.firstMatch(metar);
    if (match != null) {
      windDir = double.tryParse(match.group(1) ?? "0") ?? 0;
      windSpd = double.tryParse(match.group(2) ?? "0") ?? 0;
    } else {
      windDir = double.tryParse(gen['avg_wind_dir']?.toString() ?? "0") ?? 0;
      windSpd = double.tryParse(gen['avg_wind_spd']?.toString() ?? "0") ?? 0;
    }

    double angleDiff = _toRadians(windDir - rwyHdg);
    depHeadwind = windSpd * math.cos(angleDiff);
    depCrosswind = windSpd * math.sin(angleDiff);
    depIsCrosswindRight = depCrosswind > 0;
    depCrosswind = depCrosswind.abs();

    depThreatBadges.clear();
    depThreatNames.clear();
    depThreatCount = 0;

    double tow = double.tryParse(wghts['est_tow']?.toString() ?? "0") ?? 0;
    double mtow = double.tryParse(wghts['max_tow']?.toString() ?? "1") ?? 1;

    if (metar.contains("TS") || metar.contains("CB")) {
      depThreatBadges.add(_buildBadge("THUNDERSTORMS", cDanger));
      depThreatNames.add("thunderstorms in the area");
      depThreatCount++;
    }
    if (metar.contains("RA") || metar.contains("SN")) {
      depThreatBadges.add(_buildBadge("WET/CONTAM RWY", cWarn));
      depThreatNames.add("a contaminated runway");
      depThreatCount++;
    }
    if (metar.contains("FG") || metar.contains("BR")) {
      depThreatBadges.add(_buildBadge("LOW VISIBILITY", cDanger));
      depThreatNames.add("low visibility operations");
      depThreatCount++;
    } else if (metar.contains("CAVOK")) {
      depThreatBadges.add(_buildBadge("VISIBILITY OK", cSafe));
    }

    if (depCrosswind > 15) {
      depThreatBadges.add(_buildBadge("HIGH CROSSWIND", cWarn));
      depThreatNames.add("high crosswind limits");
      depThreatCount++;
    }

    if (tow > mtow * 0.95 && mtow > 1) {
      depThreatBadges.add(_buildBadge("HEAVY AIRCRAFT", cWarn));
      depThreatNames.add("a very heavy takeoff weight");
      depThreatCount++;
    }

    if (depThreatCount == 0) {
      depThreatBadges.add(_buildBadge("STANDARD OPS - NO THREATS", cSafe));
    }
  }

  void _buildDepScriptAndPrepareAudio() {
    if (_ofpData == null) return;

    final gen = _ofpData!['general'] ?? {};
    final origin = _ofpData!['origin'] ?? {};
    final wghts = _ofpData!['weights'] ?? {};
    final fuel = _ofpData!['fuel'] ?? {};

    String callsign =
        "${gen['icao_airline'] ?? ""}${gen['flight_number'] ?? ""}";
    String originName = origin['name']?.toString() ??
        origin['icao_code']?.toString() ??
        "Origin";
    String rwy = origin['plan_rwy']?.toString() ?? "Unknown";

    // الحل الآمن للـ null chaining
    String routeStr = gen['route']?.toString() ?? "";
    String sid = routeStr.isEmpty ? "" : routeStr.split(' ').first;

    String metar = origin['metar']?.toString() ?? "";

    double towTons =
        (double.tryParse(wghts['est_tow']?.toString() ?? "0") ?? 0) / 1000;
    double blockTons =
        (double.tryParse(fuel['plan_ramp']?.toString() ?? "0") ?? 0) / 1000;
    double extraTons =
        (double.tryParse(fuel['extra']?.toString() ?? "0") ?? 0) / 1000;
    int holdMins = (extraTons * 25).round();

    int hour = DateTime.now().hour;
    String greeting = "Good evening";
    if (hour >= 5 && hour < 12)
      greeting = "Good morning";
    else if (hour >= 12 && hour < 17) greeting = "Good afternoon";

    List<String> intros = [
      "$greeting, Captain. Let’s run through the departure brief for flight $callsign.",
      "$greeting! Ready when you are. Here’s the departure briefing for $callsign.",
      "$greeting. Let's get our departure brief out of the way for $callsign."
    ];
    String intro = intros[math.Random().nextInt(intros.length)];

    String routingTxt = "";
    if (sid.isEmpty || sid == "DCT" || sid.length < 3) {
      routingTxt =
          "We are departing from $originName, planning Runway $rwy. Expecting radar vectors out of here today.";
    } else {
      routingTxt =
          "We are departing from $originName, planning Runway $rwy. We will follow the $sid departure.";
    }

    String windTxt =
        "Looking at the weather, we have a headwind of ${depHeadwind.round()} knots, and a crosswind component of ${depCrosswind.round()} knots.";
    if (depCrosswind > 15) {
      windTxt +=
          " It's a bit gusty from the side, I'll be ready on the ailerons.";
    }

    String cloudsTxt = "Skies look relatively clear.";
    if (metar.contains("SCT") ||
        metar.contains("BKN") ||
        metar.contains("OVC")) {
      cloudsTxt = "We have some cloud layers reported in the area.";
    }

    String weightTxt =
        "Our planned takeoff weight is ${towTons.toStringAsFixed(1)} tons. Block fuel is ${blockTons.toStringAsFixed(1)} tons. This includes ${extraTons.toStringAsFixed(1)} tons of extra fuel, which buys us roughly $holdMins minutes of holding time if things get busy.";

    String emergencyTxt =
        "Takeoff speeds and thrust are set. For the emergency brief: Any warning, caution, or engine failure prior to V 1, I will call STOP. We abort, apply max brakes, and max reverse thrust. If the failure occurs after V 1, we continue the takeoff, gear up with a positive rate, silence warnings, and manage the failure at a safe altitude.";

    String outro = "";
    if (depThreatCount == 0) {
      outro =
          "I don't see any operational threats for today. The weather is beautiful, and everything looks standard. It looks like it’s going to be a very enjoyable flight. Sit back, relax, and let's have a good one. Any questions?";
    } else {
      String threatsListed = depThreatNames.join(" and ");
      outro =
          "Alright, we have a few challenges to consider today, including $threatsListed. This will require a bit more effort and coordination. Let's stay sharp and keep our guard up. Any questions?";
    }

    String rawScript =
        "$intro $routingTxt $windTxt $cloudsTxt $weightTxt $emergencyTxt $outro";

    _cleanDepAudioText = rawScript
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    setState(() {
      _isAudioReady = true;
    });
  }

  // =========================================================================
  // ====================== محرك حسابات الوصول ===============================
  // =========================================================================
  void _analyzeArrDataAndBuildTEM() {
    if (_ofpData == null) return;

    final dest = _ofpData!['destination'] ?? {};
    final altn = _ofpData!['alternate'];
    final wghts = _ofpData!['weights'] ?? {};

    // المعالجة الآمنة
    String rwyRaw = dest['plan_rwy']?.toString() ?? "36";
    String rwyStr = rwyRaw.replaceAll(RegExp(r'[A-Za-z]'), '');
    if (rwyStr.isEmpty) rwyStr = "36";
    double rwyHdg = (double.tryParse(rwyStr) ?? 36) * 10;

    double windDir = 0;
    double windSpd = 0;
    String metar = dest['metar']?.toString() ?? "";

    RegExp windRegex = RegExp(r'\b(\d{3})(\d{2,3})(?:G\d{2,3})?KT\b');
    Match? match = windRegex.firstMatch(metar);
    if (match != null) {
      windDir = double.tryParse(match.group(1) ?? "0") ?? 0;
      windSpd = double.tryParse(match.group(2) ?? "0") ?? 0;
    }

    double angleDiff = _toRadians(windDir - rwyHdg);
    arrHeadwind = windSpd * math.cos(angleDiff);
    arrCrosswind = windSpd * math.sin(angleDiff);
    arrIsCrosswindRight = arrCrosswind > 0;
    arrCrosswind = arrCrosswind.abs();

    arrThreatBadges.clear();
    arrThreatNames.clear();
    arrThreatCount = 0;

    double elw = double.tryParse(wghts['est_ldw']?.toString() ?? "0") ?? 0;
    double mlw = double.tryParse(wghts['max_ldw']?.toString() ?? "1") ?? 1;

    // معالجة المطار البديل حتى لو كان List مش Map
    if (altn == null || (altn is List && altn.isEmpty)) {
      arrThreatBadges.add(_buildBadge("NO ALTERNATE FILED", cDanger));
      arrThreatNames.add("having no alternate airport");
      arrThreatCount++;
    }

    if (metar.contains("RA") || metar.contains("SN")) {
      arrThreatBadges.add(_buildBadge("CONTAMINATED RUNWAY", cWarn));
      arrThreatNames.add("a contaminated landing runway");
      arrThreatCount++;
    }
    if (metar.contains("FG") || metar.contains("BR") || metar.contains("LVP")) {
      arrThreatBadges.add(_buildBadge("LOW VISIBILITY (LVP)", cDanger));
      arrThreatNames.add("low visibility operations");
      arrThreatCount++;
    } else if (metar.contains("CAVOK")) {
      arrThreatBadges.add(_buildBadge("VISIBILITY OK", cSafe));
    }

    if (arrCrosswind > 15) {
      arrThreatBadges.add(_buildBadge("HIGH CROSSWIND", cWarn));
      arrThreatNames.add("high crosswind limits on touchdown");
      arrThreatCount++;
    }

    if (elw > mlw * 0.95 && mlw > 1) {
      arrThreatBadges.add(_buildBadge("HEAVY LANDING", cWarn));
      arrThreatNames.add("a very heavy landing weight");
      arrThreatCount++;
    }

    arrThreatBadges.add(_buildBadge("RWY LENGTH UNVERIFIED", cWarn));

    if (arrThreatCount == 0) {
      arrThreatBadges.add(_buildBadge("STANDARD APPROACH", cSafe));
    }
  }

  void _buildArrScriptAndPrepareAudio() {
    if (_ofpData == null) return;

    final gen = _ofpData!['general'] ?? {};
    final dest = _ofpData!['destination'] ?? {};
    final altn = _ofpData!['alternate'];
    final wghts = _ofpData!['weights'] ?? {};
    final fuel = _ofpData!['fuel'] ?? {};

    String callsign =
        "${gen['icao_airline'] ?? ""}${gen['flight_number'] ?? ""}";
    String destName = dest['name']?.toString() ??
        dest['icao_code']?.toString() ??
        "Destination";
    String arrRwy = dest['plan_rwy']?.toString() ?? "Unknown";
    String metar = dest['metar']?.toString() ?? "";

    String altnName = "";
    if (altn is Map) {
      altnName =
          altn['name']?.toString() ?? altn['icao_code']?.toString() ?? "";
    } else if (altn is List && altn.isNotEmpty) {
      altnName = altn.first['name']?.toString() ??
          altn.first['icao_code']?.toString() ??
          "";
    }

    double elwTons =
        (double.tryParse(wghts['est_ldw']?.toString() ?? "0") ?? 0) / 1000;
    double mlwTons =
        (double.tryParse(wghts['max_ldw']?.toString() ?? "1") ?? 1) / 1000;

    double efobTons =
        (double.tryParse(fuel['plan_landing']?.toString() ?? "0") ?? 0) / 1000;
    if (efobTons == 0) {
      double block = double.tryParse(fuel['plan_ramp']?.toString() ?? "0") ?? 0;
      double trip =
          double.tryParse(fuel['enroute_burn']?.toString() ?? "0") ?? 0;
      efobTons = (block - trip) / 1000;
    }

    String oat = "---";
    RegExp tempRegex = RegExp(r'\b(M?\d{2})/(M?\d{2})\b');
    Match? tMatch = tempRegex.firstMatch(metar);
    if (tMatch != null) oat = tMatch.group(1)?.replaceAll('M', '-') ?? "---";

    List<String> intros = [
      "Alright Captain, let's set up the arrival and approach briefing into $destName.",
      "We are getting closer. Let's review our arrival brief for $destName.",
      "Okay, time to prepare for descent. Here is the arrival briefing for flight $callsign into $destName."
    ];
    String intro = intros[math.Random().nextInt(intros.length)];

    String altnText = "";
    if (altnName.isEmpty) {
      altnText =
          "Caution, I don't see an alternate airport filed. We are committed to destination.";
    } else {
      altnText = "Our filed alternate is $altnName.";
    }
    String routeTxt =
        "We are planning an approach for Runway $arrRwy. $altnText";

    String windTxt =
        "Destination weather gives us a headwind of ${arrHeadwind.round()} knots, and a crosswind of ${arrCrosswind.round()} knots.";
    String flapsTxt = "";
    if (arrCrosswind < 15) {
      flapsTxt =
          "Winds are relatively calm, so we will plan for a standard Flaps FULL landing.";
    } else {
      flapsTxt =
          "It's quite gusty down there. To maintain better handling, I suggest we plan for a Flaps 3 landing.";
    }

    String oatTxt = "";
    if (oat == "---") {
      oatTxt =
          "Temperature data is currently unavailable, we'll need to check the live ATIS.";
    } else {
      oatTxt = "Outside air temperature is $oat degrees Celsius.";
    }

    String weightTxt =
        "Our Estimated Landing Weight is ${elwTons.toStringAsFixed(1)} tons. Maximum landing weight is ${mlwTons.toStringAsFixed(1)} tons.";
    if (elwTons > mlwTons * 0.95 && mlwTons > 1) {
      weightTxt +=
          " We are landing quite heavy today, very close to our maximum limit. Watch the vertical speed on touchdown.";
    }

    String fuelTxt =
        "We expect to touch down with ${efobTons.toStringAsFixed(1)} tons of fuel, which gives us a comfortable margin.";
    String brakesTxt =
        "Runway length data is currently unverified in my database. Let's play it safe with the autobrakes.";
    String goAroundTxt =
        "In case of a missed approach or a go-around, the callout is: 'Go-around, Flaps'. Apply TOGA thrust, positive rate gear up, and we will follow the published missed approach procedure or ATC radar vectors.";

    String outro = "";
    if (arrThreatCount == 0) {
      outro =
          "I don't see any significant threats for this arrival. The weather is playing nice, and we are well within limits. Looks like a straightforward approach. Any questions?";
    } else {
      String threatNames = arrThreatNames.join(" and ");
      outro =
          "Alright, we need to be on our toes today. Threats to consider: $threatNames. Let's strictly adhere to our minimums and be ready for a go-around if it doesn't look right. Any questions?";
    }

    String rawScript =
        "$intro $routeTxt $windTxt $flapsTxt $oatTxt $weightTxt $fuelTxt $brakesTxt $goAroundTxt $outro";

    _cleanArrAudioText = rawScript
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // =========================================================================
  // ====================== تشغيل الصوت ======================================
  // =========================================================================
  Future<void> _playAudioBriefing() async {
    String textToPlay =
        _isDepartureTab ? _cleanDepAudioText : _cleanArrAudioText;

    if (!_isAudioReady || textToPlay.isEmpty) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);

    try {
      final result = await _edgeTts.synthesize(textToPlay);
      final base64Audio = base64Encode(result.audioBytes);
      final dataUrl = 'data:audio/mpeg;base64,$base64Audio';

      await _audioPlayer.play(UrlSource(dataUrl));

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (e) {
      debugPrint("Audio Play Error: $e");
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  // =========================================================================
  // ====================== تصميم الواجهة (UI Layout) ========================
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: efbBg,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: efbAccent))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(_errorMessage,
                            style:
                                const TextStyle(color: cDanger, fontSize: 16),
                            textAlign: TextAlign.center),
                      ))
                    : Column(
                        children: [
                          _buildHeaderToggleAndAudio(),
                          const SizedBox(height: 12),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isDepartureTab
                                  ? _buildDepartureLayout()
                                  : _buildArrivalLayout(),
                            ),
                          ),
                        ],
                      ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHomeIndicator(
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildHeaderToggleAndAudio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: efbCard,
        border: Border(bottom: BorderSide(color: efbBorder, width: 2)),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: efbBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: efbBorder)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (!_isDepartureTab) {
                        if (_isPlaying) {
                          await _audioPlayer.stop();
                          _isPlaying = false;
                        }
                        setState(() => _isDepartureTab = true);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isDepartureTab
                            ? efbAccent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                          child: Text("DEPARTURE",
                              style: TextStyle(
                                  color: _isDepartureTab
                                      ? efbAccent
                                      : efbTextMuted,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                Container(width: 1, color: efbBorder),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (_isDepartureTab) {
                        if (_isPlaying) {
                          await _audioPlayer.stop();
                          _isPlaying = false;
                        }
                        setState(() => _isDepartureTab = false);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isDepartureTab
                            ? efbAccent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                          child: Text("ARRIVAL",
                              style: TextStyle(
                                  color: !_isDepartureTab
                                      ? efbAccent
                                      : efbTextMuted,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAudioReady ? _playAudioBriefing : null,
              icon: _isPlaying
                  ? FadeTransition(
                      opacity: _pulseAnimation,
                      child: const Icon(Icons.stop_circle,
                          color: cDanger, size: 24))
                  : const Icon(Icons.record_voice_over, color: efbBg, size: 24),
              label: Text(
                _isPlaying ? "STOP BRIEFING" : "🤖 AI CO-PILOT BRIEF",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: _isPlaying ? cDanger : efbBg),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? efbBg : efbAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                side: _isPlaying
                    ? const BorderSide(color: cDanger, width: 2)
                    : BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureLayout() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600;
      bool isTabletPortrait =
          constraints.maxWidth >= 600 && constraints.maxWidth < 900;
      if (isMobile) {
        return ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            children: [
              _buildDepVisualizerCard(),
              const SizedBox(height: 12),
              _buildDepTEMBoard(),
              const SizedBox(height: 12),
              _buildDepParamsCard()
            ]);
      } else if (isTabletPortrait) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    _buildDepParamsCard(),
                    const SizedBox(height: 12),
                    _buildDepTEMBoard()
                  ])),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildDepVisualizerCard())
            ]));
      } else {
        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 1, child: _buildDepParamsCard()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildDepVisualizerCard()),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildDepTEMBoard())
            ]));
      }
    });
  }

  Widget _buildArrivalLayout() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600;
      bool isTabletPortrait =
          constraints.maxWidth >= 600 && constraints.maxWidth < 900;
      if (isMobile) {
        return ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            children: [
              _buildArrVisualizerCard(),
              const SizedBox(height: 12),
              _buildArrTEMBoard(),
              const SizedBox(height: 12),
              _buildArrParamsCard()
            ]);
      } else if (isTabletPortrait) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    _buildArrParamsCard(),
                    const SizedBox(height: 12),
                    _buildArrTEMBoard()
                  ])),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildArrVisualizerCard())
            ]));
      } else {
        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 1, child: _buildArrParamsCard()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildArrVisualizerCard()),
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildArrTEMBoard())
            ]));
      }
    });
  }

  Widget _buildDepParamsCard() {
    final gen = _ofpData?['general'] ?? {};
    final origin = _ofpData?['origin'] ?? {};
    final wghts = _ofpData?['weights'] ?? {};
    final fuel = _ofpData?['fuel'] ?? {};

    // تم التصحيح: المفتاح في SimBrief اسمه 'params' وليس 'parameters'
    final params = _ofpData?['params'] ?? {};

    double tow =
        (double.tryParse(wghts['est_tow']?.toString() ?? "0") ?? 0) / 1000;
    double block =
        (double.tryParse(fuel['plan_ramp']?.toString() ?? "0") ?? 0) / 1000;

    String rules = gen['flight_rules']?.toString().toUpperCase() ?? "IFR";
    String rwy = origin['plan_rwy']?.toString() ?? "---";

    String routeStr = gen['route']?.toString() ?? "";
    String sid = routeStr.isEmpty ? "RADAR VECTORS" : routeStr.split(' ').first;

    String climb = gen['initial_altitude']?.toString() ?? "---";
    String emergRtn = origin['icao_code']?.toString() ?? "---";

    String v1 = params['v1']?.toString() ?? "___";
    String vr = params['vr']?.toString() ?? "___";
    String v2 = params['v2']?.toString() ?? "___";

    String metarStr = origin['metar']?.toString() ?? "";
    String vis = metarStr.contains("CAVOK") ? "10+ KM (CAVOK)" : "Check METAR";
    String oat = gen['avg_temp_dev']?.toString() ?? "---";

    return Container(
      decoration: BoxDecoration(
          color: efbCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbBorder,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Text("DEPARTURE PARAMETERS",
                style: TextStyle(
                    color: efbWhite,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow("TOW", "${tow.toStringAsFixed(1)} T", efbWhite),
                _buildDataRow(
                    "BLOCK FUEL", "${block.toStringAsFixed(1)} T", efbWhite),
                _buildDataRow("RULES", rules, efbAccent),
                const Divider(color: efbBorder, height: 24),
                _buildDataRow("DEP RWY", rwy, efbWhite),
                _buildDataRow("SID", sid, sid.length < 3 ? cWarn : efbWhite),
                _buildDataRow(
                    "INITIAL CLIMB",
                    climb.length > 2 ? "FL${climb.substring(0, 3)}" : climb,
                    efbWhite),
                _buildDataRow("EMERG RETURN", emergRtn, cDanger),
                const Divider(color: efbBorder, height: 24),
                _buildDataRow("VISIBILITY", vis, cWeather),
                _buildDataRow("OAT", "$oat°C", oat == "---" ? cWarn : cWeather),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVSpeedBox("V1", v1),
                    _buildVSpeedBox("VR", vr),
                    _buildVSpeedBox("V2", v2)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDepTEMBoard() {
    return Container(
      decoration: BoxDecoration(
          color: efbCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbBorder,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Text("DEP TEM ANALYSIS (AI)",
                style: TextStyle(
                    color: efbWhite,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
                children: depThreatBadges.isEmpty
                    ? [_buildBadge("ANALYZING...", efbTextMuted)]
                    : depThreatBadges),
          )
        ],
      ),
    );
  }

  Widget _buildDepVisualizerCard() {
    final origin = _ofpData?['origin'] ?? {};
    String rwyRaw = origin['plan_rwy']?.toString() ?? "36";
    String rwyStr = rwyRaw.replaceAll(RegExp(r'[A-Za-z]'), '');
    if (rwyStr.isEmpty) rwyStr = "36";
    double rwyHdg = (double.tryParse(rwyStr) ?? 36) * 10;

    int oppositeRwy = ((rwyHdg + 180) % 360) ~/ 10;
    if (oppositeRwy == 0) oppositeRwy = 36;
    String oppositeRwyStr = oppositeRwy.toString().padLeft(2, '0');

    return Container(
      height: 350,
      decoration: BoxDecoration(
          color: efbBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("ORIGIN RWY & WIND VISUALIZER",
                  style: TextStyle(
                      color: efbTextMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _windAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: RunwayWindsockPainter(
                      runwayHeading: rwyHdg,
                      runwayStr: rwyStr,
                      oppositeRwyStr: oppositeRwyStr,
                      windSpd: depHeadwind.abs() + depCrosswind,
                      crosswind: depCrosswind,
                      isCrosswindRight: depIsCrosswindRight,
                      animValue: _windAnimationController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbCard,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("HEADWIND: ${depHeadwind.round()} kts",
                    style: const TextStyle(
                        color: cWeather, fontWeight: FontWeight.bold)),
                Text("CROSSWIND: ${depCrosswind.round()} kts",
                    style: TextStyle(
                        color: depCrosswind > 15 ? cWarn : cWeather,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArrParamsCard() {
    final dest = _ofpData?['destination'] ?? {};
    final altn = _ofpData?['alternate'];
    final wghts = _ofpData?['weights'] ?? {};
    final fuel = _ofpData?['fuel'] ?? {};
    final gen = _ofpData?['general'] ?? {};

    double elw =
        (double.tryParse(wghts['est_ldw']?.toString() ?? "0") ?? 0) / 1000;
    double mlw =
        (double.tryParse(wghts['max_ldw']?.toString() ?? "1") ?? 1) / 1000;

    double efob =
        (double.tryParse(fuel['plan_landing']?.toString() ?? "0") ?? 0) / 1000;
    if (efob == 0) {
      double block = double.tryParse(fuel['plan_ramp']?.toString() ?? "0") ?? 0;
      double trip =
          double.tryParse(fuel['enroute_burn']?.toString() ?? "0") ?? 0;
      efob = (block - trip) / 1000;
    }

    String rwy = dest['plan_rwy']?.toString() ?? "---";

    String routeStr = gen['route']?.toString() ?? "";
    List<String> routePoints = routeStr.isEmpty ? [] : routeStr.split(' ');
    String star = routePoints.length > 1 ? routePoints.last : "VECTORS";

    String altnName = "NO ALTERNATE FILED";
    Color altnColor = cDanger;

    if (altn is Map) {
      altnName = altn['icao_code']?.toString() ?? "---";
      altnColor = efbWhite;
    } else if (altn is List && altn.isNotEmpty) {
      altnName = altn.first['icao_code']?.toString() ?? "---";
      altnColor = efbWhite;
    }

    String metarStr = dest['metar']?.toString() ?? "";
    String vis = metarStr.contains("CAVOK") ? "10+ KM (CAVOK)" : "Check METAR";

    String oat = "---";
    RegExp tempRegex = RegExp(r'\b(M?\d{2})/(M?\d{2})\b');
    Match? tMatch = tempRegex.firstMatch(metarStr);
    if (tMatch != null) oat = tMatch.group(1)?.replaceAll('M', '-') ?? "---";

    String recFlaps = arrCrosswind > 15 ? "3" : "FULL";
    String recBrakes = "UNVERIFIED RWY -> MED/MAX";

    return Container(
      decoration: BoxDecoration(
          color: efbCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbBorder,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Text("ARRIVAL PARAMETERS",
                style: TextStyle(
                    color: efbWhite,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow(
                    "EST LNDG WGT (ELW)",
                    "${elw.toStringAsFixed(1)} T",
                    (elw > mlw * 0.95 && mlw > 1) ? cWarn : efbWhite),
                _buildDataRow("MAX LNDG WGT (MLW)",
                    "${mlw.toStringAsFixed(1)} T", efbWhite),
                _buildDataRow(
                    "DEST EFOB", "${efob.toStringAsFixed(1)} T", efbAccent),
                const Divider(color: efbBorder, height: 24),
                _buildDataRow("ARR RWY", rwy, efbWhite),
                _buildDataRow(
                    "STAR", star, star == "VECTORS" ? cWarn : efbWhite),
                _buildDataRow("ALTERNATE", altnName, altnColor),
                const Divider(color: efbBorder, height: 24),
                _buildDataRow("VISIBILITY", vis, cWeather),
                _buildDataRow("OAT", oat == "---" ? "UNVERIFIED" : "$oat°C",
                    oat == "---" ? cWarn : cWeather),
                const SizedBox(height: 16),
                const Center(
                    child: Text("AI SUGGESTIONS",
                        style: TextStyle(
                            color: efbTextMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVSpeedBox("FLAPS", recFlaps),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _buildVSpeedBox("AUTOBRAKES", recBrakes)))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArrTEMBoard() {
    return Container(
      decoration: BoxDecoration(
          color: efbCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbBorder,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Text("ARR TEM ANALYSIS (AI)",
                style: TextStyle(
                    color: efbWhite,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
                children: arrThreatBadges.isEmpty
                    ? [_buildBadge("ANALYZING...", efbTextMuted)]
                    : arrThreatBadges),
          )
        ],
      ),
    );
  }

  Widget _buildArrVisualizerCard() {
    final dest = _ofpData?['destination'] ?? {};
    String rwyRaw = dest['plan_rwy']?.toString() ?? "36";
    String rwyStr = rwyRaw.replaceAll(RegExp(r'[A-Za-z]'), '');
    if (rwyStr.isEmpty) rwyStr = "36";
    double rwyHdg = (double.tryParse(rwyStr) ?? 36) * 10;

    int oppositeRwy = ((rwyHdg + 180) % 360) ~/ 10;
    if (oppositeRwy == 0) oppositeRwy = 36;
    String oppositeRwyStr = oppositeRwy.toString().padLeft(2, '0');

    return Container(
      height: 350,
      decoration: BoxDecoration(
          color: efbBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: efbBorder, width: 1.5)),
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("DESTINATION RWY & WIND VISUALIZER",
                  style: TextStyle(
                      color: efbTextMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _windAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: RunwayWindsockPainter(
                      runwayHeading: rwyHdg,
                      runwayStr: rwyStr,
                      oppositeRwyStr: oppositeRwyStr,
                      windSpd: arrHeadwind.abs() + arrCrosswind,
                      crosswind: arrCrosswind,
                      isCrosswindRight: arrIsCrosswindRight,
                      animValue: _windAnimationController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: efbCard,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("HEADWIND: ${arrHeadwind.round()} kts",
                    style: const TextStyle(
                        color: cWeather, fontWeight: FontWeight.bold)),
                Text("CROSSWIND: ${arrCrosswind.round()} kts",
                    style: TextStyle(
                        color: arrCrosswind > 15 ? cWarn : cWeather,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: efbTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: valColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVSpeedBox(String label, String speed) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(color: efbAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: efbBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: efbBorder)),
          child: Text(speed,
              style: const TextStyle(
                  color: efbWhite,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

// =========================================================================
// ====================== CustomPainter للمدرج وقمع الرياح ==================
// =========================================================================

class RunwayWindsockPainter extends CustomPainter {
  final double runwayHeading;
  final String runwayStr;
  final String oppositeRwyStr;
  final double windSpd;
  final double crosswind;
  final bool isCrosswindRight;
  final double animValue;

  RunwayWindsockPainter({
    required this.runwayHeading,
    required this.runwayStr,
    required this.oppositeRwyStr,
    required this.windSpd,
    required this.crosswind,
    required this.isCrosswindRight,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_toRadians(runwayHeading));

    double rwyWidth = 60;
    double rwyHeight = size.height * 0.7;

    final rwyPaint = Paint()..color = const Color(0xFF2C323A);
    final rwyRect = Rect.fromCenter(
        center: const Offset(0, 0), width: rwyWidth, height: rwyHeight);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rwyRect, const Radius.circular(4)), rwyPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(-rwyWidth / 2 + 4, -rwyHeight / 2 + 10),
        Offset(-rwyWidth / 2 + 4, rwyHeight / 2 - 10), linePaint);
    canvas.drawLine(Offset(rwyWidth / 2 - 4, -rwyHeight / 2 + 10),
        Offset(rwyWidth / 2 - 4, rwyHeight / 2 - 10), linePaint);

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    double startY = -rwyHeight / 2 + 40;
    while (startY < rwyHeight / 2 - 40) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 15), dashPaint);
      startY += 30;
    }

    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      canvas.drawRect(
          Rect.fromLTWH(i * 10.0 - 2, rwyHeight / 2 - 20, 4, 15), dashPaint);
      canvas.drawRect(
          Rect.fromLTWH(i * 10.0 - 2, -rwyHeight / 2 + 5, 4, 15), dashPaint);
    }

    _drawText(canvas, runwayStr, const Offset(0, 50), true);
    _drawText(canvas, oppositeRwyStr, const Offset(0, -50), false);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.15, size.height * 0.5);

    final polePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 30), const Offset(0, -30), polePaint);

    double flutter = 0;
    if (windSpd > 15)
      flutter = math.sin(animValue * math.pi * 4) * 10;
    else if (windSpd > 5)
      flutter = math.sin(animValue * math.pi * 2) * 3;
    else
      flutter = 20;

    Path sockPath = Path();
    sockPath.moveTo(0, -28);
    sockPath.lineTo(40, -20 + flutter);
    sockPath.lineTo(40, -10 + flutter);
    sockPath.lineTo(0, -18);
    sockPath.close();

    final sockPaintRed = Paint()..color = cDanger;
    canvas.drawPath(sockPath, sockPaintRed);

    if (crosswind > 2) {
      final arrowPaint = Paint()
        ..color = cWeather
        ..strokeWidth = 3;
      double arrowStartX = isCrosswindRight ? 50 : -50;
      canvas.drawLine(
          Offset(arrowStartX, -40), const Offset(0, -40), arrowPaint);
      canvas.drawCircle(const Offset(0, -40), 3, arrowPaint);
    }
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, bool invert) {
    final textStyle = const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace');
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
    textPainter.layout();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (invert) canvas.rotate(math.pi);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;
  @override
  bool shouldRepaint(covariant RunwayWindsockPainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.windSpd != windSpd;
  }
}
