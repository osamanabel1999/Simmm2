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
  // بياناتك من LiveKit
  static const String _livekitUrl =
      'wss://simulator-station-ham7e1yr.livekit.cloud';
  static const String _apiKey = 'API5SxFp3ddtWz9';
  static const String _apiSecret =
      'rj1SfmWRK0edm7XZ337xHSdeZEcXUWKdQhFtjBqMtxGB';

  Room? _room;
  VideoTrack? _remoteVideoTrack;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isMicOn = false;

  final TextEditingController _roomController = TextEditingController();
  final List<String> _logs = [];

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, "[${DateTime.now().second}s] $msg");
    });
    debugPrint("LiveKit: $msg");
  }

  // دالة توليد التوكن داخلياً (بدون سيرفر خارجي)
  String _generateToken(String roomName, String participantName) {
    final jwt = JWT({
      'name': participantName,
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
      },
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(hours: 4)))
              .millisecondsSinceEpoch ~/
          1000,
      'iss': _apiKey,
      'sub': participantName,
    });

    return jwt.sign(SecretKey(_apiSecret));
  }

  Future<void> _joinRoom() async {
    final roomName = _roomController.text.trim();
    if (roomName.isEmpty) {
      _addLog("⚠️ اكتب اسم الغرفة الأول!");
      return;
    }

    if (_isConnected || _isConnecting) return;
    setState(() => _isConnecting = true);

    try {
      _addLog("1. جاري إنشاء التوكن...");
      final token = _generateToken(roomName, "iPad_Copilot");

      _room = Room();

      // 👈 التعديل السحري: تمرير كابل الاتصال للمتغير العام عشان الزراير تشوفه
      globalLiveKitRoom_xplane = _room;

      _addLog("2. تسجيل المراقبة...");
      _listener = _room!.createListener();

      _listener!.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack) {
          _addLog("🎥 تم استلام شاشة اللابتوب!");
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

      _addLog("3. جاري الاتصال بالغرفة ($roomName)...");
      await _room!.connect(_livekitUrl, token);

      _addLog("✅ تم الاتصال بنجاح!");

      // الآيباد يدخل والمايك مقفول كبداية
      await _room!.localParticipant?.setMicrophoneEnabled(false);
      await _room!.localParticipant?.setCameraEnabled(false);

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
        });
      }
    } catch (e) {
      _addLog("❌ فشل الاتصال: $e");
      setState(() => _isConnecting = false);
    }
  }

  EventsListener<RoomEvent>? _listener;

  Future<void> _toggleMic() async {
    if (_room == null || _room!.localParticipant == null) return;

    try {
      final newState = !_isMicOn;
      await _room!.localParticipant!.setMicrophoneEnabled(newState);
      setState(() => _isMicOn = newState);
      _addLog(newState ? "🎤 المايك اتفتح" : "🔇 المايك اتقفل");
    } catch (e) {
      _addLog("❌ خطأ في المايك: $e");
    }
  }

  Future<void> _leaveRoom() async {
    _addLog("جاري الخروج...");
    await _room?.disconnect();
    _listener?.dispose();

    _room = null;
    // 👈 التعديل التاني: تفريغ كابل الاتصال لما الطيار يقفل عشان ميعملش خطأ
    globalLiveKitRoom_xplane = null;

    if (mounted) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _remoteVideoTrack = null;
        _isMicOn = false;
      });
    }
    _addLog("🛑 تم الخروج");
  }

  @override
  void dispose() {
    _listener?.dispose();
    _room?.disconnect();

    // 👈 تأكيد التفريغ عند تدمير الشاشة بالكامل
    globalLiveKitRoom_xplane = null;

    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.black87,
      child: Column(
        children: [
          // شريط التحكم العلوي
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "اسم أو كود الغرفة (مثال: flight123)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      fillColor: Colors.black,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    enabled: !_isConnected && !_isConnecting,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected
                      ? _leaveRoom
                      : (_isConnecting ? null : _joinRoom),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                  child: Text(
                      _isConnecting ? "⏳" : (_isConnected ? "Leave" : "Join")),
                ),
                if (_isConnected) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _toggleMic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMicOn ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                    ),
                    child: Icon(_isMicOn ? Icons.mic : Icons.mic_off,
                        color: Colors.white),
                  ),
                ]
              ],
            ),
          ),

          // شاشة عرض البث
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.all(8),
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
                            ? "في انتظار بث اللابتوب..."
                            : "غير متصل بالغرفة",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          ),

          // السجل (Logs)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(_logs[index],
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 11)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
