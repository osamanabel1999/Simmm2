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
import 'dart:typed_data'; // تم إضافة هذا السطر لحل مشكلة ByteData و Endian
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadTrackerWidget extends StatefulWidget {
  const HeadTrackerWidget({
    Key? key,
    this.width,
    this.height,
    required this.targetIp, // Parameter الـ IP اللي طلبته عشان تربطه براحتك
  }) : super(key: key);

  final double? width;
  final double? height;
  final String targetIp;

  @override
  _HeadTrackerWidgetState createState() => _HeadTrackerWidgetState();
}

class _HeadTrackerWidgetState extends State<HeadTrackerWidget> {
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

  // القيم الخام (للسنترة)
  double _rawYaw = 0.0;
  double _rawPitch = 0.0;
  double _rawRoll = 0.0;

  // القيم النهائية (للرسم وإرسالها للمحاكي)
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;
  double _smoothedRoll = 0.0;

  // إعدادات السنترة
  double _yawOffset = 0.0;
  double _pitchOffset = 0.0;
  double _rollOffset = 0.0;

  // سرعة الاستجابة (Multipliers)
  double _yawMultiplier = 3.0;
  double _pitchMultiplier = 2.0;
  double _rollMultiplier = 1.0;

  // إعدادات التنعيم والمنطقة الميتة
  double _smoothingFactor = 0.2;
  double _deadzoneRadius = 2.0;

  // --- الحدود القصوى (Limits) والدفولت كما طلبتها بالضبط ---
  double _yawLimit = 90.0;
  double _pitchLimit = 60.0;
  double _rollLimit = 15.0;

  // نظام البروفايلات
  String _currentProfile = "Default";
  List<String> _profileNames = ["Default"];
  Map<String, Map<String, double>> _profilesData = {};

  bool _isLowLight = false;
  DateTime? _lastFaceDetectedTime;
  Timer? _lowLightCheckTimer;

  // --- متغيرات الـ UDP للاتصال بـ X-Plane ---
  int _targetPort = 49000;
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

  // --- تهيئة شبكة الـ UDP وإرسال الأوامر ---
  Future<void> _initUdpSocket() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (e) {
      print("UDP Init Error: $e");
    }
  }

  void _startUdpSender() {
    // إرسال البيانات بمعدل 30 مرة في الثانية (كل 33 مللي ثانية) لضمان حركة سلسة وواقعية جداً
    _udpSenderTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (_isTracking && _udpSocket != null) {
        _sendDrefPacket("sim/graphics/view/pilots_head_psi", _smoothedYaw);
        _sendDrefPacket("sim/graphics/view/pilots_head_the", _smoothedPitch);
        _sendDrefPacket("sim/graphics/view/pilots_head_phi", _smoothedRoll);
      }
    });
  }

  void _stopUdpSender() {
    _udpSenderTimer?.cancel();
  }

  void _sendDrefPacket(String dref, double value) {
    // استخدام الـ widget.targetIp اللي هتربطه من الـ App State
    String activeIp =
        widget.targetIp.isNotEmpty ? widget.targetIp : "192.168.1.100";
    if (_udpSocket == null || activeIp.isEmpty) return;
    try {
      final ip = InternetAddress(activeIp);
      final drefBytes = utf8.encode(dref.padRight(500, '\u0000'));
      final valueBytes = _float32ToBytes(value);
      final packet = <int>[
        ...utf8.encode('DREF\u0000'),
        ...valueBytes,
        ...drefBytes
      ];
      _udpSocket!.send(packet, ip, _targetPort);
    } catch (e) {
      print("UDP Send Error: $e");
    }
  }

  List<int> _float32ToBytes(double value) {
    final bd = ByteData(4);
    bd.setFloat32(0, value, Endian.little);
    return bd.buffer.asUint8List();
  }

  // --- نظام البروفايلات (حفظ واسترجاع) ---
  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('tracker_profiles_v4');

    if (profilesJson != null) {
      final Map<String, dynamic> decoded = json.decode(profilesJson);
      setState(() {
        _profilesData = decoded.map(
            (key, value) => MapEntry(key, Map<String, double>.from(value)));
        _profileNames = _profilesData.keys.toList();
        if (!_profileNames.contains("Default"))
          _profileNames.insert(0, "Default");
      });
    }
  }

  Future<void> _saveCurrentProfile(String profileName) async {
    final prefs = await SharedPreferences.getInstance();

    _profilesData[profileName] = {
      'yawMult': _yawMultiplier,
      'pitchMult': _pitchMultiplier,
      'rollMult': _rollMultiplier,
      'smooth': _smoothingFactor,
      'deadzone': _deadzoneRadius,
      'yawLim': _yawLimit,
      'pitchLim': _pitchLimit,
      'rollLim': _rollLimit,
    };

    await prefs.setString('tracker_profiles_v4', json.encode(_profilesData));

    setState(() {
      if (!_profileNames.contains(profileName)) _profileNames.add(profileName);
      _currentProfile = profileName;
    });
  }

  void _applyProfile(String profileName) {
    if (_profilesData.containsKey(profileName)) {
      final data = _profilesData[profileName]!;
      setState(() {
        _currentProfile = profileName;
        _yawMultiplier = data['yawMult'] ?? 3.0;
        _pitchMultiplier = data['pitchMult'] ?? 2.0;
        _rollMultiplier = data['rollMult'] ?? 1.0;
        _smoothingFactor = data['smooth'] ?? 0.2;
        _deadzoneRadius = data['deadzone'] ?? 2.0;
        _yawLimit = data['yawLim'] ?? 90.0;
        _pitchLimit = data['pitchLim'] ?? 60.0;
        _rollLimit = data['rollLim'] ?? 15.0;
      });
    }
  }

  Future<void> _showSaveProfileDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B111A),
          title: const Text("Save Profile As",
              style: TextStyle(color: Color(0xFF639DF0))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g., A320 Fenix",
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
              onPressed: () {
                if (controller.text.isNotEmpty)
                  _saveCurrentProfile(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- نافذة كتابة الأرقام يدوياً (الكيبورد الوهمي) ---
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

  // --- عمليات الكاميرا والتتبع ---
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

      _startUdpSender(); // تشغيل الإرسال للمحاكي تلقائياً عند بدء التتبع

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
    _stopUdpSender(); // إيقاف الإرسال للمحاكي
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

        double targetYaw =
            (calYaw * _yawMultiplier).clamp(-_yawLimit, _yawLimit);
        double targetPitch =
            (calPitch * _pitchMultiplier).clamp(-_pitchLimit, _pitchLimit);
        double targetRoll =
            (calRoll * _rollMultiplier).clamp(-_rollLimit, _rollLimit);

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
          // --- الشريط العلوي (Top Bar) ---
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0B111A),
              border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFF639DF0).withOpacity(0.3),
                      width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SIM STATION EFB",
                    style: TextStyle(
                        color: Color(0xFF639DF0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.tune,
                          color: _showSettings
                              ? Colors.white
                              : const Color(0xFF639DF0)),
                      onPressed: () =>
                          setState(() => _showSettings = !_showSettings),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2633),
                        side: const BorderSide(
                            color: Color(0xFF639DF0), width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isTracking ? _recenter : null,
                      icon: const Icon(Icons.center_focus_strong,
                          color: Colors.white, size: 16),
                      label: const Text("Recenter",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking
                            ? Colors.redAccent
                            : const Color(0xFF639DF0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow,
                          color: Colors.white, size: 16),
                      label: Text(_isTracking ? "Stop" : "Start",
                          style: TextStyle(color: Colors.white)),
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

          // --- الشاشة التفاعلية والإعدادات ---
          Expanded(
            child: Stack(
              children: [
                // 1. المحاكي الوهمي (الرؤية)
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border:
                        Border.all(color: const Color(0xFF1E2633), width: 2),
                    borderRadius: BorderRadius.circular(12),
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
                            child: Container(
                              width: deadzoneVisualSize,
                              height: deadzoneVisualSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1),
                                  color: Colors.white.withOpacity(0.02)),
                            ),
                          ),
                          Positioned(
                            left: clampedX,
                            top: clampedY,
                            child: Transform.rotate(
                              angle: _smoothedRoll * (pi / 180),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF639DF0),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xFF639DF0),
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

                // 2. نافذة الإعدادات الشفافة (Glassmorphism)
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
                            // البروفايلات
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("AIRCRAFT PROFILES",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5)),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: _currentProfile,
                                      dropdownColor: const Color(0xFF1E2633),
                                      style: const TextStyle(
                                          color: Color(0xFF639DF0),
                                          fontWeight: FontWeight.bold),
                                      underline: Container(),
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
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1E2633),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6))),
                                      onPressed: _showSaveProfileDialog,
                                      child: const Text("Save",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),

                            // قسم الحساسية (Multipliers)
                            const Text("SENSITIVITY (MULTIPLIERS)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Speed",
                                _yawMultiplier,
                                1.0,
                                5.0,
                                (val) => setState(() => _yawMultiplier = val)),
                            _buildSliderWithInput(
                                "Pitch Speed",
                                _pitchMultiplier,
                                1.0,
                                5.0,
                                (val) =>
                                    setState(() => _pitchMultiplier = val)),
                            _buildSliderWithInput(
                                "Roll Speed",
                                _rollMultiplier,
                                1.0,
                                5.0,
                                (val) => setState(() => _rollMultiplier = val)),

                            const Divider(color: Colors.white24, height: 30),

                            // قسم الحدود القصوى (Limits)
                            const Text("MAXIMUM LIMITS (DEGREES)",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Yaw Limit",
                                _yawLimit,
                                30.0,
                                180.0,
                                (val) => setState(() => _yawLimit = val)),
                            _buildSliderWithInput(
                                "Pitch Limit",
                                _pitchLimit,
                                30.0,
                                110.0,
                                (val) => setState(() => _pitchLimit = val)),
                            _buildSliderWithInput(
                                "Roll Limit",
                                _rollLimit,
                                0.0,
                                45.0,
                                (val) => setState(() => _rollLimit = val)),

                            const Divider(color: Colors.white24, height: 30),

                            // قسم التنعيم والمنطقة الميتة
                            const Text("STABILITY & DEADZONE",
                                style: TextStyle(
                                    color: Color(0xFF639DF0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildSliderWithInput(
                                "Smoothing",
                                _smoothingFactor,
                                0.05,
                                1.0,
                                (val) =>
                                    setState(() => _smoothingFactor = val)),
                            _buildSliderWithInput(
                                "Deadzone",
                                _deadzoneRadius,
                                0.0,
                                15.0,
                                (val) => setState(() => _deadzoneRadius = val)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // أداة بناء الـ Slider مع مربع الإدخال (EFB Style Container)
  Widget _buildSliderWithInput(String label, double value, double minVal,
      double maxVal, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: minVal,
              max: maxVal,
              activeColor: const Color(0xFF639DF0),
              inactiveColor: Colors.white12,
              onChanged: onChanged,
            ),
          ),
          InkWell(
            onTap: () =>
                _showEditNumberDialog(label, value, minVal, maxVal, onChanged),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 55,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2633),
                border:
                    Border.all(color: const Color(0xFF639DF0).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
