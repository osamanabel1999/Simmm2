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

// 🔴 تم تغيير المكتبة لتكون المكتبة الرسمية الحديثة
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '/app_state.dart';

class EFBRadarMap extends StatefulWidget {
  const EFBRadarMap({
    Key? key,
    this.width,
    this.height,
    this.userNetworkId,
    this.depIcao,
    this.arrIcao,
    this.initialLat,
    this.initialLng,
    this.initialZoom,
    this.onLocationSelected,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? userNetworkId;
  final String? depIcao;
  final String? arrIcao;

  final double? initialLat;
  final double? initialLng;
  final double? initialZoom;

  final Future Function(
    double? selectedLatitude,
    double? selectedLongitude,
    double? altitudeFt,
    double? headingDeg,
    double? speedKnots,
  )? onLocationSelected;

  @override
  _EFBRadarMapState createState() => _EFBRadarMapState();
}

class _EFBRadarMapState extends State<EFBRadarMap> {
  // 🔴 Controller متوافق مع الإصدار الرابع الرسمي
  late final WebViewController _webviewController;

  bool showVatsim = true;
  bool showIvao = true;
  bool showAirports = false;
  bool showCallsigns = false;
  bool showRadarMode = false;

  bool showLeftMenu = false;
  bool showRightMenu = false;
  String currentMapStyle = 'DARK';
  String activeWeatherLayer = 'NONE';

  Map<String, dynamic>? selectedItem;
  Timer? _refreshTimer;
  Timer? _clockTimer;
  String zuluTime = "";

  List<dynamic> rawVatsimPlanes = [];
  List<dynamic> rawIvaoPlanes = [];
  List<dynamic> rawAirports = [];
  final TextEditingController _searchController = TextEditingController();
  bool showSearchDropdown = false;
  List<Map<String, dynamic>> searchResults = [];

  // --- New Features State Variables ---
  bool teleportMode = false;
  bool showTeleportControls = false;
  double? manualLat;
  double? manualLng;
  final TextEditingController _speedCtrl = TextEditingController(text: "450");
  final TextEditingController _altCtrl = TextEditingController(text: "36000");
  final TextEditingController _hdgCtrl = TextEditingController(text: "90");
  bool showFlightPath = false;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPlanesForSearch();
      _fetchAirportsForSearch();
    });
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 30), (_) => _fetchPlanesForSearch());

    // 🔴 تجهيز رابط الخريطة وبدء تشغيل الـ WebView Controller الحديث
    String mapUrl =
        "https://osamanabel1999.github.io/EFB-Map/?lat=${widget.initialLat ?? 20.0}&lon=${widget.initialLng ?? 20.0}&zoom=${widget.initialZoom ?? 1.8}&dep=${widget.depIcao ?? ''}&arr=${widget.arrIcao ?? ''}&uid=${widget.userNetworkId ?? ''}";

    _webviewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'EFBMapChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final parsed = jsonDecode(message.message);
          final action = parsed['action'];
          final data = parsed['data'];

          if (action == 'PLANE_CLICKED') {
            setState(() {
              selectedItem = {
                'type': 'PLANE',
                'data': data['data'],
                'net': data['net'],
                'isVatsim': data['isVatsim']
              };
            });
          } else if (action == 'AIRPORT_CLICKED') {
            setState(() {
              selectedItem = {'type': 'AIRPORT', 'data': data['data']};
            });
          } else if (action == 'TELEPORT_CLICKED') {
            setState(() {
              manualLat = data['lat'];
              manualLng = data['lon'];
            });
            _webviewController.runJavaScript(
                "window.triggerTeleport(${data['lat']}, ${data['lon']}, ${_hdgCtrl.text});");
          } else if (action == 'MAP_CLICKED') {
            setState(() {
              selectedItem = null;
              showSearchDropdown = false;
            });
            FocusScope.of(context).unfocus();
          }
        },
      )
      ..loadRequest(Uri.parse(mapUrl));
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _refreshTimer?.cancel();
    _searchController.dispose();
    _speedCtrl.dispose();
    _altCtrl.dispose();
    _hdgCtrl.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now().toUtc();
    if (mounted) {
      setState(() {
        zuluTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ZULU";
      });
    }
  }

  Future<void> _fetchAirportsForSearch() async {
    try {
      final response = await http.get(Uri.parse(
          'https://gist.githubusercontent.com/tdreyno/4278655/raw/airports.json'));
      if (response.statusCode == 200) {
        rawAirports = json.decode(response.body);
      }
    } catch (e) {}
  }

  Future<void> _fetchPlanesForSearch() async {
    if (showVatsim) {
      try {
        final res = await http
            .get(Uri.parse('https://data.vatsim.net/v3/vatsim-data.json'));
        if (res.statusCode == 200) {
          rawVatsimPlanes = json.decode(res.body)['pilots'] as List;
        }
      } catch (e) {}
    }
    if (showIvao) {
      try {
        final res = await http
            .get(Uri.parse('https://api.ivao.aero/v2/tracker/whazzup'));
        if (res.statusCode == 200) {
          rawIvaoPlanes = json.decode(res.body)['clients']['pilots'] as List;
        }
      } catch (e) {}
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchDropdown = false;
      });
      return;
    }

    String q = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    for (var ap in rawAirports) {
      String icao = (ap['icao'] ?? "").toString().toLowerCase();
      String iata = (ap['iata'] ?? "").toString().toLowerCase();
      String name = (ap['name'] ?? "").toString().toLowerCase();
      if (icao.contains(q) || iata.contains(q) || name.contains(q)) {
        results.add({
          'type': 'AIRPORT',
          'title': '${ap['icao']} - ${ap['name']}',
          'data': ap
        });
      }
    }

    for (var p in rawVatsimPlanes) {
      String callsign = (p['callsign'] ?? "").toString().toLowerCase();
      if (callsign.contains(q)) {
        results.add({
          'type': 'PLANE',
          'title': '${p['callsign']} (VATSIM)',
          'data': p,
          'net': 'VATSIM',
          'isVatsim': true
        });
      }
    }

    for (var p in rawIvaoPlanes) {
      String callsign = (p['callsign'] ?? "").toString().toLowerCase();
      if (callsign.contains(q)) {
        results.add({
          'type': 'PLANE',
          'title': '${p['callsign']} (IVAO)',
          'data': p,
          'net': 'IVAO',
          'isVatsim': false
        });
      }
    }

    setState(() {
      searchResults = results.take(6).toList();
      showSearchDropdown = results.isNotEmpty;
    });
  }

  void _onSearchResultSelected(Map<String, dynamic> result) {
    setState(() {
      showSearchDropdown = false;
      _searchController.clear();
      FocusScope.of(context).unfocus();

      selectedItem = {
        'type': result['type'],
        'data': result['data'],
        if (result['type'] == 'PLANE') 'net': result['net'],
        if (result['type'] == 'PLANE') 'isVatsim': result['isVatsim']
      };
    });

    double lat = 0.0;
    double lon = 0.0;

    if (result['type'] == 'AIRPORT') {
      lat = double.parse(result['data']['lat'].toString());
      lon = double.parse(result['data']['lon'].toString());
    } else if (result['type'] == 'PLANE') {
      bool isVatsim = result['isVatsim'];
      lat = isVatsim
          ? (result['data']['latitude'] ?? 0.0).toDouble()
          : (result['data']['lastTrack']?['latitude'] ?? 0.0).toDouble();
      lon = isVatsim
          ? (result['data']['longitude'] ?? 0.0).toDouble()
          : (result['data']['lastTrack']?['longitude'] ?? 0.0).toDouble();
    }
    // 🔴 تشغيل الجافا سكريبت بالطريقة الحديثة
    _webviewController.runJavaScript("window.flyToCoords($lat, $lon, 11.0);");
  }

  void _sendMapState(String key, dynamic value) {
    String valStr = value is String ? "'$value'" : value.toString();
    _webviewController.runJavaScript("window.setMapState('$key', $valStr);");
  }

  void _triggerTeleportAction() {
    if (manualLat != null && manualLng != null) {
      double alt = double.tryParse(_altCtrl.text) ?? 36000.0;
      double hdg = double.tryParse(_hdgCtrl.text) ?? 90.0;
      double spd = double.tryParse(_speedCtrl.text) ?? 450.0;

      // 1. تخزين البيانات فوراً في الـ App State
      FFAppState().msfsTeleportLat = manualLat!;
      FFAppState().msfsTeleportLng = manualLng!;
      FFAppState().msfsTeleportAlt = alt;
      FFAppState().msfsTeleportHdg = hdg;
      FFAppState().msfsTeleportSpd = spd;

      // 2. إرسال البيانات للـ Action Parameter
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(
          manualLat!,
          manualLng!,
          alt,
          hdg,
          spd,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant EFBRadarMap oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ==========================================
          // الطبقة السفلية: الخريطة الـ 3D (بالمكتبة الرسمية)
          // ==========================================
          SizedBox(
            width: widget.width ?? MediaQuery.of(context).size.width,
            height: widget.height ?? MediaQuery.of(context).size.height,
            child: WebViewWidget(controller: _webviewController),
          ),

          // ==========================================
          // الطبقات العلوية: تصميم فلاتر الأصلي بدون أي تغيير
          // ==========================================

          // --- شريط البحث بالكامل فوق ---
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.6), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4)
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search ICAO, Callsign...",
                      hintStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.cyanAccent, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white70, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  showSearchDropdown = false;
                                  searchResults.clear();
                                });
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (showSearchDropdown)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final res = searchResults[index];
                        IconData icn = res['type'] == 'AIRPORT'
                            ? Icons.local_airport
                            : Icons.flight;
                        Color icnColor = res['type'] == 'AIRPORT'
                            ? Colors.cyanAccent
                            : (res['isVatsim'] == true
                                ? Colors.amber
                                : Colors.greenAccent);
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          leading: Icon(icn, color: icnColor, size: 20),
                          title: Text(res['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          onTap: () => _onSearchResultSelected(res),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),

          // --- ساعة الزولو (Zulu Time) ---
          Positioned(
            bottom: 25,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.6),
                    width: 1.5),
              ),
              child: Text(
                zuluTime,
                style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    shadows: [Shadow(blurRadius: 5, color: Color(0xFF00E5FF))]),
              ),
            ),
          ),

          // --- ملاحظة تحريك الطائرة أسفل الخريطة ---
          if (teleportMode)
            Positioned(
              bottom: 6,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4), width: 1),
                ),
                child: const Text(
                  "* Teleport feature currently works with MSFS only",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // --- القائمة اللي على الشمال ---
          Positioned(
            top: 65,
            left: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLeftMenu)
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(color: Colors.white24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _menuBtn("VATSIM", showVatsim, () {
                        setState(() => showVatsim = !showVatsim);
                        _sendMapState('vatsim', showVatsim);
                      }),
                      _menuBtn("IVAO", showIvao, () {
                        setState(() => showIvao = !showIvao);
                        _sendMapState('ivao', showIvao);
                      }),
                      _menuBtn("AIRPORT", showAirports, () {
                        setState(() => showAirports = !showAirports);
                        _sendMapState('airports', showAirports);
                      }),
                      _menuBtn("CALLSIGN", showCallsigns, () {
                        setState(() => showCallsigns = !showCallsigns);
                        _sendMapState('callsigns', showCallsigns);
                      }),
                      _menuBtn("RADAR", showRadarMode, () {
                        setState(() => showRadarMode = !showRadarMode);
                        _sendMapState('radar', showRadarMode);
                      }),
                      _menuBtn("TELEPORT", teleportMode, () {
                        setState(() {
                          teleportMode = !teleportMode;
                          if (teleportMode) showTeleportControls = true;
                        });
                        _sendMapState('teleportMode', teleportMode);
                      }),
                      _menuBtn("FLIGHT PATH", showFlightPath, () {
                        setState(() => showFlightPath = !showFlightPath);
                        _sendMapState('flightPath', showFlightPath);
                      }),
                    ]),
                  ),
                GestureDetector(
                  onTap: () => setState(() => showLeftMenu = !showLeftMenu),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24)),
                    child: Icon(showLeftMenu ? Icons.chevron_left : Icons.menu,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // --- القائمة اللي على اليمين ---
          Positioned(
            top: 65,
            right: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => showRightMenu = !showRightMenu),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24)),
                    child: Icon(
                        showRightMenu ? Icons.chevron_right : Icons.layers,
                        color: Colors.white,
                        size: 20),
                  ),
                ),
                if (showRightMenu)
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(color: Colors.white24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _menuBtn("DARK", currentMapStyle == 'DARK', () {
                        setState(() => currentMapStyle = 'DARK');
                        _sendMapState('mapStyle', 'DARK');
                      }),
                      _menuBtn("SATELLITE", currentMapStyle == 'SATELLITE', () {
                        setState(() => currentMapStyle = 'SATELLITE');
                        _sendMapState('mapStyle', 'SATELLITE');
                      }),
                      const Divider(color: Colors.white24, height: 1),
                      _weatherMenuBtn("RAIN", activeWeatherLayer == 'RAIN', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'RAIN' ? 'NONE' : 'RAIN');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                      _weatherMenuBtn("TEMP", activeWeatherLayer == 'TEMP', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'TEMP' ? 'NONE' : 'TEMP');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                      _weatherMenuBtn("WIND", activeWeatherLayer == 'WIND', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'WIND' ? 'NONE' : 'WIND');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                    ]),
                  ),
              ],
            ),
          ),

          // --- لوحة التحكم الخاصة بالـ Teleport ---
          if (teleportMode && showTeleportControls)
            Positioned(
              bottom: 80,
              left: 15,
              child: _buildTeleportControls(),
            ),

          if (teleportMode && !showTeleportControls)
            Positioned(
              bottom: 25,
              left: 15,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                onPressed: () => setState(() => showTeleportControls = true),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),

          if (selectedItem != null && selectedItem!['type'] == 'PLANE')
            _buildInfoBox(selectedItem!['data'], selectedItem!['net'],
                selectedItem!['isVatsim']),

          if (selectedItem != null && selectedItem!['type'] == 'AIRPORT')
            _buildAirportInfoBox(selectedItem!['data']),
        ],
      ),
    );
  }

  Widget _buildTeleportControls() {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.orangeAccent.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TELEPORT SETTINGS",
                  style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => setState(() => showTeleportControls = false),
                child: const Icon(Icons.close, color: Colors.white70, size: 16),
              )
            ],
          ),
          const Divider(color: Colors.white24),
          _buildInputRow("ALT", _altCtrl),
          _buildInputRow("SPD", _speedCtrl),
          _buildInputRow("HDG", _hdgCtrl),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              minimumSize: const Size.fromHeight(28),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              if (manualLat != null && manualLng != null) {
                _triggerTeleportAction();
              }
            },
            child: const Text("SEND TELEPORT",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 35,
              child: Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10))),
          Expanded(
            child: SizedBox(
              height: 24,
              child: TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  setState(() {});
                  if (manualLat != null && manualLng != null) {
                    _webviewController.runJavaScript(
                        "window.triggerTeleport($manualLat, $manualLng, ${_hdgCtrl.text});");
                  }
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAirportInfoBox(dynamic ap) {
    return AdvancedAirportInfoBox(
      ap: ap,
      onClose: () => setState(() => selectedItem = null),
    );
  }

  Widget _buildInfoBox(dynamic p, String net, bool isVatsim) {
    String call = p['callsign'] ?? "N/A";
    String dep = isVatsim
        ? (p['flight_plan']?['departure'] ?? "N/A")
        : (p['flightPlan']?['departureId'] ?? "N/A");
    String arr = isVatsim
        ? (p['flight_plan']?['arrival'] ?? "N/A")
        : (p['flightPlan']?['arrivalId'] ?? "N/A");
    String acft = isVatsim
        ? (p['flight_plan']?['aircraft_short'] ?? "ACFT")
        : (p['flightPlan']?['aircraft']['icaoCode'] ?? "ACFT");
    int alt = isVatsim
        ? (p['altitude'] ?? 0).toInt()
        : (p['lastTrack']?['altitude'] ?? 0).toInt();
    int gs = isVatsim
        ? (p['groundspeed'] ?? 0).toInt()
        : (p['lastTrack']?['groundSpeed'] ?? 0).toInt();
    int vs = isVatsim
        ? (p['vertical_speed'] ?? 0).toInt()
        : (p['lastTrack']?['verticalSpeed'] ?? 0).toInt();
    int hdg = isVatsim
        ? (p['heading'] ?? 0).toInt()
        : (p['lastTrack']?['heading'] ?? 0).toInt();
    String squawk = isVatsim
        ? "${p['transponder'] ?? '7000'}"
        : "${p['lastTrack']?['squawk'] ?? '7000'}";
    String pilot =
        isVatsim ? (p['name'] ?? "Unknown Pilot") : "Pilot ID: ${p['userId']}";
    String route = isVatsim
        ? (p['flight_plan']?['route'] ?? "N/A")
        : (p['flightPlan']?['route'] ?? "N/A");

    String cleanCall = call.trim().toUpperCase();
    String icao3 = "GEN";
    final match = RegExp(r'^[A-Z]{3}').firstMatch(cleanCall);
    if (match != null) {
      icao3 = match.group(0)!;
    } else if (cleanCall.length >= 3) {
      icao3 = cleanCall.substring(0, 3);
    }
    String logoUrl =
        "https://www.flightaware.com/images/airline_logos/90p/$icao3.png";

    String startTime =
        isVatsim ? (p['logon_time'] ?? "") : (p['createdAt'] ?? "");
    int onlineMinutes = 0;
    if (startTime.isNotEmpty) {
      try {
        DateTime start = DateTime.parse(startTime);
        Duration diff = DateTime.now().toUtc().difference(start);
        onlineMinutes = diff.inMinutes;
      } catch (e) {}
    }
    String timeOnline = "${onlineMinutes ~/ 60}h ${onlineMinutes % 60}m";

    int totalPlannedMins = 0;
    if (isVatsim) {
      String enroute = p['flight_plan']?['enroute_time'] ?? "0000";
      if (enroute.length == 4) {
        int h = int.tryParse(enroute.substring(0, 2)) ?? 0;
        int m = int.tryParse(enroute.substring(2, 4)) ?? 0;
        totalPlannedMins = h * 60 + m;
      }
    } else {
      int eet = int.tryParse(p['flightPlan']?['eet']?.toString() ?? '0') ?? 0;
      totalPlannedMins = eet > 1000 ? eet ~/ 60 : eet;
    }

    double progress = 0.5;
    String remaining = "N/A";
    if (totalPlannedMins > 0 && onlineMinutes > 0) {
      progress = onlineMinutes / totalPlannedMins;
      if (progress > 1.0) progress = 1.0;
      int remMins = totalPlannedMins - onlineMinutes;
      if (remMins < 0) remMins = 0;
      remaining = "${remMins ~/ 60}h ${remMins % 60}m";
    }

    double alignX = (progress * 2) - 1.0;
    int distFlown = (gs * (onlineMinutes / 60.0)).round();

    return Positioned(
      bottom: 15,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(logoUrl,
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.flight,
                              color: Colors.black54, size: 40)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(call,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(pilot,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text("Total Hrs: N/A (API) | Online: $timeOnline",
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isVatsim
                          ? Colors.amber.withOpacity(0.15)
                          : Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isVatsim ? Colors.amber : Colors.greenAccent),
                    ),
                    child: Text(net,
                        style: TextStyle(
                            color: isVatsim ? Colors.amber : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dep,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                  const Icon(Icons.flight_takeoff,
                      color: Colors.white38, size: 16),
                  const Icon(Icons.flight_land,
                      color: Colors.white38, size: 16),
                  Text(arr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      height: 2, width: double.infinity, color: Colors.white24),
                  Align(
                    alignment: Alignment(alignX, 0),
                    child: Transform.rotate(
                        angle: 3.14159 / 2,
                        child: const Icon(Icons.airplanemode_active,
                            color: Colors.blueAccent, size: 24)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dist: $distFlown nm",
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                  Text("ETA: $remaining",
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1)),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                children: [
                  _stat("GS", "$gs kts"),
                  _stat("ALT", "$alt ft"),
                  _stat("VS", "$vs fpm"),
                  _stat("HDG", "$hdg°"),
                  _stat("SQUAWK", squawk),
                  _stat("TYPE", acft),
                ],
              ),
              const SizedBox(height: 12),
              const Text("FLIGHT PLAN / ROUTE:",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10)),
                child: Text(route,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String l, String v) => Column(children: [
        Text(l, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Text(v,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
      ]);
  Widget _menuBtn(String label, bool active, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: active ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: active ? Colors.blueAccent : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)))));
  Widget _weatherMenuBtn(String label, bool active, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color:
                  active ? Colors.orange.withOpacity(0.2) : Colors.transparent,
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          color: active ? Colors.orangeAccent : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)))));
}

// ============================================================================
// 👇👇 الـ Widget الاحترافي الخاص بالمطار 👇👇
// ============================================================================

class AdvancedAirportInfoBox extends StatefulWidget {
  final dynamic ap;
  final VoidCallback onClose;

  const AdvancedAirportInfoBox({
    Key? key,
    required this.ap,
    required this.onClose,
  }) : super(key: key);

  @override
  _AdvancedAirportInfoBoxState createState() => _AdvancedAirportInfoBoxState();
}

class _AdvancedAirportInfoBoxState extends State<AdvancedAirportInfoBox> {
  bool isLoading = true;
  Map<String, dynamic>? fpdbData;

  List<dynamic> vatsimControllers = [];
  String vatsimAtis = "";
  String vatsimMetar = "";

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void didUpdateWidget(covariant AdvancedAirportInfoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ap['icao'] != widget.ap['icao']) {
      _fetchAllData();
    }
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    String icao = widget.ap['icao']?.toString().toUpperCase() ?? "";

    try {
      final fp = await http.get(
          Uri.parse('https://api.flightplandatabase.com/nav/airport/$icao'));
      if (fp.statusCode == 200) {
        fpdbData = json.decode(fp.body);
      }

      final vat = await http
          .get(Uri.parse('https://data.vatsim.net/v3/vatsim-data.json'));
      if (vat.statusCode == 200) {
        final vatData = json.decode(vat.body);
        final controllers = vatData['controllers'] as List;
        final atisList = vatData['atis'] as List;

        vatsimControllers = controllers.where((c) {
          String cs = c['callsign']?.toString() ?? "";
          return cs.startsWith("${icao}_");
        }).toList();

        var atisNode = atisList.firstWhere((a) {
          String cs = a['callsign']?.toString() ?? "";
          return cs.startsWith("${icao}_");
        }, orElse: () => null);

        if (atisNode != null && atisNode['text_atis'] != null) {
          if (atisNode['text_atis'] is List) {
            vatsimAtis = (atisNode['text_atis'] as List).join("\n");
          } else {
            vatsimAtis = atisNode['text_atis'].toString();
          }
        }

        final met = await http
            .get(Uri.parse('https://metar.vatsim.net/metar.php?id=$icao'));
        if (met.statusCode == 200) {
          vatsimMetar = met.body.trim();
        }
      }
    } catch (e) {}

    if (mounted) setState(() => isLoading = false);
  }

  String _str(dynamic val, [String def = "-"]) =>
      val != null ? val.toString() : def;

  String _parseLighting(dynamic l) {
    if (l == null) return "-";
    if (l is bool) return l ? "YES" : "NO";
    if (l is List) return l.join(", ");
    return l.toString();
  }

  String _formatFreq(dynamic freqVal) {
    if (freqVal == null) return "-";
    String s = freqVal.toString();
    double? d = double.tryParse(s);
    if (d == null) return s;
    if (d > 1000) {
      String str = d.toInt().toString();
      if (str.length >= 3) {
        String formatted = "${str.substring(0, 3)}.${str.substring(3)}";
        double? parsed = double.tryParse(formatted);
        if (parsed != null) d = parsed;
      }
    }
    return d.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.ap['name'] ?? "Unknown Airport";
    String icao = widget.ap['icao'] ?? "N/A";
    String city = widget.ap['city'] ?? "Unknown City";
    String country = widget.ap['country'] ?? "Unknown Country";

    String iata =
        widget.ap['IATA'] ?? widget.ap['iata'] ?? widget.ap['iata_code'] ?? "-";

    return Positioned(
      bottom: 15,
      left: 10,
      right: 10,
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2)
          ],
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 8, top: 12, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.local_airport,
                        color: Colors.cyanAccent, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text("$city, $country",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(icao,
                          style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white54, size: 20),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                  ],
                ),
              ),
              const TabBar(
                indicatorColor: Colors.cyanAccent,
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.white54,
                labelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "INFO"),
                  Tab(text: "RUNWAYS"),
                  Tab(text: "WEATHER"),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.cyanAccent))
                    : TabBarView(children: [
                        _buildInfoTab(iata),
                        _buildRunwaysTab(),
                        _buildWeatherTab()
                      ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab(String iataCode) {
    String elevStr = "-";
    if (fpdbData?['elevation'] != null) {
      double? el = double.tryParse(fpdbData!['elevation'].toString());
      if (el != null) elevStr = "${el.round()} ft";
    }

    String varStr = "-";
    if (fpdbData?['magneticVariation'] != null) {
      double? v = double.tryParse(fpdbData!['magneticVariation'].toString());
      if (v != null) varStr = v.toStringAsFixed(1);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            border: TableBorder.all(color: Colors.white10),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.8)
            },
            children: [
              _infoRow("ICAO", fpdbData?['icao'] ?? widget.ap['icao'] ?? "-"),
              _infoRow(
                  "IATA", fpdbData?['IATA'] ?? fpdbData?['iata'] ?? iataCode),
              _infoRow("COUNTRY",
                  fpdbData?['country'] ?? widget.ap['country'] ?? "-"),
              _infoRow("ELEVATION", elevStr),
              _infoRow("LATITUDE",
                  _str(fpdbData?['lat'], widget.ap['lat']?.toString() ?? "-")),
              _infoRow("LONGITUDE",
                  _str(fpdbData?['lon'], widget.ap['lon']?.toString() ?? "-")),
              _infoRow("VARIATION", varStr),
              _infoRow("TIMEZONE", _str(fpdbData?['timezone'])),
              _infoRow("SUNRISE", _str(fpdbData?['times']?['sunrise'])),
              _infoRow("SUNSET", _str(fpdbData?['times']?['sunset'])),
            ],
          ),
          const SizedBox(height: 16),
          if (fpdbData?['frequencies'] != null &&
                  (fpdbData!['frequencies'] as List).isNotEmpty ||
              vatsimControllers.isNotEmpty) ...[
            const Text("REAL WORLD FREQUENCIES",
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.white10),
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: Colors.cyan.withOpacity(0.1)),
                  children: [
                    _cell("TYPE", isHeader: true),
                    _cell("FREQ", isHeader: true),
                    _cell("NAME", isHeader: true)
                  ],
                ),
                ...vatsimControllers.map<TableRow>((c) => TableRow(children: [
                      _cell(c['callsign']?.toString().split('_').last ?? "ATC"),
                      _cell(_formatFreq(c['frequency'])),
                      _cell(c['name'] ?? "-")
                    ])),
                if (fpdbData?['frequencies'] != null)
                  ...(fpdbData!['frequencies'] as List)
                      .map<TableRow>((f) => TableRow(children: [
                            _cell(_str(f['type']).toUpperCase()),
                            _cell(_formatFreq(f['frequency'])),
                            _cell(_str(f['name']))
                          ]))
                      .toList()
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRunwaysTab() {
    if (fpdbData == null ||
        fpdbData!['runways'] == null ||
        (fpdbData!['runways'] as List).isEmpty) {
      return const Center(
          child: Text("No Runways Data Available",
              style: TextStyle(color: Colors.white54)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.white10),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1)),
              children: [
                _cell("R/W", isHeader: true),
                _cell("LENGTH", isHeader: true),
                _cell("WIDTH", isHeader: true),
                _cell("SURFACE", isHeader: true),
                _cell("BEARING", isHeader: true),
                _cell("LIGHTING", isHeader: true)
              ],
            ),
            ...(fpdbData!['runways'] as List).map<TableRow>((r) {
              String lenStr = "-";
              if (r['length'] != null) {
                double? lVal = double.tryParse(r['length'].toString());
                lenStr =
                    lVal != null ? "${lVal.round()} ft" : "${r['length']} ft";
              }
              String widStr = "-";
              if (r['width'] != null) {
                double? wVal = double.tryParse(r['width'].toString());
                widStr =
                    wVal != null ? "${wVal.round()} ft" : "${r['width']} ft";
              }

              String bearingStr = "-";
              dynamic bVal = r['bearing'] ?? r['heading'];
              if (bVal != null) {
                double? bDouble = double.tryParse(bVal.toString());
                if (bDouble != null) {
                  bearingStr = "${bDouble.round().toString().padLeft(3, '0')}°";
                } else {
                  String bString = bVal.toString().trim();
                  if (bString.isNotEmpty && bString != "null") {
                    bearingStr = "$bString°";
                  }
                }
              }

              return TableRow(children: [
                _cell(_str(r['ident'])),
                _cell(lenStr),
                _cell(widStr),
                _cell(_str(r['surface']).toUpperCase()),
                _cell(bearingStr),
                _cell(_parseLighting(r['lighting']))
              ]);
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("METAR",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            child: Text(
              vatsimMetar.isNotEmpty ? vatsimMetar : "No METAR available.",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text("VATSIM ATIS",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vatsimAtis.isNotEmpty
                      ? vatsimAtis
                      : "No ATIS available on VATSIM.",
                  style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4),
                ),
                if (vatsimAtis.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text("LISTEN TO ATIS"),
                      onPressed: () {
                        professionalAtis(vatsimAtis);
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _infoRow(String k, String v) => TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(k,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(v,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)))
      ]);
  Widget _cell(String txt, {bool isHeader = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(txt,
          style: TextStyle(
              color: isHeader ? Colors.cyanAccent : Colors.white,
              fontSize: 11,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)));
}

// ============================================================================
// 👇👇 كود الـ Custom Action المطلوب (professionalAtis) 👇👇
// ============================================================================

Future professionalAtis(String rawMetar) async {
  FlutterTts flutterTts = FlutterTts();

  if (rawMetar == null || rawMetar.isEmpty) return;

  String cleanText = rawMetar.replaceAll(RegExp(r'\(.*?\)'), '');
  cleanText = cleanText.replaceAll('[', ' ').replaceAll(']', ' ');

  cleanText = cleanText.toUpperCase();
  cleanText = cleanText.replaceAll(RegExp(r'[,;:\.]'), ' ');

  String speakDigit(String numStr) {
    Map<String, String> numbers = {
      '0': 'Zero',
      '1': 'One',
      '2': 'Two',
      '3': 'Three',
      '4': 'Four',
      '5': 'Five',
      '6': 'Six',
      '7': 'Seven',
      '8': 'Eight',
      '9': 'Niner'
    };
    return numStr.split('').map((char) => numbers[char] ?? char).join(' ');
  }

  Map<String, String> phonetics = {
    'A': 'Alpha',
    'B': 'Bravo',
    'C': 'Charlie',
    'D': 'Delta',
    'E': 'Echo',
    'F': 'Foxtrot',
    'G': 'Golf',
    'H': 'Hotel',
    'I': 'India',
    'J': 'Juliet',
    'K': 'Kilo',
    'L': 'Lima',
    'M': 'Mike',
    'N': 'November',
    'O': 'Oscar',
    'P': 'Papa',
    'Q': 'Quebec',
    'R': 'Romeo',
    'S': 'Sierra',
    'T': 'Tango',
    'U': 'Uniform',
    'V': 'Victor',
    'W': 'Whiskey',
    'X': 'X-ray',
    'Y': 'Yankee',
    'Z': 'Zulu'
  };

  cleanText = cleanText.replaceAll(RegExp(r'\bWIND\b'), ' wind ');
  cleanText = cleanText.replaceAll(RegExp(r'\bATIS\b'), ' atis ');
  cleanText = cleanText.replaceAll(RegExp(r'\bBOTH\b'), ' both ');
  cleanText = cleanText.replaceAll(RegExp(r'\bHAVE\b'), ' have ');
  cleanText = cleanText.replaceAll(RegExp(r'\bNEED\b'), ' need ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTO\b'), ' to ');
  cleanText = cleanText.replaceAll(RegExp(r'\bFROM\b'), ' from ');
  cleanText = cleanText.replaceAll(RegExp(r'\bHOLD\b'), ' hold ');
  cleanText = cleanText.replaceAll(RegExp(r'\bMODE\b'), ' mode ');
  cleanText = cleanText.replaceAll(RegExp(r'\bALL\b'), ' all ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d{3})V(\d{3})'), (match) {
    return " variable between ${speakDigit(match.group(1)!)} and ${speakDigit(match.group(2)!)} ";
  });

  cleanText = cleanText.replaceAll(RegExp(r'\+SHRA\b'), ' heavy shower rain ');
  cleanText = cleanText.replaceAll(RegExp(r'\-SHRA\b'), ' light shower rain ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTDZ\b'), ' touch down zone ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLRC\b'), ' clearance ');
  cleanText = cleanText.replaceAll(RegExp(r'\bREQ\b'), ' request ');
  cleanText =
      cleanText.replaceAll(RegExp(r'\bTOBT\b'), ' target off block time ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRNAV\b'), ' r nav ');
  cleanText = cleanText.replaceAll(RegExp(r'\bACK\b'), ' acknowledge ');
  cleanText = cleanText.replaceAll(RegExp(r'\bSQK\b'), ' squawk ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCTC\b'), ' contact ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLD\b'), ' cloud ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTEMP\b'), ' temperature ');

  cleanText = cleanText.replaceAll(RegExp(r'\bAPP\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPR\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPCH\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPCHS\b'), ' approaches ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPRS\b'), ' approaches ');

  cleanText =
      cleanText.replaceAll(RegExp(r'\b9999\b'), ' ten kilometers or more ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVRB\b'), ' variable ');
  cleanText = cleanText.replaceAll(RegExp(r'\bBTN\b'), ' between ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVIS\b'), ' visibility ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCMB\b'), ' climb ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEG\b'), ' degrees ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTCU\b'), ' towering cumulus ');

  cleanText = cleanText.replaceAll(RegExp(r'\bILS\b'), ' i l s ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVHF\b'), ' v h f ');
  cleanText = cleanText.replaceAll(RegExp(r'\bATC\b'), ' a t c ');
  cleanText = cleanText.replaceAll(RegExp(r'\bGLS\b'), ' glide slope ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTRL\b'), ' transition level ');
  cleanText =
      cleanText.replaceAll(RegExp(r'\bNOSIG\b'), ' no significant change ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARRS\b'), ' arrivals ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARR\b'), ' arrival ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARPT\b'), ' airport ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEP\b'), ' departure ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAVBL\b'), ' available ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDRCTN\b'), ' direction ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLSD\b'), ' closed ');
  cleanText = cleanText.replaceAll(RegExp(r'\bEXP\b'), ' expect ');
  cleanText = cleanText.replaceAll(RegExp(r'\bEQPT\b'), ' equipment ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCAUT\b'), ' caution ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEPG\b'), ' departure ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEPS\b'), ' departures ');
  cleanText = cleanText.replaceAll(RegExp(r'\bLDG\b'), ' landing ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)KT\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num knots ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)KM\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num kilometers ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)HPA\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num hectopascals ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d+)FT\b'), (match) {
    return "${match.group(1)} feet ";
  });
  cleanText = cleanText.replaceAll(RegExp(r'\bFT\b'), ' feet ');
  cleanText = cleanText.replaceAll(RegExp(r'\bKT\b'), ' knots ');
  cleanText = cleanText.replaceAll(RegExp(r'\bKM\b'), ' kilometers ');

  cleanText = cleanText.replaceAll('FEW', ' few ');
  cleanText = cleanText.replaceAll('BKN', ' broken ');
  cleanText = cleanText.replaceAll('SCT', ' scattered ');
  cleanText = cleanText.replaceAll('OVC', ' overcast ');
  cleanText = cleanText.replaceAll('CLR', ' clear ');
  cleanText = cleanText.replaceAll('SKC', ' sky clear ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRWY\b'), ' runway ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRWYS\b'), ' runways ');
  cleanText = cleanText.replaceAll(RegExp(r'\bINFO\b'), ' information ');
  cleanText = cleanText.replaceAll(RegExp(r'\bSIMUL\b'), ' simultaneous ');
  cleanText = cleanText.replaceAll(RegExp(r'\bADVS\b'), ' advice ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'\bT(\d{2})\b'), (match) {
    return " temperature ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\bDP(\d{2})\b'), (match) {
    return " dew point ${speakDigit(match.group(1)!)} ";
  });

  cleanText = cleanText.replaceAllMapped(
      RegExp(r'INFORMATION\s+([A-Z])\b', caseSensitive: false), (match) {
    String letter = match.group(1)!.toUpperCase();
    return " information ${phonetics[letter] ?? letter} ";
  });

  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\bQNH[:\s]*(\d{4})\b'), (match) {
    return " q n h ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\bA(\d{4})\b'), (match) {
    return " altimeter ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(
      RegExp(r'\b(\d{3}|VARIABLE)(\d{2,3})(G(\d{2,3}))?KNOTS\b'), (match) {
    String dir =
        match.group(1) == 'VARIABLE' ? 'Variable' : speakDigit(match.group(1)!);
    String speed = speakDigit(match.group(2)!);
    String gusts =
        match.group(4) != null ? " gusts ${speakDigit(match.group(4)!)}" : "";
    return " wind $dir at $speed $gusts knots ";
  });
  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\b(\d{2})\/(\d{2})\b'), (match) {
    return " temperature ${speakDigit(match.group(1)!)} dewpoint ${speakDigit(match.group(2)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\b(\d+)SM\b'), (match) {
    return " visibility ${speakDigit(match.group(1)!)} statute miles ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'([0-9])(L|R|C)\b'), (match) {
    String side = match.group(2) == 'L'
        ? 'left'
        : (match.group(2) == 'R' ? 'right' : 'center');
    return " ${match.group(1)} $side ";
  });

  cleanText =
      cleanText.replaceAll(RegExp(r'\bCAVOK\b'), ' ceiling and visibility ok ');
  cleanText = cleanText.replaceAll('/', ' ');

  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\b(TIME\s+)?(\d{4})Z\b'), (match) {
    return " time ${speakDigit(match.group(2)!)} zulu ";
  });

  List<String> words = cleanText.split(RegExp(r'\s+'));
  List<String> finalWords = [];
  bool foundIcaoCode = false;

  for (String word in words) {
    if (word.isEmpty) continue;

    if (!foundIcaoCode &&
        word.length == 4 &&
        RegExp(r'^[A-Z]{4}$').hasMatch(word)) {
      String phoneticIcao = "";
      for (int i = 0; i < word.length; i++) {
        phoneticIcao += (phonetics[word[i]] ?? word[i]) + " ";
      }
      finalWords.add(phoneticIcao.trim());
      foundIcaoCode = true;
      continue;
    }

    if (word.length == 1) {
      if (RegExp(r'^[A-Z]$').hasMatch(word) && phonetics.containsKey(word)) {
        finalWords.add(phonetics[word]!);
      } else {
        finalWords.add(word);
      }
    } else if (word.contains(RegExp(r'[0-9]'))) {
      String processedWord = "";
      for (int i = 0; i < word.length; i++) {
        String char = word[i];
        if (RegExp(r'[0-9]').hasMatch(char)) {
          processedWord += speakDigit(char) + " ";
        } else if (RegExp(r'^[A-Z]$').hasMatch(char) &&
            phonetics.containsKey(char)) {
          processedWord += phonetics[char]! + " ";
        } else {
          processedWord += char;
        }
      }
      finalWords.add(processedWord.trim());
    } else {
      finalWords.add(word);
    }
  }

  String finalSpeech = finalWords.join(' ').toLowerCase();

  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(0.85);
  await flutterTts.setSpeechRate(0.42);
  await flutterTts.setVolume(1.0);
  await flutterTts.speak(finalSpeech);
}
