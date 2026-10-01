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

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ألوان EFB الاحترافية الموحدة ---
const Color efbBg = Color(0xFF030508); // Darkest background
const Color efbCard = Color(0xFF0C1421); // Card background
const Color efbBorder = Color(0xFF1E324A); // Standard border
const Color efbTextMuted = Color(0xFF6B87A8); // Muted bluish text
const Color efbAccent = Color(0xFF4A90E2); // Main highlight blue
const Color efbButtonDark = Color(0xFF16263B); // Dark button fill
const Color efbWhite = Colors.white;

// --- ألوان الحالات (Status Colors) ---
const Color cDanger = Color(0xFFFF453A); // Red (Unable/Error)
const Color cWarn = Color(0xFFFFD60A); // Yellow (Standby)
const Color cGood = Color(0xFF32D74B); // Green (Wilco/Online)
const Color cWeather = Color(0xFF7AA5D2); // Weather/Info Blue
const Color cRoger = Color(0xFF8B9FB6); // Roger (Greyish Blue)

class AcarsEfbWidget extends StatefulWidget {
  const AcarsEfbWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _AcarsEfbWidgetState createState() => _AcarsEfbWidgetState();
}

class _AcarsEfbWidgetState extends State<AcarsEfbWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // --- Controllers & State ---
  final TextEditingController _logonCodeCtrl = TextEditingController();
  final TextEditingController _callsignCtrl = TextEditingController();

  // Validation States
  bool _logonError = false;
  bool _callsignError = false;

  // Telex Controllers
  final TextEditingController _telexToCtrl = TextEditingController();
  final TextEditingController _telexMsgCtrl = TextEditingController();
  bool _telexIsAtc = false;

  final TextEditingController _cpdlcStationCtrl = TextEditingController();
  final TextEditingController _icaoCtrl = TextEditingController();

  // Oceanic Controllers
  final TextEditingController _ocWpt = TextEditingController();
  final TextEditingController _ocTime = TextEditingController();
  final TextEditingController _ocFl = TextEditingController();
  final TextEditingController _ocSpd = TextEditingController();
  final TextEditingController _ocNext = TextEditingController();
  final TextEditingController _ocEto = TextEditingController();
  final TextEditingController _ocFuel = TextEditingController();
  final TextEditingController _ocTemp = TextEditingController();

  bool _posRepAttempted = false;

  // Quick ATC State
  String? _activeQuickReq;
  final TextEditingController _quickReqInputCtrl = TextEditingController();

  bool _isVatsim = true;
  bool _isOnline = false;
  Timer? _pollingTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, String>> _mailbox = [];
  final String _hoppieUrl = 'http://www.hoppie.nl/acars/system/connect.html';

  // 🔥 متغير جديد للموبايل للتحكم في الشاشات (Tabs)
  int _mobileTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLogonCode();

    _logonCodeCtrl.addListener(() {
      _saveLogonCode(_logonCodeCtrl.text);
      if (_logonCodeCtrl.text.isNotEmpty && _logonError) {
        setState(() => _logonError = false);
      }
    });

    _callsignCtrl.addListener(() {
      if (_callsignCtrl.text.isNotEmpty && _callsignError) {
        setState(() => _callsignError = false);
      }
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isOnline) _checkInbox('poll');
    });
  }

  Future<void> _saveLogonCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_logon_code', code);
  }

  Future<void> _loadLogonCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('saved_logon_code');
    if (savedCode != null && savedCode.isNotEmpty) {
      setState(() {
        _logonCodeCtrl.text = savedCode;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _audioPlayer.dispose();
    _quickReqInputCtrl.dispose();
    super.dispose();
  }

  bool _validateLogon() {
    bool hasError = false;
    if (_logonCodeCtrl.text.trim().isEmpty) {
      _logonError = true;
      hasError = true;
    }
    if (_callsignCtrl.text.trim().isEmpty) {
      _callsignError = true;
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      _showError("CALLSIGN AND LOGON CODE ARE REQUIRED!");
      return false;
    }
    return true;
  }

  Future<void> _sendMessage(String to, String type, String packet,
      {bool showInMailbox = true}) async {
    if (!_validateLogon()) return;

    String target = to.trim().toUpperCase();
    if (!_isVatsim &&
        !target.startsWith('IVAO-') &&
        target != 'SERVER' &&
        target != 'METAR' &&
        target != 'TAF') {
      target = 'IVAO-$target';
    }

    try {
      final response = await http.post(
        Uri.parse(_hoppieUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'logon': _logonCodeCtrl.text.trim(),
          'from': _callsignCtrl.text.trim().toUpperCase(),
          'to': target,
          'type': type,
          'packet': packet,
        },
      );

      String body = response.body.trim();
      if (response.statusCode == 200 && body.startsWith('ok')) {
        setState(() => _isOnline = true);

        if (showInMailbox && type != 'ping') {
          _addToMailbox("OUT", "To $target: $packet");
        }

        if (body.length > 3 && body.contains('{') && body.contains('}')) {
          String content =
              body.substring(body.indexOf('{') + 1, body.lastIndexOf('}'));
          _addToMailbox("IN", content);
        }
      } else {
        _showError("Failed to send message. Server rejected.");
      }
    } catch (e) {
      setState(() => _isOnline = false);
      _showError("Connection Error. Check your internet.");
    }
  }

  Future<void> _checkInbox(String pollType) async {
    if (_logonCodeCtrl.text.trim().isEmpty || _callsignCtrl.text.trim().isEmpty)
      return;

    try {
      final response = await http.post(
        Uri.parse(_hoppieUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'logon': _logonCodeCtrl.text.trim(),
          'from': _callsignCtrl.text.trim().toUpperCase(),
          'to': 'SERVER',
          'type': pollType,
          'packet': '',
        },
      );

      String body = response.body.trim();
      if (response.statusCode == 200 && body.startsWith('ok')) {
        setState(() => _isOnline = true);

        if (body.length > 3 && body.contains('{')) {
          String content =
              body.substring(body.indexOf('{') + 1, body.lastIndexOf('}'));
          _addToMailbox("IN", content);

          if (pollType == 'poll') {
            _playChime();
            _showFloatingNotification();
          }
        }
      }
    } catch (e) {}
  }

  void _addToMailbox(String direction, String message) {
    String time =
        "${DateTime.now().toUtc().hour.toString().padLeft(2, '0')}${DateTime.now().toUtc().minute.toString().padLeft(2, '0')}Z";
    setState(() {
      _mailbox.insert(0, {"time": time, "dir": direction, "msg": message});
    });
  }

  void _playChime() async {
    try {
      await _audioPlayer.play(AssetSource('audio/atc_msg.mp3'));
    } catch (e) {}
  }

  void _showFloatingNotification() {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8, // Responsive width
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
                color: efbCard.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cWeather, width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2)
                ]),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_unread, color: cWeather, size: 24),
                SizedBox(width: 10),
                Text("NEW ATC MESSAGE",
                    style: TextStyle(
                        color: cWeather,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
        ],
      ),
      backgroundColor: cDanger,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ==========================================
  // MAIN BUILDER (LayoutBuilder for Responsiveness)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: widget.width,
      height: widget.height,
      color: efbBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // إذا كان العرض أقل من 800 نعرض الموبايل، غير كده نعرض الآيباد
              if (constraints.maxWidth < 800) {
                return _buildMobileLayout();
              } else {
                return _buildTabletLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TABLET / IPAD LAYOUT (Untouched)
  // ==========================================
  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMailboxAndTelex()),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: _buildQuickRequestsAndWeather()),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: _buildCpdlcAndOceanic()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MOBILE SMART LAYOUT (New & Highly Professional)
  // ==========================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        _buildMobileTabBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: _getMobileTabContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: efbCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: efbBorder)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle,
                      color: _isOnline ? cGood : cDanger, size: 10),
                  const SizedBox(width: 6),
                  Text(_isOnline ? "ONLINE" : "OFFLINE",
                      style: TextStyle(
                          color: _isOnline ? cGood : cDanger,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 10)),
                ],
              ),
              const Row(children: [
                Icon(Icons.flight, color: efbAccent, size: 14),
                SizedBox(width: 6),
                Text("DATALINK",
                    style: TextStyle(
                        color: efbWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildModernInput(_callsignCtrl, "Callsign",
                    isError: _callsignError),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildModernInput(_logonCodeCtrl, "Logon Code",
                    obscure: true, isError: _logonError),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                decoration: BoxDecoration(
                    color: efbBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: efbBorder)),
                child: ToggleButtons(
                  isSelected: [_isVatsim, !_isVatsim],
                  onPressed: (index) => setState(() => _isVatsim = index == 0),
                  color: efbTextMuted,
                  selectedColor: efbWhite,
                  fillColor: efbAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                  constraints:
                      const BoxConstraints(minHeight: 38, minWidth: 45),
                  children: const [
                    Text("VAT",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10)),
                    Text("IVA",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10))
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMobileTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 40,
      decoration: BoxDecoration(
        color: efbCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: efbBorder),
      ),
      child: Row(
        children: [
          _buildMobileTabBtn(0, "📡 COMM"),
          Container(width: 1, color: efbBorder),
          _buildMobileTabBtn(1, "✈️ ATC/WX"),
          Container(width: 1, color: efbBorder),
          _buildMobileTabBtn(2, "🌍 OCEANIC"),
        ],
      ),
    );
  }

  Widget _buildMobileTabBtn(int index, String title) {
    bool isActive = _mobileTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mobileTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? efbAccent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? efbWhite : efbTextMuted,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getMobileTabContent() {
    switch (_mobileTabIndex) {
      case 0:
        return _buildMobileMailboxTab();
      case 1:
        return _buildMobileQuickAtcTab();
      case 2:
        return _buildMobileCpdlcTab();
      default:
        return Container();
    }
  }

  // Mobile Views (Safe Fixed Heights to prevent overflow)
  Widget _buildMobileMailboxTab() {
    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for scrolling safely
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: efbCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: efbBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.mail_outline, color: efbTextMuted, size: 16),
                    SizedBox(width: 8),
                    Text("MAILBOX",
                        style: TextStyle(
                            color: efbTextMuted,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: efbBorder, thickness: 1.0),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mailbox.length,
                    itemBuilder: (context, index) {
                      final msg = _mailbox[index];
                      bool isIn = msg['dir'] == "IN";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: efbBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: efbBorder)),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Courier', fontSize: 12),
                            children: [
                              TextSpan(
                                  text: "${msg['time']}   ",
                                  style: const TextStyle(color: efbTextMuted)),
                              TextSpan(
                                  text: isIn ? "ATC   " : "OUT   ",
                                  style: TextStyle(
                                      color: isIn ? cWeather : efbAccent,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: msg['msg'],
                                  style: const TextStyle(color: efbWhite)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildActionBtn(
                            "PEEK", () => _checkInbox('peek'), efbButtonDark,
                            icon: Icons.visibility_outlined,
                            textColor: efbWhite)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn(
                            "POLL", () => _checkInbox('poll'), efbButtonDark,
                            icon: Icons.refresh, textColor: efbWhite)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn(
                            "CLEAR",
                            () => setState(() => _mailbox.clear()),
                            efbButtonDark,
                            icon: Icons.delete_outline,
                            textColor: efbTextMuted)),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.chat_outlined, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("TELEX (FREE TEXT)",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                        color: efbBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: efbBorder)),
                    child: ToggleButtons(
                      isSelected: [_telexIsAtc, !_telexIsAtc],
                      onPressed: (index) =>
                          setState(() => _telexIsAtc = index == 0),
                      color: efbTextMuted,
                      selectedColor: efbWhite,
                      fillColor: efbAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                      constraints:
                          const BoxConstraints(minHeight: 36, minWidth: 50),
                      children: const [
                        Text("ATC",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        Text("AIRLINE",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildModernInput(_telexToCtrl,
                          _telexIsAtc ? "ATC Station" : "Callsign")),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telexMsgCtrl,
                style: const TextStyle(color: efbWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Enter free text message...",
                  hintStyle: const TextStyle(color: efbTextMuted, fontSize: 12),
                  filled: true,
                  fillColor: efbBg,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: efbBorder),
                      borderRadius: BorderRadius.circular(6)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: efbAccent),
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              _buildActionBtn("SEND", () {
                _sendMessage(
                    _telexIsAtc ? _cpdlcStationCtrl.text : _telexToCtrl.text,
                    'telex',
                    _telexMsgCtrl.text);
                _telexMsgCtrl.clear();
              }, efbAccent, icon: Icons.send, textColor: efbWhite),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileQuickAtcTab() {
    return _buildQuickRequestsAndWeather(); // Safe to reuse because it expands naturally without Expanded wrapper errors
  }

  Widget _buildMobileCpdlcTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.radar_outlined, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("CPDLC STATION",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildModernInput(
                          _cpdlcStationCtrl, "Logon Station")),
                  const SizedBox(width: 10),
                  _buildActionBtn(
                      "LOGON",
                      () => _sendMessage(_cpdlcStationCtrl.text, 'ping', ''),
                      efbAccent,
                      textColor: efbWhite)
                ],
              ),
              const SizedBox(height: 16),
              const Text("URGENT CPDLC RESPONSE",
                  style: TextStyle(
                      color: efbTextMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCpdlcBtn(
                      "WILCO",
                      Icons.check_circle_outline,
                      cGood,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'WILCO')),
                  const SizedBox(width: 10),
                  _buildCpdlcBtn(
                      "STANDBY",
                      Icons.access_time,
                      cWarn,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'STANDBY')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCpdlcBtn(
                      "UNABLE",
                      Icons.cancel_outlined,
                      cDanger,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'UNABLE')),
                  const SizedBox(width: 10),
                  _buildCpdlcBtn(
                      "ROGER",
                      Icons.chat_bubble_outline,
                      cRoger,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'ROGER')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.language, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("OCEANIC POS REP",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              // 🔥 Mobile specific grid ratio to prevent text cutoffs
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildLabeledInput("WPT", _ocWpt, "e.g. NAT A",
                      isError: _posRepAttempted && _ocWpt.text.isEmpty),
                  _buildLabeledInput("TIME", _ocTime, "HHMMZ",
                      isError: _posRepAttempted && _ocTime.text.isEmpty),
                  _buildLabeledInput("FL", _ocFl, "e.g. 350",
                      isError: _posRepAttempted && _ocFl.text.isEmpty),
                  _buildLabeledInput("SPD", _ocSpd, "e.g. 480",
                      isError: _posRepAttempted && _ocSpd.text.isEmpty),
                  _buildLabeledInput("NEXT", _ocNext, "e.g. RNP",
                      isError: _posRepAttempted && _ocNext.text.isEmpty),
                  _buildLabeledInput("ETO", _ocEto, "HHMMZ",
                      isError: _posRepAttempted && _ocEto.text.isEmpty),
                  _buildLabeledInput("FUEL", _ocFuel, "e.g. 12.5",
                      isError: _posRepAttempted && _ocFuel.text.isEmpty),
                  _buildLabeledInput("TEMP", _ocTemp, "e.g. -50",
                      isError: _posRepAttempted && _ocTemp.text.isEmpty),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionBtn("SEND POS REP", () {
                setState(() {
                  _posRepAttempted = true;
                });
                if (!_validateLogon()) return;

                if (_ocWpt.text.isEmpty ||
                    _ocTime.text.isEmpty ||
                    _ocFl.text.isEmpty ||
                    _ocSpd.text.isEmpty ||
                    _ocNext.text.isEmpty ||
                    _ocEto.text.isEmpty ||
                    _ocFuel.text.isEmpty ||
                    _ocTemp.text.isEmpty) {
                  _showError("⚠️ All fields are required for Position Report.");
                  return;
                }

                String report =
                    "POS REP: ${_ocWpt.text} AT ${_ocTime.text}, FL${_ocFl.text}, M${_ocSpd.text}. EST ${_ocNext.text} AT ${_ocEto.text}. FUEL ${_ocFuel.text}, TEMP ${_ocTemp.text}";
                _sendMessage(_cpdlcStationCtrl.text, 'telex', report);

                setState(() {
                  _posRepAttempted = false;
                });
              }, efbAccent, icon: Icons.send, textColor: efbWhite),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED WIDGETS (Used by both Tablet and Mobile)
  // ==========================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: efbCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: efbBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: _isOnline ? cGood : cDanger, size: 12),
              const SizedBox(width: 8),
              Text(_isOnline ? "ONLINE" : "OFFLINE",
                  style: TextStyle(
                      color: _isOnline ? cGood : cDanger,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 12)),
            ],
          ),
          Row(children: const [
            Icon(Icons.flight, color: efbAccent, size: 18),
            SizedBox(width: 8),
            Text("ACARS / CPDLC DATALINK",
                style: TextStyle(
                    color: efbWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ]),
          Row(
            children: [
              _buildModernInput(_callsignCtrl, "Callsign (e.g. MSR123)",
                  width: 140, isError: _callsignError),
              const SizedBox(width: 10),
              _buildModernInput(_logonCodeCtrl, "Logon Code",
                  obscure: true, width: 110, isError: _logonError),
              const SizedBox(width: 10),
              Container(
                height: 38,
                decoration: BoxDecoration(
                    color: efbBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: efbBorder)),
                child: ToggleButtons(
                  isSelected: [_isVatsim, !_isVatsim],
                  onPressed: (index) => setState(() => _isVatsim = index == 0),
                  color: efbTextMuted,
                  selectedColor: efbWhite,
                  fillColor: efbAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                  constraints:
                      const BoxConstraints(minHeight: 38, minWidth: 60),
                  children: const [
                    Text("VATSIM",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                    Text("IVAO",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMailboxAndTelex() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: efbCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: efbBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.mail_outline, color: efbTextMuted, size: 16),
                    SizedBox(width: 8),
                    Text("MAILBOX",
                        style: TextStyle(
                            color: efbTextMuted,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: efbBorder, thickness: 1.0),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mailbox.length,
                    itemBuilder: (context, index) {
                      final msg = _mailbox[index];
                      bool isIn = msg['dir'] == "IN";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            color: efbBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: efbBorder)),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Courier', fontSize: 12),
                            children: [
                              TextSpan(
                                  text: "${msg['time']}   ",
                                  style: const TextStyle(color: efbTextMuted)),
                              TextSpan(
                                  text: isIn ? "ATC   " : "OUT   ",
                                  style: TextStyle(
                                      color: isIn ? cWeather : efbAccent,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: msg['msg'],
                                  style: const TextStyle(color: efbWhite)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: _buildActionBtn(
                            "PEEK", () => _checkInbox('peek'), efbButtonDark,
                            icon: Icons.visibility_outlined,
                            textColor: efbWhite)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn(
                            "POLL", () => _checkInbox('poll'), efbButtonDark,
                            icon: Icons.refresh, textColor: efbWhite)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn(
                            "CLEAR",
                            () => setState(() => _mailbox.clear()),
                            efbButtonDark,
                            icon: Icons.delete_outline,
                            textColor: efbTextMuted)),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.chat_outlined, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("TELEX (FREE TEXT)",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("TO:  ",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                        color: efbBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: efbBorder)),
                    child: ToggleButtons(
                      isSelected: [_telexIsAtc, !_telexIsAtc],
                      onPressed: (index) =>
                          setState(() => _telexIsAtc = index == 0),
                      color: efbTextMuted,
                      selectedColor: efbWhite,
                      fillColor: efbAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                      constraints:
                          const BoxConstraints(minHeight: 36, minWidth: 60),
                      children: const [
                        Text("ATC",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        Text("AIRLINE",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telexMsgCtrl,
                style: const TextStyle(color: efbWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Enter free text message...",
                  hintStyle: const TextStyle(color: efbTextMuted, fontSize: 12),
                  filled: true,
                  fillColor: efbBg,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: efbBorder),
                      borderRadius: BorderRadius.circular(6)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: efbAccent),
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              _buildActionBtn("SEND", () {
                _sendMessage(
                    _telexIsAtc ? _cpdlcStationCtrl.text : _telexToCtrl.text,
                    'telex',
                    _telexMsgCtrl.text);
                _telexMsgCtrl.clear();
              }, efbAccent, icon: Icons.send, textColor: efbWhite),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAtcPadBtn(String id, String label, IconData icon) {
    bool isActive = _activeQuickReq == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (isActive) {
              _activeQuickReq = null;
            } else {
              _activeQuickReq = id;
              _quickReqInputCtrl.clear();
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 85,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? efbAccent.withOpacity(0.15) : efbBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isActive ? efbAccent : efbBorder,
                width: isActive ? 1.5 : 1.0),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        color: isActive ? efbWhite : efbTextMuted, size: 28),
                    const SizedBox(height: 8),
                    Text(label,
                        style: TextStyle(
                            color: isActive ? efbWhite : efbTextMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: efbBorder, size: 18),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendQuickReq() {
    if (!_validateLogon()) return;
    if (_quickReqInputCtrl.text.isEmpty) {
      _showError("⚠️ Please enter required data in the field.");
      return;
    }
    String msg = "";
    String val = _quickReqInputCtrl.text.toUpperCase();
    switch (_activeQuickReq) {
      case 'PDC':
        msg = 'REQUEST PDC AT $val';
        break;
      case 'PUSH':
        msg = 'REQUEST PUSHBACK AND STARTUP FROM $val';
        break;
      case 'TAXI':
        msg = 'READY FOR TAXI FROM $val';
        break;
      case 'LVL':
        msg = 'REQUEST CLIMB/DESCENT TO $val';
        break;
      case 'DIR':
        msg = 'REQUEST DIRECT TO $val';
        break;
    }
    _sendMessage(_cpdlcStationCtrl.text, 'telex', msg);
    setState(() {
      _activeQuickReq = null;
      _quickReqInputCtrl.clear();
    });
  }

  String _getQuickReqHint() {
    switch (_activeQuickReq) {
      case 'PDC':
        return "ENTER STAND & ATIS (e.g. STAND 12, INFO C)";
      case 'PUSH':
        return "ENTER STAND / GATE (e.g. STAND 12)";
      case 'TAXI':
        return "ENTER CURRENT POSITION (e.g. STAND 12)";
      case 'LVL':
        return "ENTER REQUESTED FLIGHT LEVEL (e.g. FL350)";
      case 'DIR':
        return "ENTER TARGET WAYPOINT (e.g. PASOV)";
      default:
        return "";
    }
  }

  String _getQuickReqPlaceholder() {
    switch (_activeQuickReq) {
      case 'PDC':
        return "Stand & ATIS...";
      case 'PUSH':
        return "Gate / Stand...";
      case 'TAXI':
        return "Current Position...";
      case 'LVL':
        return "Flight Level...";
      case 'DIR':
        return "Waypoint...";
      default:
        return "";
    }
  }

  Widget _buildQuickRequestsAndWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick ATC
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.headset_mic_outlined,
                      color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("QUICK ATC REQUESTS",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAtcPadBtn('PDC', 'PDC REQ', Icons.description_outlined),
                  const SizedBox(width: 10),
                  _buildAtcPadBtn('PUSH', 'REQ PUSH / START', Icons.flight),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildAtcPadBtn('TAXI', 'REQ TAXI', Icons.flight_takeoff),
                  const SizedBox(width: 10),
                  _buildAtcPadBtn('LVL', 'REQ LEVEL', Icons.swap_vert),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildAtcPadBtn('DIR', 'REQ DIRECT', Icons.route_outlined),
                ],
              ),
              if (_activeQuickReq != null) ...[
                const SizedBox(height: 16),
                const Divider(color: efbBorder, thickness: 1),
                const SizedBox(height: 8),
                Text(_getQuickReqHint(),
                    style: const TextStyle(
                        color: efbAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildModernInput(
                            _quickReqInputCtrl, _getQuickReqPlaceholder())),
                    const SizedBox(width: 8),
                    _buildActionBtn("SEND", _sendQuickReq, efbAccent,
                        textColor: efbWhite),
                  ],
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Weather & ATIS
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.wb_cloudy_outlined, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("WEATHER & ATIS",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              _buildModernInput(_icaoCtrl, "ICAO (e.g. HECA)",
                  icon: Icons.search),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherBtn("METAR", Icons.cloud_outlined, () {
                    if (_icaoCtrl.text.isEmpty) {
                      _showError("⚠️ Enter ICAO code first.");
                      return;
                    }
                    _sendMessage(
                        'SERVER', 'inforeq', 'METAR ${_icaoCtrl.text}');
                  }),
                  const SizedBox(width: 8),
                  _buildWeatherBtn("TAF", Icons.description_outlined, () {
                    if (_icaoCtrl.text.isEmpty) {
                      _showError("⚠️ Enter ICAO code first.");
                      return;
                    }
                    _sendMessage('SERVER', 'inforeq', 'TAF ${_icaoCtrl.text}');
                  }),
                  const SizedBox(width: 8),
                  _buildWeatherBtn("D-ATIS", Icons.cell_tower, () {
                    if (_icaoCtrl.text.isEmpty) {
                      _showError("⚠️ Enter ICAO code first.");
                      return;
                    }
                    _sendMessage('SERVER', 'inforeq', 'ATIS ${_icaoCtrl.text}');
                  }),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWeatherBtn(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: efbBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: efbBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: efbWhite, size: 22),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: efbWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: efbTextMuted, size: 12),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCpdlcBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCpdlcAndOceanic() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.radar_outlined, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("CPDLC STATION",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildModernInput(
                          _cpdlcStationCtrl, "Logon Station")),
                  const SizedBox(width: 10),
                  _buildActionBtn(
                      "LOGON",
                      () => _sendMessage(_cpdlcStationCtrl.text, 'ping', ''),
                      efbAccent,
                      textColor: efbWhite)
                ],
              ),
              const SizedBox(height: 16),
              const Text("URGENT CPDLC RESPONSE",
                  style: TextStyle(
                      color: efbTextMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCpdlcBtn(
                      "WILCO",
                      Icons.check_circle_outline,
                      cGood,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'WILCO')),
                  const SizedBox(width: 10),
                  _buildCpdlcBtn(
                      "STANDBY",
                      Icons.access_time,
                      cWarn,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'STANDBY')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCpdlcBtn(
                      "UNABLE",
                      Icons.cancel_outlined,
                      cDanger,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'UNABLE')),
                  const SizedBox(width: 10),
                  _buildCpdlcBtn(
                      "ROGER",
                      Icons.chat_bubble_outline,
                      cRoger,
                      () => _sendMessage(
                          _cpdlcStationCtrl.text, 'cpdlc', 'ROGER')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.language, color: efbTextMuted, size: 16),
                  SizedBox(width: 8),
                  Text("OCEANIC POS REP",
                      style: TextStyle(
                          color: efbTextMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildLabeledInput("WPT", _ocWpt, "e.g. NAT A",
                      isError: _posRepAttempted && _ocWpt.text.isEmpty),
                  _buildLabeledInput("TIME", _ocTime, "HHMMZ",
                      isError: _posRepAttempted && _ocTime.text.isEmpty),
                  _buildLabeledInput("FL", _ocFl, "e.g. 350",
                      isError: _posRepAttempted && _ocFl.text.isEmpty),
                  _buildLabeledInput("SPD", _ocSpd, "e.g. 480",
                      isError: _posRepAttempted && _ocSpd.text.isEmpty),
                  _buildLabeledInput("NEXT", _ocNext, "e.g. RNP",
                      isError: _posRepAttempted && _ocNext.text.isEmpty),
                  _buildLabeledInput("ETO", _ocEto, "HHMMZ",
                      isError: _posRepAttempted && _ocEto.text.isEmpty),
                  _buildLabeledInput("FUEL", _ocFuel, "e.g. 12.5",
                      isError: _posRepAttempted && _ocFuel.text.isEmpty),
                  _buildLabeledInput("TEMP", _ocTemp, "e.g. -50",
                      isError: _posRepAttempted && _ocTemp.text.isEmpty),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionBtn("SEND POS REP", () {
                setState(() {
                  _posRepAttempted = true;
                });

                if (!_validateLogon()) return;

                if (_ocWpt.text.isEmpty ||
                    _ocTime.text.isEmpty ||
                    _ocFl.text.isEmpty ||
                    _ocSpd.text.isEmpty ||
                    _ocNext.text.isEmpty ||
                    _ocEto.text.isEmpty ||
                    _ocFuel.text.isEmpty ||
                    _ocTemp.text.isEmpty) {
                  _showError("⚠️ All fields are required for Position Report.");
                  return;
                }

                String report =
                    "POS REP: ${_ocWpt.text} AT ${_ocTime.text}, FL${_ocFl.text}, M${_ocSpd.text}. EST ${_ocNext.text} AT ${_ocEto.text}. FUEL ${_ocFuel.text}, TEMP ${_ocTemp.text}";
                _sendMessage(_cpdlcStationCtrl.text, 'telex', report);

                setState(() {
                  _posRepAttempted = false;
                });
              }, efbAccent, icon: Icons.send, textColor: efbWhite),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledInput(
      String label, TextEditingController ctrl, String hint,
      {bool isError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: efbTextMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Expanded(
          child: _buildModernInput(ctrl, hint, isError: isError),
        ),
      ],
    );
  }

  Widget _buildModernInput(TextEditingController ctrl, String hint,
      {bool obscure = false,
      double? width,
      bool isError = false,
      IconData? icon}) {
    Widget field = SizedBox(
      height: 38,
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: efbWhite, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: efbBorder, fontSize: 12),
          prefixIcon:
              icon != null ? Icon(icon, color: efbTextMuted, size: 16) : null,
          filled: true,
          fillColor: efbBg,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                  color: isError ? cDanger : efbBorder,
                  width: isError ? 1.5 : 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: isError ? cDanger : efbAccent, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
    return width != null ? SizedBox(width: width, child: field) : field;
  }

  Widget _buildActionBtn(String label, VoidCallback onTap, Color bgColor,
      {Color? textColor, Color? borderColor, IconData? icon}) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor ?? efbWhite,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
                color: borderColor ?? Colors.transparent, width: 1.0),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
