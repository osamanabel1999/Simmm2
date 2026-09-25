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

import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class CabinPaSystemScreen extends StatefulWidget {
  const CabinPaSystemScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  // المتغيرات اللي FlutterFlow بيطلبها إجبارياً
  final double? width;
  final double? height;

  @override
  _CabinPaSystemScreenState createState() => _CabinPaSystemScreenState();
}

class _CabinPaSystemScreenState extends State<CabinPaSystemScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences _prefs;

  // ID للعنصر اللي شغال حالياً عشان ننوّر زرار الـ Play بتاعه
  String? _currentlyPlayingId;

  // القائمة الأساسية للمراحل الـ 12
  final List<Map<String, String>> _announcements = [
    {'id': 'pa_boarding', 'title': 'Welcome & Boarding'},
    {'id': 'pa_pushback', 'title': 'Pushback'},
    {'id': 'pa_taxi', 'title': 'Taxi & Safety Demo'},
    {'id': 'pa_takeoff', 'title': 'Seats for Takeoff'},
    {'id': 'pa_10k_climb', 'title': 'Passing 10,000 ft Climb'},
    {'id': 'pa_cruise', 'title': 'Cruise / Service'},
    {'id': 'pa_turbulence', 'title': 'Turbulence'},
    {'id': 'pa_tod', 'title': 'Top of Descent - TOD'},
    {'id': 'pa_10k_descent', 'title': 'Passing 10,000 ft Descent'},
    {'id': 'pa_landing_seats', 'title': 'Seats for Landing'},
    {'id': 'pa_after_landing', 'title': 'After Landing'},
    {'id': 'pa_parking', 'title': 'Parking'},
  ];

  // Map لحفظ مسارات الملفات المرفوعة
  Map<String, String?> _savedFiles = {};

  @override
  void initState() {
    super.initState();
    _initPrefs();

    // لما الصوت يخلص، نرجع حالة الزراير لطبيعتها
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        for (var item in _announcements) {
          _savedFiles[item['id']!] = _prefs.getString(item['id']!);
        }
      });
    }
  }

  Future<void> _pickFile(String id) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      await _prefs.setString(id, filePath);
      if (mounted) {
        setState(() {
          _savedFiles[id] = filePath;
        });
      }
    }
  }

  Future<void> _deleteFile(String id) async {
    if (_currentlyPlayingId == id) {
      await _audioPlayer.stop();
      _currentlyPlayingId = null;
    }
    await _prefs.remove(id);
    if (mounted) {
      setState(() {
        _savedFiles[id] = null;
      });
    }
  }

  Future<void> _playAudio(String id, String path) async {
    await _audioPlayer.stop(); // إيقاف أي صوت شغال حالياً
    if (mounted) {
      setState(() {
        _currentlyPlayingId = id;
      });
    }
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _currentlyPlayingId = null;
      });
    }
  }

  // استخراج اسم الفايل من المسار عشان نعرضه بشياكة
  String _getFileName(String path) {
    return path.split('/').last;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // دمج الـ width و height بتوع FlutterFlow في الحاوية الرئيسية
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF020617)
          ], // ألوان كحلي داكن جداً
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // عشان الجراديانت اللي ورا يظهر
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== [ تصميم الهيدر وزرار إيقاف الكل ] ====
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "CABIN PA SYSTEM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          InkWell(
            onTap: _stopAudio,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    "STOP ALL",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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

  // ==== [ تصميم الجريد المتجاوب (موبايل/آيباد) ] ====
  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent:
                500, // هيعرض كارتين في الآيباد وكارت في الموبايل
            mainAxisExtent: 140, // ارتفاع ثابت للكارت
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _announcements.length,
          itemBuilder: (context, index) {
            final item = _announcements[index];
            final id = item['id']!;
            final title = item['title']!;
            final filePath = _savedFiles[id];
            final isReady = filePath != null;
            final isPlaying = _currentlyPlayingId == id;

            return _buildGlassCard(id, title, filePath, isReady, isPlaying);
          },
        );
      },
    );
  }

  // ==== [ تصميم كارت الـ Glassmorphism الاحترافي ] ====
  Widget _buildGlassCard(
      String id, String title, String? filePath, bool isReady, bool isPlaying) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPlaying
                ? Colors.greenAccent.withOpacity(0.05)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? Colors.greenAccent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الصف الأول: العنوان وحالة الفايل
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isReady
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: isReady
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isReady
                                    ? "Ready: ${_getFileName(filePath!)}"
                                    : "No File Assigned",
                                style: TextStyle(
                                  color: isReady
                                      ? Colors.greenAccent.withOpacity(0.8)
                                      : Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // الصف الثاني: أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // زرار الرفع
                  IconButton(
                    icon: const Icon(Icons.folder_open, color: Colors.white70),
                    tooltip: "Upload MP3",
                    onPressed: () => _pickFile(id),
                  ),

                  // زرار المسح (يظهر فقط لو فيه فايل)
                  if (isReady)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white38),
                      tooltip: "Remove File",
                      onPressed: () => _deleteFile(id),
                    ),

                  const SizedBox(width: 8),

                  // زرار الإيقاف
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.stop, color: Colors.white54),
                      onPressed: isPlaying ? _stopAudio : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // زرار التشغيل
                  Container(
                    decoration: BoxDecoration(
                        color: isReady
                            ? (isPlaying
                                ? Colors.greenAccent.withOpacity(0.2)
                                : Colors.greenAccent.withOpacity(0.1))
                            : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isReady
                              ? Colors.greenAccent.withOpacity(0.5)
                              : Colors.transparent,
                        )),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.volume_up : Icons.play_arrow,
                        color: isReady ? Colors.greenAccent : Colors.white24,
                      ),
                      onPressed:
                          isReady ? () => _playAudio(id, filePath!) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
