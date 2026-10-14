// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:cached_network_image/cached_network_image.dart';

/// Responsive world-landmark selector for Flutter / FlutterFlow.
/// Uses CachedNetworkImage (v3.3.1) with automatic pre-caching so all 27
/// landmark images and 27 flags download once on first open and stay cached on device.
class WorldDestinationsWidget extends StatefulWidget {
  const WorldDestinationsWidget({
    super.key,
    this.width,
    this.height,
    this.onSpeedChanged,
    // 27 Separate Landmark Image URL Parameters
    this.landmark1Image,
    this.landmark2Image,
    this.landmark3Image,
    this.landmark4Image,
    this.landmark5Image,
    this.landmark6Image,
    this.landmark7Image,
    this.landmark8Image,
    this.landmark9Image,
    this.landmark10Image,
    this.landmark11Image,
    this.landmark12Image,
    this.landmark13Image,
    this.landmark14Image,
    this.landmark15Image,
    this.landmark16Image,
    this.landmark17Image,
    this.landmark18Image,
    this.landmark19Image,
    this.landmark20Image,
    this.landmark21Image,
    this.landmark22Image,
    this.landmark23Image,
    this.landmark24Image,
    this.landmark25Image,
    this.landmark26Image,
    this.landmark27Image,
    // 27 Separate Flag Image URL Parameters
    this.landmark1Flag,
    this.landmark2Flag,
    this.landmark3Flag,
    this.landmark4Flag,
    this.landmark5Flag,
    this.landmark6Flag,
    this.landmark7Flag,
    this.landmark8Flag,
    this.landmark9Flag,
    this.landmark10Flag,
    this.landmark11Flag,
    this.landmark12Flag,
    this.landmark13Flag,
    this.landmark14Flag,
    this.landmark15Flag,
    this.landmark16Flag,
    this.landmark17Flag,
    this.landmark18Flag,
    this.landmark19Flag,
    this.landmark20Flag,
    this.landmark21Flag,
    this.landmark22Flag,
    this.landmark23Flag,
    this.landmark24Flag,
    this.landmark25Flag,
    this.landmark26Flag,
    this.landmark27Flag,
    // 27 Separate Action Callbacks
    this.onLandmark1Tap,
    this.onLandmark2Tap,
    this.onLandmark3Tap,
    this.onLandmark4Tap,
    this.onLandmark5Tap,
    this.onLandmark6Tap,
    this.onLandmark7Tap,
    this.onLandmark8Tap,
    this.onLandmark9Tap,
    this.onLandmark10Tap,
    this.onLandmark11Tap,
    this.onLandmark12Tap,
    this.onLandmark13Tap,
    this.onLandmark14Tap,
    this.onLandmark15Tap,
    this.onLandmark16Tap,
    this.onLandmark17Tap,
    this.onLandmark18Tap,
    this.onLandmark19Tap,
    this.onLandmark20Tap,
    this.onLandmark21Tap,
    this.onLandmark22Tap,
    this.onLandmark23Tap,
    this.onLandmark24Tap,
    this.onLandmark25Tap,
    this.onLandmark26Tap,
    this.onLandmark27Tap,
  });

  final double? width;
  final double? height;

  /// Called whenever the speed field changes and immediately before a
  /// destination action runs.
  final Future Function(double speed)? onSpeedChanged;

  // 27 Landmark Image URLs
  final String? landmark1Image;
  final String? landmark2Image;
  final String? landmark3Image;
  final String? landmark4Image;
  final String? landmark5Image;
  final String? landmark6Image;
  final String? landmark7Image;
  final String? landmark8Image;
  final String? landmark9Image;
  final String? landmark10Image;
  final String? landmark11Image;
  final String? landmark12Image;
  final String? landmark13Image;
  final String? landmark14Image;
  final String? landmark15Image;
  final String? landmark16Image;
  final String? landmark17Image;
  final String? landmark18Image;
  final String? landmark19Image;
  final String? landmark20Image;
  final String? landmark21Image;
  final String? landmark22Image;
  final String? landmark23Image;
  final String? landmark24Image;
  final String? landmark25Image;
  final String? landmark26Image;
  final String? landmark27Image;

  // 27 Flag Image URLs
  final String? landmark1Flag;
  final String? landmark2Flag;
  final String? landmark3Flag;
  final String? landmark4Flag;
  final String? landmark5Flag;
  final String? landmark6Flag;
  final String? landmark7Flag;
  final String? landmark8Flag;
  final String? landmark9Flag;
  final String? landmark10Flag;
  final String? landmark11Flag;
  final String? landmark12Flag;
  final String? landmark13Flag;
  final String? landmark14Flag;
  final String? landmark15Flag;
  final String? landmark16Flag;
  final String? landmark17Flag;
  final String? landmark18Flag;
  final String? landmark19Flag;
  final String? landmark20Flag;
  final String? landmark21Flag;
  final String? landmark22Flag;
  final String? landmark23Flag;
  final String? landmark24Flag;
  final String? landmark25Flag;
  final String? landmark26Flag;
  final String? landmark27Flag;

  // 27 Tap Callbacks
  final Future Function()? onLandmark1Tap;
  final Future Function()? onLandmark2Tap;
  final Future Function()? onLandmark3Tap;
  final Future Function()? onLandmark4Tap;
  final Future Function()? onLandmark5Tap;
  final Future Function()? onLandmark6Tap;
  final Future Function()? onLandmark7Tap;
  final Future Function()? onLandmark8Tap;
  final Future Function()? onLandmark9Tap;
  final Future Function()? onLandmark10Tap;
  final Future Function()? onLandmark11Tap;
  final Future Function()? onLandmark12Tap;
  final Future Function()? onLandmark13Tap;
  final Future Function()? onLandmark14Tap;
  final Future Function()? onLandmark15Tap;
  final Future Function()? onLandmark16Tap;
  final Future Function()? onLandmark17Tap;
  final Future Function()? onLandmark18Tap;
  final Future Function()? onLandmark19Tap;
  final Future Function()? onLandmark20Tap;
  final Future Function()? onLandmark21Tap;
  final Future Function()? onLandmark22Tap;
  final Future Function()? onLandmark23Tap;
  final Future Function()? onLandmark24Tap;
  final Future Function()? onLandmark25Tap;
  final Future Function()? onLandmark26Tap;
  final Future Function()? onLandmark27Tap;

  @override
  State<WorldDestinationsWidget> createState() =>
      _WorldDestinationsWidgetState();
}

class _WorldDestinationsWidgetState extends State<WorldDestinationsWidget>
    with AutomaticKeepAliveClientMixin<WorldDestinationsWidget> {
  static const Color _background = Color(0xFF07111C);
  static const Color _panel = Color(0xFF0D1B2A);
  static const Color _panelRaised = Color(0xFF122235);
  static const Color _cyan = Color(0xFF29C8FF);
  static const Color _blue = Color(0xFF2081FF);
  static const Color _mutedText = Color(0xFF9FB2C8);

  late final TextEditingController _speedController;
  double _currentSpeed = 150.0;
  int? _pressedIndex;
  final Set<String> _precachedUrls = <String>{};

  @override
  bool get wantKeepAlive => true;

  static const List<_WorldDestination> _destinations = [
    _WorldDestination(
      name: 'The Great Pyramids',
      country: 'Egypt',
      description: 'Ancient wonder of the world.',
      latitude: 29.9688,
      longitude: 31.1342,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Eiffel Tower',
      country: 'France',
      description: 'Iconic symbol of Paris.',
      latitude: 48.8480,
      longitude: 2.2945,
      altitude: 1400.0,
    ),
    _WorldDestination(
      name: 'Statue of Liberty',
      country: 'USA',
      description: 'A symbol of freedom and hope.',
      latitude: 40.6788,
      longitude: -74.0445,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Burj Khalifa',
      country: 'UAE',
      description: 'The tallest building in the world.',
      latitude: 25.1868,
      longitude: 55.2744,
      altitude: 3200.0,
    ),
    _WorldDestination(
      name: 'Big Ben',
      country: 'United Kingdom',
      description: 'Historic clock tower in London.',
      latitude: 51.4903,
      longitude: -0.1246,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Sydney Opera House',
      country: 'Australia',
      description: 'Famous architectural masterpiece.',
      latitude: -33.8672,
      longitude: 151.2153,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Christ the Redeemer',
      country: 'Brazil',
      description: 'Iconic statue overlooking Rio de Janeiro.',
      latitude: -22.9623,
      longitude: -43.2105,
      altitude: 3500.0,
    ),
    _WorldDestination(
      name: 'The Taj Mahal',
      country: 'India',
      description: 'A timeless symbol of love.',
      latitude: 27.1647,
      longitude: 78.0421,
      altitude: 1500.0,
    ),
    _WorldDestination(
      name: 'Niagara Falls',
      country: 'Canada',
      description: 'A breathtaking natural wonder.',
      latitude: 43.0695,
      longitude: -79.0773,
      altitude: 1500.0,
    ),
    _WorldDestination(
      name: 'Grand Canyon',
      country: 'USA',
      description: 'Breathtaking natural wonder.',
      latitude: 36.0468,
      longitude: -112.1401,
      altitude: 7800.0,
    ),
    _WorldDestination(
      name: 'Mount Everest',
      country: 'Nepal',
      description: 'The highest mountain on Earth.',
      latitude: 27.9776,
      longitude: 86.9250,
      altitude: 30000.0,
    ),
    _WorldDestination(
      name: 'Machu Picchu',
      country: 'Peru',
      description: 'Ancient Incan citadel in the clouds.',
      latitude: -13.1741,
      longitude: -72.5450,
      altitude: 8900.0,
    ),
    _WorldDestination(
      name: 'Santorini',
      country: 'Greece',
      description: 'Stunning island with white buildings',
      latitude: 36.4523,
      longitude: 25.3753,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Colosseum',
      country: 'Italy',
      description: 'Ancient Roman amphitheater.',
      latitude: 41.8799,
      longitude: 12.4922,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Golden Gate Bridge',
      country: 'USA',
      description: 'Iconic bridge in San Francisco.',
      latitude: 37.8092,
      longitude: -122.4783,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Lusail Marina',
      country: 'Qatar',
      description: 'Iconic waterfront destination in Doha.',
      latitude: 25.4093,
      longitude: 51.5280,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Great Wall of China',
      country: 'China',
      description: 'Historic wonder of the world.',
      latitude: 40.4208,
      longitude: 116.5620,
      altitude: 2800.0,
    ),
    _WorldDestination(
      name: 'Tokyo Tower',
      country: 'Japan',
      description: 'Iconic landmark of Tokyo.',
      latitude: 35.6482,
      longitude: 139.7454,
      altitude: 1800.0,
    ),
    _WorldDestination(
      name: 'Dubai Palm Jumeirah',
      country: 'UAE',
      description: 'The world’s largest artificial island.',
      latitude: 25.1018,
      longitude: 55.1381,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Alhambra',
      country: 'Spain',
      description: 'Stunning palace and fortress complex.',
      latitude: 37.1666,
      longitude: -3.5899,
      altitude: 2700.0,
    ),
    _WorldDestination(
      name: 'Angkor Wat',
      country: 'Cambodia',
      description: 'Magnificent ancient temple complex.',
      latitude: 13.4018,
      longitude: 103.8670,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Iguazu Falls',
      country: 'Argentina / Brazil',
      description: 'Breathtaking system of waterfalls.',
      latitude: -25.7058,
      longitude: -54.4367,
      altitude: 1700.0,
    ),
    _WorldDestination(
      name: 'Blue Lagoon',
      country: 'Iceland',
      description: 'Famous geothermal spa.',
      latitude: 63.8690,
      longitude: -22.4481,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Louvre Museum',
      country: 'France',
      description: 'World-famous art museum.',
      latitude: 48.8509,
      longitude: 2.3376,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Banff National Park',
      country: 'Canada',
      description: 'Stunning landscapes and turquoise lakes',
      latitude: 51.1678,
      longitude: -115.5708,
      altitude: 5500.0,
    ),
    _WorldDestination(
      name: 'Bahrain World Trade Center',
      country: 'Bahrain',
      description: 'Iconic towers and sunset reflections',
      latitude: 26.2300,
      longitude: 50.5817,
      altitude: 1800.0,
    ),
    _WorldDestination(
      name: 'Masjid al-Haram',
      country: 'Saudi Arabia',
      description: 'Home of the sacred Kaaba',
      latitude: 21.4121,
      longitude: 39.8262,
      altitude: 2500.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speedController = TextEditingController(text: '150');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages();
    });
  }

  @override
  void didUpdateWidget(covariant WorldDestinationsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllImages();
    });
  }

  @override
  void dispose() {
    _speedController.dispose();
    super.dispose();
  }

  /// Normalizes GitHub links so both 'raw.githubusercontent.com' and standard
  /// 'github.com/.../blob/...' links download the binary image directly.
  String _resolveGitHubUrl(String? rawUrl) {
    if (rawUrl == null) return '';
    String url = rawUrl.trim();
    if (url.isEmpty) return '';

    if (url.contains('github.com/') && url.contains('/blob/')) {
      url = url
          .replaceFirst(
              'https://github.com/', 'https://raw.githubusercontent.com/')
          .replaceFirst(
              'http://github.com/', 'https://raw.githubusercontent.com/')
          .replaceFirst('/blob/', '/');
    }
    return url;
  }

  String _imageUrlForLandmark(int index) {
    switch (index) {
      case 0:
        return _resolveGitHubUrl(widget.landmark1Image);
      case 1:
        return _resolveGitHubUrl(widget.landmark2Image);
      case 2:
        return _resolveGitHubUrl(widget.landmark3Image);
      case 3:
        return _resolveGitHubUrl(widget.landmark4Image);
      case 4:
        return _resolveGitHubUrl(widget.landmark5Image);
      case 5:
        return _resolveGitHubUrl(widget.landmark6Image);
      case 6:
        return _resolveGitHubUrl(widget.landmark7Image);
      case 7:
        return _resolveGitHubUrl(widget.landmark8Image);
      case 8:
        return _resolveGitHubUrl(widget.landmark9Image);
      case 9:
        return _resolveGitHubUrl(widget.landmark10Image);
      case 10:
        return _resolveGitHubUrl(widget.landmark11Image);
      case 11:
        return _resolveGitHubUrl(widget.landmark12Image);
      case 12:
        return _resolveGitHubUrl(widget.landmark13Image);
      case 13:
        return _resolveGitHubUrl(widget.landmark14Image);
      case 14:
        return _resolveGitHubUrl(widget.landmark15Image);
      case 15:
        return _resolveGitHubUrl(widget.landmark16Image);
      case 16:
        return _resolveGitHubUrl(widget.landmark17Image);
      case 17:
        return _resolveGitHubUrl(widget.landmark18Image);
      case 18:
        return _resolveGitHubUrl(widget.landmark19Image);
      case 19:
        return _resolveGitHubUrl(widget.landmark20Image);
      case 20:
        return _resolveGitHubUrl(widget.landmark21Image);
      case 21:
        return _resolveGitHubUrl(widget.landmark22Image);
      case 22:
        return _resolveGitHubUrl(widget.landmark23Image);
      case 23:
        return _resolveGitHubUrl(widget.landmark24Image);
      case 24:
        return _resolveGitHubUrl(widget.landmark25Image);
      case 25:
        return _resolveGitHubUrl(widget.landmark26Image);
      case 26:
        return _resolveGitHubUrl(widget.landmark27Image);
      default:
        return '';
    }
  }

  String _flagUrlForLandmark(int index) {
    switch (index) {
      case 0:
        return _resolveGitHubUrl(widget.landmark1Flag);
      case 1:
        return _resolveGitHubUrl(widget.landmark2Flag);
      case 2:
        return _resolveGitHubUrl(widget.landmark3Flag);
      case 3:
        return _resolveGitHubUrl(widget.landmark4Flag);
      case 4:
        return _resolveGitHubUrl(widget.landmark5Flag);
      case 5:
        return _resolveGitHubUrl(widget.landmark6Flag);
      case 6:
        return _resolveGitHubUrl(widget.landmark7Flag);
      case 7:
        return _resolveGitHubUrl(widget.landmark8Flag);
      case 8:
        return _resolveGitHubUrl(widget.landmark9Flag);
      case 9:
        return _resolveGitHubUrl(widget.landmark10Flag);
      case 10:
        return _resolveGitHubUrl(widget.landmark11Flag);
      case 11:
        return _resolveGitHubUrl(widget.landmark12Flag);
      case 12:
        return _resolveGitHubUrl(widget.landmark13Flag);
      case 13:
        return _resolveGitHubUrl(widget.landmark14Flag);
      case 14:
        return _resolveGitHubUrl(widget.landmark15Flag);
      case 15:
        return _resolveGitHubUrl(widget.landmark16Flag);
      case 16:
        return _resolveGitHubUrl(widget.landmark17Flag);
      case 17:
        return _resolveGitHubUrl(widget.landmark18Flag);
      case 18:
        return _resolveGitHubUrl(widget.landmark19Flag);
      case 19:
        return _resolveGitHubUrl(widget.landmark20Flag);
      case 20:
        return _resolveGitHubUrl(widget.landmark21Flag);
      case 21:
        return _resolveGitHubUrl(widget.landmark22Flag);
      case 22:
        return _resolveGitHubUrl(widget.landmark23Flag);
      case 23:
        return _resolveGitHubUrl(widget.landmark24Flag);
      case 24:
        return _resolveGitHubUrl(widget.landmark25Flag);
      case 25:
        return _resolveGitHubUrl(widget.landmark26Flag);
      case 26:
        return _resolveGitHubUrl(widget.landmark27Flag);
      default:
        return '';
    }
  }

  /// Downloads and caches all 27 landmark images and 27 flags on device disk
  /// the first time the page is opened.
  void _precacheAllImages() {
    if (!mounted) return;
    for (int i = 0; i < _destinations.length; i++) {
      final String imgUrl = _imageUrlForLandmark(i);
      final String flagUrl = _flagUrlForLandmark(i);

      if (imgUrl.isNotEmpty && !_precachedUrls.contains(imgUrl)) {
        _precachedUrls.add(imgUrl);
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(imgUrl, cacheKey: imgUrl),
            context,
          ).catchError((_) {}),
        );
      }

      if (flagUrl.isNotEmpty && !_precachedUrls.contains(flagUrl)) {
        _precachedUrls.add(flagUrl);
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(flagUrl, cacheKey: flagUrl),
            context,
          ).catchError((_) {}),
        );
      }
    }
  }

  double get _parsedSpeed {
    final parsed = double.tryParse(_speedController.text.trim());
    return parsed != null && parsed.isFinite ? parsed : 150.0;
  }

  void _notifySpeedChanged() {
    final callback = widget.onSpeedChanged;
    if (callback == null) return;
    unawaited(_callSpeedCallback(callback, _currentSpeed));
  }

  Future<void> _callSpeedCallback(
    Future Function(double speed) callback,
    double speed,
  ) async {
    try {
      await callback(speed);
    } catch (error, stackTrace) {
      debugPrint('WorldDestinationsWidget speed callback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future Function()? _actionForLandmark(int index) {
    switch (index) {
      case 0:
        return widget.onLandmark1Tap;
      case 1:
        return widget.onLandmark2Tap;
      case 2:
        return widget.onLandmark3Tap;
      case 3:
        return widget.onLandmark4Tap;
      case 4:
        return widget.onLandmark5Tap;
      case 5:
        return widget.onLandmark6Tap;
      case 6:
        return widget.onLandmark7Tap;
      case 7:
        return widget.onLandmark8Tap;
      case 8:
        return widget.onLandmark9Tap;
      case 9:
        return widget.onLandmark10Tap;
      case 10:
        return widget.onLandmark11Tap;
      case 11:
        return widget.onLandmark12Tap;
      case 12:
        return widget.onLandmark13Tap;
      case 13:
        return widget.onLandmark14Tap;
      case 14:
        return widget.onLandmark15Tap;
      case 15:
        return widget.onLandmark16Tap;
      case 16:
        return widget.onLandmark17Tap;
      case 17:
        return widget.onLandmark18Tap;
      case 18:
        return widget.onLandmark19Tap;
      case 19:
        return widget.onLandmark20Tap;
      case 20:
        return widget.onLandmark21Tap;
      case 21:
        return widget.onLandmark22Tap;
      case 22:
        return widget.onLandmark23Tap;
      case 23:
        return widget.onLandmark24Tap;
      case 24:
        return widget.onLandmark25Tap;
      case 25:
        return widget.onLandmark26Tap;
      case 26:
        return widget.onLandmark27Tap;
      default:
        return null;
    }
  }

  Future<void> _handleLandmarkTap(int index) async {
    try {
      final speedCallback = widget.onSpeedChanged;
      if (speedCallback != null) {
        await _callSpeedCallback(speedCallback, _parsedSpeed);
      }

      final action = _actionForLandmark(index);
      if (action != null) {
        await action();
      }
    } catch (error, stackTrace) {
      debugPrint('WorldDestinationsWidget landmark action failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (mounted && _pressedIndex == index) {
        setState(() => _pressedIndex = null);
      }
    }
  }

  void _setPressed(int index) {
    if (!mounted) return;
    setState(() => _pressedIndex = index);
  }

  Widget _fitCardText({
    required String text,
    required TextStyle style,
    required double height,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.left,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: textAlign == TextAlign.center
                ? Alignment.center
                : Alignment.centerLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Text(
                text,
                style: style,
                maxLines: maxLines,
                softWrap: maxLines > 1,
                overflow: TextOverflow.clip,
                textAlign: textAlign,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCachedLandmarkImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: _panelRaised,
        alignment: Alignment.center,
        child: const Icon(
          Icons.landscape_rounded,
          color: _mutedText,
          size: 36,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: imageUrl,
      fit: BoxFit.cover,
      useOldImageOnUrlChange: true,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) => Container(
        color: _panelRaised,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: _cyan,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: _panelRaised,
        alignment: Alignment.center,
        child: const Icon(
          Icons.landscape_rounded,
          color: _mutedText,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildCachedFlagImage(String flagUrl) {
    if (flagUrl.isEmpty) {
      return const Icon(
        Icons.flag_rounded,
        color: _mutedText,
        size: 15,
      );
    }

    return CachedNetworkImage(
      imageUrl: flagUrl,
      cacheKey: flagUrl,
      fit: BoxFit.cover,
      useOldImageOnUrlChange: true,
      fadeInDuration: const Duration(milliseconds: 100),
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: _cyan,
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.flag_rounded,
        color: _mutedText,
        size: 15,
      ),
    );
  }

  Widget _buildSpeedPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF20364D), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _blue.withOpacity(0.45)),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: _cyan,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'TARGET AIRSPEED (KT)',
                  style: TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                  ),
                ),
              ),
              const Text(
                'FLIGHT CONTROL',
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speedController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _cyan,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            cursorColor: _cyan,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF07121F),
              hintText: '150',
              hintStyle: const TextStyle(color: _mutedText),
              suffixText: 'KT',
              suffixStyle: const TextStyle(
                color: _mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFF26445E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _cyan, width: 1.6),
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              setState(() {
                _currentSpeed =
                    parsed != null && parsed.isFinite ? parsed : 150.0;
              });
              _notifySpeedChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    int index,
    _WorldDestination destination,
  ) {
    final isPressed = _pressedIndex == index;
    final String imageUrl = _imageUrlForLandmark(index);
    final String flagUrl = _flagUrlForLandmark(index);

    return AnimatedScale(
      scale: isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(index),
        onTapCancel: () {
          if (mounted && _pressedIndex == index) {
            setState(() => _pressedIndex = null);
          }
        },
        onTap: () => _handleLandmarkTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isPressed ? _cyan : const Color(0xFF24405A),
              width: isPressed ? 2.2 : 1.0,
            ),
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: _cyan.withOpacity(0.68),
                      blurRadius: 26,
                      spreadRadius: 1.5,
                    ),
                    BoxShadow(
                      color: _blue.withOpacity(0.38),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCachedLandmarkImage(imageUrl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.24),
                        const Color(0xF507111C),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  left: 11,
                  right: 11,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC07111C),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _cyan.withOpacity(0.65),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC857),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'LANDMARK',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.96),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  bottom: 13,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _fitCardText(
                        text: destination.name,
                        height: 36,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                          height: 1.05,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 30,
                              height: 20,
                              color: const Color(0xFF1B2A3A),
                              child: _buildCachedFlagImage(flagUrl),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _fitCardText(
                              text: destination.country,
                              height: 22,
                              style: const TextStyle(
                                color: Color(0xFFE2EDF8),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _fitCardText(
                        text: destination.description,
                        height: 32,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color(0xFFC2D0DE),
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isPressed
                              ? _blue.withOpacity(0.28)
                              : const Color(0xD9071B2D),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isPressed ? _cyan : _cyan.withOpacity(0.65),
                            width: isPressed ? 1.4 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'FLY HERE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.25,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.flight_takeoff_rounded,
                                  color: _cyan,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        color: _background,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 26),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _cyan.withOpacity(0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.public_rounded,
                            color: _cyan,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WORLD DESTINATIONS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Explore the world’s most iconic places from the cockpit.',
                                style: TextStyle(
                                  color: _mutedText.withOpacity(0.98),
                                  fontSize: 13,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    _buildSpeedPanel(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'CHOOSE YOUR DESTINATION',
                            style: TextStyle(
                              color: Color(0xFFE6F3FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.25,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _panelRaised,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF263D53),
                            ),
                          ),
                          child: Text(
                            '${_destinations.length} LOCATIONS',
                            style: const TextStyle(
                              color: _cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth < 600 ? 2 : 3;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _destinations.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: crossAxisCount == 2 ? 0.68 : 0.76,
                          ),
                          itemBuilder: (context, index) {
                            return _buildDestinationCard(
                              context,
                              index,
                              _destinations[index],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldDestination {
  const _WorldDestination({
    required this.name,
    required this.country,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  final String name;
  final String country;
  final String description;
  final double latitude;
  final double longitude;
  final double altitude;
}
