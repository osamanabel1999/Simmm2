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

// --- الدوال الرياضية ---

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

// ============================================================================
// الويدجت الرئيسي (الدمج)
// ============================================================================

class EliteAviationEFB extends StatefulWidget {
  final double? width;
  final double? height;

  final Future Function(double lat, double lon, double heading)?
      onRunwaySelected;
  final Future Function(double lat, double lon, double heading)? onGateSelected;
  final Future Function(String name, double lat, double lon, double heading)?
      onChartGateSelected;

  final Future Function(double speed)? onSpeedSet;

  final Future Function()? onRunwayActionTap;
  final Future Function()? onGateActionTap;
  final Future Function()? onChartActionTap;
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
    this.onChartGateSelected,
    this.onSpeedSet,
    this.onRunwayActionTap,
    this.onGateActionTap,
    this.onChartActionTap,
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
  final TextEditingController _icaoController = TextEditingController();
  final TextEditingController _speedController =
      TextEditingController(text: "150");
  int _selectedMode = 0;

  bool _isLoadingRunways = false;
  List<Map<String, dynamic>> _runways = [];
  Map<String, dynamic>? _selectedRunway;

  bool _isLoadingGates = false;
  String _gateErrorMessage = '';
  List<Map<String, dynamic>> _gatesList = [];
  int _selectedGateIndex = -1;

  double? _airportCenterLat;
  double? _airportCenterLon;

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

        double sumLat = 0.0;
        double sumLon = 0.0;

        for (var r in rawRunways) {
          double rLat = double.tryParse(r['lat'].toString()) ?? 0.0;
          double rLon = double.tryParse(r['lon'].toString()) ?? 0.0;
          sumLat += rLat;
          sumLon += rLon;

          parsedRunways.add({
            'name': r['name'].toString(),
            'surface': r['surface'].toString(),
            'width': r['width'].toString(),
            'length': r['length'].toString(),
            'heading': r['heading'].toString(),
            'lat': rLat,
            'lon': rLon,
            'heading_raw': double.tryParse(r['heading_raw'].toString()) ?? 0.0,
          });
        }

        parsedRunways.sort((a, b) => a['name'].compareTo(b['name']));

        setState(() {
          _runways = parsedRunways;
          _isLoadingRunways = false;
          if (parsedRunways.isNotEmpty) {
            _airportCenterLat = sumLat / parsedRunways.length;
            _airportCenterLon = sumLon / parsedRunways.length;
          }
        });

        if (parsedRunways.isNotEmpty) {
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

    try {
      final dynamic airportData = await getOfflineAirportData(icao);

      if (airportData == null ||
          airportData['runways'] == null ||
          (airportData['runways'] as List).isEmpty) {
        if (mounted)
          setState(() {
            _gateErrorMessage = 'AIRPORT COORDS NOT FOUND';
            _isLoadingGates = false;
          });
        return;
      }

      double sumLat = 0.0;
      double sumLon = 0.0;
      List<dynamic> rwys = airportData['runways'];
      int count = rwys.length;

      for (var rwy in rwys) {
        sumLat += double.tryParse(rwy['lat'].toString()) ?? 0.0;
        sumLon += double.tryParse(rwy['lon'].toString()) ?? 0.0;
      }

      final double centerLat = sumLat / count;
      final double centerLon = sumLon / count;

      final String query = '''
        [out:json][timeout:25];
        (
          node["aeroway"~"gate|parking_position"](around:6500,$centerLat,$centerLon);
          way["aeroway"~"taxiway|taxilane"](around:6500,$centerLat,$centerLon);
        );
        out center geom;
      ''';

      final String encodedQuery = Uri.encodeComponent(query);

      final response = await http.get(
        Uri.parse(
            'https://overpass.openstreetmap.fr/api/interpreter?data=$encodedQuery'),
        headers: {'User-Agent': 'SimulatorStationApp/1'},
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

  void _selectRunway(Map<String, dynamic> runway,
      {bool triggerCallback = true}) {
    setState(() => _selectedRunway = runway);

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
          // TOP BAR
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
                        : _selectedMode == 2
                            ? _buildChartMiddleSection()
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

          // BOTTOM SECTION
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
                    : _selectedMode == 1
                        ? _buildGatesArea()
                        : _selectedMode == 2
                            ? _buildAirportChartArea()
                            : const Center(
                                child: Text("SELECT A MODE",
                                    style: TextStyle(color: Colors.white24))),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  onTap: () => _selectRunway(rw),
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
        child: Text("GATES & STANDS MODE",
            style: TextStyle(
                color: Color(0xFF5A94E3),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5)));
  }

  Widget _buildChartMiddleSection() {
    return const Center(
        child: Text("ADVANCED AIRPORT CHART",
            style: TextStyle(
                color: Color(0xFFF09819),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5)));
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
        _radioItem(2, 'AIRPORT CHART', () {
          setState(() => _selectedMode = 2);
          if (widget.onChartActionTap != null) widget.onChartActionTap!();
        }),
        _radioItem(3, 'MAP TELEPORT', () {
          setState(() => _selectedMode = 3);
          if (widget.onMapTeleportTap != null) widget.onMapTeleportTap!();
        }),
        _radioItem(4, 'WORLD TOUR', () {
          setState(() => _selectedMode = 4);
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
        padding: const EdgeInsets.symmetric(vertical: 2.5),
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
                text2: '2,500ft',
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
                text2: 'ON RWY',
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
                text2: '7000ft',
                angle: math.pi,
                txtDy: -40,
                onTap: widget.onPlaneHoldLeftTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.30,
                text1: 'Left Downwind',
                text2: '1000ft',
                angle: -math.pi / 2,
                txtDy: -40,
                onTap: widget.onPlaneLeftDownwindTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.45,
                yPct: 0.70,
                text1: 'Right base',
                text2: '7000ft',
                angle: 0,
                txtDy: 40,
                onTap: widget.onPlaneHoldRightTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.70,
                text1: 'Right Downwind',
                text2: '1,000ft',
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                color: Color(0xFF7AA5D2), strokeWidth: 3)),
        SizedBox(height: 20),
        Text('LOADING GATES...',
            style: TextStyle(
                color: Color(0xFF5A94E3),
                letterSpacing: 3,
                fontWeight: FontWeight.bold))
      ]));
    }
    if (_gateErrorMessage.isNotEmpty) {
      return Center(
          child: Text(_gateErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2.0)));
    }
    if (_gatesList.isEmpty) {
      return const Center(
          child: Text("NO ICAO LOADED YET",
              style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12),
        itemCount: _gatesList.length,
        itemBuilder: (context, index) {
          final gate = _gatesList[index];
          final isSelected = _selectedGateIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedGateIndex = index);
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
                      width: isSelected ? 1.5 : 1.0),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                              color: Color(0x335A94E3),
                              blurRadius: 10,
                              spreadRadius: 1)
                        ]
                      : []),
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
                            ])),
                  Text(gate['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: isSelected ? 16 : 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Courier')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAirportChartArea() {
    if (_airportCenterLat == null || _airportCenterLon == null) {
      return const Center(
          child: Text("SEARCH ICAO TO LOAD CHART",
              style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)));
    }
    return _AirportChartWidget(
      centerLat: _airportCenterLat!,
      centerLon: _airportCenterLon!,
      onChartGateSelected: (name, lat, lon, heading) {
        FFAppState().update(() {
          FFAppState().chartGateName = name;
          FFAppState().chartGateLat = lat;
          FFAppState().chartGateLon = lon;
          FFAppState().chartGateHdg = heading;
        });
        if (widget.onChartGateSelected != null) {
          widget.onChartGateSelected!(name, lat, lon, heading);
        }
      },
    );
  }
}

// ============================================================================
// كود الشارت المتقدم (يتم استدعاؤه داخل الويدجت الرئيسي)
// ============================================================================

class _AirportChartWidget extends StatefulWidget {
  final double centerLat;
  final double centerLon;
  final Function(String name, double lat, double lon, double heading)?
      onChartGateSelected;

  const _AirportChartWidget(
      {Key? key,
      required this.centerLat,
      required this.centerLon,
      this.onChartGateSelected})
      : super(key: key);

  @override
  _AirportChartWidgetState createState() => _AirportChartWidgetState();
}

class _AirportChartWidgetState extends State<_AirportChartWidget> {
  bool _isLoading = true;

  List<OSMWay> _runways = [];
  List<OSMWay> _taxiways = [];
  List<OSMWay> _aprons = [];
  List<OSMWay> _buildings = [];
  List<OSMNode> _holdShorts = [];
  List<OSMNode> _gates = [];
  List<OSMNode> _windsocks = [];

  final TransformationController _transformationController =
      TransformationController();
  final double mapScaleFactor = 150000.0;
  final double canvasSize = 6000.0;

  @override
  void initState() {
    super.initState();
    _fetchAllAirportData();
    _centerCamera();
  }

  @override
  void didUpdateWidget(covariant _AirportChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLat != widget.centerLat ||
        oldWidget.centerLon != widget.centerLon) {
      _fetchAllAirportData();
      _centerCamera();
    }
  }

  void _centerCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformationController.value = Matrix4.identity()
        ..translate(-canvasSize * 0.15 + 400, -canvasSize * 0.15 + 200)
        ..scale(0.15);
    });
  }

  Future<void> _fetchAllAirportData() async {
    setState(() => _isLoading = true);

    _runways.clear();
    _taxiways.clear();
    _aprons.clear();
    _buildings.clear();
    _holdShorts.clear();
    _gates.clear();
    _windsocks.clear();

    await _fetchLayer(
        '[out:json][timeout:15];way["aeroway"="runway"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'runway');
    await _fetchLayer(
        '[out:json][timeout:15];way["aeroway"~"taxiway|taxilane"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'taxiway');
    await _fetchLayer(
        '[out:json][timeout:15];way["aeroway"="apron"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'apron');
    await _fetchLayer(
        '[out:json][timeout:15];way["building"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'building');
    await _fetchLayer(
        '[out:json][timeout:15];node["aeroway"="holding_position"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'holdshort');
    await _fetchLayer(
        '[out:json][timeout:15];node["aeroway"="parking_position"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'gate');
    await _fetchLayer(
        '[out:json][timeout:15];node["aeroway"="windsock"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'windsock');

    _calculateGateHeadings();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchLayer(String query, String layerName) async {
    try {
      final String encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse(
            'https://overpass.openstreetmap.fr/api/interpreter?data=$encodedQuery'),
        headers: {'User-Agent': 'SimulatorStationApp/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _parseOSMData(jsonDecode(response.body), layerName);
      }
    } catch (e) {
      debugPrint('Skipped loading $layerName due to error: $e');
    }
  }

  void _parseOSMData(Map<String, dynamic> data, String layerName) {
    final elements = data['elements'] as List?;
    if (elements == null) return;

    for (var el in elements) {
      final tags = el['tags'] ?? {};
      final type = el['type'];

      if (type == 'way' && el['geometry'] != null) {
        List<Map<String, double>> geom = [];
        for (var pt in el['geometry']) {
          geom.add({
            'lat': (pt['lat'] as num).toDouble(),
            'lon': (pt['lon'] as num).toDouble()
          });
        }
        OSMWay way = OSMWay(geom: geom, tags: tags);
        if (layerName == 'runway')
          _runways.add(way);
        else if (layerName == 'taxiway')
          _taxiways.add(way);
        else if (layerName == 'apron')
          _aprons.add(way);
        else if (layerName == 'building') _buildings.add(way);
      } else if (type == 'node') {
        double lat = (el['lat'] as num).toDouble();
        double lon = (el['lon'] as num).toDouble();
        OSMNode node = OSMNode(lat: lat, lon: lon, tags: tags);
        if (layerName == 'holdshort')
          _holdShorts.add(node);
        else if (layerName == 'gate')
          _gates.add(node);
        else if (layerName == 'windsock') _windsocks.add(node);
      }
    }
  }

  void _calculateGateHeadings() {
    List<List<Map<String, double>>> taxiwaySegments = [];
    for (var twy in _taxiways) taxiwaySegments.add(twy.geom);

    int unnamedCounter = 1;
    for (var node in _gates) {
      String name = node.tags['ref'] ?? node.tags['name'] ?? '';
      if (name.isEmpty) {
        name = 'GATE $unnamedCounter';
        unnamedCounter++;
      }
      node.name = name.toUpperCase();

      double heading = 0.0;
      bool hasRealHeading = false;
      String? headingTag = node.tags['heading'] ??
          node.tags['direction'] ??
          node.tags['orientation'] ??
          node.tags['angle'] ??
          node.tags['airplane:heading'];

      if (headingTag != null) {
        try {
          String cleaned = headingTag.replaceAll(RegExp(r'[^0-9\.\-]'), '');
          if (cleaned.isNotEmpty) {
            heading = double.parse(cleaned);
            hasRealHeading = true;
          }
        } catch (_) {}
      }

      if (!hasRealHeading && taxiwaySegments.isNotEmpty) {
        bool connectionFound = false;
        double calculatedHeading = 0.0;
        double lat = node.lat;
        double lon = node.lon;

        for (var way in taxiwaySegments) {
          for (int i = 0; i < way.length; i++) {
            if ((way[i]['lat']! - lat).abs() < 0.000001 &&
                (way[i]['lon']! - lon).abs() < 0.000001) {
              connectionFound = true;
              if (i > 0)
                calculatedHeading = calculateBearing(
                    way[i - 1]['lat']!, way[i - 1]['lon']!, lat, lon);
              else if (i < way.length - 1)
                calculatedHeading =
                    calculateBearing(way[1]['lat']!, way[1]['lon']!, lat, lon);
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
          if (minDistance <= 250.0)
            calculatedHeading =
                calculateBearing(bestProjLat, bestProjLon, lat, lon);
        }
        heading = double.parse(calculatedHeading.toStringAsFixed(1));
      }
      node.heading = heading;
    }
  }

  Offset _projectToCanvas(double lat, double lon) {
    double x = (lon - widget.centerLon) *
        mapScaleFactor *
        math.cos(widget.centerLat * math.pi / 180.0);
    double y = (widget.centerLat - lat) * mapScaleFactor;
    return Offset(canvasSize / 2 + x, canvasSize / 2 + y);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
                color: Color(0xFF4A90E2), strokeWidth: 3))
        : Stack(
            children: [
              InteractiveViewer(
                transformationController: _transformationController,
                constrained: false,
                minScale: 0.02,
                maxScale: 10.0,
                boundaryMargin: const EdgeInsets.all(2000),
                child: SizedBox(
                  width: canvasSize,
                  height: canvasSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(canvasSize, canvasSize),
                        painter: AdvancedChartPainter(
                          centerLat: widget.centerLat,
                          centerLon: widget.centerLon,
                          runways: _runways,
                          taxiways: _taxiways,
                          aprons: _aprons,
                          buildings: _buildings,
                          holdShorts: _holdShorts,
                          windsocks: _windsocks,
                          mapScale: mapScaleFactor,
                        ),
                      ),
                      ..._gates.map((gate) {
                        Offset pos = _projectToCanvas(gate.lat, gate.lon);
                        return Positioned(
                          left: pos.dx - 100,
                          top: pos.dy - 100,
                          width: 200,
                          height: 200,
                          child: ChartAirplaneWidget(
                            gate: gate,
                            onTap: () {
                              if (widget.onChartGateSelected != null) {
                                widget.onChartGateSelected!(gate.name, gate.lat,
                                    gate.lon, gate.heading);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildNorthIndicator(),
                    const SizedBox(height: 20),
                    _buildExactScaleIndicator(),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildNorthIndicator() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: const Color(0xFF09121F).withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFF4A90E2).withOpacity(0.3), width: 1.0)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.navigation, color: Color(0xFF4A90E2), size: 20),
        Text('N',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _buildExactScaleIndicator() {
    return AnimatedBuilder(
      animation: _transformationController,
      builder: (context, child) {
        double currentZoom =
            _transformationController.value.getMaxScaleOnAxis();
        double metersPerPixel = (111320.0 / mapScaleFactor) / currentZoom;
        double initialBarWidth = 250.0;
        double totalMeters = initialBarWidth * metersPerPixel;
        double rawStep = totalMeters / 3;
        int step = _getNiceNumber(rawStep);
        int maxDist = step * 3;
        double barWidth = maxDist / metersPerPixel;
        const Color scaleColor = Color(0xFF638BB8);

        return Container(
          width: barWidth + 20,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('0',
                      style: TextStyle(
                          color: scaleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text('$step',
                      style: const TextStyle(
                          color: scaleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text('${step * 2}',
                      style: const TextStyle(
                          color: scaleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  Text('$maxDist m',
                      style: const TextStyle(
                          color: scaleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 4),
              CustomPaint(
                  size: Size(barWidth, 8),
                  painter: ExactScaleBarPainter(color: scaleColor)),
            ],
          ),
        );
      },
    );
  }

  int _getNiceNumber(double value) {
    if (value <= 0) return 1;
    double exponent = (math.log(value) / math.ln10).floorToDouble();
    double fraction = value / math.pow(10, exponent);
    double niceFraction;
    if (fraction < 1.5)
      niceFraction = 1;
    else if (fraction < 3)
      niceFraction = 2;
    else if (fraction < 7)
      niceFraction = 5;
    else
      niceFraction = 10;
    return (niceFraction * math.pow(10, exponent)).round();
  }
}

class ChartAirplaneWidget extends StatefulWidget {
  final OSMNode gate;
  final VoidCallback onTap;
  const ChartAirplaneWidget({Key? key, required this.gate, required this.onTap})
      : super(key: key);
  @override
  _ChartAirplaneWidgetState createState() => _ChartAirplaneWidgetState();
}

class _ChartAirplaneWidgetState extends State<ChartAirplaneWidget> {
  bool _isHovered = false;
  void _handleTap() {
    setState(() => _isHovered = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isHovered = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => setState(() => _isHovered = false),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color:
                      _isHovered ? const Color(0xFF223E63) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(widget.gate.name,
                  style: TextStyle(
                      color: _isHovered ? Colors.white : Colors.white70,
                      fontSize: _isHovered ? 24 : 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 5)
            ]),
            child: Center(
              child: Transform.rotate(
                angle: widget.gate.heading * math.pi / 180.0,
                child: CustomPaint(
                    size: const Size(60, 60),
                    painter: _AirplaneShapePainter(isHovered: _isHovered)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AirplaneShapePainter extends CustomPainter {
  final bool isHovered;
  _AirplaneShapePainter({required this.isHovered});
  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    canvas.save();
    canvas.translate(cx, cy);
    Path plane = Path();
    plane.moveTo(0, -20);
    plane.lineTo(4, -12);
    plane.lineTo(4, 4);
    plane.lineTo(24, 12);
    plane.lineTo(24, 18);
    plane.lineTo(4, 12);
    plane.lineTo(4, 28);
    plane.lineTo(12, 34);
    plane.lineTo(12, 38);
    plane.lineTo(0, 36);
    plane.lineTo(-12, 38);
    plane.lineTo(-12, 34);
    plane.lineTo(-4, 28);
    plane.lineTo(-4, 12);
    plane.lineTo(-24, 18);
    plane.lineTo(-24, 12);
    plane.lineTo(-4, 4);
    plane.lineTo(-4, -12);
    plane.close();
    canvas.drawPath(
        plane,
        Paint()
          ..color = isHovered ? Colors.white : const Color(0xFF7A9BBF)
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// Data Models & Painters
// ============================================================================
class OSMWay {
  final List<Map<String, double>> geom;
  final Map<String, dynamic> tags;
  OSMWay({required this.geom, required this.tags});
}

class OSMNode {
  final double lat;
  final double lon;
  final Map<String, dynamic> tags;
  String name = '';
  double heading = 0.0;
  OSMNode({required this.lat, required this.lon, required this.tags});
}

class ExactScaleBarPainter extends CustomPainter {
  final Color color;
  ExactScaleBarPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), paint);
    double third = size.width / 3;
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(third, 0), Offset(third, size.height), paint);
    canvas.drawLine(
        Offset(third * 2, 0), Offset(third * 2, size.height), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);
    double minorHeight = size.height / 2.5;
    double sixth = size.width / 6;
    canvas.drawLine(
        Offset(sixth, minorHeight), Offset(sixth, size.height), paint);
    canvas.drawLine(
        Offset(sixth * 3, minorHeight), Offset(sixth * 3, size.height), paint);
    canvas.drawLine(
        Offset(sixth * 5, minorHeight), Offset(sixth * 5, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AdvancedChartPainter extends CustomPainter {
  final double centerLat;
  final double centerLon;
  final List<OSMWay> runways;
  final List<OSMWay> taxiways;
  final List<OSMWay> aprons;
  final List<OSMWay> buildings;
  final List<OSMNode> holdShorts;
  final List<OSMNode> windsocks;
  final double mapScale;

  AdvancedChartPainter({
    required this.centerLat,
    required this.centerLon,
    required this.runways,
    required this.taxiways,
    required this.aprons,
    required this.buildings,
    required this.holdShorts,
    required this.windsocks,
    required this.mapScale,
  });

  Offset _project(double lat, double lon, Size size) {
    double x =
        (lon - centerLon) * mapScale * math.cos(centerLat * math.pi / 180.0);
    double y = (centerLat - lat) * mapScale;
    return Offset(size.width / 2 + x, size.height / 2 + y);
  }

  double _distanceToSegment(Offset p, Offset v, Offset w) {
    double l2 = (w.dx - v.dx) * (w.dx - v.dx) + (w.dy - v.dy) * (w.dy - v.dy);
    if (l2 == 0) return (p - v).distance;
    double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = math.max(0, math.min(1, t));
    Offset projection =
        Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - projection).distance;
  }

  bool _isNearRunway(Offset pt, Size size) {
    for (var rwy in runways) {
      if (rwy.geom.isEmpty) continue;
      for (int i = 0; i < rwy.geom.length - 1; i++) {
        var p1 = _project(rwy.geom[i]['lat']!, rwy.geom[i]['lon']!, size);
        var p2 =
            _project(rwy.geom[i + 1]['lat']!, rwy.geom[i + 1]['lon']!, size);
        if (_distanceToSegment(pt, p1, p2) < 100.0) return true;
      }
    }
    return false;
  }

  bool _isOverlapping(Rect candidate, List<Rect> existingLabels) {
    Rect inflated = candidate.inflate(15.0);
    for (Rect rect in existingLabels) {
      if (inflated.overlaps(rect)) return true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint apronPaint = Paint()
      ..color = const Color(0xFF131A26)
      ..style = PaintingStyle.fill;
    for (var way in aprons) {
      if (way.geom.length < 3) continue;
      Path path = Path();
      var first = _project(way.geom[0]['lat']!, way.geom[0]['lon']!, size);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < way.geom.length; i++) {
        var pt = _project(way.geom[i]['lat']!, way.geom[i]['lon']!, size);
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, apronPaint);
    }

    Paint buildingShadow = Paint()
      ..color = const Color(0xFF040810).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    Paint buildingRoof = Paint()
      ..color = const Color(0xFF1A2436)
      ..style = PaintingStyle.fill;
    Paint buildingEdge = Paint()
      ..color = const Color(0xFF2C3E5B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var way in buildings) {
      if (way.geom.length < 3) continue;
      Path shadowPath = Path();
      Path roofPath = Path();
      var first = _project(way.geom[0]['lat']!, way.geom[0]['lon']!, size);
      shadowPath.moveTo(first.dx + 12, first.dy + 12);
      roofPath.moveTo(first.dx, first.dy);
      for (int i = 1; i < way.geom.length; i++) {
        var pt = _project(way.geom[i]['lat']!, way.geom[i]['lon']!, size);
        shadowPath.lineTo(pt.dx + 12, pt.dy + 12);
        roofPath.lineTo(pt.dx, pt.dy);
      }
      shadowPath.close();
      roofPath.close();
      canvas.drawPath(shadowPath, buildingShadow);
      canvas.drawPath(roofPath, buildingRoof);
      canvas.drawPath(roofPath, buildingEdge);
    }

    Paint taxiwayBase = Paint()
      ..color = const Color(0xFF0F1724)
      ..strokeWidth = 45.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    Paint taxiwayYellowEdge = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 52.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    Paint taxiwayGlowBlue = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
      ..style = PaintingStyle.stroke;
    Paint taxiwaySolidBlue = Paint()
      ..color = const Color(0xFF8BBFFF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    for (var way in taxiways) {
      Path path = Path();
      var first = _project(way.geom[0]['lat']!, way.geom[0]['lon']!, size);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < way.geom.length; i++) {
        var pt = _project(way.geom[i]['lat']!, way.geom[i]['lon']!, size);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, taxiwayYellowEdge);
      canvas.drawPath(path, taxiwayBase);
      canvas.drawPath(path, taxiwayGlowBlue);
      canvas.drawPath(path, taxiwaySolidBlue);
    }

    Paint runwayBase = Paint()
      ..color = const Color(0xFF080D17)
      ..strokeWidth = 80.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    Paint runwayEdge = Paint()
      ..color = Colors.white
      ..strokeWidth = 84.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    Paint runwayCenterline = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    for (var way in runways) {
      if (way.geom.length < 2) continue;
      Path path = Path();
      var p1 = _project(way.geom[0]['lat']!, way.geom[0]['lon']!, size);
      var p2 = _project(way.geom[way.geom.length - 1]['lat']!,
          way.geom[way.geom.length - 1]['lon']!, size);
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      canvas.drawPath(path, runwayEdge);
      canvas.drawPath(path, runwayBase);
      double distance = (p2 - p1).distance;
      Offset dir = (p2 - p1) / distance;
      _drawRunwayThreshold(canvas, p1, dir, runwayBase.strokeWidth);
      _drawRunwayThreshold(canvas, p2, dir * -1, runwayBase.strokeWidth);
      double textOffsetDist = 110.0;
      double centerLineStartDist = 180.0;
      String ref = way.tags['ref'] ?? '';
      if (ref.isNotEmpty) {
        List<String> refs = ref.split('/');
        if (refs.isNotEmpty) {
          _drawTextRotated(canvas, refs[0], p1, dir, textOffsetDist);
          if (refs.length > 1)
            _drawTextRotated(canvas, refs[1], p2, dir * -1, textOffsetDist);
        }
      }
      double dashLength = 40.0;
      double dashSpace = 40.0;
      double currentDist = centerLineStartDist;
      while (currentDist < distance - centerLineStartDist) {
        Offset start = p1 + dir * currentDist;
        currentDist += dashLength;
        if (currentDist > distance - centerLineStartDist)
          currentDist = distance - centerLineStartDist;
        Offset end = p1 + dir * currentDist;
        canvas.drawLine(start, end, runwayCenterline);
        currentDist += dashSpace;
      }
    }

    for (var node in holdShorts) {
      var pt = _project(node.lat, node.lon, size);
      _drawHoldShort(canvas, pt, node.lat, node.lon, size);
    }

    List<Rect> drawnLabels = [];
    for (var way in taxiways) {
      String ref = way.tags['ref'] ?? '';
      if (ref.isEmpty || way.geom.length < 2) continue;
      double maxLen = 0;
      Offset? bestStart, bestEnd;
      for (int i = 0; i < way.geom.length - 1; i++) {
        var p1 = _project(way.geom[i]['lat']!, way.geom[i]['lon']!, size);
        var p2 =
            _project(way.geom[i + 1]['lat']!, way.geom[i + 1]['lon']!, size);
        double dist = (p2 - p1).distance;
        if (dist > maxLen) {
          maxLen = dist;
          bestStart = p1;
          bestEnd = p2;
        }
      }
      if (maxLen < 120.0 || bestStart == null || bestEnd == null) continue;
      _attemptToPlaceTaxiwayLabel(
          canvas, ref, bestStart, bestEnd, drawnLabels, size);
    }

    for (var node in windsocks) {
      var pt = _project(node.lat, node.lon, size);
      _drawGiantWindsock(canvas, pt);
    }
  }

  void _attemptToPlaceTaxiwayLabel(Canvas canvas, String text, Offset p1,
      Offset p2, List<Rect> drawnLabels, Size size) {
    Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    Offset dir = Offset(dx / dist, dy / dist);
    Offset perp1 = Offset(-dir.dy, dir.dx);
    Offset perp2 = Offset(dir.dy, -dir.dx);
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(
                color: Color(0xFFFFD460),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier')),
        textDirection: ui.TextDirection.ltr);
    textPainter.layout();
    double boxWidth = textPainter.width + 40;
    double boxHeight = textPainter.height + 20;
    List<Offset> candidates = [
      mid + (perp1 * 90.0),
      mid + (perp2 * 90.0),
      mid + (perp1 * 150.0),
      mid + (perp2 * 150.0)
    ];
    for (Offset candidate in candidates) {
      Rect candidateRect = Rect.fromCenter(
          center: candidate, width: boxWidth, height: boxHeight);
      if (!_isOverlapping(candidateRect, drawnLabels) &&
          !_isNearRunway(candidate, size)) {
        canvas.drawLine(
            mid,
            candidate,
            Paint()
              ..color = Colors.white.withOpacity(0.4)
              ..strokeWidth = 2.0
              ..style = PaintingStyle.stroke);
        _drawLabelBox(
            canvas, text, candidate, textPainter, boxWidth, boxHeight);
        drawnLabels.add(candidateRect);
        return;
      }
    }
  }

  void _drawLabelBox(Canvas canvas, String text, Offset position,
      TextPainter textPainter, double width, double height) {
    final rect =
        Rect.fromCenter(center: position, width: width, height: height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = Colors.black);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = const Color(0xFFFFD460)
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke);
    textPainter.paint(
        canvas,
        Offset(position.dx - textPainter.width / 2,
            position.dy - textPainter.height / 2));
  }

  void _drawRunwayThreshold(
      Canvas canvas, Offset pos, Offset dir, double runwayWidth) {
    Offset perp = Offset(-dir.dy, dir.dx);
    Paint thresholdPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5;
    int numLines = 6;
    double spacing = (runwayWidth / 2) / (numLines + 1);
    for (int i = -numLines; i <= numLines; i++) {
      if (i == 0) continue;
      Offset start = pos + (perp * (i * spacing)) + (dir * 10.0);
      Offset end = start + (dir * 45.0);
      canvas.drawLine(start, end, thresholdPaint);
    }
  }

  void _drawHoldShort(
      Canvas canvas, Offset pt, double lat, double lon, Size size) {
    Offset? dir;
    for (var way in taxiways) {
      for (int i = 0; i < way.geom.length - 1; i++) {
        var p1 = _project(way.geom[i]['lat']!, way.geom[i]['lon']!, size);
        var p2 =
            _project(way.geom[i + 1]['lat']!, way.geom[i + 1]['lon']!, size);
        if (_distanceToSegment(pt, p1, p2) < 30.0) {
          double dx = p2.dx - p1.dx;
          double dy = p2.dy - p1.dy;
          double length = math.sqrt(dx * dx + dy * dy);
          if (length > 0) {
            dir = Offset(dx / length, dy / length);
            break;
          }
        }
      }
      if (dir != null) break;
    }
    dir ??= const Offset(1, 0);
    Offset perp = Offset(-dir.dy, dir.dx);
    Offset? closestRunwayCenter;
    double minRunwayDist = double.infinity;
    for (var rwy in runways) {
      if (rwy.geom.isEmpty) continue;
      var rwyPt = _project(rwy.geom[rwy.geom.length ~/ 2]['lat']!,
          rwy.geom[rwy.geom.length ~/ 2]['lon']!, size);
      double d = (pt - rwyPt).distance;
      if (d < minRunwayDist) {
        minRunwayDist = d;
        closestRunwayCenter = rwyPt;
      }
    }
    if (closestRunwayCenter != null) {
      Offset toRunway = closestRunwayCenter - pt;
      double dotProduct = (dir.dx * toRunway.dx) + (dir.dy * toRunway.dy);
      if (dotProduct < 0) dir = Offset(-dir.dx, -dir.dy);
    }
    Paint redGlow = Paint()
      ..color = Colors.redAccent.withOpacity(0.6)
      ..strokeWidth = 35.0
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0)
      ..style = PaintingStyle.stroke;
    Paint redSolid = Paint()
      ..color = const Color(0xFF990000)
      ..strokeWidth = 25.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    double barWidth = 60.0;
    Offset startBar = pt - (perp * (barWidth / 2));
    Offset endBar = pt + (perp * (barWidth / 2));
    canvas.drawLine(startBar, endBar, redGlow);
    canvas.drawLine(startBar, endBar, redSolid);
    Paint yellowLine = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    double lineSpacing = 4.0;
    Offset solidLine1 = pt - (dir * (lineSpacing * 1.5));
    Offset solidLine2 = pt - (dir * (lineSpacing * 0.5));
    canvas.drawLine(solidLine1 - (perp * (barWidth / 2)),
        solidLine1 + (perp * (barWidth / 2)), yellowLine);
    canvas.drawLine(solidLine2 - (perp * (barWidth / 2)),
        solidLine2 + (perp * (barWidth / 2)), yellowLine);
    Offset dashedLine1 = pt + (dir * (lineSpacing * 0.5));
    Offset dashedLine2 = pt + (dir * (lineSpacing * 1.5));
    _drawDashedLine(canvas, dashedLine1 - (perp * (barWidth / 2)),
        dashedLine1 + (perp * (barWidth / 2)), yellowLine);
    _drawDashedLine(canvas, dashedLine2 - (perp * (barWidth / 2)),
        dashedLine2 + (perp * (barWidth / 2)), yellowLine);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    double dashWidth = 8.0;
    double dashSpace = 6.0;
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    Offset dir = Offset(dx / distance, dy / distance);
    double currentDist = 0;
    while (currentDist < distance) {
      double endDash = math.min(currentDist + dashWidth, distance);
      canvas.drawLine(
          start + (dir * currentDist), start + (dir * endDash), paint);
      currentDist = endDash + dashSpace;
    }
  }

  void _drawTextRotated(Canvas canvas, String text, Offset position,
      Offset direction, double offsetDist) {
    final textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900)),
        textDirection: ui.TextDirection.ltr);
    textPainter.layout();
    double angle = math.atan2(direction.dy, direction.dx) + math.pi / 2;
    canvas.save();
    Offset offsetPos = position + (direction * offsetDist);
    canvas.translate(offsetPos.dx, offsetPos.dy);
    canvas.rotate(angle);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  void _drawGiantWindsock(Canvas canvas, Offset position) {
    canvas.drawCircle(
        position,
        50.0,
        Paint()
          ..color = const Color(0xFF4A90E2).withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0));
    canvas.drawCircle(
        position,
        20.0,
        Paint()
          ..color = const Color(0xFFFF6B00).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0));
    canvas.drawCircle(position, 8.0, Paint()..color = Colors.white);
    Path tail = Path();
    tail.moveTo(position.dx, position.dy - 15);
    tail.lineTo(position.dx + 70, position.dy - 6);
    tail.lineTo(position.dx + 70, position.dy + 6);
    tail.lineTo(position.dx, position.dy + 15);
    tail.close();
    canvas.drawPath(
        tail,
        Paint()
          ..color = const Color(0xFFFF6B00)
          ..style = PaintingStyle.fill);
    Path whiteTip = Path();
    whiteTip.moveTo(position.dx + 70, position.dy - 6);
    whiteTip.lineTo(position.dx + 85, position.dy - 4);
    whiteTip.lineTo(position.dx + 85, position.dy + 4);
    whiteTip.lineTo(position.dx + 70, position.dy + 6);
    whiteTip.close();
    canvas.drawPath(
        whiteTip,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// الكلاسات القديمة والأساسية للواجهة (تم استعادتها لعدم ظهور أ
