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

// 🔥 السطر السحري اللي بيكسر حماية فلاتر فلو ويستدعي ملف الأكشن عشان يربط الزراير بالشاشة
import '/custom_code/actions/send_livekit_cmdxplane.dart';

class LiveKitViewer extends StatefulWidget {
  const LiveKitViewer({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _LiveKitViewerState createState() => _LiveKitViewerState();
}

class _LiveKitViewerState extends State<LiveKitViewer> {
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
      builder: (context) => const FloatingLiveKitUI(),
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
class FloatingLiveKitUI extends StatefulWidget {
  const FloatingLiveKitUI({Key? key}) : super(key: key);

  @override
  _FloatingLiveKitUIState createState() => _FloatingLiveKitUIState();
}

class _FloatingLiveKitUIState extends State<FloatingLiveKitUI> {
  static const String _livekitUrl =
      'wss://simulator-station-ham7e1yr.livekit.cloud';
  static const String _apiKey = 'API5SxFp3ddtWz9';
  static const String _apiSecret =
      'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';

  Room? _room;
  VideoTrack? _remoteVideoTrack;
  EventsListener<RoomEvent>? _listener;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isMicOn = false;
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
    // 🔥 بنربط اللوجز بالمتغير اللي موجود في الأكشن عشان ضغطة الزرار تظهر هنا
    globalLiveKitLog_xplane = _addLog;
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
      _addLog("⚠️ PLEASE ENTER ROOM ID");
      return;
    }
    setState(() => _isConnecting = true);

    try {
      final token = _generateToken(roomName);
      _room = Room();

      // 🔥 الشاشة بتدي الغرفة للمتغير اللي في الأكشن عشان الزراير تعرف تبعت
      globalLiveKitRoom_xplane = _room;

      _listener = _room!.createListener();
      _listener!.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("🎥 VIDEO FEED ESTABLISHED");
          setState(() {
            _remoteVideoTrack = event.track as VideoTrack;
          });
        }
      });
      _listener!.on<TrackUnsubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("❌ VIDEO FEED LOST");
          setState(() {
            _remoteVideoTrack = null;
          });
        }
      });

      _addLog("CONNECTING TO SERVER...");
      await _room!.connect(_livekitUrl, token);

      // Force Mic Off initially
      await _room!.localParticipant?.setMicrophoneEnabled(false);
      await _room!.localParticipant?.setCameraEnabled(false);
      _isMicOn = false;

      _addLog("✅ SECURE CONNECTION ESTABLISHED");

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _showLogs = false; // 🔥 Auto-hide logs to show full video cleanly!
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

    // 🔥 تنظيف المتغيرات لما نقفل
    globalLiveKitRoom_xplane = null;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _remoteVideoTrack = null;
      _showLogs = true; // Show logs again on disconnect
    });
    _addLog("🛑 DISCONNECTED");
  }

  Future<void> _toggleMic() async {
    if (_room == null || _room!.localParticipant == null) return;
    try {
      final newState = !_isMicOn;
      await _room!.localParticipant!.setMicrophoneEnabled(newState);
      setState(() => _isMicOn = newState);
      _addLog(newState ? "🎤 MIC LIVE" : "🔇 MIC MUTED");
    } catch (e) {
      _addLog("❌ MIC ERROR: $e");
    }
  }

  @override
  void dispose() {
    _leaveRoom();
    globalLiveKitLog_xplane = null;
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
            color: const Color(0xFF121212), // Deep EFB Dark
            borderRadius: BorderRadius.circular(_isMaximized ? 0 : 12),
            border: _isMaximized
                ? null
                : Border.all(color: const Color(0xFF2C2C2E), width: 1.5),
            boxShadow: _isMaximized
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isMaximized ? 0 : 10),
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
                      color: Color(0xFF1C1C1E), // Apple Dark Mode gray
                      border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF333333), width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator,
                            color: Colors.white30, size: 16),
                        const SizedBox(width: 8),
                        const Text("LIVE MONITORING",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const Spacer(),

                        // Action Icons
                        if (_isConnected)
                          IconButton(
                            icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off,
                                color: _isMicOn
                                    ? const Color(0xFF32D74B)
                                    : const Color(0xFFFF453A),
                                size: 16),
                            onPressed: _toggleMic,
                            tooltip: "Toggle Mic",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),

                        IconButton(
                          icon: Icon(Icons.terminal,
                              color: _showLogs
                                  ? const Color(0xFF0A84FF)
                                  : Colors.white54,
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
                              color: Colors.white70,
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
                                color: Color(0xFFFF453A), size: 16),
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
                                      color: Color(0xFF0A84FF),
                                      strokeWidth: 2)),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flight_takeoff,
                                    size: 40, color: Color(0xFF0A84FF)),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _roomController,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      letterSpacing: 2),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: "ROOM ID",
                                    hintStyle: const TextStyle(
                                        color: Colors.white30,
                                        letterSpacing: 2),
                                    filled: true,
                                    fillColor: const Color(0xFF1C1C1E),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isConnecting ? null : _joinRoom,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A84FF),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                    child: _isConnecting
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                        : const Text("CONNECT TO SIMULATOR",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                                color: Colors.white,
                                                fontSize: 11)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                      // Logs Overlay
                      if (_showLogs)
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          height: _isConnected
                              ? 90
                              : 120, // Takes less space if video is running
                          child: Container(
                            color: Colors.black.withOpacity(0.85),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(6),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1.5),
                                child: Text(_logs[index],
                                    style: const TextStyle(
                                        color: Color(0xFF32D74B),
                                        fontSize: 10,
                                        fontFamily:
                                            'Courier')), // Hacker/Aviation green
                              ),
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
                                      color:
                                          Colors.white30), // Resize indicator
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
