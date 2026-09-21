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

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart'; // المكتبة المسؤولة عن إذاعة الصوت

// --- ألوان EFB الاحترافية (حسب طلبك) ---
const Color efbBg = Color(0xFF0B111A);
const Color efbCard = Color(0xFF101923);
const Color efbBorder = Color(0xFF26364D);
const Color efbTextMuted = Color(0xFF8B949E);
const Color efbAccent = Color(0xFF639DF0);
const Color efbWhite = Color(0xFFFFFFFF);

// --- ألوان Smart Text ---
const Color cDanger = Color(0xFFFF5252); // أحمر للقيود والأعطال
const Color cWarn = Color(0xFFFFD740); // أصفر للروافع والعوائق
const Color cWeather = Color(0xFF18FFFF); // سماوي للطقس
const Color cGood = Color(0xFF69F0AE); // أخضر للحالة الجيدة

class AiDispatcherScreen extends StatefulWidget {
  const AiDispatcherScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  // المتغيرات المطلوبة لمنصة البناء (FlutterFlow)
  final double? width;
  final double? height;

  @override
  State<AiDispatcherScreen> createState() => _AiDispatcherScreenState();
}

class _AiDispatcherScreenState extends State<AiDispatcherScreen> {
  final TextEditingController _originCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();

  // -- تعريف مكتبة جلب الصوت من مايكروسوفت --
  final FlutterEdgeTts _edgeTts = FlutterEdgeTts(voice: "en-US-GuyNeural");

  // -- تعريف مكتبة إذاعة الصوت الفعلي --
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  String _errorMessage = "";

  // داتا الـ API
  String _rawHtmlBriefing = "";

  // داتا الصوت
  String _cleanAudioText = "";
  bool _isAudioReady = false;
  bool _isPlaying = false;

  // تأثير التحميل الوهمي
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
    _audioPlayer.dispose(); // تأمين إغلاق مشغل الصوت
    super.dispose();
  }

  // --- 1. جلب الداتا من الـ API ---
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

    // تشغيل نصوص التحميل المتغيرة
    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _loadingIndex = (_loadingIndex + 1) % _loadingPhrases.length;
      });
    });

    try {
      final url = Uri.parse(
          "https://data.skylinkapi.com/v3/briefing/flight?origin=$origin&destination=$dest&format=markdown");

      // إزالة وقت الانتظار (Timeout) بالكامل، التطبيق سينتظر براحته
      final response = await http.get(url, headers: {
        "x-api-key": "9B34BCD9-6203-4C53-B1A2-943612B8FAE6",
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _rawHtmlBriefing = data['briefing'];
        });
        _prepareAudioInBg(); // تجهيز الصوت فوراً في الخلفية
      } else {
        _showError(
            "System Malfunction. Unable to retrieve briefing. Code: ${response.statusCode}");
      }
    } catch (e) {
      // رسالة خطأ عامة لأي مشكلة في الاتصال
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

  // --- 2. تجهيز الصوت في الخلفية (Pre-fetching) ---
  Future<void> _prepareAudioInBg() async {
    try {
      // تنظيف الـ HTML بالكامل عشان الصوت يقرأ كلام نضيف
      _cleanAudioText = _rawHtmlBriefing
          .replaceAll(RegExp(r'<[^>]*>'), ' ') // إزالة التاجز
          .replaceAll('Â°C', ' degrees Celsius') // تصليح رمز الحرارة
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'\s+'), ' '); // إزالة المسافات الزايدة

      setState(() {
        _isAudioReady = true; // جاهز للتشغيل فوراً لما اليوزر يدوس
      });
    } catch (e) {
      debugPrint("Audio Init Error: $e");
    }
  }

  // --- تشغيل وإيقاف الصوت ---
  Future<void> _playAudioBriefing() async {
    if (!_isAudioReady || _cleanAudioText.isEmpty) return;

    // لو الصوت شغال بالفعل واليوزر داس تاني، هنوقفه
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);

    try {
      // 1. أمر synthesize بيولد ملف الصوت كـ Bytes من مايكروسوفت
      final result = await _edgeTts.synthesize(_cleanAudioText);

      // 2. مشغل الصوت بيقرأ الـ Bytes دي ويذيعها في السماعة
      await _audioPlayer.play(BytesSource(result.audioBytes));

      // 3. مراقبة انتهاء الصوت عشان نرجع شكل الزرار لأصله أوتوماتيك
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (e) {
      debugPrint("Audio Play Error: $e");
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  // --- 3. تصميم واجهة الـ EFB ---
  @override
  Widget build(BuildContext context) {
    // التوافق مع الأيباد والموبايل
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isIpad = screenWidth > 600;

    // تغليف الصفحة بالـ width والـ height المطلوبة لمنصة البناء
    return Container(
      width: widget.width,
      height: widget.height,
      child: Scaffold(
        backgroundColor: efbBg,
        appBar: AppBar(
          backgroundColor: efbBg,
          elevation: 1,
          shadowColor: efbBorder,
          title: Row(
            children: [
              const Icon(Icons.flight_takeoff, color: efbAccent),
              const SizedBox(width: 10),
              Text("AI DISPATCHER",
                  style: TextStyle(
                      color: efbWhite,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: isIpad ? 22 : 18)),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              constraints:
                  const BoxConstraints(maxWidth: 800), // حماية شكل الأيباد
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchHeader(isIpad),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _errorMessage.isNotEmpty
                            ? _buildErrorState()
                            : _rawHtmlBriefing.isNotEmpty
                                ? _buildBriefingContent()
                                : _buildEmptyState(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- خانات البحث ---
  Widget _buildSearchHeader(bool isIpad) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: efbCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: efbBorder, width: 1.5),
      ),
      child: Flex(
        direction: isIpad ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(
              flex: isIpad ? 1 : 0,
              child: _buildTextField(_originCtrl, "Origin ICAO (e.g. KJFK)")),
          SizedBox(width: isIpad ? 16 : 0, height: isIpad ? 0 : 16),
          Expanded(
              flex: isIpad ? 1 : 0,
              child: _buildTextField(_destCtrl, "Dest ICAO (e.g. EGLL)")),
          SizedBox(width: isIpad ? 16 : 0, height: isIpad ? 0 : 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _fetchBriefing,
              style: ElevatedButton.styleFrom(
                backgroundColor: efbAccent,
                foregroundColor: efbWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("GENERATE RELEASE",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(color: efbWhite, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: efbTextMuted),
        filled: true,
        fillColor: efbBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: efbAccent)),
      ),
    );
  }

  // --- شاشة التحميل (الوهم النفسي) ---
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: efbAccent),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingPhrases[_loadingIndex],
              key: ValueKey<int>(_loadingIndex),
              style: const TextStyle(
                  color: efbAccent, fontSize: 16, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: cDanger, size: 60),
          const SizedBox(height: 16),
          Text(_errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: efbWhite, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Awaiting input parameters to generate AI dispatch release.",
          style: TextStyle(color: efbTextMuted, fontSize: 16)),
    );
  }

  // --- عرض التقرير النهائي وزرار الصوت ---
  Widget _buildBriefingContent() {
    // فصل الـ HTML باستخدام علامات h2 كفواصل للكروت
    List<String> sections = _rawHtmlBriefing.split('<h2>');
    sections.removeWhere((s) => s.trim().isEmpty);

    return Column(
      children: [
        // --- زرار الصوت الاحترافي ---
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAudioReady ? _playAudioBriefing : null,
            icon: Icon(_isPlaying ? Icons.stop_circle : Icons.headset_mic,
                color: efbBg),
            label: Text(
              _isPlaying
                  ? "STOP AUDIO TRANSMISSION"
                  : "TRANSMIT DISPATCH AUDIO",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAudioReady ? efbAccent : efbTextMuted,
              foregroundColor: efbBg,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),

        // --- كروت التقرير ---
        Expanded(
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              String section = sections[index];
              // استخراج العنوان من البلوك
              int endTagIndex = section.indexOf('</h2>');
              String title = endTagIndex != -1
                  ? section.substring(0, endTagIndex)
                  : "Section";
              String content = endTagIndex != -1
                  ? section.substring(endTagIndex + 5)
                  : section;

              return _buildDispatchCard(title, content);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchCard(String title, String htmlContent) {
    // تنظيف بسيط للأقواس المزعجة قبل التلوين
    String content = htmlContent
        .replaceAll('<h4>', '\n\n• ')
        .replaceAll('</h4>', '')
        .replaceAll('<li>', '\n✈️ ')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('Â°', '°'); // تصليح رمز الحرارة

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: efbCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: efbBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: efbAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const Divider(color: efbBorder, height: 20, thickness: 1),
          // استخدام نظام التلوين الذكي هنا
          RichText(text: _colorSmartText(content)),
        ],
      ),
    );
  }

  // --- 4. التلوين الذكي للكلمات (Smart Text Coloring) ---
  TextSpan _colorSmartText(String text) {
    List<TextSpan> spans = [];
    // تقسيم النص لكلمات مع الحفاظ على المسافات
    RegExp wordRegex = RegExp(r"(\w+|[^\w\s]+|\s+)");
    Iterable<Match> matches = wordRegex.allMatches(text);

    for (Match m in matches) {
      String word = m.group(0)!;
      String lowerWord = word.toLowerCase();

      Color color = efbWhite;
      FontWeight weight = FontWeight.normal;

      // أحمر (خطر)
      if (lowerWord.contains('restriction') ||
          lowerWord.contains('out of service') ||
          lowerWord.contains('u/s') ||
          lowerWord.contains('closed')) {
        color = cDanger;
        weight = FontWeight.bold;
      }
      // أصفر (تحذيرات عادية)
      else if (lowerWord.contains('crane') ||
          lowerWord.contains('obstacle') ||
          lowerWord.contains('snow') ||
          lowerWord.contains('reduced')) {
        color = cWarn;
        weight = FontWeight.bold;
      }
      // سماوي (بيانات الطقس)
      else if (lowerWord.contains('wind') ||
          lowerWord.contains('visibility') ||
          lowerWord.contains('knots') ||
          lowerWord.contains('°c')) {
        color = cWeather;
        weight = FontWeight.bold;
      }
      // أخضر (حالة جيدة)
      else if (lowerWord.contains('cavok') ||
          lowerWord.contains('good') ||
          lowerWord.contains('cleared')) {
        color = cGood;
        weight = FontWeight.bold;
      }
      // علامة الطيارة والمتبقي
      else if (word.contains('✈️') || word.contains('•')) {
        color = efbAccent;
      }

      spans.add(TextSpan(
        text: word,
        style: TextStyle(
            color: color, fontSize: 15, fontWeight: weight, height: 1.4),
      ));
    }

    return TextSpan(children: spans);
  }
}
