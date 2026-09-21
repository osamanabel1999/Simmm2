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
      performanceMode: FaceDetectorMode.fast, // وضع سريع
    ),
  );

  bool _isTracking = false;
  bool _isProcessing = false;

  double _rawYaw = 0.0;
  double _rawPitch = 0.0;
  double _smoothedYaw = 0.0;
  double _smoothedPitch = 0.0;

  final double _smoothingFactor = 0.3;
  final double _multiplier = 2.5;

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
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
    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _rawYaw = 0.0;
      _rawPitch = 0.0;
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
        final face = faces.first;
        final newYaw = face.headEulerAngleY ?? 0.0;
        final newPitch = face.headEulerAngleX ?? 0.0;

        _smoothedYaw = (_smoothedYaw * (1 - _smoothingFactor)) +
            (newYaw * _smoothingFactor);
        _smoothedPitch = (_smoothedPitch * (1 - _smoothingFactor)) +
            (newPitch * _smoothingFactor);

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
    // استخدمنا الـ width والـ height بتوع FlutterFlow هنا
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF0B111A),
      child: Column(
        children: [
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isTracking ? Colors.red : const Color(0xFF639DF0),
                  ),
                  onPressed: _isTracking ? _stopTracking : _startTracking,
                  child: Text(_isTracking ? "Stop Tracking" : "Start Tracking",
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDataCard("RAW YAW", _rawYaw.toStringAsFixed(1)),
                _buildDataCard("SMOOTH YAW", _smoothedYaw.toStringAsFixed(1)),
                _buildDataCard("RAW PITCH", _rawPitch.toStringAsFixed(1)),
                _buildDataCard(
                    "SMOOTH PITCH", _smoothedPitch.toStringAsFixed(1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
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

                  final dotX = centerX -
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

                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: constraints.maxWidth,
                            height: 1,
                            color: Colors.white24),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: 1,
                            height: constraints.maxHeight,
                            color: Colors.white24),
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

  Widget _buildDataCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
