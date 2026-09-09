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

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PilotScratchPad extends StatefulWidget {
  const PilotScratchPad({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _PilotScratchPadState createState() => _PilotScratchPadState();
}

class _PilotScratchPadState extends State<PilotScratchPad> {
  final TextEditingController _notesController = TextEditingController();
  List<Offset?> _points = [];

  final Color bgColor = const Color(0xFF1D2428);
  final Color panelColor = const Color(0xFF2A3136);
  final Color strokeColor = const Color(0xFF42C0FB);

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // إضافة هامة جداً لمنع تسريب الذاكرة (Memory Leak)
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? savedNotes = prefs.getString('pilot_notes');
      if (savedNotes != null) {
        _notesController.text = savedNotes;
      }

      String? savedPoints = prefs.getString('pilot_drawing');
      if (savedPoints != null) {
        List<dynamic> decoded = jsonDecode(savedPoints);
        setState(() {
          _points = decoded.map((p) {
            if (p == null) return null;
            return Offset(
                (p['dx'] as num).toDouble(), (p['dy'] as num).toDouble());
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  Future<void> _saveNotes(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pilot_notes', text);
  }

  Future<void> _saveDrawing() async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> encodablePoints = _points.map((p) {
      if (p == null) return null;
      return {'dx': p.dx, 'dy': p.dy};
    }).toList();
    await prefs.setString('pilot_drawing', jsonEncode(encodablePoints));
  }

  void _clearNotes() {
    _notesController.clear();
    _saveNotes('');
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
    _saveDrawing();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Typed Notes", _clearNotes),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _notesController,
                onChanged: _saveNotes,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText:
                      "Type clearances, squawk codes, or ATIS notes here...",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildHeader("Scribble Pad", _clearDrawing),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(null);
                      });
                      _saveDrawing();
                    },
                    child: CustomPaint(
                      painter:
                          ScribblePainter(points: _points, color: strokeColor),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, VoidCallback onClear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: onClear,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6))),
          child: const Text("Clear"),
        )
      ],
    );
  }
}

class ScribblePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  ScribblePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScribblePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
