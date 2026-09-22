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

import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadTrackerWidgetMSFS extends StatefulWidget {
  const HeadTrackerWidgetMSFS({
    Key? key,
    this.width,
    this.height,
    required this.targetIp,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String targetIp;

  @override
  _HeadTrackerWidgetMSFSState createState() => _HeadTrackerWidgetMSFSState();
}

class _HeadTrackerWidgetMSFSState extends State<HeadTrackerWidgetMSFS> {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _isTracking = false;
  bool _isProcessing = false;
  bool _showSettings = false;
  bool _isRecenteringEffect = false;

  // القيم الخام (للسنترة)
  double _rawYaw = 0.0;
  double _rawPitch = 0.0;
  double _rawRoll = 0.0;

  // القيم النهائية (للرسم وإرسالها لـ OpenTrack)
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;
  double _smoothedRoll = 0.0;

  // إعدادات السنترة
  double _yawOffset = 0.0;
  double _pitchOffset = 0.0;
  double _rollOffset = 0.0;

  // إعدادات افتراضية ثابتة للـ Default
  final double _defYawMult = 3.0;
  final double _defPitchMult = 2.0;
  final double _defRollMult = 1.0;
  final double _defSmooth = 0.2;
  final double _defDeadzone = 2.0;
  final double _defYawLim = 90.0;
  final double _defPitchLim = 60.0;
  final double _defRollLim = 15.0;

  // الإعدادات النشطة
  late double _yawMultiplier = _defYawMult;
  late double _pitchMultiplier = _defPitchMult;
  late double _rollMultiplier = _defRollMult;
  late double _smoothingFactor = _defSmooth;
  late double _deadzoneRadius = _defDeadzone;
  late double _yawLimit = _defYawLim;
  late double _pitchLimit = _defPitchLim;
  late double _rollLimit = _defRollLim;
  bool _invertYaw = false;
  bool _invertPitch = false;
  bool _invertRoll = false;

  // نظام البروفايلات
  String _currentProfile = "Default";
  List<String> _profileNames = ["Default"];
  Map<String, Map<String, dynamic>> _profilesData = {};

  bool _isLowLight = false;
  DateTime? _lastFaceDetectedTime;
  Timer? _lowLightCheckTimer;

  // متغيرات الـ UDP للاتصال بـ OpenTrack
  int _targetPort = 4242;
  RawDatagramSocket? _udpSocket;
  Timer? _udpSenderTimer;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _initUdpSocket();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _lowLightCheckTimer?.cancel();
    _udpSenderTimer?.cancel();
    _udpSocket?.close();
    super.dispose();
  }

  Future<void> _initUdpSocket() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (e) {
      print("UDP Init Error: $e");
    }
  }

  void _startUdpSender() {
    _udpSenderTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (_isTracking && _udpSocket != null) {
        _sendOpenTrackPacket();
      }
    });
  }

  void _stopUdpSender() {
    _udpSenderTimer?.cancel();
  }

  void _sendOpenTrackPacket() {
    String activeIp =
        widget.targetIp.isNotEmpty ? widget.targetIp : "192.168.1.100";
    if (_udpSocket == null || activeIp.isEmpty) return;
    try {
      final ip = InternetAddress(activeIp);
      final bd = ByteData(48);

      bd.setFloat64(0, 0.0, Endian.little);
      bd.setFloat64(8, 0.0, Endian.little);
      bd.setFloat64(16, 0.0, Endian.little);
      bd.setFloat64(24, _smoothedYaw, Endian.little);
      bd.setFloat64(32, _smoothedPitch, Endian.little);
      bd.setFloat64(40, _smoothedRoll, Endian.little);

      final packet = bd.buffer.asUint8List();
      _udpSocket!.send(packet, ip, _targetPort);
    } catch (e) {
      print("UDP Send Error: $e");
    }
  }

  // --- نظام البروفايلات الاحترافي ---
  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('tracker_profiles_msfs_v2');

    if (profilesJson != null) {
      final Map<String, dynamic> decoded = json.decode(profilesJson);
      setState(() {
        _profilesData = decoded.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
        _profileNames = _profilesData.keys.toList();
        if (!_profileNames.contains("Default"))
          _profileNames.insert(0, "Default");
      });
    }
  }

  Future<void> _autoSaveCurrentProfile() async {
    if (_currentProfile == "Default") return; // حماية الديفولت

    final prefs = await SharedPreferences.getInstance();
    _profilesData[_currentProfile] = {
      'yawMult': _yawMultiplier,
      'pitchMult': _pitchMultiplier,
      'rollMult': _rollMultiplier,
      'smooth': _smoothingFactor,
      'deadzone': _deadzoneRadius,
      'yawLim': _yawLimit,
      'pitchLim': _pitchLimit,
      'rollLim': _rollLimit,
      'invYaw': _invertYaw,
      'invPitch': _invertPitch,
      'invRoll': _invertRoll,
    };
    await prefs.setString(
        'tracker_profiles_msfs_v2', json.encode(_profilesData));
  }

  void _applyProfile(String profileName) {
    setState(() {
      _currentProfile = profileName;
      if (profileName == "Default") {
        _yawMultiplier = _defYawMult;
        _pitchMultiplier = _defPitchMult;
        _rollMultiplier = _defRollMult;
        _smoothingFactor = _defSmooth;
        _deadzoneRadius = _defDeadzone;
        _yawLimit = _defYawLim;
        _pitchLimit = _defPitchLim;
        _rollLimit = _defRollLim;
        _invertYaw = false;
        _invertPitch = false;
        _invertRoll = false;
      } else if (_profilesData.containsKey(profileName)) {
        final data = _profilesData[profileName]!;
        _yawMultiplier = data['yawMult'] ?? _defYawMult;
        _pitchMultiplier = data['pitchMult'] ?? _defPitchMult;
        _rollMultiplier = data['rollMult'] ?? _defRollMult;
        _smoothingFactor = data['smooth'] ?? _defSmooth;
        _deadzoneRadius = data['deadzone'] ?? _defDeadzone;
        _yawLimit = data['yawLim'] ?? _defYawLim;
        _pitchLimit = data['pitchLim'] ?? _defPitchLim;
        _rollLimit = data['rollLim'] ?? _defRollLim;
        _invertYaw = data['invYaw'] ?? false;
        _invertPitch = data['invPitch'] ?? false;
        _invertRoll = data['invRoll'] ?? false;
      }
    });
  }

  Future<void> _addNewProfileDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B111A),
          title: const Text("Create New Profile",
              style: TextStyle(color: Color(0xFF639DF0))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter profile name...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF639DF0))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isNotEmpty &&
                    newName != "Default" &&
                    !_profileNames.contains(newName)) {
                  setState(() {
                    _profileNames.add(newName);
                    _currentProfile = newName;
                  });
                  await _autoSaveCurrentProfile();
                  if (mounted) Navigator.pop(context);
                }
              },
              child:
                  const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameProfileDialog() async {
    if (_currentProfile == "Default") return;
    TextEditingController controller =
        TextEditingController(text: _currentProfile);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B111A),
          title: const Text("Rename Profile",
              style: TextStyle(color: Color(0xFF639DF0))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF639DF0))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () async {
                String newName = controller.text.trim();
                if (newName.isNotEmpty &&
                    newName != "Default" &&
                    newName != _currentProfile) {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _profilesData[newName] = _profilesData[_currentProfile]!;
                    _profilesData.remove(_currentProfile);
                    int index = _profileNames.indexOf(_currentProfile);
                    if (index != -1) _profileNames[index] = newName;
                    _currentProfile = newName;
                  });
                  await prefs.setString(
                      'tracker_profiles_msfs_v2', json.encode(_profilesData));
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfile() async {
    if (_currentProfile == "Default") return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilesData.remove(_currentProfile);
      _profileNames.remove(_currentProfile);
      _currentProfile = "Default";
      _applyProfile("Default");
    });
    await prefs.setString(
        'tracker_profiles_msfs_v2', json.encode(_profilesData));
  }

  Future<void> _showEditNumberDialog(String label, double currentValue,
      double minVal, double maxVal, Function(double) onSaved) async {
    TextEditingController numController =
        TextEditingController(text: currentValue.toStringAsFixed(1));
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2633),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF639DF0))),
          title: Text("Set $label",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: numController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
                color: Color(0xFF639DF0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF0B111A),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF639DF0)),
              onPressed: () {
                double? parsed = double.tryParse(numController.text);
                if (parsed != null) {
                  parsed = parsed.clamp(minVal, maxVal);
                  onSaved(parsed);
                }
                Navigator.pop(context);
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startTracking() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isTracking = true;
        _isLowLight = false;
        _lastFaceDetectedTime = DateTime.now();
      });

      _startUdpSender();

      _lowLightCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isTracking && _lastFaceDetectedTime != null) {
          final timeSinceLastFace =
              DateTime.now().difference(_lastFaceDetectedTime!).inMilliseconds;
          if (timeSinceLastFace > 2500 && !_isLowLight) {
            setState(() {
              _isLowLight = true;
            });
          } else if (timeSinceLastFace <= 2500 && _isLowLight) {
            setState(() {
              _isLowLight = false;
            });
          }
        }
      });

      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) _processImage(image);
      });
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  Future<void> _stopTracking() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    _lowLightCheckTimer?.cancel();
    _stopUdpSender();
    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _isLowLight = false;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
      _smoothedRoll = 0.0;
      _yawOffset = 0.0;
      _pitchOffset = 0.0;
      _rollOffset = 0.0;
    });
  }

  void _recenter() {
    setState(() {
      _yawOffset = _rawYaw;
      _pitchOffset = _rawPitch;
      _rollOffset = _rawRoll;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
      _smoothedRoll = 0.0;
      _isRecenteringEffect = true; // تشغيل إيفيكت السنترة
    });

    // إيقاف الإيفيكت بعد فترة قصيرة عشان يدي شكل الفلاش
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRecenteringEffect = false;
        });
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;
    final inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        _lastFaceDetectedTime = DateTime.now();
        final face = faces.first;

        _rawYaw = face.headEulerAngleY ?? 0.0;
        _rawPitch = face.headEulerAngleX ?? 0.0;
        _rawRoll = face.headEulerAngleZ ?? 0.0;

        double calYaw = -(_rawYaw - _yawOffset);
        double calPitch = (_rawPitch - _pitchOffset);
        double calRoll = -(_rawRoll - _rollOffset);

        if (calYaw.abs() < _deadzoneRadius) calYaw = 0.0;
        if (calPitch.abs() < _deadzoneRadius) calPitch = 0.0;
        if (calRoll.abs() < _deadzoneRadius) calRoll = 0.0;

        double dirYaw = _invertYaw ? -calYaw : calYaw;
        double dirPitch = _invertPitch ? -calPitch : calPitch;
        double dirRoll = _invertRoll ? -calRoll : calRoll;

        double targetYaw =
            (dirYaw * _yawMultiplier).clamp(-_yawLimit, _yawLimit);
        double targetPitch =
            (dirPitch * _pitchMultiplier).clamp(-_pitchLimit, _pitchLimit);
        double targetRoll =
            (dirRoll * _rollMultiplier).clamp(-_rollLimit, _rollLimit);

        _smoothedYaw = (_smoothedYaw * (1 - _smoothingFactor)) +
            (targetYaw * _smoothingFactor);
        _smoothedPitch = (_smoothedPitch * (1 - _smoothingFactor)) +
            (targetPitch * _smoothingFactor);
        _smoothedRoll = (_smoothedRoll * (1 - _smoothingFactor)) +
            (targetRoll * _smoothingFactor);

        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Face Detection Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF0B111A),
      child: Column(
        children: [
          // الشريط العلوي مصمم بذكاء لمنع خروج العناصر من الشاشة
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0B111A),
              border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFF639DF0).withOpacity(0.3),
                      width: 1)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "AERO VISION ENGINE",
                    style: TextStyle(
                        color: Color(0xFF639DF0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.tune,
                          color: _showSettings
                              ? Colors.white
                              : const Color(0xFF639DF0),
                          size: 22),
                      onPressed: () =>
                          setState(() => _showSettings = !_showSettings),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: const Color(0xFF1E2633),
                          side: const BorderSide(
                              color: Color(0xFF639DF0), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _isTracking ? _recenter : null,
                        icon: const Icon(Icons.center_focus_strong,
                            color: Colors.white, size: 14),
                        label: const Text("Center",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: _isTracking
                              ? Colors.redAccent
                              : const Color(0xFF639DF0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _isTracking ? _stopTracking : _startTracking,
                        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow,
                            color: Colors.white, size: 14),
                        label: Text(_isTracking ? "Stop" : "Start",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isLowLight)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text("Low Light! Ensure your face is illuminated.",
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),

          // الشاشة التفاعلية والإعدادات
          Expanded(
            child: Stack(
              children: [
                // المحاكي الوهمي مع إيفيكت السنترة السحري
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                        color: _isRecenteringEffect
                            ? Colors.greenAccent
                            : const Color(0xFF1E2633),
                        width: _isRecenteringEffect ? 3 : 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isRecenteringEffect
                        ? [
                            BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2)
                          ]
                        : [],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final centerX = constraints.maxWidth / 2;
                      final centerY = constraints.maxHeight / 2;

                      final maxVisYaw = 180.0;
                      final maxVisPitch = 110.0;

                      final dotX = centerX +
                          (_smoothedYaw *
                              (constraints.maxWidth / (maxVisYaw * 2)));
                      final dotY = centerY +
                          (_smoothedPitch *
                              (constraints.maxHeight / (maxVisPitch * 2)));

                      final clampedX =
                          min(max(dotX, 10.0), constraints.maxWidth - 10.0) -
                              10.0;
                      final clampedY =
                          min(max(dotY, 10.0), constraints.maxHeight - 10.0) -
                              10.0;

                      final deadzoneVisualSize = (_deadzoneRadius *
                              _yawMultiplier *
                              (constraints.maxWidth / (maxVisYaw * 2))) *
                          2;

                      return Stack(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: constraints.maxWidth,
                                  height: 1,
                                  color: const Color(0xFF1E2633))),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: 1,
                                  height: constraints.maxHeight,
                                  color: const Color(0xFF1E2633))),
                          Align(
                            alignment: Alignment.center,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: deadzoneVisualSize,
                              height: deadzoneVisualSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _isRecenteringEffect
                                          ? Colors.greenAccent
                                          : Colors.grey.withOpacity(0.2),
                                      width: 1),
                                  color: Colors.white.withOpacity(0.02)),
                            ),
                          ),
                          Positioned(
                            left: clampedX,
                            top: clampedY,
                            child: Transform.rotate(
                              angle: _smoothedRoll * (pi / 180),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: _isRecenteringEffect ? 24 : 20,
                                height: _isRecenteringEffect ? 24 : 20,
                                decoration: BoxDecoration(
                                    color: _isRecenteringEffect
                                        ? Colors.greenAccent
                                        : const Color(0xFF639DF0),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: _isRecenteringEffect
                                              ? Colors.greenAccent
                                              : const Color(0xFF639DF0),
                                          blurRadius: 12,
                                          spreadRadius: 3)
                                    ]),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                      width: 2, height: 8, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // نافذة الإعدادات الشفافة بنظام البروفايلات الجديد
                if (_showSettings)
                  Positioned(
                    top: 16,
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B111A).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF639DF0).withOpacity(0.5),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text("PROFILES",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          fontSize: 14)),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1E2633),
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: Colors.white24)),
                                  child: DropdownButton<String>(
                                    value: _currentProfile,
                                    dropdownColor: const Color(0xFF1E2633),
                                    style: const TextStyle(
                                        color: Color(0xFF639DF0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                    underline: Container(),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xFF639DF0), size: 18),
                                    items: _profileNames
                                        .map((String value) =>
                                            DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) _applyProfile(val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_currentProfile == "Default")
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Color(0xFF639DF0)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _addNewProfileDialog,
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _renameProfileDialog,
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _deleteProfile,
                                  ),
                                ],
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("AXIS INVERSION",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInvertButton("Yaw", _invertYaw, () {
                                  setState(() => _invertYaw = !_invertYaw);
                                  _autoSaveCurrentProfile();
                                }),
                                _buildInvertButton("Pitch", _invertPitch, () {
                                  setState(() => _invertPitch = !_invertPitch);
                                  _autoSaveCurrentProfile();
                                }),
                                _buildInvertButton("Roll", _invertRoll, () {
                                  setState(() => _invertRoll = !_invertRoll);
                                  _autoSaveCurrentProfile();
                                }),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("SENSITIVITY (MULTIPLIERS)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Speed", _yawMultiplier, 1.0, 5.0, (val) {
                              setState(() => _yawMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Pitch Speed", _pitchMultiplier, 1.0, 5.0,
                                (val) {
                              setState(() => _pitchMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Roll Speed", _rollMultiplier, 1.0, 5.0, (val) {
                              setState(() => _rollMultiplier = val);
                              _autoSaveCurrentProfile();
                            }),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("MAXIMUM LIMITS (DEGREES)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Limit", _yawLimit, 30.0, 180.0, (val) {
                              setState(() => _yawLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Pitch Limit", _pitchLimit, 30.0, 110.0, (val) {
                              setState(() => _pitchLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Roll Limit", _rollLimit, 0.0, 45.0, (val) {
                              setState(() => _rollLimit = val);
                              _autoSaveCurrentProfile();
                            }),
                            const Divider(color: Colors.white24, height: 30),
                            const Text("STABILITY & DEADZONE",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Smoothing", _smoothingFactor, 0.05, 1.0,
                                (val) {
                              setState(() => _smoothingFactor = val);
                              _autoSaveCurrentProfile();
                            }),
                            _buildSliderWithInput(
                                "Deadzone", _deadzoneRadius, 0.0, 15.0, (val) {
                              setState(() => _deadzoneRadius = val);
                              _autoSaveCurrentProfile();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // إضافة مؤشر الرجوع (Home Indicator) أسفل الشاشة التفاعلية
          _buildHomeIndicator(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvertButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: _currentProfile == "Default"
          ? null
          : onTap, // تعطيل الضغط في الديفولت
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF639DF0).withOpacity(0.2)
              : const Color(0xFF1E2633),
          border: Border.all(
              color: isSelected ? const Color(0xFF639DF0) : Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.swap_horiz : Icons.arrow_right_alt,
              color: _currentProfile == "Default"
                  ? Colors.white24
                  : (isSelected ? const Color(0xFF639DF0) : Colors.white54),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              "Inv $label",
              style: TextStyle(
                color: _currentProfile == "Default"
                    ? Colors.white24
                    : (isSelected ? const Color(0xFF639DF0) : Colors.white54),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderWithInput(String label, double value, double minVal,
      double maxVal, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: minVal,
              max: maxVal,
              activeColor: _currentProfile == "Default"
                  ? Colors.grey
                  : const Color(0xFF639DF0),
              inactiveColor: Colors.white12,
              onChanged: _currentProfile == "Default"
                  ? null
                  : onChanged, // تعطيل السلايدر في الديفولت
            ),
          ),
          InkWell(
            onTap: _currentProfile == "Default"
                ? null
                : () => _showEditNumberDialog(
                    label, value, minVal, maxVal, onChanged),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2633),
                border: Border.all(
                    color: _currentProfile == "Default"
                        ? Colors.white12
                        : const Color(0xFF639DF0).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _currentProfile == "Default"
                        ? Colors.white54
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ودجيت الـ Home Indicator ---
  Widget _buildHomeIndicator({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
        alignment: Alignment.center,
        child: Container(
          width: 130,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
