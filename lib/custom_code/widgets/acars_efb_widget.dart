// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
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

// --- ألوان EFB الاحترافية ---
const Color efbBg = Color(0xFF0B111A);
const Color efbCard = Color(0xFF101923);
const Color efbBorder = Color(0xFF26364D);
const Color efbTextMuted = Color(0xFF8B949E);
const Color efbAccent = Color(0xFF639DF0);
const Color efbButtonDark = Color(0xFF15335E);
const Color efbWhite = Color(0xFFFFFFFF);

// --- ألوان Smart Text ---
const Color cDanger = Color(0xFFFF5252);
const Color cWarn = Color(0xFFFFD740);
const Color cWeather = Color(0xFF18FFFF);
const Color cGood = Color(0xFF69F0AE);

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

  // Quick ATC State (النظام الجديد)
  String? _activeQuickReq; // يحدد أي زر تم الضغط عليه
  final TextEditingController _quickReqInputCtrl = TextEditingController();

  bool _isVatsim = true;
  bool _isOnline = false;
  Timer? _pollingTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, String>> _mailbox = [];
  final String _hoppieUrl = 'http://www.hoppie.nl/acars/system/connect.html';

  @override
  void initState() {
    super.initState();
    _loadLogonCode();

    _logonCodeCtrl.addListener(() {
      _saveLogonCode(_logonCodeCtrl.text);
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

  // --- Core API Logic ---
  Future<void> _sendMessage(String to, String type, String packet,
      {bool showInMailbox = true}) async {
    if (_logonCodeCtrl.text.isEmpty || _callsignCtrl.text.isEmpty) {
      _showError("Enter Logon Code & Callsign first.");
      return;
    }

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
        _showError("Failed to send message.");
      }
    } catch (e) {
      setState(() => _isOnline = false);
      _showError("Connection Error.");
    }
  }

  Future<void> _checkInbox(String pollType) async {
    if (_logonCodeCtrl.text.isEmpty || _callsignCtrl.text.isEmpty) return;

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
        left: MediaQuery.of(context).size.width * 0.35,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: efbCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cWeather, width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_unread, color: cWeather, size: 24),
                SizedBox(width: 10),
                Text("NEW ATC MESSAGE",
                    style: TextStyle(
                        color: cWeather, fontWeight: FontWeight.bold)),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: cDanger));
  }

  // --- UI Builders ---
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
          child: Padding(
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
                      Expanded(flex: 2, child: _buildQuickRequestsAndWeather()),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: _buildCpdlcAndOceanic()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              Icon(Icons.circle, color: _isOnline ? cGood : cDanger, size: 14),
              const SizedBox(width: 8),
              Text(_isOnline ? "DATALINK ONLINE" : "OFFLINE",
                  style: const TextStyle(
                      color: efbWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const Text("ACARS / CPDLC SYSTEM",
              style: TextStyle(
                  color: efbAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          Row(
            children: [
              _buildModernInput(_logonCodeCtrl, "Logon Code",
                  obscure: true, width: 120),
              const SizedBox(width: 10),
              _buildModernInput(_callsignCtrl, "Callsign", width: 100),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                    color: efbBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: efbBorder)),
                child: ToggleButtons(
                  isSelected: [_isVatsim, !_isVatsim],
                  onPressed: (index) => setState(() => _isVatsim = index == 0),
                  color: efbTextMuted,
                  selectedColor: efbBg,
                  fillColor: efbAccent,
                  borderRadius: BorderRadius.circular(5),
                  constraints:
                      const BoxConstraints(minHeight: 38, minWidth: 60),
                  children: const [
                    Text("VAT", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("IVA", style: TextStyle(fontWeight: FontWeight.bold))
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
                const Text("MAILBOX",
                    style: TextStyle(
                        color: efbTextMuted, fontWeight: FontWeight.bold)),
                const Divider(color: efbBorder, thickness: 1.5),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mailbox.length,
                    itemBuilder: (context, index) {
                      final msg = _mailbox[index];
                      bool isIn = msg['dir'] == "IN";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            color: efbBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: efbBorder)),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Courier', fontSize: 14),
                            children: [
                              TextSpan(
                                  text: "[${msg['time']}] ",
                                  style: const TextStyle(color: efbTextMuted)),
                              TextSpan(
                                  text: "${msg['dir']} > ",
                                  style: TextStyle(
                                      color: isIn ? cGood : efbAccent,
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: _buildActionBtn(
                            "PEEK", () => _checkInbox('peek'), efbButtonDark,
                            textColor: efbWhite)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn(
                            "POLL", () => _checkInbox('poll'), efbAccent,
                            textColor: efbBg)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildActionBtn("CLEAR",
                            () => setState(() => _mailbox.clear()), efbBg,
                            borderColor: cDanger, textColor: cDanger)),
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
              const Text("TELEX (FREE TEXT)",
                  style: TextStyle(
                      color: efbTextMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("TO: ",
                      style: TextStyle(
                          color: efbTextMuted, fontWeight: FontWeight.bold)),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                        color: efbBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: efbBorder)),
                    child: ToggleButtons(
                      isSelected: [!_telexIsAtc, _telexIsAtc],
                      onPressed: (index) =>
                          setState(() => _telexIsAtc = index == 1),
                      color: efbTextMuted,
                      selectedColor: efbBg,
                      fillColor: efbWhite,
                      borderRadius: BorderRadius.circular(5),
                      constraints:
                          const BoxConstraints(minHeight: 36, minWidth: 60),
                      children: const [
                        Text("A/C", style: TextStyle(fontSize: 12)),
                        Text("ATC", style: TextStyle(fontSize: 12))
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildModernInput(_telexToCtrl,
                          _telexIsAtc ? "ATC Station" : "Callsign")),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telexMsgCtrl,
                style: const TextStyle(color: efbWhite),
                decoration: InputDecoration(
                  hintText: "Enter message...",
                  hintStyle: const TextStyle(color: efbTextMuted),
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
              _buildActionBtn("SEND TELEX", () {
                _sendMessage(_telexToCtrl.text, 'telex', _telexMsgCtrl.text);
                _telexMsgCtrl.clear();
              }, efbAccent, textColor: efbBg),
            ],
          ),
        ),
      ],
    );
  }

  // --- دوال وتصميم نظام الـ Quick ATC الجديد ---
  Widget _buildQuickAtcBtn(String id, String label) {
    bool isActive = _activeQuickReq == id;
    return _buildActionBtn(
      label,
      () {
        setState(() {
          if (isActive) {
            _activeQuickReq = null; // إغلاق الخانة إذا ضغطت عليه مرة أخرى
          } else {
            _activeQuickReq = id;
            _quickReqInputCtrl.clear();
          }
        });
      },
      isActive ? efbAccent : efbButtonDark,
      textColor: isActive ? efbBg : efbWhite,
    );
  }

  void _sendQuickReq() {
    if (_quickReqInputCtrl.text.isEmpty) {
      _showError("Please enter required data.");
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
        return "Stand & ATIS";
      case 'PUSH':
        return "Gate / Stand";
      case 'TAXI':
        return "Current Position";
      case 'LVL':
        return "Flight Level";
      case 'DIR':
        return "Waypoint";
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
              const Text("QUICK ATC REQUESTS",
                  style: TextStyle(
                      color: efbTextMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // ترتيب الأزرار لتبدو احترافية ولا تأخذ مساحة كبيرة
              Row(
                children: [
                  Expanded(child: _buildQuickAtcBtn('PDC', 'PDC')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAtcBtn('PUSH', 'PUSH / START')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildQuickAtcBtn('TAXI', 'TAXI')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAtcBtn('LVL', 'LVL CHG')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildQuickAtcBtn('DIR', 'DIRECT')),
                ],
              ),

              // الخانات التي تظهر داخل الصفحة (Inline Expansion)
              if (_activeQuickReq != null) ...[
                const SizedBox(height: 12),
                const Divider(color: efbBorder, thickness: 1),
                const SizedBox(height: 8),
                Text(_getQuickReqHint(),
                    style: const TextStyle(
                        color: efbAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildModernInput(
                            _quickReqInputCtrl, _getQuickReqPlaceholder())),
                    const SizedBox(width: 8),
                    _buildActionBtn("SEND", _sendQuickReq, cGood,
                        textColor: efbBg),
                  ],
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Weather
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: efbCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: efbBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("WEATHER & ATIS",
                  style: TextStyle(
                      color: efbTextMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildModernInput(_icaoCtrl, "ICAO (e.g. HECA)"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _buildActionBtn(
                          "METAR",
                          () =>
                              _sendMessage('METAR', 'inforeq', _icaoCtrl.text),
                          efbButtonDark,
                          textColor: cWeather)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildActionBtn(
                          "TAF",
                          () => _sendMessage('TAF', 'inforeq', _icaoCtrl.text),
                          efbButtonDark,
                          textColor: cWeather)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildActionBtn(
                          "D-ATIS",
                          () => _sendMessage(_icaoCtrl.text, 'inforeq', 'ATIS'),
                          efbButtonDark,
                          textColor: cWeather)),
                ],
              )
            ],
          ),
        )
      ],
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
              const Text("CPDLC STATION",
                  style: TextStyle(
                      color: efbTextMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildModernInput(
                          _cpdlcStationCtrl, "Station (e.g. EGLL)")),
                  const SizedBox(width: 10),
                  _buildActionBtn(
                      "LOGON",
                      () => _sendMessage(_cpdlcStationCtrl.text, 'ping', ''),
                      efbAccent,
                      textColor: efbBg)
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildActionBtn(
                          "WILCO",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'WILCO'),
                          efbBg,
                          borderColor: cGood,
                          textColor: cGood)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildActionBtn(
                          "STANDBY",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'STANDBY'),
                          efbBg,
                          borderColor: cWarn,
                          textColor: cWarn)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                      child: _buildActionBtn(
                          "UNABLE",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'UNABLE'),
                          efbBg,
                          borderColor: cDanger,
                          textColor: cDanger)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildActionBtn(
                          "ROGER",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'ROGER'),
                          efbBg,
                          borderColor: efbWhite,
                          textColor: efbWhite)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
                const Text("OCEANIC POS REP",
                    style: TextStyle(
                        color: efbTextMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildModernInput(_ocWpt, "WPT",
                          isError: _posRepAttempted && _ocWpt.text.isEmpty),
                      _buildModernInput(_ocTime, "TIME(Z)",
                          isError: _posRepAttempted && _ocTime.text.isEmpty),
                      _buildModernInput(_ocFl, "FL",
                          isError: _posRepAttempted && _ocFl.text.isEmpty),
                      _buildModernInput(_ocSpd, "MACH/SPD",
                          isError: _posRepAttempted && _ocSpd.text.isEmpty),
                      _buildModernInput(_ocNext, "NEXT WPT",
                          isError: _posRepAttempted && _ocNext.text.isEmpty),
                      _buildModernInput(_ocEto, "ETO(Z)",
                          isError: _posRepAttempted && _ocEto.text.isEmpty),
                      _buildModernInput(_ocFuel, "FUEL",
                          isError: _posRepAttempted && _ocFuel.text.isEmpty),
                      _buildModernInput(_ocTemp, "SAT/TAT",
                          isError: _posRepAttempted && _ocTemp.text.isEmpty),
                    ],
                  ),
                ),
                _buildActionBtn("SEND POS REP", () {
                  setState(() {
                    _posRepAttempted = true;
                  });
                  if (_ocWpt.text.isEmpty ||
                      _ocTime.text.isEmpty ||
                      _ocFl.text.isEmpty ||
                      _ocSpd.text.isEmpty ||
                      _ocNext.text.isEmpty ||
                      _ocEto.text.isEmpty ||
                      _ocFuel.text.isEmpty ||
                      _ocTemp.text.isEmpty) {
                    _showError("All fields are required for Position Report.");
                    return;
                  }

                  String report =
                      "POS REP: ${_ocWpt.text} AT ${_ocTime.text}, FL${_ocFl.text}, M${_ocSpd.text}. EST ${_ocNext.text} AT ${_ocEto.text}. FUEL ${_ocFuel.text}, TEMP ${_ocTemp.text}";
                  _sendMessage(_cpdlcStationCtrl.text, 'telex', report);

                  setState(() {
                    _posRepAttempted = false;
                  });
                }, cGood, textColor: efbBg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInput(TextEditingController ctrl, String hint,
      {bool obscure = false, double? width, bool isError = false}) {
    Widget field = SizedBox(
      height: 42,
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: efbWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: efbTextMuted, fontSize: 13),
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
      {Color? textColor, Color? borderColor}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor ?? efbWhite,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side:
              BorderSide(color: borderColor ?? Colors.transparent, width: 1.5),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
    );
  }
}
