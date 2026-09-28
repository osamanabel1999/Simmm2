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

// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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

class _AcarsEfbWidgetState extends State<AcarsEfbWidget> {
  // --- Controllers & State ---
  final TextEditingController _logonCodeCtrl = TextEditingController();
  final TextEditingController _callsignCtrl = TextEditingController();
  final TextEditingController _telexToCtrl = TextEditingController();
  final TextEditingController _telexMsgCtrl = TextEditingController();
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

  bool _isVatsim = true; // True = VATSIM, False = IVAO
  bool _isOnline = false;
  Timer? _pollingTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mailbox Storage (Local)
  List<Map<String, String>> _mailbox = [];

  // API Endpoint
  final String _hoppieUrl = 'http://www.hoppie.nl/acars/system/connect.html';

  @override
  void initState() {
    super.initState();
    // Start Background Polling every 60 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isOnline) _checkInbox('poll');
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _audioPlayer.dispose();
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
    // Smart Routing for IVAO
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

      if (response.statusCode == 200 && response.body.trim().startsWith('ok')) {
        setState(() {
          _isOnline = true;
        });
        if (showInMailbox && type != 'ping') {
          _addToMailbox("OUT", "To $target: $packet");
        }
      } else {
        _showError("Failed to send message.");
      }
    } catch (e) {
      setState(() {
        _isOnline = false;
      });
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
          'type': pollType, // 'poll' or 'peek'
          'packet': '',
        },
      );

      String body = response.body.trim();
      if (response.statusCode == 200 && body.startsWith('ok')) {
        setState(() {
          _isOnline = true;
        });

        // Parse incoming message: "ok {sender msg}"
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
    } catch (e) {
      // Handle silently for background polling
    }
  }

  void _addToMailbox(String direction, String message) {
    String time =
        "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}Z";
    setState(() {
      _mailbox.insert(0, {"time": time, "dir": direction, "msg": message});
    });
  }

  // --- Immersion Features ---
  void _playChime() async {
    try {
      // Ensure you have an asset named atc_msg.mp3 in your assets folder
      await _audioPlayer.play(AssetSource('audio/atc_msg.mp3'));
    } catch (e) {
      debugPrint("Audio file not found, skipping sound.");
    }
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
              color: const Color(0xFF0F1115).withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2)
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_unread,
                    color: Colors.cyanAccent, size: 24),
                SizedBox(width: 10),
                Text("NEW ATC MESSAGE",
                    style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF0B0C10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF1F2833),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle,
                  color: _isOnline ? Colors.greenAccent : Colors.redAccent,
                  size: 16),
              const SizedBox(width: 8),
              Text(_isOnline ? "DATALINK ONLINE" : "OFFLINE",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text("ACARS / CPDLC SYSTEM",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          Row(
            children: [
              _buildCompactInput(_logonCodeCtrl, "Logon Code",
                  obscure: true, width: 120),
              const SizedBox(width: 10),
              _buildCompactInput(_callsignCtrl, "Callsign", width: 100),
              const SizedBox(width: 10),
              ToggleButtons(
                isSelected: [_isVatsim, !_isVatsim],
                onPressed: (index) => setState(() => _isVatsim = index == 0),
                color: Colors.grey,
                selectedColor: Colors.black,
                fillColor: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 35, minWidth: 60),
                children: const [Text("VAT"), Text("IVA")],
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
        // Mailbox
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF151821),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("MAILBOX",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.grey),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mailbox.length,
                    itemBuilder: (context, index) {
                      final msg = _mailbox[index];
                      bool isIn = msg['dir'] == "IN";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Courier', fontSize: 14),
                            children: [
                              TextSpan(
                                  text: "[${msg['time']}] ",
                                  style: const TextStyle(color: Colors.grey)),
                              TextSpan(
                                  text: "${msg['dir']} > ",
                                  style: TextStyle(
                                      color: isIn
                                          ? Colors.greenAccent
                                          : Colors.cyanAccent)),
                              TextSpan(
                                  text: msg['msg'],
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionBtn(
                        "PEEK", () => _checkInbox('peek'), Colors.grey),
                    _buildActionBtn(
                        "POLL", () => _checkInbox('poll'), Colors.cyanAccent),
                    _buildActionBtn(
                        "CLEAR",
                        () => setState(() => _mailbox.clear()),
                        Colors.redAccent),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Telex (Free Text)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF1F2833),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("TELEX (FREE TEXT)",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("TO:", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  _buildCompactInput(_telexToCtrl, "Callsign/ATC", width: 120),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _telexMsgCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    hintText: "Enter message...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8)),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black),
                onPressed: () {
                  _sendMessage(_telexToCtrl.text, 'telex', _telexMsgCtrl.text);
                  _telexMsgCtrl.clear();
                },
                child: const Text("SEND TELEX",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRequestsAndWeather() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick ATC
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF1F2833),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("QUICK ATC REQUESTS",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildActionBtn(
                  "PDC REQ",
                  () => _sendMessage(
                      _cpdlcStationCtrl.text, 'telex', 'REQUEST PDC'),
                  Colors.white24),
              const SizedBox(height: 6),
              _buildActionBtn(
                  "REQ PUSH / START",
                  () => _sendMessage(_cpdlcStationCtrl.text, 'telex',
                      'REQUEST PUSHBACK AND STARTUP'),
                  Colors.white24),
              const SizedBox(height: 6),
              _buildActionBtn(
                  "REQ TAXI",
                  () => _sendMessage(
                      _cpdlcStationCtrl.text, 'telex', 'READY FOR TAXI'),
                  Colors.white24),
              const SizedBox(height: 6),
              _buildActionBtn(
                  "REQ LEVEL CHG",
                  () => _sendMessage(
                      _cpdlcStationCtrl.text, 'telex', 'REQUEST LEVEL CHANGE'),
                  Colors.white24),
              const SizedBox(height: 6),
              _buildActionBtn(
                  "REQ DIRECT",
                  () => _sendMessage(
                      _cpdlcStationCtrl.text, 'telex', 'REQUEST DIRECT'),
                  Colors.white24),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Weather
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF1F2833),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("WEATHER & ATIS",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCompactInput(_icaoCtrl, "ICAO (e.g. HECA)"),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _buildActionBtn(
                          "METAR",
                          () =>
                              _sendMessage('METAR', 'inforeq', _icaoCtrl.text),
                          Colors.cyan[700]!)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _buildActionBtn(
                          "TAF",
                          () => _sendMessage('TAF', 'inforeq', _icaoCtrl.text),
                          Colors.cyan[700]!)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _buildActionBtn(
                          "D-ATIS",
                          () => _sendMessage(_icaoCtrl.text, 'inforeq', 'ATIS'),
                          Colors.cyan[700]!)),
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
        // CPDLC Station
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF1F2833),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("CPDLC STATION",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildCompactInput(
                          _cpdlcStationCtrl, "Station (e.g. EGLL)")),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    onPressed: () =>
                        _sendMessage(_cpdlcStationCtrl.text, 'ping', ''),
                    child: const Text("LOGON",
                        style: TextStyle(color: Colors.white)),
                  )
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
                          Colors.green)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _buildActionBtn(
                          "STANDBY",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'STANDBY'),
                          Colors.amber)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                      child: _buildActionBtn(
                          "UNABLE",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'UNABLE'),
                          Colors.red)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _buildActionBtn(
                          "ROGER",
                          () => _sendMessage(
                              _cpdlcStationCtrl.text, 'cpdlc', 'ROGER'),
                          Colors.blue)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Oceanic Pos Rep
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF1F2833),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("OCEANIC POS REP",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildCompactInput(_ocWpt, "WPT"),
                      _buildCompactInput(_ocTime, "TIME(Z)"),
                      _buildCompactInput(_ocFl, "FL"),
                      _buildCompactInput(_ocSpd, "MACH/SPD"),
                      _buildCompactInput(_ocNext, "NEXT WPT"),
                      _buildCompactInput(_ocEto, "ETO(Z)"),
                      _buildCompactInput(_ocFuel, "FUEL"),
                      _buildCompactInput(_ocTemp, "SAT/TAT"),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    String report =
                        "POS REP: ${_ocWpt.text} AT ${_ocTime.text}, FL${_ocFl.text}, M${_ocSpd.text}. EST ${_ocNext.text} AT ${_ocEto.text}. FUEL ${_ocFuel.text}, TEMP ${_ocTemp.text}";
                    _sendMessage(_cpdlcStationCtrl.text, 'telex', report);
                  },
                  child: const Text("SEND POS REP",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildCompactInput(TextEditingController ctrl, String hint,
      {bool obscure = false, double? width}) {
    Widget field = TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0B0C10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        isDense: true,
      ),
    );
    return width != null ? SizedBox(width: width, child: field) : field;
  }

  Widget _buildActionBtn(String label, VoidCallback onTap, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color == Colors.white24 ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
