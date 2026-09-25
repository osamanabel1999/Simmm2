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

  final double? width;
  final double? height;

  @override
  _CabinPaSystemScreenState createState() => _CabinPaSystemScreenState();
}

class _CabinPaSystemScreenState extends State<CabinPaSystemScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences _prefs;

  String? _currentlyPlayingId;

  final List<Map<String, String>> _announcements = [
    {
      'id': 'pa_boarding',
      'title': 'WELCOME / BOARDING',
      'desc': 'Played during passenger boarding and welcome.'
    },
    {
      'id': 'pa_pushback',
      'title': 'PUSHBACK & ENGINE START',
      'desc': 'Fires before taxi, when pushing back.'
    },
    {
      'id': 'pa_taxi',
      'title': 'TAXI & SAFETY DEMO',
      'desc': 'Safety instructions during taxi to runway.'
    },
    {
      'id': 'pa_takeoff',
      'title': 'SEATS FOR TAKEOFF',
      'desc': 'Command for cabin crew to take their seats.'
    },
    {
      'id': 'pa_10k_climb',
      'title': 'PASSING 10,000 FT (CLIMB)',
      'desc': 'Seatbelts off, safe altitude reached.'
    },
    {
      'id': 'pa_cruise',
      'title': 'CRUISE / SERVICE',
      'desc': 'Reaching cruising altitude, service begins.'
    },
    {
      'id': 'pa_turbulence',
      'title': 'TURBULENCE (SEATBELTS ON)',
      'desc': 'Emergency announcement for turbulence.'
    },
    {
      'id': 'pa_tod',
      'title': 'TOP OF DESCENT (TOD)',
      'desc': 'Beginning of the descent phase.'
    },
    {
      'id': 'pa_10k_descent',
      'title': 'PASSING 10,000 FT (DESCENT)',
      'desc': 'Cabin preparation for landing.'
    },
    {
      'id': 'pa_landing_seats',
      'title': 'SEATS FOR LANDING',
      'desc': 'Final command for crew before touchdown.'
    },
    {
      'id': 'pa_after_landing',
      'title': 'AFTER LANDING',
      'desc': 'Welcome to destination announcement.'
    },
    {
      'id': 'pa_parking',
      'title': 'PARKING / DISARM DOORS',
      'desc': 'Arrived at the gate, engines off.'
    },
  ];

  Map<String, String?> _savedFiles = {};

  @override
  void initState() {
    super.initState();
    _initPrefs();
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
    try {
      // الحل هنا: استخدام FileType.custom يجبر الآيفون على فتح تطبيق الـ Files بدلاً من Apple Music
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'], // حصر الاختيار في ملفات الـ mp3 فقط
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
    } catch (e) {
      debugPrint("File Picker Error: $e");
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
    await _audioPlayer.stop();
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
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        color: Color(0xFF070B14),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // لضبط الهيدر على الشمال
                children: [
                  _buildHeader(),
                  const Divider(
                      color: Color(0xFF1E293B), thickness: 1, height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      itemCount: _announcements.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = _announcements[index];
                        final id = item['id']!;
                        final title = item['title']!;
                        final desc = item['desc']!;
                        final filePath = _savedFiles[id];
                        final isReady = filePath != null;
                        final isPlaying = _currentlyPlayingId == id;

                        return _buildPremiumRow(
                            id, title, desc, filePath, isReady, isPlaying);
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildHomeIndicator(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== [ تصميم شريط Home Indicator الخاص بنظام iOS ] ====
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

  // ==== [ تصميم الهيدر (بدون زرار Stop All) ] ====
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "PA SYSTEM CONTROL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "CABIN ANNOUNCEMENTS MANAGER",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ==== [ تصميم الصف الاحترافي لكل إعلان ] ====
  Widget _buildPremiumRow(String id, String title, String desc,
      String? filePath, bool isReady, bool isPlaying) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFF0F1e17) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying ? const Color(0xFF10B981) : const Color(0xFF1E293B),
          width: 1.5,
        ),
        boxShadow: [
          if (isPlaying)
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isReady
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: isReady
                              ? const Color(0xFF10B981)
                              : const Color(0xFF475569),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isReady
                                ? _getFileName(filePath!)
                                : "No audio file loaded (MP3 only)",
                            style: TextStyle(
                              color: isReady
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildActionButton(
                title: "Upload",
                icon: Icons.upload_file_rounded,
                color: const Color(0xFF3B82F6), // أزرق
                onTap: () => _pickFile(id),
                isOutlined: true,
              ),

              if (isReady)
                _buildActionButton(
                  title: "Delete",
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444), // أحمر
                  onTap: () => _deleteFile(id),
                  isOutlined: true,
                ),

              // الزرار الذكي (Play / Stop)
              _buildActionButton(
                title: isPlaying ? "Stop" : "Play",
                icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: isPlaying
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981), // أحمر لو شغال، أخضر لو واقف
                onTap: isReady
                    ? (isPlaying ? _stopAudio : () => _playAudio(id, filePath!))
                    : null,
                isOutlined: !isPlaying && !isReady,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==== [ دالة مساعدة لرسم الزراير ] ====
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isOutlined,
  }) {
    final bool isDisabled = onTap == null;
    final Color activeColor = isDisabled ? const Color(0xFF334155) : color;
    // لو الزرار شغال، النص والأيقونة هيكونوا أبيض عشان يظهروا بوضوح على الخلفية الملونة
    final Color textColor = isDisabled
        ? const Color(0xFF64748B)
        : (isOutlined ? color : Colors.white);
    final Color bgColor = isOutlined ? Colors.transparent : activeColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isDisabled ? const Color(0xFF334155) : activeColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
