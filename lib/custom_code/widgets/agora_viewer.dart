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
    required this.appId,
    required this.token,
    required this.channelName,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String appId;
  final String token;
  final String channelName;

  @override
  _AgoraViewerState createState() => _AgoraViewerState();
}

class _AgoraViewerState extends State<AgoraViewer> {
  int? _remoteUid;
  late RtcEngine _engine;
  bool _isJoined = false;

  final List<String> _logs = [];
  bool _showLogs = false;

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      final time =
          DateTime.now().toLocal().toString().split(' ')[1].split('.')[0];
      _logs.insert(0, "[$time] $message");
    });
    debugPrint("Agora Debug: $message");
  }

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    _addLog("بدء التشغيل...");
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (widget.appId.isEmpty || widget.token.isEmpty) {
        _addLog("❌ خطأ: الـ App ID أو الـ Token فارغ!");
        return;
      }

      _engine = createAgoraRtcEngine();

      await _engine.initialize(RtcEngineContext(
        appId: widget.appId.trim(),
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      _addLog("تمت التهيئة بنجاح ✅");

      _engine.registerEventHandler(
        RtcEngineEventHandler(onError: (ErrorCodeType err, String msg) {
          _addLog("خطأ ❌: $err - $msg");
        }, onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _addLog("متصل بالغرفة ✅: ${connection.channelId}");
          if (mounted) {
            setState(() {
              _isJoined = true;
            });
          }
        }, onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) {
          _addLog("اللابتوب انضم 💻: $remoteUid");
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
            });
          }
        }, onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _addLog("اللابتوب غادر 🚪");
          if (mounted) {
            setState(() {
              _remoteUid = null;
            });
          }
        }),
      );

      // تم حذف أوامر enableAudio و enableVideo نهائياً من هنا لمنع اختناق نظام iOS

      _addLog("جاري الانضمام للغرفة...");

      // إضافة مؤقت زمني لكسر أي تعليق صامت
      await _engine
          .joinChannel(
        token: widget.token.trim(),
        channelId: widget.channelName.trim(),
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          clientRoleType: ClientRoleType.clientRoleAudience,
        ),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception(
            "فشل الانضمام: لا يوجد رد من سيرفرات Agora أو نظام iOS يمنع الاتصال");
      });
    } catch (e) {
      _addLog("استثناء فادح ❌: $e");
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasError = _logs.any((log) => log.contains("❌"));

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : Text(
                    _isJoined
                        ? 'متصل بالغرفة ✅.. في انتظار اللابتوب'
                        : 'جاري الاتصال...',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
          ),
          if (_showLogs)
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              bottom: 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color textColor = Colors.greenAccent;
                    if (log.contains("❌"))
                      textColor = Colors.redAccent;
                    else if (log.contains("✅"))
                      textColor = Colors.lightBlueAccent;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(log,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontFamily: 'monospace')),
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() => _showLogs = !_showLogs),
              backgroundColor: hasError ? Colors.red : Colors.blue,
              child: Icon(_showLogs ? Icons.close : Icons.bug_report),
            ),
          ),
        ],
      ),
    );
  }
}
