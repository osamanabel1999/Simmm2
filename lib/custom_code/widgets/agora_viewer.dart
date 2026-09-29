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

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraViewer extends StatefulWidget {
  const AgoraViewer({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _AgoraViewerState createState() => _AgoraViewerState();
}

class _AgoraViewerState extends State<AgoraViewer> {
  // بيانات الغرفة الثابتة لضمان أقصى استقرار
  static const String _kAppId = "cb8d86db8e01476d932b9766b3468481";
  static const String _kToken =
      "007eJxTYNhw8RRzLu+6y4rrp09a0yJlYHOt/oeq4yd5E8+n8ybUt4ooMCQnWaRYmKUkWaQaGJqYm6VYGhslWZqbmSUZm5hZmFgYCn/dldUQyMjgqDeBiZEBAkF8Loa0nMz0jJKi/PxcBgYA9YEhBw==";
  static const String _kChannel = "flightroom";

  RtcEngine? _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isConnecting = false;

  final List<String> _logs = [];

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now().toLocal();
      final time =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      _logs.insert(0, "[$time] $message");
    });
    debugPrint("Agora Debug: $message");
  }

  @override
  void initState() {
    super.initState();
    _addLog("الشاشة جاهزة. اضغط Join للاتصال 🚀");
  }

  Future<void> _joinStream() async {
    if (_isConnecting || _isJoined) return;

    setState(() {
      _isConnecting = true;
    });

    _addLog("جاري تهيئة محرك Agora...");

    try {
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(const RtcEngineContext(
        appId: _kAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      _addLog("تمت التهيئة بنجاح ✅");

      // تسجيل مستمعات الأحداث التفصيلية لمراقبة كل صغيرة وكبيرة
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          // خطأ عام من Agora
          onError: (ErrorCodeType err, String msg) {
            _addLog("❌ خطأ من Agora: $err | التفاصيل: $msg");
          },

          // تغير حالة الاتصال بالسيرفر
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            _addLog("📡 حالة الشبكة: ${state.name} | السبب: ${reason.name}");
          },

          // نجاح الانضمام
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _addLog("✅ متصل بالغرفة رسمياً: ${connection.channelId}");
            if (mounted) {
              setState(() {
                _isJoined = true;
                _isConnecting = false;
              });
            }
          },

          // انضمام جهاز اللابتوب
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _addLog("💻 تم رصد اللابتوب! المعرّف (UID): $remoteUid");
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
              });
            }
          },

          // مراقبة فيديو اللابتوب وفك التشفير
          onRemoteVideoStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) {
            _addLog(
                "🎥 حالة فيديو اللابتوب: ${state.name} (السبب: ${reason.name})");
          },

          // مراقبة صوت اللابتوب
          onRemoteAudioStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteAudioState state,
              RemoteAudioStateReason reason,
              int elapsed) {
            _addLog("🔊 حالة صوت اللابتوب: ${state.name}");
          },

          // مغادرة اللابتوب
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            _addLog("🚪 اللابتوب غادر الغرفة (${reason.name})");
            if (mounted) {
              setState(() {
                _remoteUid = null;
              });
            }
          },

          // تنبيه بخصوص صلاحية التوكن
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _addLog("⚠️ تحذير: التوكن قارب على الانتهاء!");
          },
        ),
      );

      // تفعيل استقبال الفيديو والصوت
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      _addLog("جاري إرسال طلب الانضمام إلى $_kChannel...");

      await _engine!.joinChannel(
        token: _kToken,
        channelId: _kChannel,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          clientRoleType: ClientRoleType.clientRoleAudience,
        ),
      );
    } catch (e, stack) {
      _addLog("❌ استثناء فادح: $e");
      debugPrint("Stack: $stack");
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _leaveStream() async {
    _addLog("جاري قطع الاتصال وتنظيف الذاكرة...");
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      }
      if (mounted) {
        setState(() {
          _isJoined = false;
          _isConnecting = false;
          _remoteUid = null;
        });
      }
      _addLog("تم قطع الاتصال بالكامل 🛑");
    } catch (e) {
      _addLog("خطأ أثناء الفصل: $e");
    }
  }

  @override
  void dispose() {
    if (_engine != null) {
      _engine!.leaveChannel();
      _engine!.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // شاشة عرض الفيديو الرئيسية
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_remoteUid != null && _engine != null)
                    AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine!,
                        canvas: VideoCanvas(
                          uid: _remoteUid,
                          renderMode: RenderModeType.renderModeFit,
                        ),
                        connection: const RtcConnection(channelId: _kChannel),
                        useFlutterTexture: true,
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isJoined ? Icons.tv : Icons.tv_off,
                          size: 48,
                          color: _isJoined ? Colors.greenAccent : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isConnecting
                              ? 'جاري الاتصال بالسيرفر... ⏳'
                              : _isJoined
                                  ? 'متصل بالغرفة ✅ في انتظار بث اللابتوب...'
                                  : 'اضغط Join لبدء الاتصال بالبث',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // لوحة أزرار التحكم
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_isConnecting || _isJoined) ? null : _joinStream,
                    icon: _isConnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                        _isConnecting ? "جاري الاتصال..." : "Join Room 🚀"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: (_isJoined || _isConnecting) ? _leaveStream : null,
                  icon: const Icon(Icons.stop),
                  label: const Text("Leave / Reset 🛑"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // لوحة السجلات اللحظية المفتوحة (Deep Logs)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "📋 سجل العمليات اللحظي (Live Diagnostics):",
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_logs.length} أحداث",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color color = Colors.greenAccent;
                        if (log.contains("❌") || log.contains("خطأ")) {
                          color = Colors.redAccent;
                        } else if (log.contains("⚠️")) {
                          color = Colors.amberAccent;
                        } else if (log.contains("📡") || log.contains("🎥")) {
                          color = Colors.lightBlueAccent;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            log,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontFamily: 'monospace'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
