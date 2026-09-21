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
import 'dart:async'; // نحتاجه لحساب وقت الإضاءة المنخفضة
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

  // القيم الخام والمنعمة
  double _rawYaw = 0.0;
  double _rawPitch = 0.0;
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;

  // 1. إعدادات السنترة (Recenter)
  double _yawOffset = 0.0;
  double _pitchOffset = 0.0;

  // 2. إعدادات المستخدم (Sensitivity, Smoothing, Deadzone, Invert)
  double _multiplier = 2.5; // الحساسية
  double _smoothingFactor = 0.3; // النعومة (رقم أصغر = أنعم بس أبطأ)
  double _deadzoneRadius =
      2.5; // حجم المنطقة الميتة بالدرجات (لا توجد حركة بداخلها)
  bool _invertYaw = true; // عكس حركة اليمين والشمال
  bool _invertPitch = true; // عكس حركة الفوق والتحت

  // 3. نظام تحذير الإضاءة المنخفضة
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

      // مؤقت يراجع هل الوش اختفى لفترة طويلة (بسبب الضلمة)
      _lowLightCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isTracking && _lastFaceDetectedTime != null) {
          final timeSinceLastFace =
              DateTime.now().difference(_lastFaceDetectedTime!).inMilliseconds;
          if (timeSinceLastFace > 2500 && !_isLowLight) {
            // لو عدى 2.5 ثانية ومفيش وش، نطلع تحذير الإضاءة
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
    });
  }

  // دالة السنترة (بتعتبر الوضع الحالي هو الصفر)
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
        _lastFaceDetectedTime = DateTime.now(); // تحديث وقت آخر وش تم اكتشافه

        final face = faces.first;

        // جلب الزوايا الخام
        double newYaw = face.headEulerAngleY ?? 0.0;
        double newPitch = face.headEulerAngleX ?? 0.0;

        // تطبيق العكس (Invert) لو متفعل
        if (_invertYaw) newYaw = -newYaw;
        if (_invertPitch) newPitch = -newPitch;

        // تطبيق السنترة (Offset)
        double calibratedYaw = newYaw - (_invertYaw ? -_yawOffset : _yawOffset);
        double calibratedPitch =
            newPitch - (_invertPitch ? -_pitchOffset : _pitchOffset);

        // تطبيق المنطقة الميتة (Deadzone)
        // لو الحركة أصغر من الـ Radius اللي حددناه، اعتبرها صفر
        if (calibratedYaw.abs() < _deadzoneRadius) calibratedYaw = 0.0;
        if (calibratedPitch.abs() < _deadzoneRadius) calibratedPitch = 0.0;

        // تطبيق التنعيم (Smoothing)
        _smoothedYaw = (_smoothedYaw * (1 - _smoothingFactor)) +
            (calibratedYaw * _smoothingFactor);
        _smoothedPitch = (_smoothedPitch * (1 - _smoothingFactor)) +
            (calibratedPitch * _smoothingFactor);

        if (mounted) {
          setState(() {
            _rawYaw = newYaw;
            _rawPitch = newPitch;
          });
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

          // عرض تحذير الإضاءة لو موجود
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
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // لوحة تحكم الإعدادات (Sliders)
          _buildSettingsPanel(),

          // الشاشة التفاعلية (المحاكي الوهمي)
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
                      min(max(dotX, 0.0), constraints.maxWidth - 20);
                  final clampedY =
                      min(max(dotY, 0.0), constraints.maxHeight - 20);

                  // رسم دائرة المنطقة الميتة في المنتصف
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

                      // دائرة الـ Deadzone (عشان تشوفها بعينك)
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

                      // نقطة الحركة
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

  // بناء واجهة الإعدادات (المتزلجات والأزرار)
  Widget _buildSettingsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggle("Invert Yaw", _invertYaw,
                  (val) => setState(() => _invertYaw = val)),
              const SizedBox(width: 20),
              _buildToggle("Invert Pitch", _invertPitch,
                  (val) => setState(() => _invertPitch = val)),
            ],
          )
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

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF639DF0),
        ),
      ],
    );
  }
}
