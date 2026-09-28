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

import 'dart:ui';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EfbBrowserScreen extends StatefulWidget {
  const EfbBrowserScreen({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _EfbBrowserScreenState createState() => _EfbBrowserScreenState();
}

// استخدام AutomaticKeepAliveClientMixin لمنع مسح المتصفح أو عمل Reload عند الانتقال لشاشة ثانية
class _EfbBrowserScreenState extends State<EfbBrowserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final WebViewController _controller;
  final TextEditingController _urlTextController = TextEditingController();

  double _loadingProgress = 0.0;
  bool _isLoading = true;
  String _currentUrl = 'https://webeye.ivao.aero'; // الموقع الافتراضي (IVAO)
  String _activePresetTitle = 'IVAO WEBEYE';

  // قائمة الاختصارات المعتمدة للطيران بعد التعديل
  final List<Map<String, String>> _aviationPresets = [
    {'title': 'IVAO WEBEYE', 'url': 'https://webeye.ivao.aero', 'icon': '📡'},
    {'title': 'VATSIM RADAR', 'url': 'https://map.vatsim.net', 'icon': '🌐'},
    {
      'title': 'SIMBRIEF',
      'url': 'https://www.simbrief.com/system/dispatch.php',
      'icon': '✈️'
    },
    {'title': 'SKYVECTOR', 'url': 'https://skyvector.com', 'icon': '🗺️'},
  ];

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _restoreLastSession();
  }

  // استرجاع آخر موقع كان مفتوحاً لفتحه مباشرة
  Future<void> _restoreLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('efb_browser_last_url');
    if (savedUrl != null && savedUrl.isNotEmpty && savedUrl != _currentUrl) {
      _loadTargetUrl(savedUrl);
    }
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101923))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
                _urlTextController.text = url;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
                _urlTextController.text = url;
              });
            }
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('efb_browser_last_url', url);
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  void _loadTargetUrl(String url) {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    _controller.loadRequest(Uri.parse(formattedUrl));
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _urlTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ضروري لعمل الـ KeepAlive

    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF101923),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. شريط التحكم العلوي والروابط (متجاوب للآيباد والموبايل)
                _buildControlBar(),

                // 2. شريط الاختصارات السريعة (Presets Bar)
                _buildPresetsBar(),

                // 3. مؤشر التحميل النحيف (Progress Bar)
                if (_isLoading)
                  LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: const Color(0xFF26364D),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF639DF0)),
                    minHeight: 2.5,
                  )
                else
                  Container(height: 1.5, color: const Color(0xFF26364D)),

                // 4. مساحة عرض الويب مع حفظ الحالة
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D141C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF26364D), width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.5),
                        child: KeyedSubtree(
                          key: const PageStorageKey('efb_browser_viewport'),
                          child: WebViewWidget(controller: _controller),
                        ),
                      ),
                    ),
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

  // ==== [ تصميم شريط التحكم العلوي ] ====
  Widget _buildControlBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 650;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // أزرار الملاحة (Back, Forward, Refresh)
              _buildNavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () async {
                  if (await _controller.canGoBack()) {
                    await _controller.goBack();
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  if (await _controller.canGoForward()) {
                    await _controller.goForward();
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.refresh_rounded,
                onTap: () => _controller.reload(),
              ),
              const SizedBox(width: 12),

              // حقل إدخال الرابط
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF162232),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF26364D), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.lock_outline_rounded,
                            size: 16, color: Color(0xFF639DF0)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _urlTextController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter URL or Search...',
                            hintStyle: TextStyle(
                                color: Color(0xFF8B949E), fontSize: 13),
                            isDense: true,
                          ),
                          onSubmitted: (value) => _loadTargetUrl(value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF639DF0), size: 18),
                        onPressed: () =>
                            _loadTargetUrl(_urlTextController.text),
                      ),
                    ],
                  ),
                ),
              ),

              if (isWide) ...[
                const SizedBox(width: 12),
                _buildActionButton(
                  title: 'CLEAR CACHE',
                  icon: Icons.cleaning_services_rounded,
                  onTap: () async {
                    await _controller.clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache Cleared'),
                        backgroundColor: Color(0xFF26364D),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  // ==== [ تصميم شريط المواقع السريعة (Presets) ] ====
  Widget _buildPresetsBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _aviationPresets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final preset = _aviationPresets[index];
          final bool isActive = _currentUrl.contains(preset['url']!) ||
              _activePresetTitle == preset['title'];

          return Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF639DF0).withOpacity(0.15)
                    : const Color(0xFF162232),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF639DF0)
                      : const Color(0xFF26364D),
                  width: 1.5,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activePresetTitle = preset['title']!;
                  });
                  _loadTargetUrl(preset['url']!);
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: const Color(0xFF639DF0).withOpacity(0.3),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset['icon']!,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        preset['title']!,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF639DF0)
                              : const Color(0xFF8B949E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==== [ أزرار الملاحة الدائرية ] ====
  Widget _buildNavButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF162232),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF26364D), width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: const Color(0xFF639DF0).withOpacity(0.3),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  // ==== [ زرار فرعي للإجراءات ] ====
  Widget _buildActionButton(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF162232),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF26364D), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B949E), size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
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
