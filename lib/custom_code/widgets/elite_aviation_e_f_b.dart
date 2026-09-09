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

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;

// --- الدوال الرياضية (مدمجة هنا بدون أي تعديل) ---

double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
  double lat1Rad = lat1 * math.pi / 180.0;
  double lon1Rad = lon1 * math.pi / 180.0;
  double lat2Rad = lat2 * math.pi / 180.0;
  double lon2Rad = lon2 * math.pi / 180.0;

  double dLon = lon2Rad - lon1Rad;
  double y = math.sin(dLon) * math.cos(lat2Rad);
  double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
      math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

  double brng = math.atan2(y, x) * 180.0 / math.pi;
  return (brng + 360.0) % 360.0;
}

Map<String, double> getClosestPointOnSegment(double pLat, double pLon,
    double aLat, double aLon, double bLat, double bLon) {
  double cosLat = math.cos(pLat * math.pi / 180.0);

  double kX = cosLat * 111320.0;
  double kY = 110540.0;

  double px = pLon * kX;
  double py = pLat * kY;
  double ax = aLon * kX;
  double ay = aLat * kY;
  double bx = bLon * kX;
  double by = bLat * kY;

  double dx = bx - ax;
  double dy = by - ay;
  double lenSq = dx * dx + dy * dy;

  if (lenSq == 0) {
    double dist = math.sqrt((px - ax) * (px - ax) + (py - ay) * (py - ay));
    return {'lat': aLat, 'lon': aLon, 'dist': dist};
  }

  double t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
  t = t.clamp(0.0, 1.0);

  double cx = ax + t * dx;
  double cy = ay + t * dy;

  double cLon = cx / kX;
  double cLat = cy / kY;

  double dist = math.sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy));

  return {'lat': cLat, 'lon': cLon, 'dist': dist};
}

// --- نهاية الدوال الرياضية ---

class EliteAviationEFB extends StatefulWidget {
  final double? width;
  final double? height;

  final Future Function(double lat, double lon, double heading)?
      onRunwaySelected;
  final Future Function(double lat, double lon, double heading)? onGateSelected;

  final Future Function(double speed)? onSpeedSet;

  final Future Function()? onRunwayActionTap;
  final Future Function()? onGateActionTap;
  final Future Function()? onMapTeleportTap;
  final Future Function()? onWorldTourTap;

  final Future Function()? onTakeoffConfigTap;
  final Future Function()? onLandingConfigTap;

  final Future Function()? onPlane15nmTap;
  final Future Function()? onPlane10nmTap;
  final Future Function()? onPlane7nmTap;
  final Future Function()? onPlane4nmTap;
  final Future Function()? onPlaneHoldLeftTap;
  final Future Function()? onPlaneHoldRightTap;
  final Future Function()? onPlaneLeftDownwindTap;
  final Future Function()? onPlaneRightDownwindTap;
  final Future Function()? onPlaneCruiseTap;

  const EliteAviationEFB({
    Key? key,
    this.width,
    this.height,
    this.onRunwaySelected,
    this.onGateSelected,
    this.onSpeedSet,
    this.onRunwayActionTap,
    this.onGateActionTap,
    this.onMapTeleportTap,
    this.onWorldTourTap,
    this.onTakeoffConfigTap,
    this.onLandingConfigTap,
    this.onPlane15nmTap,
    this.onPlane10nmTap,
    this.onPlane7nmTap,
    this.onPlane4nmTap,
    this.onPlaneHoldLeftTap,
    this.onPlaneHoldRightTap,
    this.onPlaneLeftDownwindTap,
    this.onPlaneRightDownwindTap,
    this.onPlaneCruiseTap,
  }) : super(key: key);

  @override
  _EliteAviationEFBState createState() => _EliteAviationEFBState();
}

class _EliteAviationEFBState extends State<EliteAviationEFB> {
  // Common State
  final TextEditingController _icaoController = TextEditingController();
  final TextEditingController _speedController =
      TextEditingController(text: "150");
  int _selectedMode = 0;

  // Runway State
  bool _isLoadingRunways = false;
  List<Map<String, dynamic>> _runways = [];
  Map<String, dynamic>? _selectedRunway;

  // Gate State
  bool _isLoadingGates = false;
  String _gateErrorMessage = '';
  List<Map<String, dynamic>> _gatesList = [];
  int _selectedGateIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  void _handleSearch() {
    final icao = _icaoController.text.trim().toUpperCase();
    if (icao.isEmpty) return;

    _fetchRunwayData(icao);
    _fetchGatesData(icao);
  }

  Future<void> _fetchRunwayData(String icao) async {
    setState(() {
      _isLoadingRunways = true;
      _runways = [];
      _selectedRunway = null;
    });

    try {
      final dynamic airportData = await getOfflineAirportData(icao);

      if (airportData != null && airportData['runways'] != null) {
        List<dynamic> rawRunways = airportData['runways'];
        List<Map<String, dynamic>> parsedRunways = [];

        for (var r in rawRunways) {
          parsedRunways.add({
            'name': r['name'].toString(),
            'surface': r['surface'].toString(),
            'width': r['width'].toString(),
            'length': r['length'].toString(),
            'heading': r['heading'].toString(),
            'lat': double.tryParse(r['lat'].toString()) ?? 0.0,
            'lon': double.tryParse(r['lon'].toString()) ?? 0.0,
            'heading_raw': double.tryParse(r['heading_raw'].toString()) ?? 0.0,
          });
        }

        parsedRunways.sort((a, b) => a['name'].compareTo(b['name']));

        setState(() {
          _runways = parsedRunways;
          _isLoadingRunways = false;
        });

        if (parsedRunways.isNotEmpty) {
          // 🔴 التعديل السحري هنا: لو إنت على شاشة الجيت، هنختار أول مدرج بصمت من غير ما نبعت الأكشن يشتغل
          _selectRunway(parsedRunways[0], triggerCallback: _selectedMode == 0);
        }
      } else {
        _showError("❌ ICAO Code '$icao' not found in database.");
        setState(() => _isLoadingRunways = false);
      }
    } catch (e) {
      _showError("❌ Error connecting to data.");
      setState(() => _isLoadingRunways = false);
    }
  }

  Future<void> _fetchGatesData(String icao) async {
    setState(() {
      _isLoadingGates = true;
      _gateErrorMessage = '';
      _gatesList = [];
      _selectedGateIndex = -1;
    });

    final String query = '''
      [out:json][timeout:25];
      area["icao"="$icao"]->.a;
      nwr["aeroway"="parking_position"](area.a)->.gates;
      way["aeroway"~"taxiway|taxilane"](area.a)->.taxiways;
      .gates out center;
      .taxiways out geom;
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'User-Agent': 'FlutterFlow_Sim_App_v1.0'},
        body: {'data': query},
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        if (mounted)
          setState(() {
            _gateErrorMessage = 'API ERROR: ${response.statusCode}';
            _isLoadingGates = false;
          });
        return;
      }

      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> elements = jsonResponse['elements'] ?? [];

      List<dynamic> gatesRaw = [];
      List<List<Map<String, double>>> taxiwaySegments = [];

      for (var el in elements) {
        if (el['tags'] != null && el['tags']['aeroway'] == 'parking_position') {
          gatesRaw.add(el);
        } else if (el['geometry'] != null) {
          List<dynamic> geomList = el['geometry'];
          List<Map<String, double>> currentWay = [];
          for (var pt in geomList) {
            currentWay.add({
              'lat': (pt['lat'] as num).toDouble(),
              'lon': (pt['lon'] as num).toDouble()
            });
          }
          if (currentWay.length > 1) {
            taxiwaySegments.add(currentWay);
          }
        }
      }

      List<Map<String, dynamic>> tempGatesList = [];
      int unnamedCounter = 1;

      for (var element in gatesRaw) {
        final tags = element['tags'];
        double lat = 0.0;
        double lon = 0.0;

        if (element['type'] == 'node') {
          lat = (element['lat'] as num).toDouble();
          lon = (element['lon'] as num).toDouble();
        } else if (element.containsKey('center')) {
          lat = (element['center']['lat'] as num).toDouble();
          lon = (element['center']['lon'] as num).toDouble();
        }

        String name = tags['ref'] ?? tags['name'] ?? '';
        if (name.isEmpty) {
          name = 'GATE $unnamedCounter';
          unnamedCounter++;
        }

        double heading = 0.0;
        bool hasRealHeading = false;

        String? headingTag = tags['heading'] ??
            tags['direction'] ??
            tags['orientation'] ??
            tags['angle'] ??
            tags['airplane:heading'];
        if (headingTag != null) {
          try {
            String cleaned = headingTag.replaceAll(RegExp(r'[^0-9\.\-]'), '');
            if (cleaned.isNotEmpty) {
              heading = double.parse(cleaned);
              hasRealHeading = true;
            }
          } catch (_) {}
        }

        if (!hasRealHeading &&
            lat != 0.0 &&
            lon != 0.0 &&
            taxiwaySegments.isNotEmpty) {
          bool connectionFound = false;
          double calculatedHeading = 0.0;

          for (var way in taxiwaySegments) {
            for (int i = 0; i < way.length; i++) {
              if ((way[i]['lat']! - lat).abs() < 0.000001 &&
                  (way[i]['lon']! - lon).abs() < 0.000001) {
                connectionFound = true;
                if (i > 0) {
                  calculatedHeading = calculateBearing(
                      way[i - 1]['lat']!, way[i - 1]['lon']!, lat, lon);
                } else if (i < way.length - 1) {
                  calculatedHeading = calculateBearing(
                      way[1]['lat']!, way[1]['lon']!, lat, lon);
                }
                break;
              }
            }
            if (connectionFound) break;
          }

          if (!connectionFound) {
            double minDistance = double.infinity;
            double bestProjLat = 0.0;
            double bestProjLon = 0.0;

            for (var way in taxiwaySegments) {
              for (int i = 0; i < way.length - 1; i++) {
                var proj = getClosestPointOnSegment(lat, lon, way[i]['lat']!,
                    way[i]['lon']!, way[i + 1]['lat']!, way[i + 1]['lon']!);
                if (proj['dist']! < minDistance) {
                  minDistance = proj['dist']!;
                  bestProjLat = proj['lat']!;
                  bestProjLon = proj['lon']!;
                }
              }
            }
            if (minDistance <= 250.0) {
              calculatedHeading =
                  calculateBearing(bestProjLat, bestProjLon, lat, lon);
            }
          }
          heading = double.parse(calculatedHeading.toStringAsFixed(1));
        }

        if (lat != 0.0 && lon != 0.0) {
          tempGatesList.add({
            'name': name.toUpperCase(),
            'lat': lat,
            'lon': lon,
            'heading': heading,
            'type': tags['aeroway'] ?? 'PARKING',
          });
        }
      }

      tempGatesList
          .sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

      if (mounted) {
        setState(() {
          _gatesList = tempGatesList;
          if (_gatesList.isEmpty) {
            _gateErrorMessage = 'NO GATES FOUND IN DATABASE';
          }
          _isLoadingGates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gateErrorMessage = 'DATALINK FAILED';
          _isLoadingGates = false;
        });
      }
    }
  }

  // 🔴 تم إضافة triggerCallback للتحكم في تشغيل الأكشن من عدمه
  void _selectRunway(Map<String, dynamic> runway,
      {bool triggerCallback = true}) {
    setState(() => _selectedRunway = runway);

    // تحديث متغيرات المدرج في App State
    FFAppState().update(() {
      FFAppState().radarRwyName = runway['name'];
      FFAppState().radarLat = runway['lat'];
      FFAppState().radarLon = runway['lon'];
      FFAppState().radarHdgRaw = runway['heading_raw'];
    });

    if (triggerCallback && widget.onRunwaySelected != null) {
      widget.onRunwaySelected!(
          runway['lat'], runway['lon'], runway['heading_raw']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setSpeed() {
    double? speed = double.tryParse(_speedController.text.trim());
    if (speed != null && widget.onSpeedSet != null) {
      widget.onSpeedSet!(speed);
    }
  }

  Widget _buildGlowingSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E324A), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A94E3).withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C1421),
            Color(0xFF030508),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // ======================= TOP BAR =======================
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGlowingSection(
                  child: _buildCompactSearchAndSpeed(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildGlowingSection(
                    child: _selectedMode == 0
                        ? _buildCompactRunwayDetails()
                        : _buildEmptyMiddleSection(),
                  ),
                ),
                const SizedBox(width: 14),
                _buildGlowingSection(
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EFBConfigButton(
                              title: "TAKEOFF CONFIG",
                              onTap: widget.onTakeoffConfigTap),
                          const SizedBox(height: 8),
                          EFBConfigButton(
                              title: "LANDING CONFIG",
                              onTap: widget.onLandingConfigTap),
                        ],
                      ),
                      const SizedBox(width: 16),
                      _buildRightRadioButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ======================= BOTTOM SECTION =======================
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E324A), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A94E3).withOpacity(0.12),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _selectedMode == 0
                    ? _buildRunwayRadarArea()
                    : _buildGatesArea(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Components Functions ---

  Widget _buildCompactSearchAndSpeed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 70,
              height: 28,
              child: TextField(
                controller: _icaoController,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'ICAO',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 11),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  filled: true,
                  fillColor: Color(0xFF0A121E),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E2F45))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E2F45))),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 55,
              height: 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16263B),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: (_isLoadingRunways || _isLoadingGates)
                    ? null
                    : _handleSearch,
                child: (_isLoadingRunways || _isLoadingGates)
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 1.5))
                    : const Icon(Icons.search,
                        size: 16, color: Color(0xFF7AA5D2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 70,
              height: 28,
              child: TextField(
                controller: _speedController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: 'SPD ',
                  prefixStyle: TextStyle(color: Colors.white30, fontSize: 10),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  filled: true,
                  fillColor: Color(0xFF0A121E),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E2F45))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E2F45))),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 55,
              height: 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16263B),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                onPressed: _setSpeed,
                child: const Text('SET',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7AA5D2),
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactRunwayDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_runways.isEmpty)
          const Expanded(
              child: Center(
                  child: Text("NO AIRPORT LOADED",
                      style: TextStyle(
                          color: Colors.white24,
                          fontWeight: FontWeight.bold)))),
        if (_runways.isNotEmpty) ...[
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _runways.length,
              itemBuilder: (context, index) {
                final rw = _runways[index];
                final isSel = _selectedRunway != null &&
                    _selectedRunway!['name'] == rw['name'];
                return GestureDetector(
                  onTap: () => _selectRunway(
                      rw), // هنا بيشغل الكول باك طبيعي لأنه استدعاء يدوي
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFF223E63)
                          : const Color(0xFF0A121E),
                      border: Border.all(
                          color: isSel
                              ? const Color(0xFF7AA5D2)
                              : const Color(0xFF1E2F45)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(rw['name'],
                        style: TextStyle(
                            color: isSel ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (_selectedRunway != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1E2F45)),
                  color: const Color(0xFF0A121E),
                  borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoText('SFC: ', _selectedRunway!['surface']),
                  _infoText('LEN: ', '${_selectedRunway!['length']} ft'),
                  _infoText('WID: ', '${_selectedRunway!['width']} ft'),
                  _infoText('HDG: ', '${_selectedRunway!['heading']}°'),
                ],
              ),
            ),
        ]
      ],
    );
  }

  Widget _buildEmptyMiddleSection() {
    return const Center(
      child: Text(
        "GATES & STANDS MODE",
        style: TextStyle(
          color: Color(0xFF5A94E3),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
        ),
      ),
    );
  }

  Widget _infoText(String title, String val) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: title,
              style: const TextStyle(color: Color(0xFF537396), fontSize: 10)),
          TextSpan(
              text: val,
              style: const TextStyle(
                  color: Color(0xFFA6C2DF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRightRadioButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _radioItem(0, 'RUNWAY', () {
          setState(() => _selectedMode = 0);
          if (widget.onRunwayActionTap != null) widget.onRunwayActionTap!();
        }),
        _radioItem(1, 'GATE', () {
          setState(() => _selectedMode = 1);
          if (widget.onGateActionTap != null) widget.onGateActionTap!();
        }),
        _radioItem(2, 'MAP TELEPORT', () {
          setState(() => _selectedMode = 2);
          if (widget.onMapTeleportTap != null) widget.onMapTeleportTap!();
        }),
        _radioItem(3, 'WORLD TOUR', () {
          setState(() => _selectedMode = 3);
          if (widget.onWorldTourTap != null) widget.onWorldTourTap!();
        }),
      ],
    );
  }

  Widget _radioItem(int index, String label, VoidCallback onTap) {
    bool isSel = _selectedMode == index;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 14,
                color:
                    isSel ? const Color(0xFF7AA5D2) : const Color(0xFF324866)),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isSel
                        ? const Color(0xFFA6C2DF)
                        : const Color(0xFF537396),
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildRunwayRadarArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MasterILSPainter(
                    runwayName: _selectedRunway != null
                        ? _selectedRunway!['name']
                        : 'RWY'),
              ),
            ),
            RadarPlane(
                constraints: constraints,
                xPct: 0.12,
                yPct: 0.50,
                text1: '15nm OUT',
                text2: '3,000ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane15nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.26,
                yPct: 0.50,
                text1: '10nm OUT',
                text2: '3,000ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane10nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.39,
                yPct: 0.50,
                text1: '7nm',
                text2: '2,300ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane7nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.51,
                yPct: 0.50,
                text1: 'Takeoff',
                text2: '1,300ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane4nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.26,
                yPct: 0.28,
                text1: 'Cruise',
                text2: '10,000ft',
                angle: math.pi / 2,
                txtDy: -40,
                onTap: widget.onPlaneCruiseTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.45,
                yPct: 0.30,
                text1: 'Left base',
                text2: '3,000ft',
                angle: math.pi,
                txtDy: -40,
                onTap: widget.onPlaneHoldLeftTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.30,
                text1: 'Left Downwind 45L',
                text2: '3,000ft',
                angle: -math.pi / 2,
                txtDy: -40,
                onTap: widget.onPlaneLeftDownwindTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.45,
                yPct: 0.70,
                text1: 'Right base',
                text2: '3,000ft',
                angle: 0,
                txtDy: 40,
                onTap: widget.onPlaneHoldRightTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.70,
                text1: 'Right Downwind 45L',
                text2: '3,000ft',
                angle: -math.pi / 2,
                txtDy: 40,
                onTap: widget.onPlaneRightDownwindTap),
          ],
        );
      },
    );
  }

  Widget _buildGatesArea() {
    if (_isLoadingGates) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                  color: Color(0xFF7AA5D2), strokeWidth: 3),
            ),
            SizedBox(height: 20),
            Text(
              'LOADING GATES...',
              style: TextStyle(
                  color: Color(0xFF5A94E3),
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (_gateErrorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _gateErrorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 2.0),
        ),
      );
    }

    if (_gatesList.isEmpty) {
      return const Center(
        child: Text(
          "NO ICAO LOADED YET",
          style: TextStyle(
              color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 110,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _gatesList.length,
        itemBuilder: (context, index) {
          final gate = _gatesList[index];
          final isSelected = _selectedGateIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedGateIndex = index);

              // 🔴 تحديث App State الخاصة بالبوابات (Gates) بشكل منفصل
              FFAppState().update(() {
                FFAppState().gateName = gate['name'];
                FFAppState().gateLat = gate['lat'];
                FFAppState().gateLon = gate['lon'];
                FFAppState().gateHdg = gate['heading'];
              });

              if (widget.onGateSelected != null) {
                widget.onGateSelected!(
                    gate['lat'], gate['lon'], gate['heading']);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF223E63)
                    : const Color(0xFF0A121E),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF7AA5D2)
                      : const Color(0xFF1E2F45),
                  width: isSelected ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                            color: Color(0x335A94E3),
                            blurRadius: 10,
                            spreadRadius: 1)
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7AA5D2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF7AA5D2), blurRadius: 4)
                        ],
                      ),
                    ),
                  Text(
                    gate['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: isSelected ? 16 : 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EFBConfigButton extends StatefulWidget {
  final String title;
  final Future Function()? onTap;
  const EFBConfigButton({required this.title, required this.onTap});
  @override
  _EFBConfigButtonState createState() => _EFBConfigButtonState();
}

class _EFBConfigButtonState extends State<EFBConfigButton> {
  bool _isPressed = false;
  void _handleTap() async {
    setState(() => _isPressed = true);
    if (widget.onTap != null) widget.onTap!();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF7AA5D2) : const Color(0xFF16263B),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF5A94E3), width: 1.0),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                      color: const Color(0xFF7AA5D2).withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1)
                ]
              : [],
        ),
        child: Text(widget.title,
            style: TextStyle(
                color: _isPressed
                    ? const Color(0xFF070B14)
                    : const Color(0xFF7AA5D2),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      ),
    );
  }
}

class RadarPlane extends StatefulWidget {
  final BoxConstraints constraints;
  final double xPct, yPct;
  final String text1, text2;
  final double angle, txtDy;
  final Future Function()? onTap;
  const RadarPlane(
      {required this.constraints,
      required this.xPct,
      required this.yPct,
      required this.text1,
      required this.text2,
      required this.angle,
      required this.txtDy,
      required this.onTap});
  @override
  _RadarPlaneState createState() => _RadarPlaneState();
}

class _RadarPlaneState extends State<RadarPlane> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final Color planeBlue = const Color(0xFF7AA5D2);
    final Color textOrange = const Color(0xFFE5B064);
    double centerX = widget.constraints.maxWidth * widget.xPct;
    double centerY = widget.constraints.maxHeight * widget.yPct;

    return Positioned(
      left: centerX - 100,
      top: centerY - 100,
      width: 200,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IgnorePointer(
              child: CustomPaint(
                  size: const Size(200, 200),
                  painter: StraightPointerPainter(dy: widget.txtDy))),
          IgnorePointer(
            child: Transform.translate(
              offset: Offset(0, widget.txtDy + (widget.txtDy > 0 ? 28 : -28)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.text1.isNotEmpty)
                    Text(widget.text1,
                        style: TextStyle(
                            color: planeBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 3)
                            ])),
                  if (widget.text2.isNotEmpty)
                    Text(widget.text2,
                        style: TextStyle(
                            color: textOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 3)
                            ])),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _isHovered = true);
              if (widget.onTap != null) widget.onTap!();
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) setState(() => _isHovered = false);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                if (_isHovered)
                  BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5)
              ]),
              child: Transform.rotate(
                  angle: widget.angle,
                  child: Icon(Icons.airplanemode_active,
                      color: _isHovered ? Colors.white : planeBlue,
                      size: 50,
                      shadows: [
                        Shadow(color: planeBlue.withOpacity(0.6), blurRadius: 6)
                      ])),
            ),
          ),
        ],
      ),
    );
  }
}

class StraightPointerPainter extends CustomPainter {
  final double dy;
  StraightPointerPainter({required this.dy});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF6B87A8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    double cx = size.width / 2;
    double cy = size.height / 2;
    double startY = cy + (dy > 0 ? 25 : -25);
    canvas.drawLine(Offset(cx, startY), Offset(cx, cy + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MasterILSPainter extends CustomPainter {
  final String runwayName;
  MasterILSPainter({required this.runwayName});
  @override
  void paint(Canvas canvas, Size size) {
    double runwayWidth = size.width * 0.42;
    double runwayHeight = 40.0;
    double runwayLeft = size.width * 0.52;
    double centerY = size.height * 0.50;
    double runwayTop = centerY - (runwayHeight / 2);
    double ilsLength = size.width * 0.45;
    double ilsHeight = 45.0;

    Paint wireframePaint = Paint()
      ..color = const Color(0xFF4370AC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    Path outerFeather = Path();
    outerFeather.moveTo(runwayLeft, centerY);
    outerFeather.lineTo(runwayLeft - ilsLength, centerY - ilsHeight);
    outerFeather.lineTo(runwayLeft - ilsLength + 90, centerY);
    outerFeather.lineTo(runwayLeft - ilsLength, centerY + ilsHeight);
    outerFeather.close();

    Path innerFeather = Path();
    double scale = 0.65;
    innerFeather.moveTo(runwayLeft, centerY);
    innerFeather.lineTo(
        runwayLeft - (ilsLength * scale), centerY - (ilsHeight * scale));
    innerFeather.lineTo(
        runwayLeft - (ilsLength * scale) + (90 * scale), centerY);
    innerFeather.lineTo(
        runwayLeft - (ilsLength * scale), centerY + (ilsHeight * scale));
    innerFeather.close();

    canvas.drawPath(outerFeather, wireframePaint);
    canvas.drawPath(
        innerFeather,
        Paint()
          ..color = const Color(0xFF4370AC).withOpacity(0.6)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);

    Paint glowGold = Paint()
      ..color = const Color(0xFFF09819)
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    Paint solidGold = Paint()
      ..color = const Color(0xFFFFD460)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(runwayLeft - ilsLength, centerY),
        Offset(runwayLeft, centerY), glowGold);
    canvas.drawLine(Offset(runwayLeft - ilsLength, centerY),
        Offset(runwayLeft, centerY), solidGold);

    final rwyRect =
        Rect.fromLTWH(runwayLeft, runwayTop, runwayWidth, runwayHeight);
    canvas.drawRect(rwyRect, Paint()..color = const Color(0xFF13171C));
    canvas.drawRect(
        rwyRect,
        Paint()
          ..color = const Color(0xFF5A7494)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    final dashPaint = Paint()
      ..color = const Color(0xFF8B9FB6)
      ..strokeWidth = 2.0;
    double dashX = runwayLeft + 45;
    while (dashX < runwayLeft + runwayWidth - 20) {
      canvas.drawLine(
          Offset(dashX, centerY), Offset(dashX + 20, centerY), dashPaint);
      dashX += 35;
    }

    final pianoKeyPaint = Paint()
      ..color = const Color(0xFFD9E2EC)
      ..strokeWidth = 2.5;
    double keyStartX = runwayLeft + 4;
    for (int i = 0; i < 5; i++) {
      double yOffset = runwayTop + 6 + (i * 6.5);
      canvas.drawLine(Offset(keyStartX, yOffset),
          Offset(keyStartX + 12, yOffset), pianoKeyPaint);
    }

    final textSpan = TextSpan(
        text: runwayName,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5));
    final textPainter =
        TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
    textPainter.layout();

    canvas.save();
    canvas.translate(runwayLeft + 25, centerY);
    canvas.rotate(math.pi / 2);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
