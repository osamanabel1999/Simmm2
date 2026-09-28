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

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';

// --- ألوان EFB الاحترافية ---
const Color efbBg = Color(0xFF0B111A);
const Color efbCard = Color(0xFF101923);
const Color efbBorder = Color(0xFF26364D);
const Color efbTextMuted = Color(0xFF8B949E);
const Color efbAccent = Color(0xFF639DF0); // للكلمات المميزة والأيقونات
const Color efbButtonDark = Color(0xFF15335E); // أزرق غامق احترافي للأزرار
const Color efbWhite = Color(0xFFFFFFFF);

// --- ألوان Smart Text ---
const Color cDanger = Color(0xFFFF5252);
const Color cWarn = Color(0xFFFFD740);
const Color cWeather = Color(0xFF18FFFF);
const Color cGood = Color(0xFF69F0AE);

class AiDispatcherScreen extends StatefulWidget {
  const AiDispatcherScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<AiDispatcherScreen> createState() => _AiDispatcherScreenState();
}

class _AiDispatcherScreenState extends State<AiDispatcherScreen> {
  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();

  final FlutterEdgeTts _edgeTts = FlutterEdgeTts(voice: "en-US-GuyNeural");
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  String _errorMessage = "";

  String _rawHtmlBriefing = "";
  String _cleanAudioText = "";
  bool _isAudioReady = false;
  bool _isPlaying = false;

  final List<String> _loadingPhrases = [
    "Establishing Secure Link with AI Dispatcher...",
    "Fetching Live METAR & TAF...",
    "Scanning Global NOTAMs Database...",
    "Analyzing Route Restrictions...",
    "Generating Final Flight Release..."
  ];
  int _loadingIndex = 0;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _loadingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchBriefing() async {
    final origin = _originCtrl.text.trim().toUpperCase();
    final dest = _destCtrl.text.trim().toUpperCase();

    if (origin.isEmpty || dest.isEmpty) {
      _showError("Please enter Origin and Destination ICAO codes.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _rawHtmlBriefing = "";
      _isAudioReady = false;
      _isPlaying = false;
      _loadingIndex = 0;
    });

    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _loadingIndex = (_loadingIndex + 1) % _loadingPhrases.length;
      });
    });

    try {
      final url = Uri.parse(
          "https://data.skylinkapi.com/v3/briefing/flight?origin=$origin&destination=$dest&format=markdown");

      final response = await http.get(url, headers: {
        "x-api-key": "9B34BCD9-6203-4C53-B1A2-943612B8FAE6",
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _rawHtmlBriefing = data['briefing'];
        });
        _prepareAudioInBg();
      } else {
        _showError(
            "System Malfunction. Unable to retrieve briefing. Code: ${response.statusCode}");
      }
    } catch (e) {
      _showError(
          "Connection failed or system error occurred. Please check your network and try again.");
    } finally {
      _loadingTimer?.cancel();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String msg) {
    setState(() {
      _errorMessage = msg;
    });
  }

  Future<void> _prepareAudioInBg() async {
    try {
      _cleanAudioText = _rawHtmlBriefing
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll('Â°C', ' degrees Celsius')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      setState(() {
        _isAudioReady = true;
      });
    } catch (e) {
      debugPrint("Audio Init Error: $e");
    }
  }

  Future<void> _playAudioBriefing() async {
    if (!_isAudioReady || _cleanAudioText.isEmpty) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);

    try {
      final result = await _edgeTts.synthesize(_cleanAudioText);
      final base64Audio = base64Encode(result.audioBytes);
      final dataUrl = 'data:audio/mpeg;base64,$base64Audio';

      await _audioPlayer.play(UrlSource(dataUrl));

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (e) {
      debugPrint("Audio Play Error: $e");
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: efbBg,
      child: SafeArea(
        child: Column(
          children: [
            // الهيدر ثابت لا يتأثر بالسكرول
            _buildCompactHeader(),

            // زرار الصوت ثابت أيضاً يظهر فقط عند نجاح جلب الداتا
            if (_rawHtmlBriefing.isNotEmpty && !_isLoading)
              _buildStickyTransmitButton(),

            // المحتوى القابل للسكرول
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _rawHtmlBriefing.isNotEmpty
                          ? _buildBriefingContent()
                          : _buildEmptyState(),
            ),

            // إضافة مؤشر الرجوع (Home Indicator) هنا بناءً على طلبك
            _buildHomeIndicator(
              onTap: () {
                // يمكنك إضافة وظيفة الخروج أو الرجوع هنا (الوضع الافتراضي: إغلاق الشاشة)
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- هيدر البحث (تصميم مدمج واحترافي) ---
  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: efbCard,
        border: Border(bottom: BorderSide(color: efbBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildCompactTextField(_originCtrl, "ORIGIN (KJFK)")),
              const SizedBox(width: 12),
              Expanded(child: _buildCompactTextField(_destCtrl, "DEST (EGLL)")),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40, // زرار أنحف وأشيك
            child: ElevatedButton(
              onPressed: _isLoading ? null : _fetchBriefing,
              style: ElevatedButton.styleFrom(
                backgroundColor: efbButtonDark, // أزرق غامق احترافي
                foregroundColor: efbWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text("GENERATE RELEASE",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: ctrl,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
            color: efbWhite, fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: efbTextMuted, fontSize: 12),
          filled: true,
          fillColor: efbBg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: efbAccent, width: 1)),
        ),
      ),
    );
  }

  // --- زرار الصوت (ثابت تحت الهيدر) ---
  Widget _buildStickyTransmitButton() {
    return Container(
      width: double.infinity,
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: ElevatedButton.icon(
        onPressed: _isAudioReady ? _playAudioBriefing : null,
        icon: Icon(_isPlaying ? Icons.stop_circle : Icons.headset_mic,
            size: 20, color: efbWhite),
        label: Text(
          _isPlaying ? "STOP TRANSMISSION" : "TRANSMIT AUDIO",
          style: const TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isAudioReady ? efbButtonDark : efbBorder, // أزرق غامق
          foregroundColor: efbWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // --- شاشة التحميل ---
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(color: efbAccent, strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingPhrases[_loadingIndex],
              key: ValueKey<int>(_loadingIndex),
              style: const TextStyle(
                  color: efbAccent, fontSize: 14, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: cDanger, size: 50),
            const SizedBox(height: 16),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: efbWhite, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // --- الشاشة الافتتاحية الأنيقة ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined,
              size: 70, color: efbBorder.withOpacity(0.6)),
          const SizedBox(height: 20),
          const Text(
            "AI DISPATCHER READY",
            style: TextStyle(
                color: efbTextMuted,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter Origin and Destination ICAO codes\nto generate intelligent flight release.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: efbTextMuted.withOpacity(0.7),
                fontSize: 13,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- عرض الكروت ---
  Widget _buildBriefingContent() {
    List<String> sections = _rawHtmlBriefing.split('<h2>');
    sections.removeWhere((s) => s.trim().isEmpty);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        String section = sections[index];
        int endTagIndex = section.indexOf('</h2>');
        String title =
            endTagIndex != -1 ? section.substring(0, endTagIndex) : "Section";
        String content =
            endTagIndex != -1 ? section.substring(endTagIndex + 5) : section;

        return _buildDispatchCard(title, content);
      },
    );
  }

  Widget _buildDispatchCard(String title, String htmlContent) {
    String content = htmlContent
        .replaceAll('<h4>', '\n\n• ')
        .replaceAll('</h4>', '')
        .replaceAll('<li>', '\n✈️ ')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('Â°', '°');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: efbCard,
        borderRadius: BorderRadius.circular(8), // حواف أنعم
        border: Border.all(color: efbBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: efbAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const Divider(color: efbBorder, height: 20, thickness: 1),
          RichText(text: _colorSmartText(content)),
        ],
      ),
    );
  }

  // --- نظام التلوين الذكي ---
  TextSpan _colorSmartText(String text) {
    List<TextSpan> spans = [];
    RegExp wordRegex = RegExp(r"(\w+|[^\w\s]+|\s+)");
    Iterable<Match> matches = wordRegex.allMatches(text);

    for (Match m in matches) {
      String word = m.group(0)!;
      String lowerWord = word.toLowerCase();

      Color color = efbWhite;
      FontWeight weight = FontWeight.normal;

      if (lowerWord.contains('restriction') ||
          lowerWord.contains('out of service') ||
          lowerWord.contains('u/s') ||
          lowerWord.contains('closed')) {
        color = cDanger;
        weight = FontWeight.bold;
      } else if (lowerWord.contains('crane') ||
          lowerWord.contains('obstacle') ||
          lowerWord.contains('snow') ||
          lowerWord.contains('reduced')) {
        color = cWarn;
        weight = FontWeight.bold;
      } else if (lowerWord.contains('wind') ||
          lowerWord.contains('visibility') ||
          lowerWord.contains('knots') ||
          lowerWord.contains('°c')) {
        color = cWeather;
        weight = FontWeight.bold;
      } else if (lowerWord.contains('cavok') ||
          lowerWord.contains('good') ||
          lowerWord.contains('cleared')) {
        color = cGood;
        weight = FontWeight.bold;
      } else if (word.contains('✈️') || word.contains('•')) {
        color = efbAccent;
      }

      spans.add(TextSpan(
        text: word,
        style: TextStyle(
            color: color, fontSize: 14, fontWeight: weight, height: 1.5),
      ));
    }

    return TextSpan(children: spans);
  }

  // --- إضافة الودجيت المطلوبة (Home Indicator) بنفس التفاصيل تماماً ---
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
