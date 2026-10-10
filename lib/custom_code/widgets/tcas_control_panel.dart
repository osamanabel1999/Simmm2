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

import 'dart:math' as math;

/// FlutterFlow custom widget: TCAS control panel for an iPad in landscape
/// mode.
///
/// Bind the action callbacks to the existing FlutterFlow Custom Actions that
/// communicate with X-Plane. This widget does not directly open a network
/// connection or write X-Plane DataRefs itself.
class TcasControlPanel extends StatefulWidget {
  const TcasControlPanel({
    super.key,
    this.width,
    this.height,
    this.onGenerateAction,
    this.onRemoveAllAction,
    this.onPositionModeChanged,
    this.onAheadAction,
    this.onBehindAction,
    this.onLeftAction,
    this.onRightAction,
    this.onFrontLeftAction,
    this.onFrontRightAction,
    this.onRearLeftAction,
    this.onRearRightAction,
    this.onHeadingModeAction,
    this.onDistanceChanged,
    this.onTrueAirspeedChanged,
    this.onRelativeAltitudeChanged,
    this.onVerticalSpeedChanged,
    this.onCustomHeadingChanged,
  });

  final double? width;
  final double? height;

  /// Sends the current shared input values, then requests a new target.
  final Future Function()? onGenerateAction;

  /// Calls the single Remove All command.
  final Future Function()? onRemoveAllAction;

  /// Optional shared callback: receives mode 0..7, or 8 for custom heading.
  /// Used when the corresponding dedicated callback below is not supplied.
  final Future Function(int? mode)? onPositionModeChanged;

  /// Dedicated action parameters for each of the eight relative positions.
  /// Each receives its fixed mode value (0..7) when pressed.
  final Future Function(int? mode)? onAheadAction;
  final Future Function(int? mode)? onBehindAction;
  final Future Function(int? mode)? onLeftAction;
  final Future Function(int? mode)? onRightAction;
  final Future Function(int? mode)? onFrontLeftAction;
  final Future Function(int? mode)? onFrontRightAction;
  final Future Function(int? mode)? onRearLeftAction;
  final Future Function(int? mode)? onRearRightAction;

  /// Called when Custom Heading is switched on/off. Receives 8 when on,
  /// and the last selected normal mode (0..7) when off.
  final Future Function(int? mode)? onHeadingModeAction;

  /// Numeric input callbacks. Bind these to actions that write the matching
  /// shared DataRef. The new parsed value is passed to the callback.
  final Future Function(double? value)? onDistanceChanged;
  final Future Function(double? value)? onTrueAirspeedChanged;
  final Future Function(double? value)? onRelativeAltitudeChanged;
  final Future Function(double? value)? onVerticalSpeedChanged;
  final Future Function(double? value)? onCustomHeadingChanged;

  @override
  State<TcasControlPanel> createState() => _TcasControlPanelState();
}

// --- EFB palette provided by the user ---
const Color _efbBg = Color(0xFF0B111A);
const Color _efbCard = Color(0xFF101923);
const Color _efbBorder = Color(0xFF26364D);
const Color _efbTextMuted = Color(0xFF8B949E);
const Color _efbAccent = Color(0xFF639DF0);
const Color _efbButtonDark = Color(0xFF15335E);
const Color _efbWhite = Color(0xFFFFFFFF);
const Color _cDanger = Color(0xFFFF5252);
const Color _cWarn = Color(0xFFFFD740);
const Color _cGood = Color(0xFF69F0AE);

/// Static session state intentionally survives page navigation while the app
/// process remains alive. It resets naturally when the app process restarts.
class _TcasSessionState {
  static String distanceText = '10';
  static String tasText = '230';
  static String altitudeText = '0';
  static String verticalSpeedText = '0';
  static String headingText = '0';

  static int selectedMode = 0;
  static int lastNormalMode = 0;
  static bool customHeadingEnabled = false;

  static final List<_TcasIntruder> intruders = <_TcasIntruder>[];
  static int nextTargetNumber = 1;
}

class _TcasIntruder {
  const _TcasIntruder({
    required this.number,
    required this.mode,
    required this.distanceNm,
    required this.tasKt,
    required this.relativeAltitudeFt,
    required this.verticalSpeedFpm,
    required this.customHeadingDeg,
  });

  final int number;
  final int mode;
  final double distanceNm;
  final double tasKt;
  final double relativeAltitudeFt;
  final double verticalSpeedFpm;
  final double customHeadingDeg;

  double get bearingDeg {
    if (mode == 8) return _normalizeHeading(customHeadingDeg);
    const Map<int, double> bearings = <int, double>{
      0: 0,
      1: 180,
      2: 270,
      3: 90,
      4: 315,
      5: 45,
      6: 225,
      7: 135,
    };
    return bearings[mode] ?? 0;
  }

  String get callsign => 'B737-${number.toString().padLeft(2, '0')}';

  String get level {
    final double separation = relativeAltitudeFt.abs();
    if (separation <= 500) return 'LOW';
    if (separation <= 999) return 'MEDIUM';
    return 'HIGH';
  }

  Color get levelColor {
    switch (level) {
      case 'LOW':
        return _cDanger;
      case 'MEDIUM':
        return _cWarn;
      default:
        return _cGood;
    }
  }
}

double _normalizeHeading(double value) {
  final double normalized = value % 360;
  return normalized < 0 ? normalized + 360 : normalized;
}

class _TcasControlPanelState extends State<TcasControlPanel> {
  late final TextEditingController _distanceController;
  late final TextEditingController _tasController;
  late final TextEditingController _altitudeController;
  late final TextEditingController _verticalSpeedController;
  late final TextEditingController _headingController;

  bool _working = false;

  // Validation state variables
  bool _errDistance = false;
  bool _errTas = false;
  bool _errAltitude = false;
  bool _errVs = false;
  bool _errHeading = false;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController(
      text: _TcasSessionState.distanceText,
    );
    _tasController = TextEditingController(text: _TcasSessionState.tasText);
    _altitudeController = TextEditingController(
      text: _TcasSessionState.altitudeText,
    );
    _verticalSpeedController = TextEditingController(
      text: _TcasSessionState.verticalSpeedText,
    );
    _headingController = TextEditingController(
      text: _TcasSessionState.headingText,
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _tasController.dispose();
    _altitudeController.dispose();
    _verticalSpeedController.dispose();
    _headingController.dispose();
    super.dispose();
  }

  double? _parse(String value) => double.tryParse(value.trim());

  void _rememberText(String field, String value) {
    switch (field) {
      case 'distance':
        _TcasSessionState.distanceText = value;
        break;
      case 'tas':
        _TcasSessionState.tasText = value;
        break;
      case 'altitude':
        _TcasSessionState.altitudeText = value;
        break;
      case 'verticalSpeed':
        _TcasSessionState.verticalSpeedText = value;
        break;
      case 'heading':
        _TcasSessionState.headingText = value;
        break;
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? _cDanger : _efbButtonDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _commitNumericField({required String field}) async {
    final String text;
    final Future Function(double? value)? callback;
    switch (field) {
      case 'distance':
        text = _distanceController.text;
        callback = widget.onDistanceChanged;
        break;
      case 'tas':
        text = _tasController.text;
        callback = widget.onTrueAirspeedChanged;
        break;
      case 'altitude':
        text = _altitudeController.text;
        callback = widget.onRelativeAltitudeChanged;
        break;
      case 'verticalSpeed':
        text = _verticalSpeedController.text;
        callback = widget.onVerticalSpeedChanged;
        break;
      default:
        text = _headingController.text;
        callback = widget.onCustomHeadingChanged;
        break;
    }

    _rememberText(field, text);
    final double? value = _parse(text);
    if (value == null) {
      setState(() {
        if (field == 'distance') _errDistance = true;
        if (field == 'tas') _errTas = true;
        if (field == 'altitude') _errAltitude = true;
        if (field == 'verticalSpeed') _errVs = true;
        if (field == 'heading') _errHeading = true;
      });
      _showMessage('Invalid numeric value in settings.', isError: true);
      return;
    }
    if (field == 'heading' && !_TcasSessionState.customHeadingEnabled) return;
    if (callback == null) return;

    try {
      await callback(value);
    } catch (error) {
      _showMessage('Failed to send value to simulator: $error', isError: true);
    }
  }

  Future<bool> _commitAllFields() async {
    final double? distance = _parse(_distanceController.text);
    final double? tas = _parse(_tasController.text);
    final double? altitude = _parse(_altitudeController.text);
    final double? verticalSpeed = _parse(_verticalSpeedController.text);
    final double? heading = _parse(_headingController.text);

    setState(() {
      _errDistance = distance == null;
      _errTas = tas == null;
      _errAltitude = altitude == null;
      _errVs = verticalSpeed == null;
      _errHeading = _TcasSessionState.customHeadingEnabled && heading == null;
    });

    if (_errDistance || _errTas || _errAltitude || _errVs || _errHeading) {
      _showMessage('Please ensure all required fields contain valid numbers.',
          isError: true);
      return false;
    }

    _TcasSessionState.distanceText = _distanceController.text;
    _TcasSessionState.tasText = _tasController.text;
    _TcasSessionState.altitudeText = _altitudeController.text;
    _TcasSessionState.verticalSpeedText = _verticalSpeedController.text;
    _TcasSessionState.headingText = _headingController.text;

    try {
      await widget.onDistanceChanged?.call(distance);
      await widget.onTrueAirspeedChanged?.call(tas);
      await widget.onRelativeAltitudeChanged?.call(altitude);
      await widget.onVerticalSpeedChanged?.call(verticalSpeed);
      if (_TcasSessionState.customHeadingEnabled) {
        await widget.onCustomHeadingChanged?.call(heading);
      }
      return true;
    } catch (error) {
      _showMessage('Failed to send settings to simulator: $error',
          isError: true);
      return false;
    }
  }

  Future<void> _selectPosition(int mode) async {
    if (_working || _TcasSessionState.customHeadingEnabled) return;

    setState(() {
      _TcasSessionState.selectedMode = mode;
      _TcasSessionState.lastNormalMode = mode;
    });

    try {
      final Future Function(int? mode)? dedicatedAction = _actionForMode(mode);
      if (dedicatedAction != null) {
        await dedicatedAction(mode);
      } else {
        await widget.onPositionModeChanged?.call(mode);
      }
    } catch (error) {
      _showMessage('Failed to change target position: $error', isError: true);
    }
  }

  Future Function(int? mode)? _actionForMode(int mode) {
    switch (mode) {
      case 0:
        return widget.onAheadAction;
      case 1:
        return widget.onBehindAction;
      case 2:
        return widget.onLeftAction;
      case 3:
        return widget.onRightAction;
      case 4:
        return widget.onFrontLeftAction;
      case 5:
        return widget.onFrontRightAction;
      case 6:
        return widget.onRearLeftAction;
      case 7:
        return widget.onRearRightAction;
      default:
        return null;
    }
  }

  Future<void> _toggleCustomHeading() async {
    if (_working) return;
    final bool enabled = !_TcasSessionState.customHeadingEnabled;
    final int mode = enabled ? 8 : _TcasSessionState.lastNormalMode;
    setState(() {
      _TcasSessionState.customHeadingEnabled = enabled;
      _TcasSessionState.selectedMode = mode;
      if (!enabled) _errHeading = false;
    });

    try {
      if (widget.onHeadingModeAction != null) {
        await widget.onHeadingModeAction!(mode);
      } else {
        await widget.onPositionModeChanged?.call(mode);
      }
      if (enabled) {
        final double? heading = _parse(_headingController.text);
        if (heading != null) await widget.onCustomHeadingChanged?.call(heading);
      }
    } catch (error) {
      _showMessage('Failed to change heading mode: $error', isError: true);
    }
  }

  Future<void> _generateTarget() async {
    if (_working) return;
    if (_TcasSessionState.intruders.length >= 63) {
      _showMessage('Maximum limit reached: 63 targets.', isError: true);
      return;
    }

    setState(() {
      _working = true;
    });

    try {
      final bool committed = await _commitAllFields();
      if (!committed) return;

      await widget.onGenerateAction?.call();

      final double distance = _parse(_TcasSessionState.distanceText)!;
      final double tas = _parse(_TcasSessionState.tasText)!;
      final double altitude = _parse(_TcasSessionState.altitudeText)!;
      final double verticalSpeed = _parse(_TcasSessionState.verticalSpeedText)!;
      final double heading = _parse(_TcasSessionState.headingText)!;

      _TcasSessionState.intruders.add(
        _TcasIntruder(
          number: _TcasSessionState.nextTargetNumber,
          mode: _TcasSessionState.selectedMode,
          distanceNm: distance,
          tasKt: tas,
          relativeAltitudeFt: altitude,
          verticalSpeedFpm: verticalSpeed,
          customHeadingDeg: heading,
        ),
      );
      _TcasSessionState.nextTargetNumber++;
      if (mounted) setState(() {});
    } catch (error) {
      _showMessage('Failed to generate target: $error', isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _removeAllTargets() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await widget.onRemoveAllAction?.call();
      _TcasSessionState.intruders.clear();
      _TcasSessionState.nextTargetNumber = 1;
      if (mounted) setState(() {});
    } catch (error) {
      _showMessage('Failed to execute Remove All: $error', isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        double finalWidth = screenWidth;
        if (widget.width != null &&
            widget.width!.isFinite &&
            widget.width! > 0) {
          finalWidth = widget.width!;
        } else if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          finalWidth = constraints.maxWidth;
        }

        double finalHeight = screenHeight;
        if (widget.height != null &&
            widget.height!.isFinite &&
            widget.height! > 0) {
          finalHeight = widget.height!;
        } else if (constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0) {
          finalHeight = constraints.maxHeight;
        }

        final bool isDesktop = finalWidth >= 900; // Breakpoint for iPad layout

        if (isDesktop) {
          // ==========================================
          // IPAD / DESKTOP LAYOUT (UNTOUCHED)
          // ==========================================
          return SizedBox(
            width: finalWidth,
            height: finalHeight,
            child: Scaffold(
              backgroundColor: _efbBg,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    math.max(10.0, finalWidth * 0.012).toDouble(),
                    6,
                    math.max(10.0, finalWidth * 0.012).toDouble(),
                    10,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 42, child: _buildPageTitle()),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 30,
                              child: _buildSettingsPanel(isMobile: false),
                            ),
                            const SizedBox(width: 14),
                            Expanded(flex: 40, child: _buildRadarPanel()),
                            const SizedBox(width: 14),
                            Expanded(flex: 30, child: _buildIntruderPanel()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // ==========================================
          // MOBILE LAYOUT (VERTICAL SCROLL)
          // ==========================================
          return SizedBox(
            width: finalWidth,
            height: finalHeight,
            child: Scaffold(
              backgroundColor: _efbBg,
              body: SafeArea(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  children: <Widget>[
                    SizedBox(height: 42, child: _buildPageTitle()),
                    const SizedBox(height: 16),
                    SizedBox(
                        height: 380, child: _buildRadarPanel()), // 1. Radar
                    const SizedBox(height: 16),
                    _buildSettingsPanel(
                        isMobile:
                            true), // 2. Settings (Full height without internal scroll)
                    const SizedBox(height: 16),
                    SizedBox(
                        height: 400,
                        child: _buildIntruderPanel()), // 3. Traffic
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPageTitle() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _efbWhite,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const Text(
          'TCAS',
          style: TextStyle(
            color: _efbWhite,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.8,
            shadows: <Shadow>[
              Shadow(color: Color(0x55639DF0), blurRadius: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: _efbCard,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _efbBorder, width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x16000000), blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: child,
    );
  }

  Widget _panelTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: _efbAccent,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 13),
        Container(height: 1, color: _efbBorder),
      ],
    );
  }

  Widget _buildSettingsPanel({bool isMobile = false}) {
    Widget formContent = Column(
      children: <Widget>[
        _numericSetting(
          label: 'DISTANCE (NM)',
          controller: _distanceController,
          signed: false,
          hasError: _errDistance,
          onTextChanged: (String value) {
            _rememberText('distance', value);
            if (_errDistance) setState(() => _errDistance = false);
          },
          onCommit: () => _commitNumericField(field: 'distance'),
        ),
        const SizedBox(height: 13),
        _numericSetting(
          label: 'TRUE AIRSPEED (KT)',
          controller: _tasController,
          signed: false,
          hasError: _errTas,
          onTextChanged: (String value) {
            _rememberText('tas', value);
            if (_errTas) setState(() => _errTas = false);
          },
          onCommit: () => _commitNumericField(field: 'tas'),
        ),
        const SizedBox(height: 13),
        _numericSetting(
          label: 'RELATIVE ALT. (FT)',
          controller: _altitudeController,
          signed: true,
          hasError: _errAltitude,
          onTextChanged: (String value) {
            _rememberText('altitude', value);
            if (_errAltitude) setState(() => _errAltitude = false);
          },
          onCommit: () => _commitNumericField(field: 'altitude'),
        ),
        const SizedBox(height: 13),
        _numericSetting(
          label: 'VERTICAL SPEED (FT/MIN)',
          controller: _verticalSpeedController,
          signed: true,
          hasError: _errVs,
          onTextChanged: (String value) {
            _rememberText('verticalSpeed', value);
            if (_errVs) setState(() => _errVs = false);
          },
          onCommit: () => _commitNumericField(field: 'verticalSpeed'),
        ),
        const SizedBox(height: 23),
        _sectionDivider(),
        const SizedBox(height: 20),
        _buildCustomHeadingRow(),
        const SizedBox(height: 22),
        _sectionDivider(),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'INTRUDER AIRCRAFT',
            style: TextStyle(
              color: _efbAccent.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _actionButton(
          label: 'GENERATE INTRUDER AIRCRAFT',
          icon: Icons.my_location_rounded,
          onTap: _generateTarget,
          isPrimary: true,
          isBusy: _working,
        ),
        const SizedBox(height: 12),
        _actionButton(
          label: 'REMOVE ALL TRAFFIC',
          icon: Icons.delete_outline_rounded,
          onTap: _removeAllTargets,
          isDanger: true,
          isBusy: _working,
        ),
        const SizedBox(height: 10),
        Text(
          '${_TcasSessionState.intruders.length} / 63 TARGETS',
          style: const TextStyle(
            color: _efbTextMuted,
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return _panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: <Widget>[
          _panelTitle('TCAS SETTINGS'),
          const SizedBox(height: 16),
          if (isMobile)
            formContent
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: formContent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionDivider() => Container(height: 1, color: _efbBorder);

  Widget _numericSetting({
    required String label,
    required TextEditingController controller,
    required bool signed,
    required bool hasError,
    required ValueChanged<String> onTextChanged,
    required Future<void> Function() onCommit,
  }) {
    return SizedBox(
      height: 42,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 48,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9BB8E1),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            flex: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B1521),
                border: Border.all(color: hasError ? _cDanger : _efbBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: signed,
                ),
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  color: _efbWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: _efbAccent,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: InputBorder.none,
                ),
                onChanged: onTextChanged,
                onSubmitted: (_) => onCommit(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeadingRow() {
    final bool enabled = _TcasSessionState.customHeadingEnabled;
    return Row(
      children: <Widget>[
        const Expanded(
          flex: 4,
          child: Text(
            'HEADING (DEG)',
            style: TextStyle(
              color: Color(0xFF9BB8E1),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: _toggleCustomHeading,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 50,
            height: 27,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: enabled ? _efbAccent : const Color(0xFF243244),
              borderRadius: BorderRadius.circular(30),
              boxShadow: enabled
                  ? const <BoxShadow>[
                      BoxShadow(
                          color: Color(0x44639DF0),
                          blurRadius: 11,
                          spreadRadius: 1),
                    ]
                  : null,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 21,
                height: 21,
                decoration: const BoxDecoration(
                  color: _efbWhite,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          flex: 5,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: enabled ? 1 : 0.45,
            child: Container(
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1521),
                border: Border.all(
                    color: _errHeading
                        ? _cDanger
                        : (enabled ? _efbAccent : _efbBorder)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _headingController,
                enabled: enabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: _efbWhite, fontSize: 13),
                cursorColor: _efbAccent,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  border: InputBorder.none,
                ),
                onChanged: (String value) {
                  _rememberText('heading', value);
                  if (_errHeading) setState(() => _errHeading = false);
                },
                onSubmitted: (_) => _commitNumericField(field: 'heading'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Future<void> Function() onTap,
    bool isPrimary = false,
    bool isDanger = false,
    bool isBusy = false,
  }) {
    final Color color = isDanger ? _cDanger : _efbAccent;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: isBusy ? null : onTap,
        splashColor: color.withOpacity(0.20),
        highlightColor: color.withOpacity(0.10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 49,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isPrimary
                ? _efbButtonDark.withOpacity(0.48)
                : isDanger
                    ? _cDanger.withOpacity(0.09)
                    : Colors.transparent,
            border: Border.all(
              color: isDanger
                  ? _cDanger.withOpacity(0.75)
                  : _efbAccent.withOpacity(0.85),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: isPrimary
                ? const <BoxShadow>[
                    BoxShadow(
                        color: Color(0x1F639DF0),
                        blurRadius: 12,
                        spreadRadius: 1),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isBusy)
                SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDanger ? _cDanger : _efbAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarPanel() {
    return _panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panelTitle('TRAFFIC RELATIVE POSITION'),
          const SizedBox(height: 7),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double diameter = math
                    .max(
                      180.0,
                      math.min(constraints.maxWidth - 12,
                          constraints.maxHeight - 10),
                    )
                    .toDouble();
                return Center(
                  child: SizedBox.square(
                    dimension: diameter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        const Positioned.fill(
                            child: CustomPaint(painter: _RadarPainter())),
                        const Align(
                          alignment: Alignment(0, -0.98),
                          child: _CompassLabel('N'),
                        ),
                        const Align(
                          alignment: Alignment(-0.99, 0.02),
                          child: _CompassLabel('W'),
                        ),
                        const Align(
                          alignment: Alignment(0.99, 0.02),
                          child: _CompassLabel('E'),
                        ),
                        const Align(
                          alignment: Alignment(0, 0.98),
                          child: _CompassLabel('S'),
                        ),
                        _positionButton(
                          mode: 0,
                          alignment: const Alignment(0, -0.73),
                          icon: Icons.arrow_downward_rounded,
                        ),
                        _positionButton(
                          mode: 1,
                          alignment: const Alignment(0, 0.73),
                          icon: Icons.arrow_upward_rounded,
                        ),
                        _positionButton(
                          mode: 2,
                          alignment: const Alignment(-0.73, 0),
                          icon: Icons.arrow_forward_rounded,
                        ),
                        _positionButton(
                          mode: 3,
                          alignment: const Alignment(0.73, 0),
                          icon: Icons.arrow_back_rounded,
                        ),
                        _positionButton(
                          mode: 4,
                          alignment: const Alignment(-0.57, -0.50),
                          icon: Icons.arrow_downward_rounded,
                          angle: -math.pi / 4,
                        ),
                        _positionButton(
                          mode: 5,
                          alignment: const Alignment(0.57, -0.50),
                          icon: Icons.arrow_downward_rounded,
                          angle: math.pi / 4,
                        ),
                        _positionButton(
                          mode: 6,
                          alignment: const Alignment(-0.57, 0.50),
                          icon: Icons.arrow_upward_rounded,
                          angle: math.pi / 4,
                        ),
                        _positionButton(
                          mode: 7,
                          alignment: const Alignment(0.57, 0.50),
                          icon: Icons.arrow_upward_rounded,
                          angle: -math.pi / 4,
                        ),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: _efbBg.withOpacity(0.92),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: _efbBorder.withOpacity(0.7)),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                  color: Color(0x44000000), blurRadius: 16),
                            ],
                          ),
                          child: const Icon(
                            Icons.airplanemode_active_rounded,
                            color: _efbWhite,
                            size: 55,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionButton({
    required int mode,
    required Alignment alignment,
    required IconData icon,
    double angle = 0,
  }) {
    final bool customEnabled = _TcasSessionState.customHeadingEnabled;
    final bool selected =
        !customEnabled && _TcasSessionState.selectedMode == mode;
    final bool available = !customEnabled && !_working;
    return Align(
      alignment: alignment,
      child: Semantics(
        button: true,
        enabled: available,
        label: _modeLabel(mode),
        child: Tooltip(
          message: _modeLabel(mode),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: available ? () => _selectPosition(mode) : null,
              borderRadius: BorderRadius.circular(8),
              splashColor: _efbAccent.withOpacity(0.25),
              highlightColor: _efbAccent.withOpacity(0.12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected
                      ? _efbAccent.withOpacity(0.23)
                      : const Color(0xFF0A1420).withOpacity(0.95),
                  border: Border.all(
                    color: selected
                        ? _efbAccent
                        : _efbAccent.withOpacity(customEnabled ? 0.22 : 0.78),
                    width: selected ? 1.7 : 1.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? const <BoxShadow>[
                          BoxShadow(
                              color: Color(0x88639DF0),
                              blurRadius: 17,
                              spreadRadius: 1),
                        ]
                      : null,
                ),
                child: Opacity(
                  opacity: customEnabled ? 0.26 : 1,
                  child: Center(
                    child: Transform.rotate(
                      angle: angle,
                      child: Icon(
                        icon,
                        color: _efbAccent,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _modeLabel(int mode) {
    const List<String> labels = <String>[
      'AHEAD',
      'BEHIND',
      'LEFT',
      'RIGHT',
      'FRONT LEFT',
      'FRONT RIGHT',
      'REAR LEFT',
      'REAR RIGHT',
    ];
    return labels[mode];
  }

  Widget _buildIntruderPanel() {
    return _panel(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panelTitle('INTRUDER TRAFFIC'),
          const SizedBox(height: 5),
          Expanded(
            child: _TcasSessionState.intruders.isEmpty
                ? _buildEmptyTrafficState()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _TcasSessionState.intruders.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: _efbBorder.withOpacity(0.9),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final _TcasIntruder target =
                          _TcasSessionState.intruders[index];
                      return _buildIntruderRow(target);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrafficState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.airplanemode_inactive_rounded,
                size: 42, color: _efbAccent.withOpacity(0.42)),
            const SizedBox(height: 12),
            const Text(
              'NO INTRUDER TRAFFIC',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _efbTextMuted,
                fontSize: 11,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Generate an aircraft to begin',
              textAlign: TextAlign.center,
              style: TextStyle(color: _efbTextMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntruderRow(_TcasIntruder target) {
    final String altitude = target.relativeAltitudeFt >= 0
        ? '+${target.relativeAltitudeFt.round()}'
        : '${target.relativeAltitudeFt.round()}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.airplanemode_active_rounded,
                  color: Color(0xFFB7CCE9), size: 29),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: target.levelColor.withOpacity(0.10),
                        border: Border.all(
                            color: target.levelColor.withOpacity(0.65)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: target.levelColor,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: target.levelColor.withOpacity(0.55),
                                    blurRadius: 5),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            target.level,
                            style: TextStyle(
                              color: target.levelColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target.callsign,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _efbWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: _efbAccent.withOpacity(0.9)),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: _metricCell(
                  'REL. BEARING',
                  '${target.bearingDeg.round().toString().padLeft(3, '0')}°',
                ),
              ),
              Expanded(
                child: _metricCell(
                    'DISTANCE', '${_formatNumber(target.distanceNm)} NM'),
              ),
              Expanded(
                child: _metricCell('ALT. SEPARATION', '$altitude FT'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Widget _metricCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8FA9CE),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _efbWhite,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassLabel extends StatelessWidget {
  const _CompassLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB9CCE7),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height).toDouble() * 0.43;
    final Paint ringPaint = Paint()
      ..color = const Color(0xFF3B5778).withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final double fraction in <double>[0.42, 0.68, 1.0]) {
      _drawDashedCircle(canvas, center, radius * fraction, ringPaint);
    }

    final Paint innerGlow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          _efbAccent.withOpacity(0.055),
          _efbAccent.withOpacity(0.012),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.73));
    canvas.drawCircle(center, radius * 0.73, innerGlow);
  }

  void _drawDashedCircle(
      Canvas canvas, Offset center, double radius, Paint paint) {
    const double dash = 0.075;
    const double gap = 0.055;
    double angle = 0;
    while (angle < math.pi * 2) {
      final double end = math.min(angle + dash, math.pi * 2).toDouble();
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        end - angle,
        false,
        paint,
      );
      angle += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => false;
}
