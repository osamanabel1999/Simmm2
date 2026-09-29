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

// 🔥 السطر السحري اللي بيستدعي ملف الأكشن حرفياً عشان نقرأ المتغيرات اللي جواه غصب عن فلاتر فلو
import '/custom_code/actions/send_livekit_cmdxplane.dart';

class LiveKitViewer extends StatefulWidget {
  const LiveKitViewer({
    Key? key,
    this.width,
    this.height,
    this.onTestClick,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Future<dynamic> Function()? onTestClick;

  @override
  _LiveKitViewerState createState() => _LiveKitViewerState();
}

class _LiveKitViewerState extends State<LiveKitViewer> {
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

  final TextEditingController _roomController = TextEditingController();
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // بنربط اللوجز بالمتغير اللي موجود في ملف الأكشن
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
      _addLog("⚠️ اكتب اسم الغرفة!");
      return;
    }
    setState(() => _isConnecting = true);

    try {
      final token = _generateToken(roomName);
      _room = Room();

      // 🔥 الشاشة دلوقتي بتبعت الاتصال للمتغير اللي موجود في الأكشن عشان الزرار الخارجي يلاقيه
      globalLiveKitRoom_xplane = _room;

      _listener = _room!.createListener();
      _listener!.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("🎥 تم استلام شير سكرين اللابتوب بنجاح!");
          setState(() {
            _remoteVideoTrack = event.track as VideoTrack;
          });
        }
      });

      _listener!.on<TrackUnsubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("❌ اللابتوب قفل البث");
          setState(() {
            _remoteVideoTrack = null;
          });
        }
      });

      _addLog("جاري الاتصال بالغرفة...");
      await _room!.connect(_livekitUrl, token);

      _addLog("✅ تم الاتصال بنجاح!");
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });
    } catch (e) {
      _addLog("❌ فشل الاتصال: $e");
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _sendTestCommand() async {
    if (_room == null || _room!.localParticipant == null) {
      _addLog("⚠️ مفيش اتصال عشان نبعت!");
      return;
    }
    try {
      _addLog("⏳ جاري إرسال TEST داخلي...");
      final data = utf8.encode('TEST');
      await _room!.localParticipant!.publishData(data, topic: 'cmd');
      _addLog("🚀 تم الإرسال من الزرار الداخلي!");

      if (widget.onTestClick != null) {
        widget.onTestClick!();
      }
    } catch (e) {
      _addLog("❌ فشل الإرسال: $e");
    }
  }

  Future<void> _leaveRoom() async {
    await _room?.disconnect();
    _listener?.dispose();
    _room = null;

    // تنظيف
    globalLiveKitRoom_xplane = null;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _remoteVideoTrack = null;
    });
    _addLog("🛑 تم الخروج");
  }

  @override
  void dispose() {
    _listener?.dispose();
    globalLiveKitLog_xplane = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: "اسم الغرفة",
                        filled: true,
                        fillColor: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnected ? _leaveRoom : _joinRoom,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isConnected ? Colors.red : Colors.green),
                  child: Text(_isConnected ? "Leave" : "Join"),
                ),
                if (_isConnected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _sendTestCommand,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: const Text("🚀 إرسال",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              child: _remoteVideoTrack != null
                  ? VideoTrackRenderer(_remoteVideoTrack!)
                  : Center(
                      child: Text(
                        _isConnected
                            ? "في انتظار بث الشاشة من اللابتوب..."
                            : "غير متصل بالغرفة",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black54,
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(_logs[index],
                      style: const TextStyle(
                          color: Colors.greenAccent, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
