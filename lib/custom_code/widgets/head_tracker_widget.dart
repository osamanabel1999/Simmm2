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
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class HeadTrackerWidget extends StatefulWidget {
  const HeadTrackerWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

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

  // القيم الخام التي لا يتم التلاعب بها أبداً (تُستخدم للسنترة فقط)
  double _rawYaw = 0.0;
  double _rawPitch = 0.0;

  // القيم النهائية بعد كل العمليات الحسابية (تُستخدم للرسم)
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;

  // إعدادات السنترة (Recenter Offsets)
  double _yawOffset = 0.0;
  double _pitchOffset = 0.0;

  // إعدادات المستخدم (الحساسية والنعومة والمنطقة الميتة)
  double _multiplier = 3.0;
  double _smoothingFactor = 0.2;
  double _deadzoneRadius = 2.0;

  // نظام تحذير الإضاءة
  bool _isLowLight = false;
  DateTime? _lastFaceDetectedTime;
  Timer? _lowLightCheckTimer;

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _lowLightCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

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
        if (!_isProcessing) {
          _processImage(image);
        }
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
    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _isLowLight = false;
      _rawYaw = 0.0;
      _rawPitch = 0.0;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
      _yawOffset = 0.0;
      _pitchOffset = 0.0;
    });
  }

  // الدالة الاحترافية للسنترة
  void _recenter() {
    setState(() {
      _yawOffset = _rawYaw;
      _pitchOffset = _rawPitch;
      _smoothedYaw = 0.0;
      _smoothedPitch = 0.0;
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

        // 1. استخراج القيم الخام
        final currentRawYaw = face.headEulerAngleY ?? 0.0;
        final currentRawPitch = face.headEulerAngleX ?? 0.0;

        _rawYaw = currentRawYaw;
        _rawPitch = currentRawPitch;

        // 2. تطبيق السنترة وعكس الـ Yaw فقط (حسب طلبك لتوحيد الاتجاه)
        // تم وضع سالب (-) قبل معادلة الـ Yaw لعكسها للأبد، وترك الـ Pitch كما هي
        double calibratedYaw = -(currentRawYaw - _yawOffset);
        double calibratedPitch = currentRawPitch - _pitchOffset;

        // 3. تطبيق المنطقة الميتة (Deadzone)
        if (calibratedYaw.abs() < _deadzoneRadius) calibratedYaw = 0.0;
        if (calibratedPitch.abs() < _deadzoneRadius) calibratedPitch = 0.0;

        // 4. تطبيق التنعيم (Smoothing)
        _smoothedYaw = (_smoothedYaw * (1 - _smoothingFactor)) +
            (calibratedYaw * _smoothingFactor);
        _smoothedPitch = (_smoothedPitch * (1 - _smoothingFactor)) +
            (calibratedPitch * _smoothingFactor);

        if (mounted) {
          setState(() {});
        }
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
          // شريط الأزرار العلوي
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Head Tracking Lab",
                  style: TextStyle(
                      color: Color(0xFF639DF0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800]),
                      onPressed: _isTracking ? _recenter : null,
                      child: const Text("Recenter",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isTracking ? Colors.red : const Color(0xFF639DF0),
                      ),
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      child: Text(_isTracking ? "Stop" : "Start",
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isLowLight)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text("Low Light! Ensure your face is illuminated.",
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),

          _buildSettingsPanel(),

          // الشاشة التفاعلية
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                border: Border.all(color: const Color(0xFF639DF0), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centerX = constraints.maxWidth / 2;
                  final centerY = constraints.maxHeight / 2;

                  final dotX = centerX +
                      (_smoothedYaw *
                          _multiplier *
                          (constraints.maxWidth / 90));
                  final dotY = centerY +
                      (_smoothedPitch *
                          _multiplier *
                          (constraints.maxHeight / 90));

                  final clampedX =
                      min(max(dotX, 10.0), constraints.maxWidth - 10.0) - 10.0;
                  final clampedY =
                      min(max(dotY, 10.0), constraints.maxHeight - 10.0) - 10.0;

                  final deadzoneVisualSize = (_deadzoneRadius *
                          _multiplier *
                          (constraints.maxWidth / 90)) *
                      2;

                  return Stack(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: constraints.maxWidth,
                              height: 1,
                              color: Colors.white24)),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 1,
                              height: constraints.maxHeight,
                              color: Colors.white24)),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: deadzoneVisualSize,
                          height: deadzoneVisualSize,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1),
                              color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                      Positioned(
                        left: clampedX,
                        top: clampedY,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.redAccent,
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
              child: _buildSlider("Sensitivity", _multiplier, 1.0, 5.0,
                  (val) => setState(() => _multiplier = val))),
          Expanded(
              child: _buildSlider("Smoothing", _smoothingFactor, 0.05, 1.0,
                  (val) => setState(() => _smoothingFactor = val))),
          Expanded(
              child: _buildSlider("Deadzone", _deadzoneRadius, 0.0, 10.0,
                  (val) => setState(() => _deadzoneRadius = val))),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double minVal, double maxVal,
      Function(double) onChanged) {
    return Column(
      children: [
        Text("$label: ${value.toStringAsFixed(1)}",
            style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Slider(
          value: value,
          min: minVal,
          max: maxVal,
          activeColor: const Color(0xFF639DF0),
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
