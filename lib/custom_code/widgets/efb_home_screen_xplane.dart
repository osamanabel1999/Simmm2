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

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class EfbHomeScreenXplane extends StatefulWidget {
  final double? width;
  final double? height;
  final String wallpaperUrl;
  final String iconAirportWx;
  final String iconWxCharts;
  final String iconNotams;
  final String iconScratchpad;
  final String iconSettings;
  final Future<dynamic> Function()? onExitAction;
  final Future<dynamic> Function()? onSettingsAction;
  final String simbriefUserId;
  const EfbHomeScreenXplane({
    Key? key,
    this.width,
    this.height,
    this.wallpaperUrl =
        'https://dummyimage.com/1024x768/0b111a/ffffff&text=Wallpaper',
    this.iconAirportWx = 'https://dummyimage.com/256x256/101923/639DF0&text=WX',
    this.iconWxCharts =
        'https://dummyimage.com/256x256/101923/639DF0&text=Charts',
    this.iconNotams =
        'https://dummyimage.com/256x256/101923/639DF0&text=NOTAMs',
    this.iconScratchpad =
        'https://dummyimage.com/256x256/101923/639DF0&text=Pad',
    this.iconSettings =
        'https://dummyimage.com/256x256/101923/639DF0&text=Settings',
    this.onExitAction,
    this.onSettingsAction,
    this.simbriefUserId = '',
  }) : super(key: key);
  @override
  State<EfbHomeScreenXplane> createState() => _EfbHomeScreenXplaneState();
}

class _EfbHomeScreenXplaneState extends State<EfbHomeScreenXplane>
    with SingleTickerProviderStateMixin {
  bool _isAppOpen = false;
  String _openedAppName = '';
  String get _currentTime {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  String get _currentDate {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}";
  }

  void _openApp(String appName) {
    setState(() {
      _openedAppName = appName;
      _isAppOpen = true;
    });
  }

  void _closeApp() {
    setState(() {
      _isAppOpen = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Springboard / Dock state
  // ---------------------------------------------------------------------------
  bool isLoadingOfp = false;
  Map<String, dynamic>? _simBriefOfp;
  String? _simBriefError;
  String? _simBriefMetar;
  String? _simBriefWind;
  String? _simBriefQnh;
  String? _simBriefTemperature;
  int _simBriefRequestSerial = 0;

  final List<String> _dockAppNames = <String>[];
  bool _dockLoaded = false;
  bool _isJiggling = false;
  bool _isEditMode = false;
  late final AnimationController _jiggleController;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
    );
    _loadDock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchSimBriefOfp();
      }
    });
  }

  @override
  void didUpdateWidget(covariant EfbHomeScreenXplane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simbriefUserId.trim() != widget.simbriefUserId.trim()) {
      _fetchSimBriefOfp();
    }
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  Future<void> _loadDock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('efb_home_screen_dock_v3');
      if (!mounted) return;
      setState(() {
        _dockAppNames
          ..clear()
          ..addAll(saved ??
              <String>[
                'Airport WX',
                'WX Charts',
                'NOTAMs',
                'Scratchpad',
              ]);
        _dockLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dockAppNames
          ..clear()
          ..addAll(<String>[
            'Airport WX',
            'WX Charts',
            'NOTAMs',
            'Scratchpad',
          ]);
        _dockLoaded = true;
      });
    }
  }

  Future<void> _persistDock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('efb_home_screen_dock_v3', _dockAppNames);
  }

  void _enterEditMode() {
    if (!mounted) return;
    if (!_isEditMode || !_isJiggling) {
      setState(() {
        _isEditMode = true;
        _isJiggling = true;
      });
    }
    if (!_jiggleController.isAnimating) {
      _jiggleController.repeat(reverse: true);
    }
    HapticFeedback.mediumImpact();
  }

  void _exitEditMode() {
    _jiggleController.stop();
    if (!mounted) return;
    if (_isEditMode || _isJiggling) {
      setState(() {
        _isEditMode = false;
        _isJiggling = false;
      });
    }
  }

  void _startJiggle() {
    _enterEditMode();
  }

  void _stopJiggle() {
    if (_isEditMode) return;
    _jiggleController.stop();
    if (!mounted) return;
    if (_isJiggling) {
      setState(() {
        _isJiggling = false;
      });
    }
  }

  int _maxDockApps(bool isTablet) => isTablet ? 6 : 4;

  void _addToDock(String appName, int maxDockApps, {int? targetIndex}) {
    if (_dockAppNames.contains(appName) ||
        _dockAppNames.length >= maxDockApps) {
      return;
    }

    final int insertAt = (targetIndex ?? _dockAppNames.length)
        .clamp(0, _dockAppNames.length)
        .toInt();
    setState(() {
      _dockAppNames.insert(insertAt, appName);
    });
    _persistDock();
    HapticFeedback.selectionClick();
  }

  void _removeFromDock(String appName) {
    if (!_dockAppNames.contains(appName)) return;
    setState(() {
      _dockAppNames.remove(appName);
    });
    _persistDock();
    HapticFeedback.selectionClick();
  }

  Future<void> _showRemoveFromDockActionSheet(String appName) async {
    final bool? confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Remove from Dock?'),
          message: Text(
            '$appName will be removed from the Dock but kept on your Home Screen.',
          ),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      _removeFromDock(appName);
    }
  }

  Future<void> _showAddToDockActionSheet(
    String appName,
    int maxDockApps,
  ) async {
    final bool? confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Add to Dock?'),
          message: Text('$appName will be added to your Dock.'),
          actions: [
            CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: const Text('Add'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      _addToDock(appName, maxDockApps);
    }
  }

  void _reorderDock(String appName, int targetIndex) {
    final int oldIndex = _dockAppNames.indexOf(appName);
    if (oldIndex < 0) return;

    int adjustedTarget = targetIndex;
    if (adjustedTarget > oldIndex) {
      adjustedTarget -= 1;
    }
    adjustedTarget = adjustedTarget.clamp(0, _dockAppNames.length - 1).toInt();

    if (oldIndex == adjustedTarget) return;

    setState(() {
      final String item = _dockAppNames.removeAt(oldIndex);
      _dockAppNames.insert(adjustedTarget, item);
    });
    _persistDock();
    HapticFeedback.selectionClick();
  }

  void _handleDockDrop(String appName, int targetIndex, int maxDockApps) {
    if (_dockAppNames.contains(appName)) {
      _reorderDock(appName, targetIndex);
    } else {
      _addToDock(
        appName,
        maxDockApps,
        targetIndex: targetIndex.clamp(0, _dockAppNames.length).toInt(),
      );
    }
  }

  String _appImageUrl(String appName) {
    switch (appName) {
      case 'Airport WX':
        return widget.iconAirportWx;
      case 'WX Charts':
        return widget.iconWxCharts;
      case 'NOTAMs':
        return widget.iconNotams;
      case 'Scratchpad':
        return widget.iconScratchpad;
      case 'Settings':
        return widget.iconSettings;
      default:
        return '';
    }
  }

  void _handleAppTap(String appName) {
    if (_isEditMode) return;
    if (appName == 'Settings') {
      if (widget.onSettingsAction != null) {
        widget.onSettingsAction!();
      }
      return;
    }
    _openApp(appName);
  }

  Future<void> _fetchSimBriefOfp() async {
    final String userId = widget.simbriefUserId.trim();
    final int requestSerial = ++_simBriefRequestSerial;

    if (userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoadingOfp = false;
        _simBriefOfp = null;
        _simBriefError = null;
        _simBriefMetar = null;
        _simBriefWind = null;
        _simBriefQnh = null;
        _simBriefTemperature = null;
      });
      return;
    }

    setState(() {
      isLoadingOfp = true;
      _simBriefError = null;
    });

    try {
      final Uri uri = Uri.parse(
        'https://www.simbrief.com/api/xml.fetcher.php'
        '?userid=${Uri.encodeQueryComponent(userId)}&json=1',
      );

      final http.Response response = await http.get(
        uri,
        headers: const <String, String>{
          'Accept': 'application/json,text/plain,*/*',
        },
      );

      if (!mounted || requestSerial != _simBriefRequestSerial) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          isLoadingOfp = false;
          _simBriefOfp = null;
          _simBriefError = 'HTTP ${response.statusCode}';
          _simBriefMetar = null;
          _simBriefWind = null;
          _simBriefQnh = null;
          _simBriefTemperature = null;
        });
        return;
      }

      if (response.body.trim().isEmpty) {
        setState(() {
          isLoadingOfp = false;
          _simBriefOfp = null;
          _simBriefError = null;
          _simBriefMetar = null;
          _simBriefWind = null;
          _simBriefQnh = null;
          _simBriefTemperature = null;
        });
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        setState(() {
          isLoadingOfp = false;
          _simBriefOfp = null;
          _simBriefError = 'Invalid OFP';
        });
        return;
      }

      final Map<String, dynamic> ofp =
          Map<String, dynamic>.from(decoded as Map<dynamic, dynamic>);

      final dynamic general = ofp['general'];
      final dynamic origin = ofp['origin'];
      final dynamic destination = ofp['destination'];
      final dynamic times = ofp['times'];
      final dynamic weights = ofp['weights'];
      final dynamic fuel = ofp['fuel'];

      final bool hasRequiredSections = general is Map &&
          origin is Map &&
          destination is Map &&
          times is Map &&
          weights is Map &&
          fuel is Map;

      if (!hasRequiredSections) {
        setState(() {
          isLoadingOfp = false;
          _simBriefOfp = null;
          _simBriefError = null;
          _simBriefMetar = null;
          _simBriefWind = null;
          _simBriefQnh = null;
          _simBriefTemperature = null;
        });
        return;
      }

      final Map<String, dynamic> originMap =
          Map<String, dynamic>.from(origin as Map<dynamic, dynamic>);
      final String? metar = _simBriefString(originMap['metar']);
      final _SimBriefWeatherData weather = _parseSimBriefMetar(metar);

      setState(() {
        isLoadingOfp = false;
        _simBriefOfp = ofp;
        _simBriefError = null;
        _simBriefMetar = metar;
        _simBriefWind = weather.wind;
        _simBriefQnh = weather.qnh;
        _simBriefTemperature = weather.temperature;
      });
    } on FormatException {
      if (!mounted || requestSerial != _simBriefRequestSerial) return;
      setState(() {
        isLoadingOfp = false;
        _simBriefOfp = null;
        _simBriefError = 'Invalid JSON';
        _simBriefMetar = null;
        _simBriefWind = null;
        _simBriefQnh = null;
        _simBriefTemperature = null;
      });
    } catch (e) {
      if (!mounted || requestSerial != _simBriefRequestSerial) return;
      setState(() {
        isLoadingOfp = false;
        _simBriefOfp = null;
        _simBriefError = e.toString();
        _simBriefMetar = null;
        _simBriefWind = null;
        _simBriefQnh = null;
        _simBriefTemperature = null;
      });
    }
  }

  String? _simBriefString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  dynamic _simBriefSection(String section, String key) {
    final dynamic raw = _simBriefOfp?[section];
    if (raw is! Map) return null;
    return raw[key];
  }

  String _simBriefText(
    String section,
    String key, [
    String fallback = '—',
  ]) {
    return _simBriefString(_simBriefSection(section, key)) ?? fallback;
  }

  String _formatSimBriefTime(dynamic raw) {
    final String value = _simBriefString(raw) ?? '—';
    if (value == '—') return value;

    if (RegExp(r'^\d{4}$').hasMatch(value)) {
      return '${value.substring(0, 2)}:${value.substring(2, 4)}Z';
    }

    if (RegExp(r'^\d{12}$').hasMatch(value)) {
      return '${value.substring(8, 10)}:${value.substring(10, 12)}Z';
    }

    final int? epoch = int.tryParse(value);
    if (epoch != null && value.length >= 9) {
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);
      final String hh = date.hour.toString().padLeft(2, '0');
      final String mm = date.minute.toString().padLeft(2, '0');
      return '$hh:$mm Z';
    }

    final RegExp hm = RegExp(r'\b(\d{2}):(\d{2})\b');
    final Match? match = hm.firstMatch(value);
    if (match != null) {
      return '${match.group(1)}:${match.group(2)}';
    }

    return value;
  }

  String _formatSimBriefWeight(String section, String key) {
    final String value = _simBriefText(section, key);
    if (value == '—') return value;

    final double? number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return value;

    return number % 1 == 0
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(1);
  }

  String _formatSimBriefRouteDistance() {
    final dynamic raw = _simBriefSection('general', 'route_distance') ??
        _simBriefSection('general', 'gc_distance') ??
        _simBriefSection('general', 'air_distance');
    final String value = _simBriefString(raw) ?? '—';
    if (value == '—') return value;

    final double? number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) {
      return value.toUpperCase().contains('NM') ? value : '$value NM';
    }

    return number % 1 == 0
        ? '${number.toStringAsFixed(0)} NM'
        : '${number.toStringAsFixed(1)} NM';
  }

  _SimBriefWeatherData _parseSimBriefMetar(String? metar) {
    if (metar == null || metar.trim().isEmpty) {
      return const _SimBriefWeatherData();
    }

    final String normalized = metar.toUpperCase();

    String? wind;
    final Match? windMatch = RegExp(
      r'\b(\d{3}|VRB)(\d{2,3})(?:G(\d{2,3}))?KT\b',
    ).firstMatch(normalized);
    if (windMatch != null) {
      final String direction = windMatch.group(1)!;
      final String speed = windMatch.group(2)!;
      final String? gust = windMatch.group(3);
      wind = gust == null
          ? '$direction° $speed KT'
          : '$direction° $speed KT G$gust';
    }

    String? qnh;
    final Match? qMatch = RegExp(r'\bQ(\d{4})\b').firstMatch(normalized);
    if (qMatch != null) {
      qnh = 'Q${qMatch.group(1)}';
    } else {
      final Match? altimeterMatch =
          RegExp(r'\bA(\d{4})\b').firstMatch(normalized);
      if (altimeterMatch != null) {
        final int raw = int.tryParse(altimeterMatch.group(1)!) ?? 0;
        final double inHg = raw / 100.0;
        final int hpa = (inHg * 33.8639).round();
        qnh = '${hpa} hPa';
      }
    }

    String? temperature;
    final Match? tempMatch =
        RegExp(r'\b(M?\d{2})/(M?\d{2})\b').firstMatch(normalized);
    if (tempMatch != null) {
      String normalizeTemp(String value) =>
          value.startsWith('M') ? '-${value.substring(1)}' : value;
      temperature =
          '${normalizeTemp(tempMatch.group(1)!)}° / ${normalizeTemp(tempMatch.group(2)!)}°';
    }

    return _SimBriefWeatherData(
      wind: wind,
      qnh: qnh,
      temperature: temperature,
    );
  }

  Widget _buildSpringboardIcon(
    String name,
    String imageUrl,
    double size, {
    bool showLabel = true,
  }) {
    final Widget image = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.225),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.225),
        child: imageUrl.trim().isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF101923),
                  child: Icon(
                    name == 'Settings'
                        ? Icons.settings_rounded
                        : Icons.flight_rounded,
                    color: const Color(0xFF639DF0),
                    size: size * 0.42,
                  ),
                ),
              )
            : Container(
                color: const Color(0xFF101923),
                child: Icon(
                  name == 'Settings'
                      ? Icons.settings_rounded
                      : Icons.flight_rounded,
                  color: const Color(0xFF639DF0),
                  size: size * 0.42,
                ),
              ),
      ),
    );

    if (!showLabel) {
      return SizedBox(
        width: size,
        height: size,
        child: image,
      );
    }

    return SizedBox(
      width: size + 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          image,
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapJigglingIcon(Widget child) {
    if (!_isEditMode && !_isJiggling) {
      return child;
    }

    return AnimatedBuilder(
      animation: _jiggleController,
      builder: (context, animatedChild) {
        final double turn =
            math.sin(_jiggleController.value * math.pi * 2) * 0.025;
        return Transform.rotate(
          angle: turn,
          child: animatedChild,
        );
      },
      child: child,
    );
  }

  Widget _buildDockAppIcon(String name, double size) {
    final Widget icon = _buildSpringboardIcon(
      name,
      _appImageUrl(name),
      size,
      showLabel: false,
    );

    final Widget tapTarget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleAppTap(name),
      child: icon,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _wrapJigglingIcon(tapTarget),
        if (_isEditMode)
          Positioned(
            left: -6,
            top: -6,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showRemoveFromDockActionSheet(name),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.08),
                    width: 0.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.minus,
                  color: Color(0xFF3A3A3C),
                  size: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDock({
    required bool isTablet,
    required int maxDockApps,
  }) {
    final double dockIconSize = isTablet ? 64.0 : 58.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24.0 : 12.0,
        8.0,
        isTablet ? 24.0 : 12.0,
        16.0,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 25,
              sigmaY: 25,
            ),
            child: Container(
              height: isTablet ? 90.0 : 84.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int index = 0;
                      index < _dockAppNames.length && index < maxDockApps;
                      index++)
                    DragTarget<String>(
                      onWillAccept: (data) => data != null,
                      onAccept: (data) => _handleDockDrop(
                        data,
                        index,
                        maxDockApps,
                      ),
                      builder: (context, candidateData, rejectedData) {
                        final String appName = _dockAppNames[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8.0 : 6.0,
                          ),
                          child: LongPressDraggable<String>(
                            data: appName,
                            onDragStarted: _startJiggle,
                            onDragEnd: (_) => _stopJiggle(),
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildDockAppIcon(
                                appName,
                                dockIconSize,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: _buildDockAppIcon(
                                appName,
                                dockIconSize,
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              transform: candidateData.isNotEmpty
                                  ? (Matrix4.identity()..scale(1.08))
                                  : Matrix4.identity(),
                              child: _buildDockAppIcon(
                                appName,
                                dockIconSize,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (_dockAppNames.length < maxDockApps)
                    DragTarget<String>(
                      onWillAccept: (data) =>
                          data != null && !_dockAppNames.contains(data),
                      onAccept: (data) => _handleDockDrop(
                          data, _dockAppNames.length, maxDockApps),
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: isTablet ? 54.0 : 48.0,
                          height: dockIconSize,
                          margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8.0 : 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty
                                ? Colors.white.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: candidateData.isNotEmpty
                              ? Icon(
                                  CupertinoIcons.arrow_down_to_line,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 22,
                                )
                              : const SizedBox.shrink(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Apple Style Ticket Widgets (Top)
  // =========================================================================
  Widget _buildPremiumTopWidgets(bool isTablet) {
    final String origin = _simBriefText('origin', 'icao_code', 'HECA');
    final String dest = _simBriefText('destination', 'icao_code', 'EGLL');
    final String schedOut =
        _formatSimBriefTime(_simBriefSection('times', 'sched_out'));
    final String schedIn =
        _formatSimBriefTime(_simBriefSection('times', 'sched_in'));
    final String distance = _formatSimBriefRouteDistance();
    final String zfw = _formatSimBriefWeight('weights', 'est_zfw');
    final String callsign = _simBriefText('general', 'atc_callsign', 'MSR701');

    final String metarOrigin = _simBriefText('origin', 'icao_code', 'HECA');
    final String temp = _simBriefTemperature ?? '28° / 16°';
    final String wind = _simBriefWind ?? '320° 12 KT';
    final String qnh = _simBriefQnh ?? '1014 hPa';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: [
          // 1. Flight Plan Ticket Widget
          Expanded(
            child: AspectRatio(
              aspectRatio: isTablet ? 2.0 : 1.0,
              child: _buildGlassWidgetCard(
                title: "SIMBRIEF FLIGHT",
                subTitle: callsign,
                isLoading: isLoadingOfp,
                hasError: _simBriefError != null,
                isEmpty: _simBriefOfp == null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(
                            origin,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(CupertinoIcons.airplane,
                                color: Color(0xFF639DF0), size: 18),
                          ),
                          Text(
                            dest,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "OUT: $schedOut  •  IN: $schedIn",
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF639DF0).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "DIST: $distance  •  ZFW: $zfw",
                          style: const TextStyle(
                              color: Color(0xFF639DF0),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 2. Weather Ticket Widget
          Expanded(
            child: AspectRatio(
              aspectRatio: isTablet ? 2.0 : 1.0,
              child: _buildGlassWidgetCard(
                title: "ORIGIN WX",
                subTitle: metarOrigin,
                isLoading: isLoadingOfp,
                hasError: _simBriefError != null,
                isEmpty: _simBriefOfp == null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              temp.split('/').first.trim() + "°",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const Text("⛅", style: TextStyle(fontSize: 26)),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "WIND: $wind",
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "QNH: $qnh",
                        style: const TextStyle(
                            color: Color(0xFF639DF0),
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassWidgetCard({
    required String title,
    required String subTitle,
    required Widget child,
    required bool isLoading,
    required bool hasError,
    required bool isEmpty,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101923).withOpacity(0.55),
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                  Text(subTitle,
                      style: const TextStyle(
                          color: Color(0xFF639DF0),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : (hasError || isEmpty)
                        ? const Center(
                            child: Text("No Data",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)))
                        : child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpringboardHomeArea(
    BoxConstraints constraints,
    bool isTablet,
  ) {
    final int crossAxisCount;
    if (!isTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = constraints.maxWidth >= constraints.maxHeight ? 6 : 5;
    }

    final double sidePadding = isTablet ? 24.0 : 16.0;
    final double gridIconSize = isTablet
        ? (constraints.maxWidth >= constraints.maxHeight ? 68 : 66)
        : 58;

    final List<_EfbHomeApp> apps = <_EfbHomeApp>[
      _EfbHomeApp(
        name: 'Airport WX',
        imageUrl: widget.iconAirportWx,
      ),
      _EfbHomeApp(
        name: 'WX Charts',
        imageUrl: widget.iconWxCharts,
      ),
      _EfbHomeApp(
        name: 'NOTAMs',
        imageUrl: widget.iconNotams,
      ),
      _EfbHomeApp(
        name: 'Scratchpad',
        imageUrl: widget.iconScratchpad,
      ),
      _EfbHomeApp(
        name: 'Settings',
        imageUrl: widget.iconSettings,
      ),
    ];

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: _enterEditMode,
              onTap: () {
                if (_isEditMode) _exitEditMode();
              },
              child: _wrapJigglingIcon(_buildPremiumTopWidgets(isTablet)),
            ),
            const SizedBox(height: 9),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: _enterEditMode,
                onTap: () {
                  if (_isEditMode) _exitEditMode();
                },
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  itemCount: apps.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isTablet ? 14.0 : 7.0,
                    mainAxisSpacing: isTablet ? 10.0 : 5.0,
                    childAspectRatio: isTablet ? 0.84 : 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final _EfbHomeApp app = apps[index];
                    final bool showAddBadge = _isEditMode &&
                        _dockAppNames.length < _maxDockApps(isTablet) &&
                        !_dockAppNames.contains(app.name);

                    final Widget appIcon = _wrapJigglingIcon(
                      _buildSpringboardIcon(
                        app.name,
                        app.imageUrl,
                        gridIconSize,
                        showLabel: true,
                      ),
                    );

                    final Widget tappable = GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleAppTap(app.name),
                      onLongPress: _enterEditMode,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topLeft,
                        children: [
                          appIcon,
                          if (showAddBadge)
                            Positioned(
                              left: -6,
                              top: -6,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _showAddToDockActionSheet(
                                  app.name,
                                  _maxDockApps(isTablet),
                                ),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E5EA),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.08),
                                      width: 0.6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.22),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    CupertinoIcons.plus,
                                    color: Color(0xFF3A3A3C),
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );

                    return LongPressDraggable<String>(
                      data: app.name,
                      onDragStarted: _startJiggle,
                      onDragEnd: (_) => _stopJiggle(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildDockAppIcon(
                          app.name,
                          isTablet ? 64.0 : 58.0,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.28,
                        child: tappable,
                      ),
                      child: tappable,
                    );
                  },
                ),
              ),
            ),
            if (_dockLoaded)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: _enterEditMode,
                child: _buildDock(
                  isTablet: isTablet,
                  maxDockApps: _maxDockApps(isTablet),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth >= 600;
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: _enterEditMode,
                    onTap: () {
                      if (_isEditMode && !_isAppOpen) {
                        _exitEditMode();
                      }
                    },
                    child: Image.network(
                      widget.wallpaperUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isAppOpen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: _isAppOpen,
                    child: SafeArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: _enterEditMode,
                        onTap: () {
                          if (_isEditMode) _exitEditMode();
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _currentTime,
                                        style: _statusBarStyle.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _currentDate,
                                        style: _statusBarStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(CupertinoIcons.wifi,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Text("100%", style: _statusBarStyle),
                                      const SizedBox(width: 4),
                                      const Icon(CupertinoIcons.battery_100,
                                          color: Colors.white, size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSpringboardHomeArea(
                              constraints,
                              isTablet,
                            ),
                            _buildHomeIndicator(
                              onTap: () {
                                if (widget.onExitAction != null) {
                                  widget.onExitAction!();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: _isAppOpen ? 0 : constraints.maxHeight,
                  bottom: _isAppOpen ? 0 : -constraints.maxHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: const Color(0xFF0B111A),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: switch (_openedAppName) {
                              'Airport WX' => AviationMetarTafDashboard(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                ),
                              'WX Charts' => AviationWeatherCharts(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                ),
                              'NOTAMs' => RealTimeNotamsViewer(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  initialIcao: 'KJFK',
                                ),
                              'Scratchpad' => EFBDigitalScratchpad(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                ),
                              _ => const SizedBox.shrink(),
                            },
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildHomeIndicator(onTap: _closeApp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  final TextStyle _statusBarStyle = const TextStyle(
    color: Colors.white,
    fontSize: 14,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
  );
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

  Widget _buildSettingsAppIcon(double size) {
    final String settingsImageUrl = widget.iconSettings.trim();
    return GestureDetector(
      onTap: () {
        if (widget.onSettingsAction != null) {
          widget.onSettingsAction!();
        }
      },
      child: SizedBox(
        width: size + 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.22),
                child: settingsImageUrl.isNotEmpty
                    ? Image.network(
                        settingsImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF101923),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: Color(0xFF639DF0),
                            size: 34,
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF101923),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Color(0xFF639DF0),
                          size: 34,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Settings",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(String name, String imageUrl, double size,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _openApp(name),
      child: SizedBox(
        width: size + 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.22),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF101923),
                    child: const Icon(Icons.flight, color: Color(0xFF639DF0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EfbHomeApp {
  const _EfbHomeApp({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;
}

class _SimBriefWeatherData {
  const _SimBriefWeatherData({
    this.wind,
    this.qnh,
    this.temperature,
  });

  final String? wind;
  final String? qnh;
  final String? temperature;
}

class AviationMetarTafDashboard extends StatefulWidget {
  const AviationMetarTafDashboard({
    Key? key,
    this.width,
    this.height,
    this.initialIcao = 'KJFK',
  }) : super(key: key);
  final double? width;
  final double? height;
  final String initialIcao;
  @override
  State<AviationMetarTafDashboard> createState() =>
      _AviationMetarTafDashboardState();
}

class _AviationMetarTafDashboardState extends State<AviationMetarTafDashboard> {
  static const Color _background = Color(0xFF0B111A);
  static const Color _surface = Color(0xFF101923);
  static const Color _border = Color(0xFF26364D);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _primary = Colors.white;
  final TextEditingController _icaoController = TextEditingController();
  Map<String, dynamic>? _metar;
  Map<String, dynamic>? _taf;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasSearched = false;
  int _requestSerial = 0;
  @override
  void initState() {
    super.initState();
    final initial = widget.initialIcao.trim().toUpperCase();
    _icaoController.text = initial.length == 4 ? initial : 'KJFK';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _search();
      }
    });
  }

  @override
  void dispose() {
    _icaoController.dispose();
    super.dispose();
  }

  String _normalizeIcao(String value) {
    return value.trim().toUpperCase();
  }

  bool _isValidIcao(String value) {
    return RegExp(r'^[A-Z0-9]{4}$').hasMatch(value);
  }

  dynamic _firstItem(dynamic decoded) {
    if (decoded is List && decoded.isNotEmpty) {
      return decoded.first;
    }
    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['data'];
      if (data is List && data.isNotEmpty) {
        return data.first;
      }
      if (decoded.containsKey('icaoId')) {
        return decoded;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getJsonObject(
    String endpoint,
    String icao,
  ) async {
    final uri = Uri.parse('$endpoint?format=json&ids=$icao');
    final response = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'FlutterFlow-Aviation-Weather-Dashboard',
      },
    );
    if (response.statusCode == 204) {
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'HTTP ${response.statusCode} from ${endpoint.contains('/metar') ? 'METAR' : 'TAF'}',
      );
    }
    if (response.body.trim().isEmpty) {
      return null;
    }
    final dynamic decoded = jsonDecode(response.body);
    final dynamic item = _firstItem(decoded);
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    return null;
  }

  Future<void> _search() async {
    final icao = _normalizeIcao(_icaoController.text);
    FocusScope.of(context).unfocus();
    if (!_isValidIcao(icao)) {
      setState(() {
        _errorMessage = 'Enter a valid 4-letter ICAO code.';
        _isLoading = false;
        _hasSearched = true;
      });
      return;
    }
    final int requestId = ++_requestSerial;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _metar = null;
      _taf = null;
    });
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _getJsonObject(
        'https://aviationweather.gov/api/data/metar',
        icao,
      ).then<dynamic>((value) => value).catchError((Object error) => error),
      _getJsonObject(
        'https://aviationweather.gov/api/data/taf',
        icao,
      ).then<dynamic>((value) => value).catchError((Object error) => error),
    ]);
    if (!mounted || requestId != _requestSerial) {
      return;
    }
    final dynamic metarResult = results[0];
    final dynamic tafResult = results[1];
    final Map<String, dynamic>? metar =
        metarResult is Map<String, dynamic> ? metarResult : null;
    final Map<String, dynamic>? taf =
        tafResult is Map<String, dynamic> ? tafResult : null;
    final List<String> errors = <String>[];
    if (metarResult is Object && metarResult is! Map<String, dynamic>) {
      errors.add('METAR could not be loaded.');
    }
    if (tafResult is Object && tafResult is! Map<String, dynamic>) {
      errors.add('TAF could not be loaded.');
    }
    setState(() {
      _metar = metar;
      _taf = taf;
      _isLoading = false;
      _errorMessage = errors.isEmpty ? null : errors.join(' ');
    });
  }

  dynamic _value(Map<String, dynamic>? data, String key) {
    if (data == null) return null;
    return data[key];
  }

  String _text(dynamic value, [String fallback = '—']) {
    if (value == null) return fallback;
    final String result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  double? _number(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _formatNumber(dynamic value, {int decimals = 0}) {
    final number = _number(value);
    if (number == null) return '—';
    if (decimals == 0) return number.round().toString();
    return number.toStringAsFixed(decimals);
  }

  String _formatWindDirection(dynamic value) {
    final number = _number(value);
    if (number == null) return 'VRB';
    return '${number.round().toString().padLeft(3, '0')}°';
  }

  String _formatWindSpeed(dynamic value) {
    final number = _number(value);
    if (number == null) return '—';
    return '${number.round()} KT';
  }

  String _formatVisibility(dynamic value) {
    final number = _number(value);
    if (number == null) return '—';
    if (number >= 10) return '${number.toStringAsFixed(0)} SM';
    if (number >= 1) return '${number.toStringAsFixed(1)} SM';
    return '${number.toStringAsFixed(2)} SM';
  }

  String _formatTemp(dynamic value) {
    final number = _number(value);
    if (number == null) return '—';
    return '${number.round()}°C';
  }

  String _formatAltimeter(dynamic value) {
    final number = _number(value);
    if (number == null) return '—';
    return '${number.toStringAsFixed(2)} inHg';
  }

  String _formatAirportName() {
    final name = _text(_value(_metar, 'name'), '');
    if (name.isNotEmpty) return name;
    final station = _text(_value(_metar, 'icaoId'), '');
    if (station.isNotEmpty) return station;
    return _normalizeIcao(_icaoController.text);
  }

  Color _flightCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'VFR':
        return const Color(0xFF32D583);
      case 'MVFR':
        return _accent;
      case 'IFR':
        return const Color(0xFFFF4D5E);
      case 'LIFR':
        return const Color(0xFFE65CFF);
      default:
        return _muted;
    }
  }

  IconData _cloudIcon(String cover) {
    switch (cover.toUpperCase()) {
      case 'FEW':
        return Icons.cloud_queue_rounded;
      case 'SCT':
        return Icons.cloud_rounded;
      case 'BKN':
        return Icons.cloud_circle_rounded;
      case 'OVC':
        return Icons.filter_drama_rounded;
      case 'CLR':
      case 'SKC':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _cloudColor(String cover) {
    switch (cover.toUpperCase()) {
      case 'FEW':
        return const Color(0xFF8DB7FF);
      case 'SCT':
        return const Color(0xFF73A5F7);
      case 'BKN':
        return const Color(0xFF639DF0);
      case 'OVC':
        return const Color(0xFF4C82D4);
      default:
        return _muted;
    }
  }

  String _formatUtcTime(dynamic raw) {
    if (raw == null) return '—';
    DateTime? date;
    if (raw is num) {
      final double value = raw.toDouble();
      if (value > 100000000000) {
        date = DateTime.fromMillisecondsSinceEpoch(
          value.round(),
          isUtc: true,
        );
      } else if (value > 1000000000) {
        date = DateTime.fromMillisecondsSinceEpoch(
          (value * 1000).round(),
          isUtc: true,
        );
      }
    } else {
      final String text = raw.toString().trim();
      final int? numeric = int.tryParse(text);
      if (numeric != null) {
        return _formatUtcTime(numeric);
      }
      final parsed = DateTime.tryParse(text);
      if (parsed != null) {
        date = parsed.toUtc();
      }
      if (date == null) {
        final digits = RegExp(r'\d{10,13}').firstMatch(text)?.group(0);
        if (digits != null) {
          date = DateTime.tryParse(
            digits.length == 13
                ? DateTime.fromMillisecondsSinceEpoch(
                    int.parse(digits),
                    isUtc: true,
                  ).toIso8601String()
                : DateTime.fromMillisecondsSinceEpoch(
                    int.parse(digits) * 1000,
                    isUtc: true,
                  ).toIso8601String(),
          );
        }
      }
    }
    if (date == null) return raw.toString();
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final mon = _monthName(date.month);
    return '$dd $mon ${date.year}, $hh:$mm UTC';
  }

  String _formatShortUtcTime(dynamic raw) {
    if (raw == null) return '—';
    DateTime? date;
    if (raw is num) {
      final double value = raw.toDouble();
      if (value > 100000000000) {
        date = DateTime.fromMillisecondsSinceEpoch(
          value.round(),
          isUtc: true,
        );
      } else if (value > 1000000000) {
        date = DateTime.fromMillisecondsSinceEpoch(
          (value * 1000).round(),
          isUtc: true,
        );
      }
    } else {
      final text = raw.toString().trim();
      final parsed = DateTime.tryParse(text);
      if (parsed != null) {
        date = parsed.toUtc();
      } else {
        final numeric = int.tryParse(text);
        if (numeric != null) {
          return _formatShortUtcTime(numeric);
        }
      }
    }
    if (date == null) return raw.toString();
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final mon = _monthName(date.month);
    return '$dd $mon • $hh:${mm}Z';
  }

  String _monthName(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  List<Map<String, dynamic>> _cloudsFrom(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    final result = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        result.add(Map<String, dynamic>.from(item));
      }
    }
    result.sort((a, b) {
      final aBase = _number(a['base']) ?? double.infinity;
      final bBase = _number(b['base']) ?? double.infinity;
      return aBase.compareTo(bBase);
    });
    return result;
  }

  String _cloudBase(dynamic base) {
    final number = _number(base);
    if (number == null) return '—';
    return '${number.round()} FT';
  }

  String _forecastWind(Map<String, dynamic> forecast) {
    final dir = _number(forecast['wdir']);
    final spd = _number(forecast['wspd']);
    final gst = _number(forecast['wgst']);
    if (dir == null && spd == null && gst == null) return '';
    final direction =
        dir == null ? 'VRB' : '${dir.round().toString().padLeft(3, '0')}°';
    final speed = spd == null ? '' : '${spd.round()} KT';
    final gust = gst == null ? '' : ' G${gst.round()}';
    return '$direction $speed$gust'.trim();
  }

  String _forecastVisibility(Map<String, dynamic> forecast) {
    final value = forecast['visib'];
    if (value == null) return '';
    return 'VIS ${_formatVisibility(value)}';
  }

  String _forecastClouds(Map<String, dynamic> forecast) {
    final clouds = _cloudsFrom(forecast['clouds']);
    if (clouds.isEmpty) return '';
    return clouds.map((cloud) {
      final cover = _text(cloud['cover'], '');
      final base = _number(cloud['base']);
      if (base == null) return cover;
      return '$cover ${base.round()}FT';
    }).join(' • ');
  }

  String _forecastChangeLabel(Map<String, dynamic> forecast) {
    final indicator = _text(forecast['changeIndicator'], '');
    if (indicator.isNotEmpty) return indicator;
    final probability = _number(forecast['probability']);
    if (probability != null) return 'PROB ${probability.round()}';
    return 'FORECAST';
  }

  List<Map<String, dynamic>> _forecasts() {
    final dynamic raw = _value(_taf, 'fcsts');
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Widget _sectionHeader(
    String title, {
    String? subtitle,
    IconData icon = Icons.dashboard_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _icaoController,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.search,
        maxLength: 4,
        style: const TextStyle(
          color: _primary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: 'ICAO CODE',
          hintStyle: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          prefixIcon: const Icon(
            Icons.flight_takeoff_rounded,
            color: _accent,
            size: 20,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              color: _accent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: _isLoading ? null : _search,
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => _search(),
      ),
    );
  }

  Widget _airportHeader() {
    final icao =
        _text(_value(_metar, 'icaoId'), _normalizeIcao(_icaoController.text));
    final category = _text(_value(_metar, 'fltCat'), 'N/A').toUpperCase();
    final categoryColor = _flightCategoryColor(category);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.airport_shuttle_rounded,
              color: _accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAirportName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  icao,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: categoryColor.withOpacity(0.65),
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: categoryColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    String? secondary,
    Color? accent,
  }) {
    final cardAccent = accent ?? _accent;
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: accent == null ? _border : cardAccent.withOpacity(0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cardAccent, size: 19),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (secondary != null && secondary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cardAccent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metarGrid() {
    final windSpeed = _number(_value(_metar, 'wspd'));
    final gust = _number(_value(_metar, 'wgst'));
    final bool windWarning =
        (windSpeed != null && windSpeed > 15) || gust != null;
    final windSecondary = gust != null
        ? 'GUST ${gust.round()} KT'
        : 'DIRECTION ${_formatWindDirection(_value(_metar, 'wdir'))}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoColumns = constraints.maxWidth >= 430;
        final cardWidth =
            twoColumns ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: _metricCard(
                icon: Icons.air_rounded,
                label: 'WIND',
                value: _formatWindSpeed(_value(_metar, 'wspd')),
                secondary: windSecondary,
                accent: windWarning ? const Color(0xFFFF8A3D) : null,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _metricCard(
                icon: Icons.visibility_rounded,
                label: 'VISIBILITY',
                value: _formatVisibility(_value(_metar, 'visib')),
                secondary: 'STATUTE MILES',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _metricCard(
                icon: Icons.thermostat_rounded,
                label: 'TEMP / DEW',
                value: _formatTemp(_value(_metar, 'temp')),
                secondary: 'DEW ${_formatTemp(_value(_metar, 'dewp'))}',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _metricCard(
                icon: Icons.speed_rounded,
                label: 'ALTIMETER',
                value: _formatAltimeter(_value(_metar, 'altim')),
                secondary: 'PRESSURE SETTING',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cloudVisualization() {
    final clouds = _cloudsFrom(_value(_metar, 'clouds'));
    if (clouds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _border),
        ),
        child: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: _muted, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No cloud layers reported.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < clouds.length; i++)
            _cloudRow(
              clouds[i],
              isLast: i == clouds.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _cloudRow(
    Map<String, dynamic> cloud, {
    required bool isLast,
  }) {
    final cover = _text(cloud['cover'], '—').toUpperCase();
    final color = _cloudColor(cover);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Icon(
                    _cloudIcon(cover),
                    color: color,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: _border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 11,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cover,
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CLOUD LAYER',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _cloudBase(cloud['base']),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

  Widget _forecastTimeline() {
    final forecasts = _forecasts();
    if (forecasts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _border),
        ),
        child: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: _muted, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No TAF forecast periods are available.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 7),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < forecasts.length; i++)
            _forecastItem(
              forecasts[i],
              isLast: i == forecasts.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _forecastItem(
    Map<String, dynamic> forecast, {
    required bool isLast,
  }) {
    final wind = _forecastWind(forecast);
    final visibility = _forecastVisibility(forecast);
    final clouds = _forecastClouds(forecast);
    final change = _forecastChangeLabel(forecast);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: _border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 10 : 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          change,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        _formatShortUtcTime(forecast['timeFrom']),
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatShortUtcTime(forecast['timeFrom'])}  →  ${_formatShortUtcTime(forecast['timeTo'])}',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (wind.isNotEmpty)
                        _forecastChip(
                          Icons.air_rounded,
                          wind,
                        ),
                      if (visibility.isNotEmpty)
                        _forecastChip(
                          Icons.visibility_rounded,
                          visibility,
                        ),
                      if (clouds.isNotEmpty)
                        _forecastChip(
                          Icons.cloud_rounded,
                          clouds,
                        ),
                      if (_text(forecast['wxString'], '').isNotEmpty)
                        _forecastChip(
                          Icons.thunderstorm_outlined,
                          _text(forecast['wxString']),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastChip(IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rawTicket({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final hasValue = value.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 8),
            child: Row(
              children: [
                Icon(icon, color: _accent, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy $title',
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  onPressed: hasValue ? () => _copyRaw(title, value) : null,
                  icon: Icon(
                    Icons.copy_rounded,
                    color: hasValue ? _accent : _muted,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border.withOpacity(0.8)),
            ),
            child: SelectableText(
              hasValue ? value : 'No raw data available.',
              style: TextStyle(
                color: hasValue ? _primary : _muted,
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyRaw(String title, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: _accent,
                size: 18,
              ),
              const SizedBox(width: 9),
              Text(
                '$title copied!',
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _border),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _loadingView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
          SizedBox(height: 13),
          Text(
            'LOADING METAR + TAF',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    if (_errorMessage == null || _errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFFF4D5E).withOpacity(0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF4D5E),
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: _primary,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: _muted,
            size: 34,
          ),
          SizedBox(height: 12),
          Text(
            'NO WEATHER DATA',
            style: TextStyle(
              color: _primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'No recent METAR or TAF was returned for this ICAO.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final rawMetar = _text(_value(_metar, 'rawOb'), '');
    final rawTaf = _text(
      _value(_taf, 'rawTAF'),
      _text(_value(_taf, 'rawTaf'), ''),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _airportHeader(),
        _sectionHeader(
          'METAR QUICK LOOK',
          subtitle: 'CURRENT OBSERVATION',
          icon: Icons.speed_outlined,
        ),
        _metarGrid(),
        _sectionHeader(
          'CLOUD PROFILE',
          subtitle: 'LOWEST TO HIGHEST REPORTED LAYER',
          icon: Icons.cloud_outlined,
        ),
        _cloudVisualization(),
        _sectionHeader(
          'TAF FORECAST',
          subtitle: _text(
            _value(_taf, 'rawTAF'),
            'TERMINAL AERODROME FORECAST',
          ).isEmpty
              ? 'TERMINAL AERODROME FORECAST'
              : 'TERMINAL AERODROME FORECAST',
          icon: Icons.timeline_rounded,
        ),
        _forecastTimeline(),
        _sectionHeader(
          'RAW WEATHER TICKETS',
          subtitle: 'ORIGINAL AVIATION WEATHER REPORTS',
          icon: Icons.receipt_long_outlined,
        ),
        _rawTicket(
          title: 'RAW METAR',
          value: rawMetar,
          icon: Icons.cloud_done_outlined,
        ),
        _rawTicket(
          title: 'RAW TAF',
          value: rawTaf,
          icon: Icons.description_outlined,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _searchBar(),
          _errorView(),
          if (_isLoading)
            _loadingView()
          else if (_metar == null && _taf == null)
            _emptyView()
          else
            _dashboard(),
        ],
      ),
    );
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: _background,
        child: Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: _background,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _accent,
                  secondary: _accent,
                  surface: _surface,
                ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: _surface,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class RealTimeNotamsViewer extends StatefulWidget {
  const RealTimeNotamsViewer({
    Key? key,
    this.width,
    this.height,
    required this.initialIcao,
  }) : super(key: key);
  final double? width;
  final double? height;
  final String initialIcao;
  @override
  State<RealTimeNotamsViewer> createState() => _RealTimeNotamsViewerState();
}

class _RealTimeNotamsViewerState extends State<RealTimeNotamsViewer> {
  static const Color backgroundColor = Color(0xFF0B111A);
  static const Color cardColor = Color(0xFF101923);
  static const Color borderColor = Color(0xFF26364D);
  static const Color inactiveColor = Color(0xFF8B949E);
  static const Color accentColor = Color(0xFF639DF0);
  static const Color primaryTextColor = Colors.white;
  static const Color activeGreen = Color(0xFF35D07F);
  static const Color inactiveRed = Color(0xFFFF5C5C);
  static const String _apiKey = '9B34BCD9-6203-4C53-B1A2-943612B8FAE6';
  static const String _baseUrl = 'https://data.skylinkapi.com/v3.1/notams/';
  final TextEditingController _icaoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'ALL';
  List<Map<String, dynamic>> _notams = <Map<String, dynamic>>[];
  int _simBriefRequestSerial = 0;
  @override
  void initState() {
    super.initState();
    final String supplied = widget.initialIcao.trim().toUpperCase();
    _icaoController.text = supplied.isEmpty ? 'KJFK' : supplied;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchNotams();
      }
    });
  }

  @override
  void dispose() {
    _icaoController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotams() async {
    final int requestSerial = ++_simBriefRequestSerial;
    final String icao = _icaoController.text.trim().toUpperCase();
    if (!_isValidIcao(icao)) {
      setState(() {
        _errorMessage = 'Enter a valid 4-letter ICAO code.';
        _notams = <Map<String, dynamic>>[];
        _isLoading = false;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedFilter = 'ALL';
    });
    try {
      final Uri uri = Uri.parse('$_baseUrl$icao');
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'x-api-key': _apiKey,
          'Accept': 'application/json',
        },
      );
      if (!mounted) return;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'Unable to load NOTAMs (${response.statusCode}).';
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final dynamic apiMessage =
                decoded['message'] ?? decoded['error'] ?? decoded['detail'];
            if (apiMessage != null && apiMessage.toString().trim().isNotEmpty) {
              message = apiMessage.toString().trim();
            }
          }
        } catch (_) {}
        setState(() {
          _isLoading = false;
          _notams = <Map<String, dynamic>>[];
          _errorMessage = message;
        });
        return;
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _isLoading = false;
          _notams = <Map<String, dynamic>>[];
          _errorMessage = 'The NOTAM service returned an invalid response.';
        });
        return;
      }
      final dynamic rawNotams = decoded['notams'];
      final List<Map<String, dynamic>> parsed = <Map<String, dynamic>>[];
      if (rawNotams is List) {
        for (final dynamic item in rawNotams) {
          if (item is Map) {
            parsed.add(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            );
          }
        }
      }
      setState(() {
        _isLoading = false;
        _notams = parsed;
        _errorMessage = null;
      });
    } on FormatException {
      if (!mounted || requestSerial != _simBriefRequestSerial) return;
      setState(() {
        _isLoading = false;
        _notams = <Map<String, dynamic>>[];
        _errorMessage = 'The NOTAM service returned invalid JSON data.';
      });
    } catch (e) {
      if (!mounted || requestSerial != _simBriefRequestSerial) return;
      setState(() {
        _isLoading = false;
        _notams = <Map<String, dynamic>>[];
        _errorMessage =
            'Network error. Please check your connection and try again.';
      });
    }
  }

  bool _isValidIcao(String value) {
    return RegExp(r'^[A-Z]{4}$').hasMatch(value);
  }

  List<Map<String, dynamic>> get _filteredNotams {
    if (_selectedFilter == 'ALL') {
      return List<Map<String, dynamic>>.from(_notams);
    }
    return _notams.where((Map<String, dynamic> notam) {
      final String scope = (notam['scope'] ?? '').toString().toUpperCase();
      final String type = (notam['type'] ?? '').toString().toUpperCase();
      switch (_selectedFilter) {
        case 'AERODROME':
          return scope == 'AERODROME' || type == 'AERODROME';
        case 'NAV':
          return scope == 'NAV' || scope == 'NAVIGATION' || type == 'NAV';
        case 'OBSTACLE':
          return scope == 'OBSTACLE' || type == 'OBSTACLE';
        default:
          return true;
      }
    }).toList();
  }

  String _formatNotamDate(dynamic value) {
    final String raw = value?.toString().trim() ?? '';
    if (raw.length < 12) {
      return raw.isEmpty ? '—' : raw;
    }
    final String digits = raw.substring(0, 12);
    if (!RegExp(r'^\d{12}$').hasMatch(digits)) {
      return raw;
    }
    try {
      final int year = int.parse(digits.substring(0, 4));
      final int month = int.parse(digits.substring(4, 6));
      final int day = int.parse(digits.substring(6, 8));
      final int hour = int.parse(digits.substring(8, 10));
      final int minute = int.parse(digits.substring(10, 12));
      final DateTime date = DateTime.utc(year, month, day, hour, minute);
      if (date.year != year || date.month != month || date.day != day) {
        return raw;
      }
      const List<String> months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} '
          '${date.year}, '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')} UTC';
    } catch (_) {
      return raw;
    }
  }

  String _statusFor(Map<String, dynamic> notam) {
    final String status =
        (notam['status'] ?? '').toString().trim().toUpperCase();
    if (status.isEmpty) return 'UNKNOWN';
    return status;
  }

  bool _isActive(Map<String, dynamic> notam) {
    return _statusFor(notam) == 'ACTIVE';
  }

  Future<void> _copyRaw(String raw) async {
    await Clipboard.setData(ClipboardData(text: raw));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Raw NOTAM copied!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'ICAO',
      hintStyle: const TextStyle(
        color: inactiveColor,
        fontSize: 14,
      ),
      filled: true,
      fillColor: cardColor,
      prefixIcon: const Icon(
        Icons.flight_takeoff_rounded,
        color: accentColor,
        size: 21,
      ),
      suffixIcon: IconButton(
        onPressed: _isLoading ? null : _fetchNotams,
        tooltip: 'Search NOTAMs',
        icon: const Icon(
          Icons.search_rounded,
          color: accentColor,
          size: 22,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: accentColor,
          width: 1.2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _icaoController,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            maxLength: 4,
            onSubmitted: (_) => _fetchNotams(),
            style: const TextStyle(
              color: primaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
            decoration: _searchDecoration().copyWith(
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool selected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : inactiveColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        selected: selected,
        onSelected: (bool valueSelected) {
          if (!valueSelected) return;
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: cardColor,
        selectedColor: accentColor,
        disabledColor: cardColor,
        side: BorderSide(
          color: selected ? accentColor : borderColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 5,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          _buildFilterChip('All', 'ALL'),
          _buildFilterChip('Aerodrome', 'AERODROME'),
          _buildFilterChip('Nav', 'NAV'),
          _buildFilterChip('Obstacle', 'OBSTACLE'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: accentColor,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'LOADING NOTAMS',
            style: TextStyle(
              color: inactiveColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: inactiveColor,
                size: 27,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'UNABLE TO LOAD NOTAMS',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: inactiveColor,
                fontSize: 11,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _fetchNotams,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text('RETRY'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool filterProducedEmpty =
        _notams.isNotEmpty && _filteredNotams.isEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: inactiveColor,
                size: 27,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              filterProducedEmpty ? 'NO MATCHING NOTAMS' : 'NO ACTIVE NOTAMS',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              filterProducedEmpty
                  ? 'No NOTAMs match the selected filter.'
                  : 'No NOTAMs are currently available for ${_icaoController.text.trim().toUpperCase()}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: inactiveColor,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: inactiveColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.45,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: primaryTextColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool active = status == 'ACTIVE';
    final Color color = active ? activeGreen : inactiveRed;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.38)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.65,
        ),
      ),
    );
  }

  Widget _buildScopeTag(String scope) {
    final String display = scope.isEmpty ? 'UNKNOWN' : scope;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        display,
        style: const TextStyle(
          color: inactiveColor,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
    );
  }

  Widget _buildNotamCard(Map<String, dynamic> notam) {
    final String id = (notam['notam_id'] ?? 'UNKNOWN NOTAM').toString();
    final String status = _statusFor(notam);
    final String scope = (notam['scope'] ?? '').toString().toUpperCase();
    final String effective = _formatNotamDate(notam['effective']);
    final String expiration = _formatNotamDate(notam['expiration']);
    final String body = (notam['body'] ?? '').toString().trim();
    final String raw = (notam['raw'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: accentColor.withOpacity(0.06),
          highlightColor: accentColor.withOpacity(0.04),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(13, 9, 9, 9),
          childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
          collapsedIconColor: inactiveColor,
          iconColor: accentColor,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: <Widget>[
                    _buildScopeTag(scope),
                    if ((notam['type'] ?? '').toString().trim().isNotEmpty)
                      _buildScopeTag(
                        'TYPE ${(notam['type'] ?? '').toString().toUpperCase()}',
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  label: 'EFFECTIVE',
                  value: effective,
                ),
                _buildInfoRow(
                  label: 'EXPIRATION',
                  value: expiration,
                ),
                const SizedBox(height: 2),
                Text(
                  body.isEmpty ? 'No NOTAM body available.' : body,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          children: <Widget>[
            if (raw.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: borderColor),
                ),
                child: const Text(
                  'RAW NOTAM DATA NOT AVAILABLE',
                  style: TextStyle(
                    color: inactiveColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(11, 10, 7, 10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'RAW',
                            style: TextStyle(
                              color: inactiveColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyRaw(raw),
                          tooltip: 'Copy raw NOTAM',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      raw,
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 10,
                        height: 1.45,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    final List<Map<String, dynamic>> visible = _filteredNotams;
    if (visible.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      physics: const BouncingScrollPhysics(),
      itemCount: visible.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildNotamCard(visible[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildFilters(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EFBDigitalScratchpad extends StatefulWidget {
  const EFBDigitalScratchpad({
    Key? key,
    this.width,
    this.height,
    this.initialPage = 0,
  }) : super(key: key);
  final double? width;
  final double? height;
  final int initialPage;
  @override
  State<EFBDigitalScratchpad> createState() => _EFBDigitalScratchpadState();
}

class _EFBDigitalScratchpadState extends State<EFBDigitalScratchpad> {
  static const Color _background = Color(0xFF0B111A);
  static const Color _surface = Color(0xFF101923);
  static const Color _border = Color(0xFF26364D);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _accent = Color(0xFF639DF0);
  static const List<Color> _penColors = <Color>[
    Colors.white,
    Color(0xFFFF4D5E),
    Color(0xFF32D583),
    Color(0xFF639DF0),
    Color(0xFFFFD166),
    Color(0xFFE65CFF),
  ];
  static const List<String> _pageNames = <String>[
    'TAKEOFF',
    'LANDING',
    'HOLDING',
    'CRAFT',
  ];
  static const String _storageKey = 'efb_digital_scratchpad_v1';
  late int _currentPage;
  late final List<List<_ScratchStroke>> _strokes;
  late final List<List<_ScratchStroke>> _redo;
  Color _penColor = Colors.white;
  double _penWidth = 2.7;
  _ScratchStroke? _activeStroke;
  bool _loading = true;
  bool _saving = false;
  bool _saveAgain = false;
  List<_ScratchStroke> get _pageStrokes => _strokes[_currentPage];
  List<_ScratchStroke> get _pageRedo => _redo[_currentPage];
  @override
  void initState() {
    super.initState();
    final int requested = widget.initialPage;
    _currentPage = requested.clamp(0, 3);
    _strokes = List<List<_ScratchStroke>>.generate(
      4,
      (_) => <_ScratchStroke>[],
    );
    _redo = List<List<_ScratchStroke>>.generate(
      4,
      (_) => <_ScratchStroke>[],
    );
    _restore();
  }

  Future<void> _restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map) {
          final dynamic pages = decoded['pages'];
          if (pages is List) {
            final int count = math.min(4, pages.length);
            for (int i = 0; i < count; i++) {
              final dynamic page = pages[i];
              if (page is List) {
                final List<_ScratchStroke> restored = <_ScratchStroke>[];
                for (final dynamic item in page) {
                  final _ScratchStroke? stroke = _ScratchStroke.fromJson(item);
                  if (stroke != null && stroke.points.isNotEmpty) {
                    restored.add(stroke);
                  }
                }
                _strokes[i] = restored;
              }
            }
          }
          final dynamic color = decoded['penColor'];
          if (color is num) {
            final Color candidate = Color(color.toInt());
            if (_penColors.any(
              (Color c) => c.value == candidate.value,
            )) {
              _penColor = candidate;
            }
          }
          final dynamic width = decoded['penWidth'];
          if (width is num && width > 0 && width <= 20) {
            _penWidth = width.toDouble();
          }
        }
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) {
      _saveAgain = true;
      return;
    }
    _saving = true;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = <String, dynamic>{
        'version': 1,
        'penColor': _penColor.value,
        'penWidth': _penWidth,
        'pages': _strokes
            .map(
              (List<_ScratchStroke> page) => page
                  .map(
                    (_ScratchStroke stroke) => stroke.toJson(),
                  )
                  .toList(),
            )
            .toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {
    } finally {
      _saving = false;
      if (_saveAgain) {
        _saveAgain = false;
        await _save();
      }
    }
  }

  Offset _normalized(Offset p, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return Offset.zero;
    }
    return Offset(
      (p.dx / size.width).clamp(0.0, 1.0),
      (p.dy / size.height).clamp(0.0, 1.0),
    );
  }

  void _startStroke(DragStartDetails details, Size size) {
    if (_loading) return;
    setState(() {
      _activeStroke = _ScratchStroke(
        color: _penColor,
        width: _penWidth,
        points: <Offset>[
          _normalized(details.localPosition, size),
        ],
      );
    });
  }

  void _updateStroke(DragUpdateDetails details, Size size) {
    final _ScratchStroke? stroke = _activeStroke;
    if (stroke == null) return;
    final Offset next = _normalized(details.localPosition, size);
    if (stroke.points.isNotEmpty) {
      final Offset last = stroke.points.last;
      final double dx = next.dx - last.dx;
      final double dy = next.dy - last.dy;
      if ((dx * dx + dy * dy) < 0.0000008) {
        return;
      }
    }
    setState(() {
      stroke.points.add(next);
    });
  }

  void _finishStroke() {
    final _ScratchStroke? stroke = _activeStroke;
    if (stroke == null) return;
    if (stroke.points.length == 1) {
      final Offset p = stroke.points.first;
      stroke.points.add(
        Offset(
          (p.dx + 0.0001).clamp(0.0, 1.0),
          (p.dy + 0.0001).clamp(0.0, 1.0),
        ),
      );
    }
    setState(() {
      _pageStrokes.add(stroke);
      _pageRedo.clear();
      _activeStroke = null;
    });
    _save();
  }

  void _undo() {
    if (_pageStrokes.isEmpty) return;
    setState(() {
      _pageRedo.add(_pageStrokes.removeLast());
    });
    _save();
  }

  void _redoAction() {
    if (_pageRedo.isEmpty) return;
    setState(() {
      _pageStrokes.add(_pageRedo.removeLast());
    });
    _save();
  }

  void _switchPage(int page) {
    if (page < 0 || page > 3 || page == _currentPage) return;
    setState(() {
      _currentPage = page;
      _activeStroke = null;
    });
  }

  Future<void> _clearAll() async {
    if (_pageStrokes.isEmpty) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          title: const Text(
            'Clear this scratchpad?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'All handwriting on the current page will be cleared.',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'CLEAR ALL',
                style: TextStyle(
                  color: Color(0xFFFF4D5E),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _pageStrokes.clear();
      _pageRedo.clear();
      _activeStroke = null;
    });
    _save();
  }

  Future<void> _pickPenColor() async {
    final Color? selected = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          title: const Text(
            'PEN COLOR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _penColors.map((Color color) {
              final bool selectedColor = color.value == _penColor.value;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedColor ? color : _border,
                      width: selectedColor ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: selectedColor
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 15,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() {
      _penColor = selected;
    });
    _save();
  }

  Widget _toolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    Color? color,
    bool active = false,
  }) {
    final Color iconColor = color ?? (active ? _accent : _muted);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? _accent.withOpacity(0.10) : _surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? _accent.withOpacity(0.55) : _border,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: onTap == null ? _border : iconColor,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          _toolButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Clear All',
            onTap: _pageStrokes.isEmpty ? null : _clearAll,
            color: const Color(0xFFFF4D5E),
          ),
          const SizedBox(width: 6),
          _toolButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onTap: _pageStrokes.isEmpty ? null : _undo,
          ),
          const SizedBox(width: 6),
          _toolButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onTap: _pageRedo.isEmpty ? null : _redoAction,
          ),
          const SizedBox(width: 6),
          _toolButton(
            icon: Icons.lens_rounded,
            tooltip: 'Pen Color',
            onTap: _pickPenColor,
            active: true,
            color: _penColor,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _penColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'PEN',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 9),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: List<Widget>.generate(4, (int index) {
          final bool selected = index == _currentPage;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: selected ? _accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _switchPage(index),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(
                        _pageNames[index],
                        style: TextStyle(
                          color: selected ? Colors.white : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _canvas() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (DragStartDetails details) {
            _startStroke(details, size);
          },
          onPanUpdate: (DragUpdateDetails details) {
            _updateStroke(details, size);
          },
          onPanEnd: (_) => _finishStroke(),
          onPanCancel: _finishStroke,
          child: CustomPaint(
            painter: _ScratchpadPainter(
              pageIndex: _currentPage,
              strokes: _pageStrokes,
              activeStroke: _activeStroke,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: _background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _toolbar(),
            _pageTabs(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: _loading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(_accent),
                          ),
                        ),
                      )
                    : _canvas(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScratchStroke {
  _ScratchStroke({
    required this.color,
    required this.width,
    required this.points,
  });
  final Color color;
  final double width;
  final List<Offset> points;
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': color.value,
      'width': width,
      'points': points
          .map(
            (Offset p) => <String, dynamic>{
              'x': p.dx,
              'y': p.dy,
            },
          )
          .toList(),
    };
  }

  static _ScratchStroke? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final dynamic color = raw['color'];
    final dynamic width = raw['width'];
    final dynamic points = raw['points'];
    if (color is! num || width is! num || points is! List) {
      return null;
    }
    final List<Offset> result = <Offset>[];
    for (final dynamic item in points) {
      if (item is! Map) continue;
      final double? x = _doubleValue(item['x']);
      final double? y = _doubleValue(item['y']);
      if (x == null || y == null) continue;
      result.add(
        Offset(
          x.clamp(0.0, 1.0),
          y.clamp(0.0, 1.0),
        ),
      );
    }
    if (result.isEmpty) return null;
    return _ScratchStroke(
      color: Color(color.toInt()),
      width: width.toDouble().clamp(0.5, 20.0),
      points: result,
    );
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class _ScratchpadPainter extends CustomPainter {
  const _ScratchpadPainter({
    required this.pageIndex,
    required this.strokes,
    required this.activeStroke,
  });
  final int pageIndex;
  final List<_ScratchStroke> strokes;
  final _ScratchStroke? activeStroke;
  static const Color _background = Color(0xFF0B111A);
  static const Color _surface = Color(0xFF101923);
  static const Color _border = Color(0xFF26364D);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _accent = Color(0xFF639DF0);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _background,
    );
    final _Template template = _Template(canvas, size);
    switch (pageIndex) {
      case 0:
        _takeoff(template);
        break;
      case 1:
        _landing(template);
        break;
      case 2:
        _holding(template);
        break;
      case 3:
        _craft(template);
        break;
    }
    for (final _ScratchStroke stroke in strokes) {
      _drawStroke(canvas, size, stroke);
    }
    if (activeStroke != null) {
      _drawStroke(canvas, size, activeStroke!);
    }
  }

  void _takeoff(_Template t) {
    t.header('TAKEOFF DATA');
    t.row2('T/O N1 ____', 'CLB N1 ____', 48);
    t.row3('V1 ____', 'VR ____', 'V2 ____', 78);
    t.row3('VFR ____', 'VENR ____', 'FLAPS ____', 108);
    t.section('CLEARANCE', 146);
    t.dashed(170);
    t.dashed(t.size.height * .47);
    t.grid3('APT ____', 'ELEV ____', 'RWY ____', t.size.height * .50);
    t.grid3('ATIS ____', 'WIND ____', 'VIS ____', t.size.height * .56);
    t.grid3('CIG ____', 'TEMP/DP ____', 'ALT ____', t.size.height * .62);
    t.single('RMKS ____', t.size.height * .68);
    t.grid2('RWY LENGTH ____', "RWY REQ'D ____", t.size.height * .74);
    t.grid2('ZFW ____', 'T/O WGT ____', t.size.height * .80);
    t.footer(
      'EMERGENCY RETURN  →  VREF ____   VAPP ____   MSA ____',
    );
  }

  void _landing(_Template t) {
    t.header('LANDING DATA');
    t.row2('VREF ____', 'VAPP ____', 48);
    t.row2('GA N1 ____', "RWY REQ'D ____", 78);
    t.section('CLEARANCE', 116);
    t.dashed(140);
    t.dashed(t.size.height * .47);
    t.grid3('APT ____', 'ELEV ____', 'RWY ____', t.size.height * .50);
    t.grid3('ATIS ____', 'WIND ____', 'VIS ____', t.size.height * .56);
    t.grid3('CIG ____', 'TEMP/DP ____', 'ALT ____', t.size.height * .62);
    t.single('RMKS ____', t.size.height * .68);
    t.grid2('RWY LENGTH ____', "RWY REQ'D ____", t.size.height * .74);
    t.grid2('ZFW ____', 'LDG WGT ____', t.size.height * .80);
  }

  void _holding(_Template t) {
    t.header('HOLDING CLEARANCE');
    t.row2('HOLD ____', 'OF ____', 50);
    t.row2('RAD/CRS ____', 'TURNS: RIGHT / LEFT', 82);
    t.single('ALTITUDE ____', 114);
    t.single('EXPECT FURTHER CLRNC ____', 146);
    t.section('HOLDING PATTERN', 181);
    t.dashed(205);
    t.dashed(t.size.height - 16);
  }

  void _craft(_Template t) {
    t.header('ATC CLEARANCE');
    final double start = 82;
    final double available = math.max(100, t.size.height - start - 28);
    final double spacing = available / 4;
    const List<String> letters = <String>[
      'C',
      'R',
      'A',
      'F',
      'T',
    ];
    for (int i = 0; i < letters.length; i++) {
      final double y = start + spacing * i;
      t.letter(letters[i], y);
      if (i < letters.length - 1) {
        t.dashedAt(y + spacing * .62, 72);
      }
    }
  }

  void _drawStroke(
    Canvas canvas,
    Size size,
    _ScratchStroke stroke,
  ) {
    if (stroke.points.isEmpty) return;
    final Paint paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    if (stroke.points.length == 1) {
      final Offset p = Offset(
        stroke.points.first.dx * size.width,
        stroke.points.first.dy * size.height,
      );
      canvas.drawCircle(
        p,
        math.max(1.5, stroke.width / 2),
        Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill,
      );
      return;
    }
    final Path path = Path();
    for (int i = 0; i < stroke.points.length; i++) {
      final Offset p = Offset(
        stroke.points[i].dx * size.width,
        stroke.points[i].dy * size.height,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScratchpadPainter oldDelegate) {
    return true;
  }
}

class _Template {
  _Template(this.canvas, this.size);
  final Canvas canvas;
  final Size size;
  static const Color _surface = Color(0xFF101923);
  static const Color _border = Color(0xFF26364D);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _accent = Color(0xFF639DF0);
  void header(String title) {
    final Rect rect = Rect.fromLTWH(
      12,
      12,
      math.max(40, size.width - 24),
      27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(7),
      ),
      Paint()..color = _surface,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(7),
      ),
      Paint()
        ..color = _border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    text(
      title,
      Offset(22, 19),
      color: _accent,
      size: 10.5,
      weight: FontWeight.w900,
      letterSpacing: 1,
    );
  }

  void section(String value, double top) {
    text(
      value,
      Offset(17, top),
      color: _accent,
      size: 10,
      weight: FontWeight.w900,
      letterSpacing: 1,
    );
  }

  void row2(String a, String b, double top) {
    final double half = (size.width - 32) / 2;
    text(
      a,
      Offset(16, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
    text(
      b,
      Offset(16 + half, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
  }

  void row3(String a, String b, String c, double top) {
    final double cell = (size.width - 32) / 3;
    text(
      a,
      Offset(16, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
    text(
      b,
      Offset(16 + cell, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
    text(
      c,
      Offset(16 + cell * 2, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
  }

  void grid3(String a, String b, String c, double top) {
    row3(a, b, c, top);
  }

  void grid2(String a, String b, double top) {
    row2(a, b, top);
  }

  void single(String value, double top) {
    text(
      value,
      Offset(16, top),
      color: _muted,
      size: 9.5,
      weight: FontWeight.w700,
    );
  }

  void letter(String value, double y) {
    text(
      value,
      Offset(20, y),
      color: _accent,
      size: 21,
      weight: FontWeight.w900,
    );
  }

  void footer(String value) {
    final double top = size.height - 29;
    final Rect rect = Rect.fromLTWH(
      12,
      top,
      math.max(40, size.width - 24),
      20,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(6),
      ),
      Paint()..color = _surface,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(6),
      ),
      Paint()
        ..color = _border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    text(
      value,
      Offset(19, top + 5),
      color: _muted,
      size: 8.2,
      weight: FontWeight.w800,
    );
  }

  void dashed(double y) {
    dashedAt(y, 16);
  }

  void dashedAt(double y, double left) {
    final Paint paint = Paint()
      ..color = _border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const double dash = 5;
    const double gap = 5;
    double x = left;
    final double right = size.width - 16;
    while (x < right) {
      final double end = math.min(x + dash, right);
      canvas.drawLine(
        Offset(x, y),
        Offset(end, y),
        paint,
      );
      x += dash + gap;
    }
  }

  void text(
    String value,
    Offset position, {
    required Color color,
    required double size,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final double maxWidth = math.max(20, this.size.width - position.dx - 12);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    painter.layout(maxWidth: maxWidth);
    painter.paint(canvas, position);
  }
}

class AviationWeatherCharts extends StatefulWidget {
  const AviationWeatherCharts({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);
  final double? width;
  final double? height;
  @override
  State<AviationWeatherCharts> createState() => _AviationWeatherChartsState();
}

class _AviationWeatherChartsState extends State<AviationWeatherCharts> {
  static const Color background = Color(0xFF0B111A);
  static const Color cardColor = Color(0xFF101923);
  static const Color borderColor = Color(0xFF26364D);
  static const Color mutedText = Color(0xFF8B949E);
  static const Color accent = Color(0xFF639DF0);
  static const String _categoryWindTemperature = 'windTemperature';
  static const String _categorySigwx = 'sigwx';
  static const String _categoryCanadianGfa = 'canadianGfa';
  static const String _sigwxHigh = 'high';
  static const String _sigwxMid = 'mid';
  static const String _sigwxLow = 'low';
  String _category = _categoryWindTemperature;
  String _sigwxLevel = _sigwxHigh;
  String? _selectedArea;
  String? _selectedFlightLevel;
  String? _selectedWindTime;
  String? _selectedGfaType;
  String? _selectedGfaTime;
  String? _chartUrl;
  bool _showChart = false;
  static const List<String> _windAreas = [
    'a',
    'b1',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'm',
  ];
  static const List<String> _windFlightLevels = [
    '630',
    '450',
    '390',
    '340',
    '300',
    '240',
    '180',
    '100',
    '050',
  ];
  static const List<String> _windTimes = [
    '06',
    '12',
    '18',
    '24',
    '30',
    '36',
  ];
  static const List<String> _sigwxHighAreas = [
    'a',
    'b',
    'c',
    'e',
  ];
  static const List<String> _sigwxMidAreas = [
    'nat',
    'eur',
    'mea',
    'seas',
  ];
  static const List<String> _sigwxLowAreas = [
    'us',
  ];
  static const List<String> _gfaTypes = [
    'cldwx',
    'icetb',
  ];
  static const List<String> _gfaTimes = [
    '00',
    '06',
    '12',
  ];
  static const List<String> _gfaAreas = [
    'pa',
    'pr',
    'oq',
    'at',
    'nw',
    'nu',
    'ar',
  ];
  String get _categoryTitle {
    if (_category == _categoryWindTemperature) {
      return 'Wind / Temperature';
    }
    if (_category == _categorySigwx) {
      return 'SIGWX';
    }
    return 'Canadian GFA';
  }

  String get _categorySubtitle {
    if (_category == _categoryWindTemperature) {
      return 'Upper-air wind & temperature charts';
    }
    if (_category == _categorySigwx) {
      return 'Significant weather charts';
    }
    return 'Canadian graphical area forecasts';
  }

  List<String> get _currentAreas {
    if (_category == _categoryWindTemperature) {
      return _windAreas;
    }
    if (_category == _categorySigwx) {
      if (_sigwxLevel == _sigwxHigh) {
        return _sigwxHighAreas;
      }
      if (_sigwxLevel == _sigwxMid) {
        return _sigwxMidAreas;
      }
      return _sigwxLowAreas;
    }
    return _gfaAreas;
  }

  String _regionDisplayName(String area) {
    const Map<String, String> displayNames = {
      'a': 'Americas',
      'b1': 'Americas-Africa',
      'c': 'Europe-Africa',
      'd': 'Asia',
      'e': 'Asia-Australia',
      'f': 'Pacific',
      'g': 'Asia',
      'h': 'North Atlantic',
      'i': 'North Pacific',
      'j': 'South Pole',
      'm': 'Pacific',
      'b': 'Europe-South America',
      'nat': 'North Atlantic',
      'eur': 'Europe',
      'mea': 'Middle East',
      'seas': 'Asia South',
      'sam': 'South America',
      'af': 'Africa',
      'aus': 'Australia',
      'pac': 'Pacific',
      'us': 'Contiguous United States',
      'ca': 'Canada',
      'asia': 'Asia',
      'pa': 'Pacific',
      'pr': 'Prairie',
      'oq': 'Ontario/Quebec',
      'at': 'Atlantic',
      'nw': 'Yukon/NWT',
      'nu': 'Nunavut',
      'ar': 'Arctic',
    };
    return displayNames[area.toLowerCase()] ?? area.toUpperCase();
  }

  bool get _parametersComplete {
    if (_category == _categoryWindTemperature) {
      return _selectedArea != null &&
          _selectedFlightLevel != null &&
          _selectedWindTime != null;
    }
    if (_category == _categorySigwx) {
      return _selectedArea != null;
    }
    return _selectedArea != null &&
        _selectedGfaType != null &&
        _selectedGfaTime != null;
  }

  String? _generateChartUrl() {
    if (_selectedArea == null) {
      return null;
    }
    if (_category == _categoryWindTemperature) {
      if (_selectedFlightLevel == null || _selectedWindTime == null) {
        return null;
      }
      return 'https://aviationweather.gov/data/products/fax/'
          'F${_selectedWindTime}_wind_'
          '${_selectedFlightLevel}_'
          '${_selectedArea}.gif';
    }
    if (_category == _categorySigwx) {
      if (_sigwxLevel == _sigwxHigh) {
        return 'https://aviationweather.gov/data/products/fax/'
            'F24_sigwx_hi_${_selectedArea}.gif';
      }
      if (_sigwxLevel == _sigwxMid) {
        return 'https://aviationweather.gov/data/products/fax/'
            'F24_sigwx_mid_${_selectedArea}.gif';
      }
      return 'https://aviationweather.gov/data/products/fax/'
          'sigwx_lo_${_selectedArea}.gif';
    }
    if (_selectedGfaType == null || _selectedGfaTime == null) {
      return null;
    }
    return 'https://aviationweather.gov/data/products/fax/'
        'F${_selectedGfaTime}_canfa_'
        '${_selectedGfaType}_'
        '${_selectedArea}.gif';
  }

  void _selectCategory(String category) {
    setState(() {
      _category = category;
      _selectedArea = null;
      _selectedFlightLevel = null;
      _selectedWindTime = null;
      _selectedGfaType = category == _categoryCanadianGfa ? 'cldwx' : null;
      _selectedGfaTime = null;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectSigwxLevel(String level) {
    setState(() {
      _sigwxLevel = level;
      _selectedArea = null;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectArea(String area) {
    setState(() {
      _selectedArea = area;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectWindFlightLevel(String level) {
    setState(() {
      _selectedFlightLevel = level;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectWindTime(String time) {
    setState(() {
      _selectedWindTime = time;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectGfaType(String type) {
    setState(() {
      _selectedGfaType = type;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _selectGfaTime(String time) {
    setState(() {
      _selectedGfaTime = time;
      _chartUrl = null;
      _showChart = false;
    });
  }

  void _viewChart() {
    final String? url = _generateChartUrl();
    if (url == null) {
      return;
    }
    setState(() {
      _chartUrl = url;
      _showChart = true;
    });
  }

  Widget _sectionHeader({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: accent.withOpacity(0.35),
            ),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 11.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modernChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    String? secondaryLabel,
  }) {
    return ChoiceChip(
      label: secondaryLabel == null
          ? Text(label)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                const SizedBox(height: 1),
                Text(
                  secondaryLabel,
                  style: TextStyle(
                    color: selected ? Colors.white70 : mutedText,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      backgroundColor: background,
      selectedColor: accent.withOpacity(0.18),
      side: BorderSide(
        color: selected ? accent : borderColor,
        width: selected ? 1.2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : mutedText,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  Widget _segmentedButton({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(
          labels.length,
          (index) {
            final bool selected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withOpacity(0.17)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(
                            color: accent.withOpacity(0.4),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? Colors.white : mutedText,
                        fontSize: 11.5,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          number: '01',
          title: 'Chart Type',
          subtitle: 'Select the aviation weather product',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _modernChoiceChip(
                label: 'WIND / TEMP',
                secondaryLabel: 'UPPER AIR',
                selected: _category == _categoryWindTemperature,
                onSelected: () {
                  _selectCategory(_categoryWindTemperature);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _modernChoiceChip(
                label: 'SIGWX',
                secondaryLabel: 'SIGNIFICANT WEATHER',
                selected: _category == _categorySigwx,
                onSelected: () {
                  _selectCategory(_categorySigwx);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _modernChoiceChip(
                label: 'CANADIAN GFA',
                secondaryLabel: 'CANADA',
                selected: _category == _categoryCanadianGfa,
                onSelected: () {
                  _selectCategory(_categoryCanadianGfa);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSigwxLevelSelector() {
    int selectedIndex = 0;
    if (_sigwxLevel == _sigwxMid) {
      selectedIndex = 1;
    } else if (_sigwxLevel == _sigwxLow) {
      selectedIndex = 2;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _sectionHeader(
          number: '02',
          title: 'SIGWX Level',
          subtitle: 'Choose the applicable significant weather level',
        ),
        const SizedBox(height: 14),
        _segmentedButton(
          labels: const [
            'HIGH',
            'MID',
            'LOW',
          ],
          selectedIndex: selectedIndex,
          onChanged: (index) {
            if (index == 0) {
              _selectSigwxLevel(_sigwxHigh);
            } else if (index == 1) {
              _selectSigwxLevel(_sigwxMid);
            } else {
              _selectSigwxLevel(_sigwxLow);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRegionSelector() {
    final String sectionNumber = _category == _categorySigwx ? '03' : '02';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _sectionHeader(
          number: sectionNumber,
          title: 'Region',
          subtitle: _category == _categorySigwx
              ? 'Select the geographical chart area'
              : 'Select the geographical coverage area',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _currentAreas.map((area) {
            return _modernChoiceChip(
              label: _regionDisplayName(area),
              selected: _selectedArea == area,
              onSelected: () => _selectArea(area),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWindParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _sectionHeader(
          number: '03',
          title: 'Parameters',
          subtitle: 'Select forecast time and flight level',
        ),
        const SizedBox(height: 16),
        const Text(
          'FORECAST TIME',
          style: TextStyle(
            color: mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _windTimes.map((time) {
            return _modernChoiceChip(
              label: 'F$time',
              selected: _selectedWindTime == time,
              onSelected: () => _selectWindTime(time),
            );
          }).toList(),
        ),
        const SizedBox(height: 17),
        const Text(
          'FLIGHT LEVEL',
          style: TextStyle(
            color: mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _windFlightLevels.map((level) {
            return _modernChoiceChip(
              label: 'FL$level',
              selected: _selectedFlightLevel == level,
              onSelected: () => _selectWindFlightLevel(level),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGfaParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _sectionHeader(
          number: '03',
          title: 'Parameters',
          subtitle: 'Select chart product and forecast time',
        ),
        const SizedBox(height: 16),
        const Text(
          'CHART PRODUCT',
          style: TextStyle(
            color: mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 9),
        _segmentedButton(
          labels: const [
            'CLOUDS / WEATHER',
            'ICING / TURBULENCE',
          ],
          selectedIndex: _selectedGfaType == 'icetb' ? 1 : 0,
          onChanged: (index) {
            _selectGfaType(index == 0 ? 'cldwx' : 'icetb');
          },
        ),
        const SizedBox(height: 17),
        const Text(
          'FORECAST TIME',
          style: TextStyle(
            color: mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: _gfaTimes.map((time) {
            return _modernChoiceChip(
              label: 'F$time',
              selected: _selectedGfaTime == time,
              onSelected: () => _selectGfaTime(time),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSigwxParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _sectionHeader(
          number: '04',
          title: 'Parameters',
          subtitle: 'SIGWX charts use a fixed F24 forecast period',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 17,
                color: accent,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Forecast period',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                _sigwxLevel == _sigwxLow ? 'NO TIME IN URL' : 'F24',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlPreview() {
    final String? url = _generateChartUrl();
    if (url == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.link_rounded,
            size: 17,
            color: accent,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: SelectableText(
              url,
              style: const TextStyle(
                color: mutedText,
                fontSize: 9.5,
                height: 1.35,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton() {
    final bool enabled = _parametersComplete;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: enabled ? _viewChart : null,
          icon: const Icon(
            Icons.visibility_rounded,
            size: 19,
          ),
          label: const Text(
            'VIEW WEATHER CHART',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: accent,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartViewer() {
    if (!_showChart || _chartUrl == null) {
      return _buildEmptyChartState();
    }
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6.0,
              boundaryMargin: const EdgeInsets.all(150),
              panEnabled: true,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              child: Center(
                child: Image.network(
                  _chartUrl!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    final int? total = loadingProgress.expectedTotalBytes;
                    final int loaded = loadingProgress.cumulativeBytesLoaded;
                    final double? value = total != null ? loaded / total : null;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 2.5,
                              color: accent,
                              backgroundColor: borderColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'LOADING WEATHER CHART',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Fetching aviation weather product...',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return _buildChartError();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _buildChartHud(),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: background.withOpacity(0.92),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pan_tool_alt_rounded,
                    size: 13,
                    color: mutedText,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'PINCH TO ZOOM  •  DRAG TO PAN',
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
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

  Widget _buildChartHud() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: background.withOpacity(0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            _categoryTitle.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.55,
            ),
          ),
          if (_selectedArea != null) ...[
            const SizedBox(width: 7),
            Container(
              width: 1,
              height: 12,
              color: borderColor,
            ),
            const SizedBox(width: 7),
            Text(
              _selectedArea!.toUpperCase(),
              style: const TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: mutedText.withOpacity(0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: mutedText,
                size: 27,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'CHART NOT AVAILABLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chart not available for these specific parameters '
              'on the server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 11,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _viewChart,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: accent,
              ),
              label: const Text(
                'RETRY',
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChartState() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.07),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: accent,
                  size: 31,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'WEATHER CHART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your chart parameters above\n'
                'to display the aviation weather product.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedText,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final List<String> items = <String>[];
    items.add(_categoryTitle);
    if (_category == _categorySigwx) {
      if (_sigwxLevel == _sigwxHigh) {
        items.add('HIGH');
      } else if (_sigwxLevel == _sigwxMid) {
        items.add('MID');
      } else {
        items.add('LOW');
      }
    }
    if (_selectedArea != null) {
      items.add(_selectedArea!.toUpperCase());
    }
    if (_selectedWindTime != null) {
      items.add('F${_selectedWindTime!}');
    }
    if (_selectedFlightLevel != null) {
      items.add('FL${_selectedFlightLevel!}');
    }
    if (_selectedGfaType != null) {
      items.add(
        _selectedGfaType == 'cldwx' ? 'CLOUDS / WX' : 'ICING / TURB',
      );
    }
    if (_selectedGfaTime != null) {
      items.add('F${_selectedGfaTime!}');
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            color: accent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    Text(
                      items[i],
                      style: TextStyle(
                        color: i == 0 ? Colors.white : accent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (i != items.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: mutedText,
                          size: 13,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 850;
              if (isCompact) {
                return _buildCompactLayout();
              }
              return _buildDesktopLayout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              18,
            ),
            child: Column(
              children: [
                _buildControlsCard(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 500,
                  child: _buildChartViewer(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 390,
                  child: _buildControlsCard(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildChartViewer(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accent.withOpacity(0.28),
              ),
            ),
            child: const Icon(
              Icons.cloud_rounded,
              color: accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVIATION WEATHER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'WEATHER CHARTS  •  EFB METEOROLOGY',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(),
            if (_category == _categorySigwx) _buildSigwxLevelSelector(),
            _buildRegionSelector(),
            if (_category == _categoryWindTemperature) _buildWindParameters(),
            if (_category == _categorySigwx) _buildSigwxParameters(),
            if (_category == _categoryCanadianGfa) _buildGfaParameters(),
            const SizedBox(height: 22),
            _buildSelectionSummary(),
            const SizedBox(height: 15),
            _buildViewButton(),
          ],
        ),
      ),
    );
  }
}
