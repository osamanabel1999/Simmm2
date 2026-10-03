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

import 'package:livekit_client/livekit_client.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';

// 🔥 السطر السحري اللي بيكسر حماية فلاتر فلو ويستدعي ملف الأكشن بتاع MSFS عشان يربط الزراير بالشاشة
import '/custom_code/actions/send_livekit_cmdmsfs.dart';

class LiveKitViewermsfs extends StatefulWidget {
  const LiveKitViewermsfs({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _LiveKitViewermsfsState createState() => _LiveKitViewermsfsState();
}

class _LiveKitViewermsfsState extends State<LiveKitViewermsfs> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFloatingWindow();
    });
  }

  void _showFloatingWindow() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => const FloatingLiveKitUImsfs(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ==========================================
// Professional EFB-Style Floating Window
// ==========================================
class FloatingLiveKitUImsfs extends StatefulWidget {
  const FloatingLiveKitUImsfs({Key? key}) : super(key: key);

  @override
  _FloatingLiveKitUImsfsState createState() => _FloatingLiveKitUImsfsState();
}

class _FloatingLiveKitUImsfsState extends State<FloatingLiveKitUImsfs> {
  // 🔥 تم التحديث لبيانات سيرفر MSFS الجديد والموثوق
  static const String _livekitUrl =
      'wss://simulator-station-msfs-vb0uhblk.livekit.cloud';
  static const String _apiKey = 'APIA87Lpk5cmUMP';
  static const String _apiSecret =
      'aYWjjLKISVk663H7fYEBsx9cX69NTlg2er0oxtISsRD';

  Room? _room;
  VideoTrack? _remoteVideoTrack;
  EventsListener<RoomEvent>? _listener;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isMicOn = true;
  bool _showLogs = true;

  final TextEditingController _roomController = TextEditingController();
  final List<String> _logs = [];

  // Window default dimensions
  double _x = 50.0;
  double _y = 50.0;
  double _width = 380.0;
  double _height = 280.0;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    // 🔥 ربط لوجيك الشاشة بمتغير الـ MSFS
    globalLiveKitLog_msfs = _addLog;
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, "[${DateTime.now().second}s] $msg");
    });
    debugPrint("LiveKit Log: $msg");
  }

  String _generateToken(String roomName) {
    final jwt = JWT({
      'name': 'Instructor',
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': _apiKey,
      'sub': 'Instructor',
    });
    return jwt.sign(SecretKey(_apiSecret));
  }

  Future<void> _joinRoom() async {
    final roomName = _roomController.text.trim();
    if (roomName.isEmpty) {
      _addLog("⚠️ PLEASE ENTER SESSION ID");
      return;
    }
    setState(() => _isConnecting = true);

    try {
      final token = _generateToken(roomName);
      _room = Room();

      // 🔥 ربط الغرفة بمتغير الـ MSFS الخارجي
      globalLiveKitRoom_msfs = _room;

      _listener = _room!.createListener();
      _listener!.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("🎥 VIDEO DATALINK ESTABLISHED");
          setState(() {
            _remoteVideoTrack = event.track as VideoTrack;
          });
        }
      });
      _listener!.on<TrackUnsubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("❌ VIDEO DATALINK LOST");
          setState(() {
            _remoteVideoTrack = null;
          });
        }
      });

      _addLog("CONNECTING TO PILOT DEVICE...");
      await _room!.connect(_livekitUrl, token);

      await _room!.localParticipant?.setMicrophoneEnabled(true);
      await _room!.localParticipant?.setCameraEnabled(false);
      _isMicOn = true;

      _addLog("✅ SECURE DATALINK ESTABLISHED");

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _showLogs = false;
      });
    } catch (e) {
      _addLog("❌ CONNECTION FAILED: $e");
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _leaveRoom() async {
    await _room?.disconnect();
    _listener?.dispose();
    _room = null;

    // 🔥 تصفير متغير الغرفة لـ MSFS
    globalLiveKitRoom_msfs = null;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _remoteVideoTrack = null;
      _showLogs = true;
    });
    _addLog("🛑 DATALINK SEVERED");
  }

  Future<void> _toggleMic() async {
    if (_room == null || _room!.localParticipant == null) return;
    try {
      final newState = !_isMicOn;
      await _room!.localParticipant!.setMicrophoneEnabled(newState);
      setState(() => _isMicOn = newState);
      _addLog(newState ? "🎤 MIC HOT" : "🔇 MIC MUTED");
    } catch (e) {
      _addLog("❌ MIC ERROR: $e");
    }
  }

  @override
  void dispose() {
    _leaveRoom();
    // 🔥 فصل اللوج
    globalLiveKitLog_msfs = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final width = _isMaximized ? screenWidth : _width;
    final height = _isMaximized ? screenHeight : _height;
    final left = _isMaximized ? 0.0 : _x;
    final top = _isMaximized ? 0.0 : _y;

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        elevation: _isMaximized ? 0 : 24,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C1421), Color(0xFF030508)],
            ),
            borderRadius: BorderRadius.circular(_isMaximized ? 0 : 10),
            border: _isMaximized
                ? null
                : Border.all(color: const Color(0xFF1E324A), width: 1.5),
            boxShadow: _isMaximized
                ? []
                : [
                    BoxShadow(
                        color: const Color(0xFF5A94E3).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 2)
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isMaximized ? 0 : 8),
            child: Column(
              children: [
                // 1. Sleek Header Bar
                GestureDetector(
                  onPanUpdate: _isMaximized
                      ? null
                      : (details) {
                          setState(() {
                            _x += details.delta.dx;
                            _y += details.delta.dy;
                          });
                        },
                  onDoubleTap: () =>
                      setState(() => _isMaximized = !_isMaximized),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF070B14),
                      border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF1E324A), width: 1.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator,
                            color: Color(0xFF537396), size: 16),
                        const SizedBox(width: 8),
                        const Text("INSTRUCTOR OPERATING STATION",
                            style: TextStyle(
                                color: Color(0xFFA6C2DF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const Spacer(),

                        // Action Icons
                        if (_isConnected)
                          IconButton(
                            icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off,
                                color: _isMicOn
                                    ? const Color(0xFF4A90E2)
                                    : const Color(0xFF537396),
                                size: 16),
                            onPressed: _toggleMic,
                            tooltip: "Toggle Mic",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),

                        IconButton(
                          icon: Icon(Icons.terminal,
                              color: _showLogs
                                  ? const Color(0xFF7AA5D2)
                                  : const Color(0xFF537396),
                              size: 16),
                          onPressed: () =>
                              setState(() => _showLogs = !_showLogs),
                          tooltip: "Toggle Logs",
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),

                        IconButton(
                          icon: Icon(
                              _isMaximized
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: const Color(0xFF7AA5D2),
                              size: 16),
                          onPressed: () =>
                              setState(() => _isMaximized = !_isMaximized),
                          tooltip: "Toggle Fullscreen",
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),

                        if (_isConnected)
                          IconButton(
                            icon: const Icon(Icons.power_settings_new,
                                color: Colors.redAccent, size: 16),
                            onPressed: _leaveRoom,
                            tooltip: "Disconnect",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 6),
                          ),
                      ],
                    ),
                  ),
                ),

                // 2. Main Content Area
                Expanded(
                  child: Stack(
                    children: [
                      // Video or Login Screen
                      if (_isConnected)
                        Positioned.fill(
                          child: _remoteVideoTrack != null
                              ? VideoTrackRenderer(_remoteVideoTrack!)
                              : const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF7AA5D2),
                                      strokeWidth: 2)),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.satellite_alt,
                                    size: 44, color: Color(0xFF4A90E2)),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 48,
                                  child: TextField(
                                    controller: _roomController,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: "PILOT SESSION ID",
                                      hintStyle: const TextStyle(
                                          color: Color(0xFF455A75),
                                          letterSpacing: 1.5,
                                          fontSize: 11),
                                      filled: true,
                                      fillColor: const Color(0xFF0A121E),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1E324A))),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1E324A))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF4A90E2),
                                              width: 1.5)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: _isConnecting ? null : _joinRoom,
                                    icon: _isConnecting
                                        ? const SizedBox.shrink()
                                        : const Icon(Icons.login,
                                            color: Color(0xFF7AA5D2), size: 18),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16263B),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: const BorderSide(
                                              color: Color(0xFF5A94E3),
                                              width: 1.0)),
                                    ),
                                    label: _isConnecting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                color: Color(0xFF7AA5D2),
                                                strokeWidth: 2))
                                        : const Text("JOIN PILOT SESSION",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                                color: Color(0xFF7AA5D2),
                                                fontSize: 12)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                      // Logs Overlay
                      if (_showLogs)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: _isConnected ? 90 : 120,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF030508).withOpacity(0.9),
                                border: const Border(
                                    top: BorderSide(
                                        color: Color(0xFF1E324A), width: 1.0))),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final msg = _logs[index];
                                Color textColor = const Color(0xFFA6C2DF);
                                if (msg.contains("✅") || msg.contains("🚀"))
                                  textColor = const Color(0xFFF09819);
                                else if (msg.contains("❌") ||
                                    msg.contains("⚠️"))
                                  textColor = Colors.redAccent;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(msg,
                                      style: TextStyle(
                                          color: textColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Courier')),
                                );
                              },
                            ),
                          ),
                        ),

                      // Resize Drag Handle (Bottom Right)
                      if (!_isMaximized)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _width = (_width + details.delta.dx)
                                    .clamp(280.0, screenWidth);
                                _height = (_height + details.delta.dy)
                                    .clamp(220.0, screenHeight);
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              color: Colors.transparent,
                              child: const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.open_in_full,
                                      size: 12,
                                      color: Color(
                                          0xFF537396)), // Resize indicator
                                ),
                              ),
                            ),
                          ),
                        ),
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
}
