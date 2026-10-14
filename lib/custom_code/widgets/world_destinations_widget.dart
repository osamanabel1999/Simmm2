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

// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!

import 'dart:async';
import 'dart:ui' show FontFeature;

/// Responsive world-landmark selector for Flutter / FlutterFlow.
///
/// The 27 asset pairs and destination details below are mapped from the
/// original World Tour widget. Each card invokes its matching callback.
class WorldDestinationsWidget extends StatefulWidget {
  const WorldDestinationsWidget({
    super.key,
    this.width,
    this.height,
    this.onSpeedChanged,
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

class _WorldDestinationsWidgetState extends State<WorldDestinationsWidget> {
  static const Color _background = Color(0xFF07111C);
  static const Color _panel = Color(0xFF0D1B2A);
  static const Color _panelRaised = Color(0xFF122235);
  static const Color _cyan = Color(0xFF29C8FF);
  static const Color _blue = Color(0xFF2081FF);
  static const Color _mutedText = Color(0xFF9FB2C8);

  late final TextEditingController _speedController;
  double _currentSpeed = 150.0;
  int? _pressedIndex;

  final List<_WorldDestination> _destinations = const [
    _WorldDestination(
      name: 'The Great Pyramids',
      country: 'Egypt',
      description: 'Ancient wonder of the world.',
      imagePath:
          'assets/images/image_7E58189C-CB1B-4174-9AC1-0341F70AEF60_1787640842.png',
      flagPath:
          'assets/images/image_9706F552-46DE-447D-906B-A9A5B75BEF05_1787638862.png',
      latitude: 29.9688,
      longitude: 31.1342,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Eiffel Tower',
      country: 'France',
      description: 'Iconic symbol of Paris.',
      imagePath:
          'assets/images/image_F8133037-936B-4727-85C2-26AA1EC6A2A2_1787641565.jpeg',
      flagPath:
          'assets/images/image_E3795009-7440-47A1-85CB-B469BE9FCF14_1787641435.png',
      latitude: 48.8480,
      longitude: 2.2945,
      altitude: 1400.0,
    ),
    _WorldDestination(
      name: 'Statue of Liberty',
      country: 'USA',
      description: 'A symbol of freedom and hope.',
      imagePath:
          'assets/images/image_600F4E68-C631-491B-805D-BBA1841B312D_1787641914.png',
      flagPath:
          'assets/images/image_9DF31649-DAB2-4CDE-B490-30F6F6684E8E_1787641860.png',
      latitude: 40.6788,
      longitude: -74.0445,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Burj Khalifa',
      country: 'UAE',
      description: 'The tallest building in the world.',
      imagePath:
          'assets/images/image_7CD5962B-2AD3-48EE-BF4F-AC70CE7BDD19_1787642147.png',
      flagPath:
          'assets/images/image_2C23A605-1ECC-4FBE-98F8-94E2C9FC27AC_1787642299.png',
      latitude: 25.1868,
      longitude: 55.2744,
      altitude: 3200.0,
    ),
    _WorldDestination(
      name: 'Big Ben',
      country: 'United Kingdom',
      description: 'Historic clock tower in London.',
      imagePath:
          'assets/images/image_88C17B6D-06BF-4662-919A-00894F5C799C_1787642445.png',
      flagPath:
          'assets/images/image_53FF85CE-653E-4D82-AD52-B37E843631C1_1787642416.jpeg',
      latitude: 51.4903,
      longitude: -0.1246,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Sydney Opera House',
      country: 'Australia',
      description: 'Famous architectural masterpiece.',
      imagePath:
          'assets/images/image_1F12844F-D568-4EDB-8A01-215D9FC07043_1787642584.png',
      flagPath:
          'assets/images/image_F177DBE7-109D-4454-82EE-DC1F7C742C18_1787642552.png',
      latitude: -33.8672,
      longitude: 151.2153,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Christ the Redeemer',
      country: 'Brazil',
      description: 'Iconic statue overlooking Rio de Janeiro.',
      imagePath:
          'assets/images/image_22EF13A2-CEC7-4C17-961A-E88E25F48A23_1787643112.png',
      flagPath:
          'assets/images/image_47A3416A-551C-46AE-B64B-EEE379953DE5_1787643141.png',
      latitude: -22.9623,
      longitude: -43.2105,
      altitude: 3500.0,
    ),
    _WorldDestination(
      name: 'The Taj Mahal',
      country: 'India',
      description: 'A timeless symbol of love.',
      imagePath:
          'assets/images/image_18F5E2B1-F026-4BC6-855F-DCDDE59D6ED7_1787643514.png',
      flagPath:
          'assets/images/image_B1E573F2-9144-4749-9163-CA15DB3D80D8_1787643522.webp',
      latitude: 27.1647,
      longitude: 78.0421,
      altitude: 1500.0,
    ),
    _WorldDestination(
      name: 'Niagara Falls',
      country: 'Canada',
      description: 'A breathtaking natural wonder.',
      imagePath:
          'assets/images/image_F458974B-5796-49F6-830E-CB6A04552083_1787643740.png',
      flagPath:
          'assets/images/image_4EA424E2-3357-42D2-8945-C0FCBEDBF677_1787643597.png',
      latitude: 43.0695,
      longitude: -79.0773,
      altitude: 1500.0,
    ),
    _WorldDestination(
      name: 'Grand Canyon',
      country: 'USA',
      description: 'Breathtaking natural wonder.',
      imagePath:
          'assets/images/image_A449B87A-A002-4DE0-8711-51E7059FAB94_1787643945.png',
      flagPath:
          'assets/images/image_9DF31649-DAB2-4CDE-B490-30F6F6684E8E_1787641860.png',
      latitude: 36.0468,
      longitude: -112.1401,
      altitude: 7800.0,
    ),
    _WorldDestination(
      name: 'Mount Everest',
      country: 'Nepal',
      description: 'The highest mountain on Earth.',
      imagePath:
          'assets/images/image_0314134B-6A1E-4E17-BBEE-8707C611057E_1787644112.png',
      flagPath:
          'assets/images/image_ECF18ED3-2634-4757-934A-625580CD0922_1787644094.png',
      latitude: 27.9776,
      longitude: 86.9250,
      altitude: 30000.0,
    ),
    _WorldDestination(
      name: 'Machu Picchu',
      country: 'Peru',
      description: 'Ancient Incan citadel in the clouds.',
      imagePath:
          'assets/images/image_CD28B3A3-EB3F-4CA3-867A-3BFA8838FF81_1787644281.png',
      flagPath:
          'assets/images/image_8A0EA8AE-B48B-4725-A67D-4D14EE34DB41_1787644255.png',
      latitude: -13.1741,
      longitude: -72.5450,
      altitude: 8900.0,
    ),
    _WorldDestination(
      name: 'Santorini',
      country: 'Greece',
      description: 'Stunning island with white buildings',
      imagePath:
          'assets/images/image_F87B2D99-E4F2-49F8-A2E4-32E1AB5DCF85_1787644513.png',
      flagPath:
          'assets/images/image_5D4F6841-7729-4FDB-99AD-A706F77F8EF2_1787644468.png',
      latitude: 36.4523,
      longitude: 25.3753,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Colosseum',
      country: 'Italy',
      description: 'Ancient Roman amphitheater.',
      imagePath:
          'assets/images/image_596C7DB7-8042-4C9E-AA14-C8F26DAD2E2C_1787644865.png',
      flagPath:
          'assets/images/image_2F110B04-2814-492D-8C19-65D2751BB5DD_1787644756.png',
      latitude: 41.8799,
      longitude: 12.4922,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Golden Gate Bridge',
      country: 'USA',
      description: 'Iconic bridge in San Francisco.',
      imagePath:
          'assets/images/image_5CD3FA13-C439-4409-8D54-D552EEB1ED73_1787644941.png',
      flagPath:
          'assets/images/image_8A0EA8AE-B48B-4725-A67D-4D14EE34DB41_1787644255.png',
      latitude: 37.8092,
      longitude: -122.4783,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Lusail Marina',
      country: 'Qatar',
      description: 'Iconic waterfront destination in Doha.',
      imagePath:
          'assets/images/image_5B5AE5A1-9F1E-425B-B6E9-0F5524D1E55E_1787645129.png',
      flagPath:
          'assets/images/image_8143C6BA-1D60-4D9F-937A-C4FF128590D6_1787645123.png',
      latitude: 25.4093,
      longitude: 51.5280,
      altitude: 1000.0,
    ),
    _WorldDestination(
      name: 'Great Wall of China',
      country: 'China',
      description: 'Historic wonder of the world.',
      imagePath:
          'assets/images/image_B264C480-6885-45EB-BEB2-88321DE3C825_1787645438.png',
      flagPath:
          'assets/images/image_E5503140-B3EF-4EF8-9C31-1B00212DDFAA_1787645305.png',
      latitude: 40.4208,
      longitude: 116.5620,
      altitude: 2800.0,
    ),
    _WorldDestination(
      name: 'Tokyo Tower',
      country: 'Japan',
      description: 'Iconic landmark of Tokyo.',
      imagePath:
          'assets/images/image_89C0331B-5DCB-4608-84BB-F8626A77D504_1787645597.png',
      flagPath:
          'assets/images/image_84AAFE07-BCA3-4BCE-85FE-8A588C8F1164_1787645626.png',
      latitude: 35.6482,
      longitude: 139.7454,
      altitude: 1800.0,
    ),
    _WorldDestination(
      name: 'Dubai Palm Jumeirah',
      country: 'UAE',
      description: 'The world’s largest artificial island.',
      imagePath:
          'assets/images/image_4EAD0B0E-3088-4AC6-A39A-D3164399E480_1787646182.png',
      flagPath:
          'assets/images/image_2C23A605-1ECC-4FBE-98F8-94E2C9FC27AC_1787642299.png',
      latitude: 25.1018,
      longitude: 55.1381,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Alhambra',
      country: 'Spain',
      description: 'Stunning palace and fortress complex.',
      imagePath:
          'assets/images/image_EE4DCE73-E366-4815-8E99-9E594A778ADA_1787646373.png',
      flagPath:
          'assets/images/image_DB27D00D-85D6-4528-9E87-D24054E138C7_1787646277.png',
      latitude: 37.1666,
      longitude: -3.5899,
      altitude: 2700.0,
    ),
    _WorldDestination(
      name: 'Angkor Wat',
      country: 'Cambodia',
      description: 'Magnificent ancient temple complex.',
      imagePath:
          'assets/images/image_135A6F44-56F6-451A-BC52-70BCE0A06A6C_1787646353.png',
      flagPath:
          'assets/images/image_76433193-4194-4A25-A1DA-9214F7005699_1787646300.webp',
      latitude: 13.4018,
      longitude: 103.8670,
      altitude: 1200.0,
    ),
    _WorldDestination(
      name: 'Iguazu Falls',
      country: 'Argentina / Brazil',
      description: 'Breathtaking system of waterfalls.',
      imagePath:
          'assets/images/image_8C531546-1F68-4326-A2BF-372B9492F2C1_1787647236.png',
      flagPath:
          'assets/images/image_32883F14-2E08-48AE-AD3B-8D2B57C0146A_1787646893.png',
      latitude: -25.7058,
      longitude: -54.4367,
      altitude: 1700.0,
    ),
    _WorldDestination(
      name: 'Blue Lagoon',
      country: 'Iceland',
      description: 'Famous geothermal spa.',
      imagePath:
          'assets/images/image_F612E763-4BF3-4508-9DCE-4F0F94DB7960_1787647214.png',
      flagPath:
          'assets/images/image_EA1DF57A-65AC-4F07-AEAC-A9B3D371D28C_1787646996.png',
      latitude: 63.8690,
      longitude: -22.4481,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Louvre Museum',
      country: 'France',
      description: 'World-famous art museum.',
      imagePath:
          'assets/images/image_E45BBFF4-6996-4925-A500-943431F991B0_1787647169.png',
      flagPath:
          'assets/images/image_FBE03A04-3999-4393-85ED-108BE5033498_1787641796.png',
      latitude: 48.8509,
      longitude: 2.3376,
      altitude: 1100.0,
    ),
    _WorldDestination(
      name: 'Banff National Park',
      country: 'Canada',
      description: 'Stunning landscapes and turquoise lakes',
      imagePath:
          'assets/images/image_D880BCF7-78CB-4E2D-A4C2-58B08659364E_1787647865.png',
      flagPath:
          'assets/images/image_4EA424E2-3357-42D2-8945-C0FCBEDBF677_1787643597.png',
      latitude: 51.1678,
      longitude: -115.5708,
      altitude: 5500.0,
    ),
    _WorldDestination(
      name: 'Bahrain World Trade Center',
      country: 'Bahrain',
      description: 'Iconic towers and sunset reflections',
      imagePath:
          'assets/images/image_5D9C5D75-490B-40EE-8B56-BFD8B7ACF3DA_1787647914.png',
      flagPath:
          'assets/images/image_2ABDE972-2781-4DF6-832E-06AB829DA6B1_1787647722.png',
      latitude: 26.2300,
      longitude: 50.5817,
      altitude: 1800.0,
    ),
    _WorldDestination(
      name: 'Masjid al-Haram',
      country: 'Saudi Arabia',
      description: 'Home of the sacred Kaaba',
      imagePath:
          'assets/images/image_F5C1FAC5-6CDA-41F7-A60F-A80260B382E3_1787647947.png',
      flagPath:
          'assets/images/image_1CFE6A2B-565F-4D08-A0C4-46171F6C89A7_1787648102.png',
      latitude: 21.4121,
      longitude: 39.8262,
      altitude: 2500.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speedController = TextEditingController(text: '150');
  }

  @override
  void dispose() {
    _speedController.dispose();
    super.dispose();
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
      // Always send the current speed before invoking the selected action.
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
      // Keep the press glow visible briefly, then release only this card.
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
              // Notify on every edit, including while the user is typing.
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
                Image.asset(
                  destination.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _panelRaised,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: _mutedText,
                        size: 36,
                      ),
                    );
                  },
                ),
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
                              child: Image.asset(
                                destination.flagPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.flag_rounded,
                                    color: _mutedText,
                                    size: 15,
                                  );
                                },
                              ),
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
                        // Exactly two columns below 600 logical pixels;
                        // exactly three columns at 600 and above.
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
    required this.imagePath,
    required this.flagPath,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  final String name;
  final String country;
  final String description;
  final String imagePath;
  final String flagPath;

  // Preserved from the source data for each matching destination action.
  final double latitude;
  final double longitude;
  final double altitude;
}
