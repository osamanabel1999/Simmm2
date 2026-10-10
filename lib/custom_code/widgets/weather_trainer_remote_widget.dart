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

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show FontFeature;

/// Weather Trainer send-only remote panel.
///
/// IMPORTANT: - The widget sends commands and writable DataRefs to X-Plane
/// via UDP. - It does not receive simulator state. Values displayed here are
/// local draft values and cannot reflect Load/Apply effects made inside
/// X-Plane unless the user changes them here or a receive protocol is added
/// later. - X-Plane must be configured to accept UDP input on port 49000.
class WeatherTrainerRemoteWidget extends StatefulWidget {
  const WeatherTrainerRemoteWidget({
    super.key,
    this.width,
    this.height,
    required this.ipAddress,
  });

  final double? width;
  final double? height;
  final String ipAddress;

  @override
  State<WeatherTrainerRemoteWidget> createState() =>
      _WeatherTrainerRemoteWidgetState();
}

class _WeatherTrainerRemoteWidgetState
    extends State<WeatherTrainerRemoteWidget> {
  static const String _pathPrefix = 'qX7_9vK/4mZ_2p8/';
  static const int _xPlanePort = 49000;

  // Approved EFB night palette.
  static const Color _bg = Color(0xFF0B111A);
  static const Color _card = Color(0xFF101923);
  static const Color _border = Color(0xFF26364D);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _buttonDark = Color(0xFF15335E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _danger = Color(0xFFFF5252);
  static const Color _warn = Color(0xFFFFD740);
  static const Color _good = Color(0xFF69F0AE);
  static const Color _fieldBg = Color(0xFF0B1521);
  static const Color _heading = Color(0xFF9BB8E1);
  static const Color _smallValue = Color(0xFF8FA9CE);
  static const Color _directionInactive = Color(0xF20A1420);
  static const Color _compass = Color(0xFFB9CCE7);
  static const Color _aircraft = Color(0xFFB7CCE9);
  static const Color _headingControlBg = Color(0xFF243244);

  int _page = 0; // k001..k004 / v001
  int _subTab = 0; // k009..k012 / v002
  int _cloudLayer = 0; // k013..k015 / v003
  int _windLayer = 0; // k053..k055 / v004
  int _month = 1;
  int _day = 1;
  int _hour = 12;
  int _minute = 0;
  int _gmtOffsetMinutes = 0;
  int _timeSeconds = 43200;
  bool _trackSystemTimeDraft = false;
  bool _rvrModeDraft = false;
  bool _nativeWindowDraft = false;
  String _lastTx = 'Ready';
  int _sentPackets = 0;
  int _selectedTurbulence = 0;
  int _selectedIcing = 0;
  int _precipType = 0;
  int _precipRate = 0;
  int _selectedWindTurbulence = 0;
  final Map<int, double> _values = <int, double>{};
  final Map<int, TextEditingController> _controllers =
      <int, TextEditingController>{};

  static const List<String> _months = <String>[
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
  static const List<String> _mainPageTitles = <String>[
    'TIME / SEASON',
    'USER-DEFINED WEATHER',
    'REAL-WORLD WEATHER',
    'PRESET WEATHER',
  ];
  static const List<String> _subTabTitles = <String>[
    'CLOUDS',
    'WIND',
    'TEMP / PRESS',
    'VISIBILITY'
  ];
  static const List<String> _cloudTypes = <String>[
    'Cirrus',
    'Stratus',
    'Cumulus',
    'Thunderstorms'
  ];
  static const List<String> _coverageNames = <String>[
    '1/8',
    '2/8',
    '3/8',
    '4/8',
    '5/8',
    '6/8',
    '7/8',
    '8/8'
  ];
  static const List<String> _severityNames = <String>[
    'None',
    'Light',
    'Moderate',
    'Heavy',
    'Severe'
  ];
  static const List<String> _icingNames = <String>[
    'None',
    'Trace',
    'Light',
    'Moderate',
    'Severe'
  ];
  static const List<String> _precipNames = <String>[
    'None',
    'Rain',
    'Snow',
    'Convective'
  ];
  static const List<String> _rateNames = <String>[
    'Very Light',
    'Light',
    'Moderate',
    'Heavy',
    'Very Heavy'
  ];
  static const List<String> _presetNames = <String>[
    'Clear',
    'VFR Few Clouds',
    'VFR Scattered',
    'IFR Overcast',
    'Low Visibility',
    'Rain',
    'Snow Conditions',
    'Thunderstorm',
    'Icing Conditions',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDraftValues();
  }

  void _initializeDraftValues() {
    _values[5] = 43200.0;
    _values[6] = 12.0;
    _values[7] = 0.0;
    _values[8] = 0.0;
    _values[13] = 0.0;
    _values[14] = 1000.0;
    for (int i = 0; i < 3; i++) {
      final int base = 16 + i * 5;
      _values[base] = 0.0;
      _values[base + 1] = 2.0;
      _values[base + 2] = 0.0;
      _values[base + 3] = 1000.0 + i * 4000.0;
      _values[base + 4] = 5000.0 + i * 4000.0;
    }
    for (int i = 0; i < 3; i++) {
      final int base = 31 + i * 6;
      _values[base] = i == 0 ? 1.0 : 0.0;
      _values[base + 1] = i * 10000.0;
      _values[base + 2] = 270.0;
      _values[base + 3] = i == 0 ? 5.0 : 0.0;
      _values[base + 4] = i == 0 ? 5.0 : 0.0;
      _values[base + 5] = 0.0;
    }
    _values[49] = 20.0;
    _values[50] = 10.0;
    _values[51] = 1013.25;
    _values[52] = 10.0;
    _values[53] = 1000.0;
    _values[54] = 0.0;
    _values[55] = 0.0;
    _values[56] = 0.0;
    _values[57] = 0.0;
    _values[58] = 1.0;
    _values[59] = 1.0;
    _values[60] = 0.0;
    _values[61] = 0.0;

    for (final int refId in <int>[
      19,
      20,
      24,
      25,
      29,
      30,
      32,
      33,
      34,
      35,
      36,
      38,
      39,
      40,
      41,
      42,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      14,
    ]) {
      _controllers[refId] = TextEditingController(
        text: _formatValue(_values[refId] ?? 0.0, _fieldDecimals(refId)),
      );
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatValue(double value, int decimals) =>
      value.toStringAsFixed(decimals);

  int _fieldDecimals(int refId) {
    if (refId == 51) return 2;
    if (refId == 52) return 1;
    if (refId == 14) return 0;
    if (refId == 33 || refId == 39 || refId == 45) return 0;
    return 0;
  }

  String _commandPath(int commandId) =>
      '$_pathPrefix' + 'k${commandId.toString().padLeft(3, '0')}';

  String _dataRefPath(int dataRefId) =>
      '$_pathPrefix' + 'v${dataRefId.toString().padLeft(3, '0')}';

  InternetAddress? _targetAddress() {
    final String raw = widget.ipAddress.trim();
    if (raw.isEmpty) return null;
    return InternetAddress.tryParse(raw);
  }

  Future<void> _sendCommand(int commandId, {String? label}) async {
    if (commandId < 1 || commandId > 205) {
      if (mounted) setState(() => _lastTx = 'Invalid command ID');
      return;
    }
    final InternetAddress? address = _targetAddress();
    if (address == null) {
      if (mounted) setState(() => _lastTx = 'Invalid IP address');
      return;
    }
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final String path = _commandPath(commandId);
      final List<int> packet = <int>[]
        ..addAll('CMND\x00'.codeUnits)
        ..addAll(path.codeUnits)
        ..add(0);
      final int sent = socket.send(packet, address, _xPlanePort);
      if (mounted) {
        setState(() {
          _sentPackets++;
          _lastTx = sent == packet.length
              ? 'Sent command k${commandId.toString().padLeft(3, '0')}${label == null ? '' : ' • $label'}'
              : 'Command send incomplete';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _lastTx = 'UDP command error: $e');
    } finally {
      socket?.close();
    }
  }

  Future<void> _sendDataRef(int dataRefId, double value,
      {String? label}) async {
    if (dataRefId < 1 ||
        dataRefId > 61 ||
        const <int>{9, 10, 12, 15}.contains(dataRefId)) {
      if (mounted) setState(() => _lastTx = 'Invalid or read-only DataRef ID');
      return;
    }
    final InternetAddress? address = _targetAddress();
    if (address == null) {
      if (mounted) setState(() => _lastTx = 'Invalid IP address');
      return;
    }
    final String path = _dataRefPath(dataRefId);
    if (path.codeUnits.length > 500) {
      if (mounted) setState(() => _lastTx = 'DataRef path exceeds 500 bytes');
      return;
    }
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final Uint8List header = Uint8List.fromList(<int>[68, 82, 69, 70, 0]);
      final ByteData number = ByteData(4);
      number.setFloat32(0, value, Endian.little);
      final Uint8List pathBuffer = Uint8List(500);
      pathBuffer.setRange(0, path.codeUnits.length, path.codeUnits);
      final BytesBuilder builder = BytesBuilder(copy: false)
        ..add(header)
        ..add(number.buffer.asUint8List())
        ..add(pathBuffer);
      final Uint8List packet = builder.toBytes();
      final int sent = socket.send(packet, address, _xPlanePort);
      if (mounted) {
        setState(() {
          _sentPackets++;
          _lastTx = sent == packet.length
              ? 'Sent DataRef v${dataRefId.toString().padLeft(3, '0')} = ${value.toStringAsFixed(2)}${label == null ? '' : ' • $label'}'
              : 'DataRef send incomplete';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _lastTx = 'UDP DataRef error: $e');
    } finally {
      socket?.close();
    }
  }

  Future<void> _sendValueAndCommand(
    int dataRefId,
    double value,
    int commandId, {
    String? label,
  }) async {
    await _sendDataRef(dataRefId, value, label: label);
    await _sendCommand(commandId, label: label);
  }

  Future<void> _selectPage(int page) async {
    if (page < 0 || page > 3) return;
    setState(() => _page = page);
    await _sendDataRef(1, page.toDouble(), label: 'Page');
    await _sendCommand(page + 1, label: _mainPageTitles[page]);
  }

  Future<void> _selectSubTab(int tab) async {
    setState(() => _subTab = tab);
    await _sendDataRef(2, tab.toDouble(), label: 'Weather subtab');
    await _sendCommand(9 + tab, label: _subTabTitles[tab]);
  }

  Future<void> _selectCloudLayer(int layer) async {
    setState(() => _cloudLayer = layer);
    await _sendDataRef(3, layer.toDouble(), label: 'Cloud layer ${layer + 1}');
    await _sendCommand(13 + layer, label: 'Cloud layer ${layer + 1}');
  }

  Future<void> _selectWindLayer(int layer) async {
    setState(() => _windLayer = layer);
    await _sendDataRef(4, layer.toDouble(), label: 'Wind layer ${layer + 1}');
    await _sendCommand(53 + layer, label: 'Wind layer ${layer + 1}');
  }

  static const List<int> _monthLengths = <int>[
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  int _dayOfYearFor(int month, int day) {
    int total = 0;
    for (int i = 0; i < month - 1; i++) {
      total += _monthLengths[i];
    }
    return total + day - 1;
  }

  Future<void> _chooseMonth(int month) async {
    final int adjustedDay = _day.clamp(1, _monthLengths[month - 1]).toInt();
    setState(() {
      _month = month;
      _day = adjustedDay;
      _trackSystemTimeDraft = false;
    });
    await _sendValueAndCommand(58, month.toDouble(), 107 + month,
        label: _months[month - 1]);
  }

  Future<void> _chooseDay(int day) async {
    final int adjustedDay = day.clamp(1, _monthLengths[_month - 1]).toInt();
    setState(() {
      _day = adjustedDay;
      _trackSystemTimeDraft = false;
    });
    await _sendValueAndCommand(59, adjustedDay.toDouble(), 119 + adjustedDay,
        label: 'Day $adjustedDay');
  }

  Future<void> _chooseHour(int hour) async {
    setState(() {
      _hour = hour;
      _timeSeconds = hour * 3600 + _minute * 60;
      _values[5] = _timeSeconds.toDouble();
      _values[6] = hour.toDouble();
      _trackSystemTimeDraft = false;
    });
    await _sendDataRef(6, hour.toDouble(), label: 'Hour $hour');
    await _sendCommand(151 + hour, label: 'Hour $hour');
    await _sendCommand(205, label: 'Manual time: system tracking off');
  }

  Future<void> _chooseMinute(int minute) async {
    setState(() {
      _minute = minute;
      _timeSeconds = _hour * 3600 + minute * 60;
      _values[5] = _timeSeconds.toDouble();
      _values[7] = minute.toDouble();
      _trackSystemTimeDraft = false;
    });
    await _sendDataRef(7, minute.toDouble(), label: 'Minute $minute');
    await _sendCommand(175 + (minute ~/ 5), label: 'Minute $minute');
    await _sendCommand(205, label: 'Manual time: system tracking off');
  }

  Future<void> _chooseGmtOffset(int minutes) async {
    setState(() {
      _gmtOffsetMinutes = minutes;
      _trackSystemTimeDraft = false;
    });
    await _sendCommand(195 + (minutes ~/ 15),
        label: 'GMT offset ${_formatOffset(minutes)}');
  }

  String _formatOffset(int minutes) {
    final String sign = minutes < 0 ? '-' : '+';
    final int absolute = minutes.abs();
    return '$sign${(absolute ~/ 60).toString().padLeft(2, '0')}:${(absolute % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _setTrackSystemTime(bool enabled) async {
    setState(() => _trackSystemTimeDraft = enabled);
    await _sendValueAndCommand(60, enabled ? 1.0 : 0.0, enabled ? 204 : 205,
        label: enabled ? 'Track system time ON' : 'Track system time OFF');
  }

  Future<void> _setTimeSlider(double rawValue) async {
    final int seconds =
        ((rawValue / 300.0).round() * 300).clamp(0, 86100).toInt();
    setState(() {
      _timeSeconds = seconds;
      _hour = seconds ~/ 3600;
      _minute = ((seconds % 3600) ~/ 60 ~/ 5) * 5;
      _values[5] = seconds.toDouble();
      _values[6] = _hour.toDouble();
      _values[7] = _minute.toDouble();
      _trackSystemTimeDraft = false;
    });
    await _sendCommand(205, label: 'Manual time: system tracking off');
    await _sendDataRef(5, seconds.toDouble(),
        label: 'Time slider ${_timeText}');
  }

  String get _timeText =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  Future<void> _commitNumberField(
    int refId,
    String raw, {
    double min = -1000000,
    double max = 1000000,
    int decimals = 0,
    String? label,
  }) async {
    final double? parsed = double.tryParse(raw.trim());
    if (parsed == null || !parsed.isFinite) {
      if (mounted)
        setState(
            () => _lastTx = 'Enter a valid number for ${label ?? 'field'}');
      return;
    }
    final double value = parsed.clamp(min, max).toDouble();
    setState(() {
      _values[refId] = value;
      final TextEditingController? controller = _controllers[refId];
      if (controller != null) {
        controller.value = TextEditingValue(
          text: _formatValue(value, decimals),
          selection: TextSelection.collapsed(
              offset: _formatValue(value, decimals).length),
        );
      }
      _lastTx = 'Preparing ${label ?? 'value'}';
    });
    await _sendDataRef(refId, value, label: label);
  }

  Future<void> _sendValue(int refId, double value, {String? label}) async {
    setState(() => _values[refId] = value);
    final TextEditingController? c = _controllers[refId];
    if (c != null) {
      final String text = _formatValue(value, _fieldDecimals(refId));
      c.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    await _sendDataRef(refId, value, label: label);
  }

  Future<void> _stepValue({
    required int refId,
    required double delta,
    required int commandId,
    required double min,
    required double max,
    required String label,
  }) async {
    final double next =
        ((_values[refId] ?? 0.0) + delta).clamp(min, max).toDouble();
    setState(() => _values[refId] = next);
    final TextEditingController? controller = _controllers[refId];
    if (controller != null) {
      final String nextText = _formatValue(next, _fieldDecimals(refId));
      controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
    await _sendCommand(commandId, label: label);
  }

  Future<void> _setLayerToggle({
    required int refId,
    required bool enabled,
    required int commandId,
    required String label,
  }) async {
    setState(() => _values[refId] = enabled ? 1.0 : 0.0);
    await _sendCommand(commandId, label: label);
    await _sendDataRef(refId, enabled ? 1.0 : 0.0, label: label);
  }

  Widget _panel(
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.fromLTRB(16, 16, 16, 14)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border, width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x16000000), blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child:
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: _heading,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: _muted, fontSize: 11, height: 1.3)),
              ],
            ])),
      ]),
    );
  }

  Widget _button(
    String label, {
    required VoidCallback onPressed,
    bool selected = false,
    bool destructive = false,
    bool compact = false,
    IconData? icon,
    double? minWidth,
  }) {
    final Color back = destructive
        ? const Color(0xFF381C24)
        : selected
            ? _buttonDark
            : _directionInactive;
    final Color edge = destructive ? _danger : (selected ? _accent : _border);
    return ConstrainedBox(
      constraints:
          BoxConstraints(minWidth: minWidth ?? 0, minHeight: compact ? 34 : 42),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(
                      color: Color(0x1F639DF0),
                      blurRadius: 12,
                      spreadRadius: 1),
                ]
              : const <BoxShadow>[],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: back,
            foregroundColor: destructive ? _danger : _white,
            disabledBackgroundColor: _card,
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 14, vertical: compact ? 7 : 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: edge, width: 1),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 16),
                  const SizedBox(width: 7)
                ],
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ]),
        ),
      ),
    );
  }

  Widget _choiceWrap(List<Widget> children,
          {double spacing = 8, double runSpacing = 8}) =>
      Wrap(spacing: spacing, runSpacing: runSpacing, children: children);

  Widget _selector<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
    VoidCallback? onTap,
    double width = 150,
  }) {
    return SizedBox(
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label.toUpperCase(),
                style: const TextStyle(
                    color: _heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _border, width: 1)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  dropdownColor: _card,
                  iconEnabledColor: _accent,
                  style: const TextStyle(
                      color: _white, fontSize: 13, fontWeight: FontWeight.w600),
                  items: values
                      .map((T item) => DropdownMenuItem<T>(
                          value: item,
                          child: Text(display(item),
                              overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: onChanged,
                  onTap: onTap,
                ),
              ),
            ),
          ]),
    );
  }

  Widget _numberField({
    required int refId,
    required String label,
    String unit = '',
    double min = -1000000,
    double max = 1000000,
    int decimals = 0,
    double width = 235,
  }) {
    final TextEditingController controller = _controllers.putIfAbsent(
      refId,
      () => TextEditingController(
          text: _formatValue(_values[refId] ?? 0.0, decimals)),
    );
    return SizedBox(
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label.toUpperCase(),
                style: const TextStyle(
                    color: _heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7)),
            const SizedBox(height: 5),
            Row(children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                      color: _white, fontSize: 14, fontWeight: FontWeight.w600),
                  cursorColor: _accent,
                  onSubmitted: (String value) => _commitNumberField(
                      refId, value,
                      min: min, max: max, decimals: decimals, label: label),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: _fieldBg,
                    suffixText: unit.isEmpty ? null : unit,
                    suffixStyle:
                        const TextStyle(color: _smallValue, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _border, width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _accent, width: 1)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _button('SEND',
                  compact: true,
                  selected: true,
                  icon: Icons.north_east,
                  onPressed: () => _commitNumberField(refId, controller.text,
                      min: min, max: max, decimals: decimals, label: label)),
            ]),
          ]),
    );
  }

  Widget _stepper({
    required int refId,
    required String label,
    required double step,
    required double min,
    required double max,
    required int minusCommand,
    required int plusCommand,
    String unit = '',
    int decimals = 0,
  }) {
    final double value = _values[refId] ?? 0.0;
    return _panel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label.toUpperCase(),
                style: const TextStyle(
                    color: _heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6)),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              _button('−',
                  compact: true,
                  onPressed: () => _stepValue(
                      refId: refId,
                      delta: -step,
                      commandId: minusCommand,
                      min: min,
                      max: max,
                      label: '$label −')),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      '${_formatValue(value, decimals)}${unit.isEmpty ? '' : ' $unit'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures()
                          ]))),
              const SizedBox(width: 8),
              _button('+',
                  compact: true,
                  selected: true,
                  onPressed: () => _stepValue(
                      refId: refId,
                      delta: step,
                      commandId: plusCommand,
                      min: min,
                      max: max,
                      label: '$label +')),
            ]),
          ]),
    );
  }

  Widget _toggle(
      {required String label,
      required bool value,
      required ValueChanged<bool> onChanged,
      String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _border, width: 1)),
      child: Row(children: <Widget>[
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Text(label,
                  style: const TextStyle(
                      color: _white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(color: _muted, fontSize: 10))
              ],
            ])),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: _good,
          activeTrackColor: _good.withOpacity(0.25),
          inactiveThumbColor: _muted,
          inactiveTrackColor: _border,
        ),
      ]),
    );
  }

  Widget _mainTabButton(int index) {
    return _button(
      _mainPageTitles[index],
      selected: _page == index,
      compact: true,
      onPressed: () => _selectPage(index),
      icon: <IconData>[
        Icons.schedule,
        Icons.cloud,
        Icons.public,
        Icons.tune
      ][index],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
          color: _card,
          border: Border(bottom: BorderSide(color: _border, width: 1))),
      child: Row(children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: _buttonDark,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _accent.withOpacity(0.45), width: 1)),
          child: const Icon(Icons.cloud_queue, color: _accent, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
              Text('WEATHER TRAINER',
                  style: TextStyle(
                      color: _white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1)),
              SizedBox(height: 3),
              Text('REMOTE CONTROL PANEL',
                  style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
            ])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
              color: _fieldBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _border, width: 1)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Text('X-PLANE TARGET',
                    style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text(
                    widget.ipAddress.trim().isEmpty
                        ? 'IP NOT SET'
                        : widget.ipAddress.trim(),
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ]),
        ),
      ]),
    );
  }

  Widget _buildTimePage() {
    final int offset = _gmtOffsetMinutes;
    final List<int> offsets = List<int>.generate(17, (int i) => -120 + i * 15);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Time and Season',
                    subtitle:
                        'Choose month, day, hour, minute and GMT correction. Values shown are local selections; simulator state is not received.'),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _selector<int>(
                      label: 'Month',
                      value: _month,
                      values: List<int>.generate(12, (int i) => i + 1),
                      display: (int m) => _months[m - 1],
                      width: 145,
                      onChanged: (int? m) {
                        if (m != null) _chooseMonth(m);
                      }),
                  _selector<int>(
                      label: 'Day',
                      value: _day,
                      values: List<int>.generate(31, (int i) => i + 1),
                      display: (int d) => d.toString().padLeft(2, '0'),
                      width: 100,
                      onChanged: (int? d) {
                        if (d != null) _chooseDay(d);
                      }),
                  _selector<int>(
                      label: 'Hour',
                      value: _hour,
                      values: List<int>.generate(24, (int i) => i),
                      display: (int h) => h.toString().padLeft(2, '0'),
                      width: 105,
                      onTap: () => _sendCommand(95, label: 'Focus hour entry'),
                      onChanged: (int? h) {
                        if (h != null) _chooseHour(h);
                      }),
                  _selector<int>(
                      label: 'Minute',
                      value: _minute,
                      values: List<int>.generate(12, (int i) => i * 5),
                      display: (int m) => m.toString().padLeft(2, '0'),
                      width: 105,
                      onTap: () =>
                          _sendCommand(96, label: 'Focus minute entry'),
                      onChanged: (int? m) {
                        if (m != null) _chooseMinute(m);
                      }),
                  _selector<int>(
                      label: 'GMT Offset',
                      value: offset,
                      values: offsets,
                      display: _formatOffset,
                      width: 145,
                      onChanged: (int? m) {
                        if (m != null) _chooseGmtOffset(m);
                      }),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      child: _sectionTitle('Time Slider',
                          subtitle:
                              '00:00–23:55 • 5-minute steps • value sent as seconds from midnight.')),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                        color: _fieldBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _accent, width: 1)),
                    child: Text(_timeText,
                        style: const TextStyle(
                            color: _white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            fontFeatures: <FontFeature>[
                              FontFeature.tabularFigures()
                            ])),
                  ),
                ]),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _accent,
                    inactiveTrackColor: _border,
                    thumbColor: _white,
                    overlayColor: _accent.withOpacity(0.15),
                    valueIndicatorColor: _buttonDark,
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value:
                        _timeSeconds.toDouble().clamp(0.0, 86100.0).toDouble(),
                    min: 0,
                    max: 86100,
                    divisions: 287,
                    label: _timeText,
                    onChanged: (double value) {
                      final int seconds =
                          ((value / 300).round() * 300).clamp(0, 86100).toInt();
                      setState(() {
                        _timeSeconds = seconds;
                        _hour = seconds ~/ 3600;
                        _minute = ((seconds % 3600) ~/ 60 ~/ 5) * 5;
                        _trackSystemTimeDraft = false;
                      });
                    },
                    onChangeEnd: _setTimeSlider,
                  ),
                ),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('00:00',
                          style: TextStyle(color: _smallValue, fontSize: 10)),
                      Text('06:00',
                          style: TextStyle(color: _smallValue, fontSize: 10)),
                      Text('12:00',
                          style: TextStyle(color: _smallValue, fontSize: 10)),
                      Text('18:00',
                          style: TextStyle(color: _smallValue, fontSize: 10)),
                      Text('23:55',
                          style: TextStyle(color: _smallValue, fontSize: 10)),
                    ]),
                const SizedBox(height: 14),
                _choiceWrap(<Widget>[
                  _button('DAY −',
                      compact: true,
                      icon: Icons.remove,
                      onPressed: () => _stepDate(-1)),
                  _button('DAY +',
                      compact: true,
                      selected: true,
                      icon: Icons.add,
                      onPressed: () => _stepDate(1)),
                  _button('HOUR −',
                      compact: true, onPressed: () => _stepTime(hours: -1)),
                  _button('HOUR +',
                      compact: true,
                      selected: true,
                      onPressed: () => _stepTime(hours: 1)),
                  _button('−10 MIN',
                      compact: true, onPressed: () => _stepTime(minutes: -10)),
                  _button('+10 MIN',
                      compact: true,
                      selected: true,
                      onPressed: () => _stepTime(minutes: 10)),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('System Time',
                    subtitle:
                        'This sends the plugin command and writable DataRef. The widget does not read back or confirm the simulator state.'),
                _toggle(
                  label: 'TRACK SYSTEM TIME',
                  value: _trackSystemTimeDraft,
                  subtitle:
                      'Local toggle only • simulator state is not read back',
                  onChanged: _setTrackSystemTime,
                ),
              ])),
        ]);
  }

  Future<void> _stepTime({int hours = 0, int minutes = 0}) async {
    final int seconds =
        (_timeSeconds + hours * 3600 + minutes * 60).clamp(0, 86100).toInt();
    setState(() {
      _timeSeconds = ((seconds / 300).round() * 300).clamp(0, 86100).toInt();
      _hour = _timeSeconds ~/ 3600;
      _minute = ((_timeSeconds % 3600) ~/ 60 ~/ 5) * 5;
      _trackSystemTimeDraft = false;
    });
    final int commandId = hours < 0
        ? 91
        : hours > 0
            ? 92
            : minutes < 0
                ? 93
                : 94;
    await _sendCommand(commandId, label: 'Time step');
  }

  Future<void> _stepDate(int delta) async {
    int nextMonth = _month;
    int nextDay = _day + delta;
    const List<int> monthDays = <int>[
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    if (nextDay > monthDays[nextMonth - 1]) {
      nextDay = 1;
      nextMonth = nextMonth == 12 ? 1 : nextMonth + 1;
    } else if (nextDay < 1) {
      nextMonth = nextMonth == 1 ? 12 : nextMonth - 1;
      nextDay = monthDays[nextMonth - 1];
    }
    setState(() {
      _month = nextMonth;
      _day = nextDay;
      _trackSystemTimeDraft = false;
    });
    await _sendCommand(delta < 0 ? 89 : 90,
        label: delta < 0 ? 'Day minus' : 'Day plus');
  }

  Widget _cloudProfileBar({
    required int index,
    required double columnWidth,
    required double chartHeight,
    required double Function(double) yFor,
  }) {
    final int baseRef = 16 + index * 5;
    final double base =
        _values[baseRef + 3] ?? (1000 + index * 4000).toDouble();
    final double top = _values[baseRef + 4] ?? (5000 + index * 4000).toDouble();
    final double barTop = yFor(top);
    final double barBottom = yFor(base);
    final double barHeight =
        (barBottom - barTop).abs().clamp(6.0, chartHeight).toDouble();
    final bool active = (_values[baseRef] ?? 0) != 0;
    final bool selected = _cloudLayer == index;
    return Positioned(
      left: columnWidth * index + 4,
      width: columnWidth - 8,
      top: barTop.clamp(0.0, chartHeight - 6.0).toDouble(),
      height: barHeight,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              active ? _accent.withOpacity(selected ? 0.52 : 0.26) : _fieldBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: selected ? _accent : _border, width: 1),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(color: Color(0x88639DF0), blurRadius: 9)
                ]
              : const <BoxShadow>[],
        ),
        child: Text(
          'L${index + 1}',
          style: TextStyle(
              color: active ? _white : _muted,
              fontSize: 10,
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildCloudProfileGraphic() {
    const double chartHeight = 150;
    const List<int> ticks = <int>[40000, 30000, 20000, 10000, 0];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionTitle('Cloud Profile',
                subtitle:
                    'Altitude profile • local draft only, not simulator readback.'),
            SizedBox(
              height: chartHeight,
              child: Row(children: <Widget>[
                SizedBox(
                  width: 58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: ticks
                        .map((int tick) => Text(
                              tick == 0 ? '0 ft' : '${tick ~/ 1000}k',
                              style: const TextStyle(
                                  color: _smallValue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    final double h = constraints.maxHeight;
                    final double colWidth = constraints.maxWidth / 3;
                    double yFor(double altitude) =>
                        (1 - (altitude.clamp(0.0, 40000.0) / 40000.0)) * h;
                    return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          for (final int tick in ticks)
                            Positioned(
                              top: yFor(tick.toDouble())
                                  .clamp(0.0, h - 1.0)
                                  .toDouble(),
                              left: 0,
                              right: 0,
                              child: Container(height: 1, color: _border),
                            ),
                          for (int i = 0; i < 3; i++)
                            _cloudProfileBar(
                                index: i,
                                columnWidth: colWidth,
                                chartHeight: h,
                                yFor: yFor),
                        ]);
                  }),
                ),
              ]),
            ),
          ]),
    );
  }

  Widget _buildCloudsPage() {
    final int activeRef = 16 + _cloudLayer * 5;
    final int typeRef = activeRef + 1;
    final int coverageRef = activeRef + 2;
    final int baseRef = activeRef + 3;
    final int topRef = activeRef + 4;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Cloud Layers',
                    subtitle:
                        'Three editable layers • altitude in feet MSL • local draft values are not read from X-Plane.'),
                _buildCloudProfileGraphic(),
                const SizedBox(height: 10),
                Row(children: <Widget>[
                  Expanded(
                    child: _choiceWrap(List<Widget>.generate(
                        3,
                        (int i) => _button('LAYER ${i + 1}',
                            compact: true,
                            selected: _cloudLayer == i,
                            onPressed: () => _selectCloudLayer(i)))),
                  ),
                  const SizedBox(width: 8),
                  _button('ADD LAYER',
                      compact: true,
                      icon: Icons.add,
                      selected: true, onPressed: () async {
                    await _sendCommand(16, label: 'Add cloud layer');
                    final int target = _firstInactiveCloudLayer();
                    if (target >= 0) setState(() => _cloudLayer = target);
                  }),
                  const SizedBox(width: 8),
                  _button('DELETE',
                      compact: true,
                      destructive: true,
                      icon: Icons.delete_outline, onPressed: () async {
                    await _sendCommand(17,
                        label: 'Delete selected cloud layer');
                    setState(() {
                      _values[activeRef] = 0.0;
                      _values[coverageRef] = 0.0;
                    });
                  }),
                ]),
                const SizedBox(height: 14),
                _toggle(
                    label: 'CLOUD LAYER ${_cloudLayer + 1} ENABLED',
                    value: (_values[activeRef] ?? 0.0) != 0,
                    subtitle:
                        'Local control selection only • no simulator readback',
                    onChanged: (bool on) async {
                      await _sendValue(activeRef, on ? 1.0 : 0.0,
                          label: 'Cloud layer active');
                    }),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _numberField(
                      refId: topRef,
                      label: 'Top',
                      unit: 'ft',
                      min: 0,
                      max: 40000,
                      decimals: 0),
                  _numberField(
                      refId: baseRef,
                      label: 'Base',
                      unit: 'ft',
                      min: 0,
                      max: 40000,
                      decimals: 0),
                ]),
                const SizedBox(height: 12),
                _sliderEditor(
                    label: 'TOP ALTITUDE',
                    refId: topRef,
                    min: 0,
                    max: 40000,
                    step: 500,
                    unit: 'ft'),
                _sliderEditor(
                    label: 'BASE ALTITUDE',
                    refId: baseRef,
                    min: 0,
                    max: 40000,
                    step: 500,
                    unit: 'ft'),
                const SizedBox(height: 8),
                _choiceSection(
                    'CLOUD TYPE',
                    _cloudTypes
                        .asMap()
                        .entries
                        .map((MapEntry<int, String> e) => _button(e.value,
                                compact: true,
                                selected: (_values[typeRef] ?? 2).round() ==
                                    e.key, onPressed: () async {
                              setState(() {
                                _values[typeRef] = e.key.toDouble();
                                _values[activeRef] = 1.0;
                                if ((_values[coverageRef] ?? 0) == 0)
                                  _values[coverageRef] = 4.0;
                              });
                              await _sendValueAndCommand(
                                  typeRef, e.key.toDouble(), 22 + e.key,
                                  label: 'Cloud type ${e.value}');
                              await _sendDataRef(activeRef, 1.0,
                                  label: 'Cloud layer enabled');
                              await _sendDataRef(
                                  coverageRef, _values[coverageRef] ?? 4.0,
                                  label: 'Cloud coverage');
                            }))
                        .toList()),
                _choiceSection(
                    'COVERAGE',
                    List<Widget>.generate(
                        8,
                        (int i) => _button(_coverageNames[i],
                                compact: true,
                                selected: (_values[coverageRef] ?? 0).round() ==
                                    i + 1, onPressed: () async {
                              setState(() {
                                _values[coverageRef] = (i + 1).toDouble();
                                _values[activeRef] = 1.0;
                              });
                              await _sendValueAndCommand(
                                  coverageRef, (i + 1).toDouble(), 26 + i,
                                  label: 'Coverage ${i + 1}/8');
                              await _sendDataRef(activeRef, 1.0,
                                  label: 'Cloud layer enabled');
                            }))),
                _choiceSection(
                    'TURBULENCE PROFILE',
                    List<Widget>.generate(
                        5,
                        (int i) => _button(_severityNames[i],
                                compact: true,
                                selected: _selectedTurbulence == i,
                                onPressed: () async {
                              setState(() {
                                _selectedTurbulence = i;
                                _values[54] = i.toDouble();
                              });
                              await _sendValueAndCommand(
                                  54, i.toDouble(), 34 + i,
                                  label: 'Turbulence ${_severityNames[i]}');
                            }))),
                _choiceSection(
                    'ICING PROFILE',
                    List<Widget>.generate(
                        5,
                        (int i) => _button(_icingNames[i],
                                compact: true, selected: _selectedIcing == i,
                                onPressed: () async {
                              setState(() {
                                _selectedIcing = i;
                                _values[55] = i.toDouble();
                              });
                              await _sendValueAndCommand(
                                  55, i.toDouble(), 39 + i,
                                  label: 'Icing ${_icingNames[i]}');
                            }))),
                _choiceSection(
                    'PRECIPITATION TYPE',
                    List<Widget>.generate(
                        4,
                        (int i) => _button(_precipNames[i],
                                compact: true, selected: _precipType == i,
                                onPressed: () async {
                              setState(() {
                                _precipType = i;
                                _values[56] = i.toDouble();
                              });
                              await _sendValueAndCommand(
                                  56, i.toDouble(), 44 + i,
                                  label: 'Precipitation ${_precipNames[i]}');
                            }))),
                _choiceSection(
                    'PRECIPITATION RATE',
                    List<Widget>.generate(
                        5,
                        (int i) => _button(_rateNames[i],
                                compact: true, selected: _precipRate == i,
                                onPressed: () async {
                              setState(() {
                                _precipRate = i;
                                _values[57] = i.toDouble();
                              });
                              await _sendValueAndCommand(
                                  57, i.toDouble(), 48 + i,
                                  label: 'Precipitation rate ${_rateNames[i]}');
                            }))),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _numberField(
                      refId: 53,
                      label: 'Precipitation Base',
                      unit: 'ft MSL',
                      min: 0,
                      max: 40000),
                  SizedBox(
                      width: 230,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('PRECEDING FIELD STEPS',
                                style: TextStyle(
                                    color: _heading,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7)),
                            const SizedBox(height: 6),
                            _choiceWrap(<Widget>[
                              _button('TOP −500',
                                  compact: true,
                                  onPressed: () =>
                                      _stepCloud(topRef, -500.0, 18)),
                              _button('TOP +500',
                                  compact: true,
                                  selected: true,
                                  onPressed: () =>
                                      _stepCloud(topRef, 500.0, 19)),
                              _button('BASE −500',
                                  compact: true,
                                  onPressed: () =>
                                      _stepCloud(baseRef, -500.0, 20)),
                              _button('BASE +500',
                                  compact: true,
                                  selected: true,
                                  onPressed: () =>
                                      _stepCloud(baseRef, 500.0, 21)),
                            ]),
                          ])),
                ]),
                const SizedBox(height: 8),
                const Text(
                    'Icing and precipitation presets may also adjust related model values inside X-Plane. This widget intentionally does not receive those changes.',
                    style:
                        TextStyle(color: _muted, fontSize: 10, height: 1.35)),
              ])),
        ]);
  }

  int _firstInactiveCloudLayer() {
    for (int i = 0; i < 3; i++) {
      if ((_values[16 + i * 5] ?? 0) == 0) return i;
    }
    return -1;
  }

  Future<void> _stepCloud(int refId, double delta, int cmd) async {
    await _stepValue(
        refId: refId,
        delta: delta,
        commandId: cmd,
        min: 0,
        max: 40000,
        label: refId == 20 + _cloudLayer * 5 ? 'Cloud top' : 'Cloud base');
  }

  Widget _sliderEditor(
      {required String label,
      required int refId,
      required double min,
      required double max,
      required double step,
      required String unit}) {
    final double value = (_values[refId] ?? min).clamp(min, max).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(children: <Widget>[
        SizedBox(
            width: 115,
            child: Text(label,
                style: const TextStyle(
                    color: _heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5))),
        Expanded(
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _accent,
                    inactiveTrackColor: _border,
                    thumbColor: _white,
                    trackHeight: 3,
                    overlayColor: _accent.withOpacity(0.12)),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) / step).round(),
                  onChanged: (double next) => setState(() => _values[refId] =
                      ((next / step).round() * step)
                          .clamp(min, max)
                          .toDouble()),
                  onChangeEnd: (double next) => _sendValue(refId,
                      ((next / step).round() * step).clamp(min, max).toDouble(),
                      label: label),
                ))),
        SizedBox(
            width: 80,
            child: Text('${(_values[refId] ?? min).round()} $unit',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: _white, fontSize: 11, fontWeight: FontWeight.w700))),
      ]),
    );
  }

  Widget _choiceSection(String title, List<Widget> choices) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: const TextStyle(
                    color: _heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7)),
            const SizedBox(height: 7),
            _choiceWrap(choices),
          ]),
    );
  }

  Widget _buildWindLayerOverview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sectionTitle('Wind Layer Overview',
                subtitle:
                    'Values below are local draft estimates, not live simulator state.'),
            for (int i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == 2 ? 0 : 7),
                child: Row(children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _buttonDark,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: _border)),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: _white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                      child: Text('WIND LAYER ${i + 1}',
                          style: const TextStyle(
                              color: _white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700))),
                  Text(
                    (_values[31 + i * 6] ?? 0) != 0
                        ? 'ON • DRAFT'
                        : 'OFF • DRAFT',
                    style: TextStyle(
                        color: (_values[31 + i * 6] ?? 0) != 0 ? _good : _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Text('${(_values[32 + i * 6] ?? 0).round()} FT',
                      style: const TextStyle(
                          color: _smallValue,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
          ]),
    );
  }

  Widget _buildWindPage() {
    final int base = 31 + _windLayer * 6;
    final int activeRef = base;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Wind Layers',
                    subtitle:
                        'Three selectable wind layers • direction is TRUE degrees • speed and gust in knots.'),
                _choiceWrap(
                    List<Widget>.generate(
                        3,
                        (int i) => _button('WIND LAYER ${i + 1}',
                            compact: true,
                            selected: _windLayer == i,
                            icon: Icons.air,
                            onPressed: () => _selectWindLayer(i))),
                    spacing: 9),
                const SizedBox(height: 10),
                _buildWindLayerOverview(),
                const SizedBox(height: 12),
                _toggle(
                    label: 'WIND LAYER ${_windLayer + 1} ENABLED',
                    value: (_values[activeRef] ?? 0) != 0,
                    subtitle:
                        'Local control selection only • no simulator readback',
                    onChanged: (bool on) => _setLayerToggle(
                        refId: activeRef,
                        enabled: on,
                        commandId: 56,
                        label: 'Toggle selected wind layer')),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _numberField(
                      refId: base + 1,
                      label: 'Altitude',
                      unit: 'ft MSL',
                      min: 0,
                      max: 60000),
                  _numberField(
                      refId: base + 2,
                      label: 'Direction TRUE',
                      unit: 'deg',
                      min: 0,
                      max: 359),
                  _numberField(
                      refId: base + 3,
                      label: 'Wind Speed',
                      unit: 'kt',
                      min: 0,
                      max: 250),
                  _numberField(
                      refId: base + 4,
                      label: 'Gust Speed TOTAL',
                      unit: 'kt',
                      min: (_values[base + 3] ?? 0.0),
                      max: 300),
                  _numberField(
                      refId: base + 5,
                      label: 'Shear (Simulator Units)',
                      unit: '',
                      min: 0,
                      max: 180),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Wind Parameter Steps',
                    subtitle:
                        'These controls send the original increment/decrement commands. Displayed values are local estimates because this panel does not receive simulator data.'),
                Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
                  SizedBox(
                      width: 205,
                      child: _stepper(
                          refId: base + 1,
                          label: 'Altitude',
                          step: 1000,
                          min: 0,
                          max: 60000,
                          minusCommand: 57,
                          plusCommand: 58,
                          unit: 'ft')),
                  SizedBox(
                      width: 205,
                      child: _stepper(
                          refId: base + 2,
                          label: 'Direction',
                          step: 5,
                          min: 0,
                          max: 359,
                          minusCommand: 59,
                          plusCommand: 60,
                          unit: '°')),
                  SizedBox(
                      width: 205,
                      child: _stepper(
                          refId: base + 3,
                          label: 'Speed',
                          step: 5,
                          min: 0,
                          max: 250,
                          minusCommand: 61,
                          plusCommand: 62,
                          unit: 'kt')),
                  SizedBox(
                      width: 205,
                      child: _stepper(
                          refId: base + 4,
                          label: 'Gust',
                          step: 5,
                          min: (_values[base + 3] ?? 0.0),
                          max: 300,
                          minusCommand: 63,
                          plusCommand: 64,
                          unit: 'kt')),
                  SizedBox(
                      width: 205,
                      child: _stepper(
                          refId: base + 5,
                          label: 'Shear',
                          step: 5,
                          min: 0,
                          max: 180,
                          minusCommand: 65,
                          plusCommand: 66,
                          unit: '')),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Turbulence Profile',
                    subtitle:
                        'Shared turbulence profile for the weather layers.'),
                _choiceWrap(List<Widget>.generate(
                    5,
                    (int i) => _button(_severityNames[i],
                            compact: true,
                            selected: _selectedWindTurbulence == i,
                            onPressed: () async {
                          setState(() {
                            _selectedWindTurbulence = i;
                            _values[54] = i.toDouble();
                          });
                          await _sendValueAndCommand(54, i.toDouble(), 67 + i,
                              label: 'Wind turbulence ${_severityNames[i]}');
                        }))),
              ])),
        ]);
  }

  Widget _buildTempPage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Surface / Sea-Level Conditions',
                    subtitle:
                        'Values are editable locally and transmitted to the matching DataRefs.'),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _numberField(
                      refId: 49,
                      label: 'Temperature',
                      unit: '°C',
                      min: -80,
                      max: 60),
                  _numberField(
                      refId: 50,
                      label: 'Dew Point',
                      unit: '°C',
                      min: -100,
                      max: (_values[49] ?? 20.0)),
                  _numberField(
                      refId: 51,
                      label: 'QNH',
                      unit: 'hPa',
                      min: 870,
                      max: 1085,
                      decimals: 2),
                ]),
                const SizedBox(height: 16),
                Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
                  SizedBox(
                      width: 220,
                      child: _stepper(
                          refId: 49,
                          label: 'Temperature',
                          step: 1,
                          min: -80,
                          max: 60,
                          minusCommand: 72,
                          plusCommand: 73,
                          unit: '°C')),
                  SizedBox(
                      width: 220,
                      child: _stepper(
                          refId: 50,
                          label: 'Dew Point',
                          step: 1,
                          min: -100,
                          max: (_values[49] ?? 20.0),
                          minusCommand: 74,
                          plusCommand: 75,
                          unit: '°C')),
                  SizedBox(
                      width: 220,
                      child: _stepper(
                          refId: 51,
                          label: 'QNH',
                          step: 1,
                          min: 870,
                          max: 1085,
                          minusCommand: 76,
                          plusCommand: 77,
                          unit: 'hPa',
                          decimals: 2)),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Standard Atmosphere',
                    subtitle:
                        'Loads ISA surface values into the Weather Trainer model; it does not apply weather until Apply is pressed.'),
                _choiceWrap(<Widget>[
                  _button('STANDARD ATMOSPHERE',
                      selected: true,
                      icon: Icons.straighten, onPressed: () async {
                    setState(() {
                      _values[49] = 15.0;
                      _values[50] = 10.0;
                      _values[51] = 1013.25;
                    });
                    await _sendCommand(78, label: 'Standard atmosphere');
                    await _sendDataRef(49, 15.0, label: 'Temperature');
                    await _sendDataRef(50, 10.0, label: 'Dew point');
                    await _sendDataRef(51, 1013.25, label: 'QNH');
                    _syncControllers(<int>[49, 50, 51]);
                  }),
                ]),
                const SizedBox(height: 10),
                const Text(
                    'Standard pressure: 1013.25 hPa (29.92 inHg) • ISA sea-level temperature: 15 °C • Dew point is limited to the current local temperature draft.',
                    style: TextStyle(color: _muted, fontSize: 11, height: 1.4)),
              ])),
        ]);
  }

  void _syncControllers(List<int> refs) {
    for (final int id in refs) {
      final TextEditingController? c = _controllers[id];
      if (c != null) {
        final String text = _formatValue(_values[id] ?? 0, _fieldDecimals(id));
        c.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length));
      }
    }
  }

  Widget _buildVisibilityPage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Visibility and Precipitation',
                    subtitle:
                        'Visibility uses kilometers. Precipitation base is feet MSL.'),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _numberField(
                      refId: 52,
                      label: 'Visibility',
                      unit: 'km',
                      min: 0.1,
                      max: 80,
                      decimals: 1),
                  _numberField(
                      refId: 53,
                      label: 'Precipitation Base',
                      unit: 'ft MSL',
                      min: 0,
                      max: 40000),
                  _numberField(
                      refId: 14,
                      label: 'RVR Target',
                      unit: 'm',
                      min: 0,
                      max: 6000),
                ]),
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
                  SizedBox(
                      width: 220,
                      child: _stepper(
                          refId: 52,
                          label: 'Visibility',
                          step: 1,
                          min: 0.1,
                          max: 80,
                          minusCommand: 79,
                          plusCommand: 80,
                          unit: 'km',
                          decimals: 1)),
                  SizedBox(
                      width: 220,
                      child: _stepper(
                          refId: 53,
                          label: 'Precipitation Base',
                          step: 500,
                          min: 0,
                          max: 40000,
                          minusCommand: 81,
                          plusCommand: 82,
                          unit: 'ft')),
                ]),
                const SizedBox(height: 12),
                _toggle(
                    label: 'RVR TRAINING MODE',
                    value: _rvrModeDraft,
                    subtitle: _rvrModeDraft
                        ? 'Local request: RVR proxy • not runway sensor data'
                        : 'Local request: standard visibility • simulator state is not read back',
                    onChanged: (bool enabled) async {
                      setState(() {
                        _rvrModeDraft = enabled;
                        _values[13] = enabled ? 1.0 : 0.0;
                      });
                      await _sendCommand(88,
                          label:
                              enabled ? 'RVR mode ON' : 'Visibility mode ON');
                      await _sendDataRef(13, enabled ? 1.0 : 0.0,
                          label: 'RVR mode');
                    }),
                const SizedBox(height: 10),
                _choiceSection(
                    'PRECIPITATION RATE',
                    List<Widget>.generate(
                        5,
                        (int i) => _button(_rateNames[i],
                                compact: true, selected: _precipRate == i,
                                onPressed: () async {
                              setState(() {
                                _precipRate = i;
                                _values[57] = i.toDouble();
                              });
                              await _sendValueAndCommand(
                                  57, i.toDouble(), 83 + i,
                                  label:
                                      'Visibility precipitation rate ${_rateNames[i]}');
                            }))),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('RVR Training Note'),
                const Text(
                    'RVR is runway-specific in real operations. This control sends a training target that Weather Trainer uses as an atmospheric horizontal-visibility proxy (minimum effective proxy 100 m). It does not create runway transmissometers, runway lights, or real RVR sensor reports.',
                    style:
                        TextStyle(color: _muted, fontSize: 12, height: 1.45)),
              ])),
        ]);
  }

  Widget _buildUserWeatherPage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _choiceWrap(
              List<Widget>.generate(
                  4,
                  (int i) => _button(_subTabTitles[i],
                      compact: true,
                      selected: _subTab == i,
                      icon: <IconData>[
                        Icons.cloud_queue,
                        Icons.air,
                        Icons.thermostat,
                        Icons.visibility
                      ][i],
                      onPressed: () => _selectSubTab(i))),
              spacing: 8,
              runSpacing: 8),
          const SizedBox(height: 12),
          if (_subTab == 0) _buildCloudsPage(),
          if (_subTab == 1) _buildWindPage(),
          if (_subTab == 2) _buildTempPage(),
          if (_subTab == 3) _buildVisibilityPage(),
        ]);
  }

  Widget _buildRealWeatherPage() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Real-World Weather',
                    subtitle:
                        'Send-only controls. No state or text is received from the simulator.'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _border, width: 1)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.public, color: _accent, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              Text('SIMULATOR WEATHER MODE',
                                  style: TextStyle(
                                      color: _white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 5),
                              Text(
                                  'Enable Real-World Weather asks the plugin to switch X-Plane to real weather. Return to User Weather requests the manual weather mode. This widget cannot confirm which mode the simulator accepted.',
                                  style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.45)),
                            ])),
                      ]),
                ),
                const SizedBox(height: 16),
                Wrap(spacing: 12, runSpacing: 12, children: <Widget>[
                  _button('ENABLE REAL-WORLD WEATHER',
                      icon: Icons.public,
                      minWidth: 230,
                      onPressed: () =>
                          _sendCommand(97, label: 'Enable real-world weather')),
                  _button('RETURN TO USER WEATHER',
                      icon: Icons.tune,
                      minWidth: 230,
                      onPressed: () =>
                          _sendCommand(98, label: 'Return to user weather')),
                ]),
              ])),
          const SizedBox(height: 12),
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Remote Mode Policy'),
                const Text(
                    'No response listener is implemented, by design. Button highlighting indicates the action button style only; it is not a live indication of X-Plane weather-mode state.',
                    style:
                        TextStyle(color: _muted, fontSize: 12, height: 1.45)),
              ])),
        ]);
  }

  Widget _buildPresetsPage() {
    final List<IconData> icons = <IconData>[
      Icons.wb_sunny_outlined,
      Icons.cloud_outlined,
      Icons.cloud_queue,
      Icons.cloud,
      Icons.visibility_off_outlined,
      Icons.grain,
      Icons.ac_unit,
      Icons.flash_on,
      Icons.ac_unit,
    ];
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                _sectionTitle('Training Presets',
                    subtitle:
                        'Each preset sends its matching plugin command. The displayed weather values are local draft estimates because the simulator is not sending state back to this widget.'),
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  final int columns = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 560
                          ? 2
                          : 1;
                  final double gap = 10;
                  final double itemWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: List<Widget>.generate(
                          9,
                          (int i) => SizedBox(
                                width: itemWidth,
                                child: _button(_presetNames[i],
                                    minWidth: itemWidth,
                                    icon: icons[i],
                                    selected: false,
                                    onPressed: () => _choosePreset(i)),
                              )));
                }),
                const SizedBox(height: 12),
                const Text(
                    'These are representative training scenarios. They are not a promise of exact observed weather for a specific airport or date.',
                    style: TextStyle(color: _muted, fontSize: 11, height: 1.4)),
              ])),
        ]);
  }

  Future<void> _choosePreset(int preset) async {
    await _sendCommand(99 + preset, label: _presetNames[preset]);
    setState(() {
      _page = 1;
      _subTab = 0;
      _cloudLayer = 0;
      _windLayer = 0;
      _applyPresetDraft(preset);
    });
    await _sendDataRef(1, 1.0, label: 'User-defined page');
    await _sendDataRef(2, 0.0, label: 'Clouds subtab');
  }

  void _applyPresetDraft(int preset) {
    for (int i = 0; i < 3; i++) {
      final int c = 16 + i * 5;
      _values[c] = 0.0;
      _values[c + 1] = 2.0;
      _values[c + 2] = 0.0;
      _values[c + 3] = 1000.0 + i * 4000.0;
      _values[c + 4] = 5000.0 + i * 4000.0;
      final int w = 31 + i * 6;
      _values[w] = i == 0 ? 1.0 : 0.0;
      _values[w + 1] = i * 10000.0;
      _values[w + 2] = 270.0;
      _values[w + 3] = 0.0;
      _values[w + 4] = 0.0;
      _values[w + 5] = 0.0;
    }
    _values[49] = 20.0;
    _values[50] = 10.0;
    _values[51] = 1013.25;
    _values[52] = 10.0;
    _values[53] = 1000.0;
    _values[54] = 0.0;
    _values[55] = 0.0;
    _values[56] = 0.0;
    _values[57] = 0.0;
    switch (preset) {
      case 0:
        _values[52] = 40.0;
        _values[49] = 22.0;
        _values[50] = 10.0;
        _values[34] = 4.0;
        _values[35] = 4.0;
        break;
      case 1:
        _values[16] = 1.0;
        _values[17] = 2.0;
        _values[18] = 2.0;
        _values[19] = 6000.0;
        _values[20] = 10000.0;
        _values[52] = 10.0;
        _values[49] = 20.0;
        _values[50] = 12.0;
        _values[34] = 8.0;
        _values[35] = 10.0;
        break;
      case 2:
        _values[16] = 1.0;
        _values[17] = 2.0;
        _values[18] = 4.0;
        _values[19] = 3000.0;
        _values[20] = 7500.0;
        _values[52] = 10.0;
        _values[49] = 17.0;
        _values[50] = 11.0;
        _values[34] = 10.0;
        _values[35] = 14.0;
        break;
      case 3:
        _values[16] = 1.0;
        _values[17] = 1.0;
        _values[18] = 8.0;
        _values[19] = 500.0;
        _values[20] = 2400.0;
        _values[52] = 3.5;
        _values[49] = 8.0;
        _values[50] = 7.0;
        _values[34] = 12.0;
        _values[35] = 16.0;
        _values[51] = 1008.0;
        break;
      case 4:
        _values[16] = 1.0;
        _values[17] = 1.0;
        _values[18] = 8.0;
        _values[19] = 100.0;
        _values[20] = 900.0;
        _values[52] = 0.8;
        _values[49] = 2.0;
        _values[50] = 1.0;
        _values[34] = 3.0;
        _values[35] = 4.0;
        break;
      case 5:
        _values[16] = 1.0;
        _values[17] = 1.0;
        _values[18] = 7.0;
        _values[19] = 700.0;
        _values[20] = 5000.0;
        _values[52] = 4.0;
        _values[49] = 12.0;
        _values[50] = 11.0;
        _values[56] = 1.0;
        _values[57] = 2.0;
        _values[53] = 700.0;
        _values[34] = 18.0;
        _values[35] = 25.0;
        _values[51] = 1005.0;
        break;
      case 6:
        _values[16] = 1.0;
        _values[17] = 1.0;
        _values[18] = 8.0;
        _values[19] = 700.0;
        _values[20] = 5000.0;
        _values[52] = 2.0;
        _values[49] = -5.0;
        _values[50] = -6.0;
        _values[56] = 2.0;
        _values[57] = 3.0;
        _values[53] = 700.0;
        _values[34] = 12.0;
        _values[35] = 20.0;
        _values[51] = 1004.0;
        break;
      case 7:
        _values[16] = 1.0;
        _values[17] = 3.0;
        _values[18] = 8.0;
        _values[19] = 1800.0;
        _values[20] = 36000.0;
        _values[52] = 5.0;
        _values[49] = 25.0;
        _values[50] = 22.0;
        _values[56] = 3.0;
        _values[57] = 4.0;
        _values[53] = 1800.0;
        _values[34] = 25.0;
        _values[35] = 40.0;
        _values[33] = 210.0;
        _values[51] = 1002.0;
        _values[54] = 4.0;
        break;
      case 8:
        _values[16] = 1.0;
        _values[17] = 2.0;
        _values[18] = 6.0;
        _values[19] = 2500.0;
        _values[20] = 9000.0;
        _values[52] = 7.0;
        _values[49] = -6.0;
        _values[50] = -7.0;
        _values[56] = 1.0;
        _values[57] = 1.0;
        _values[53] = 2500.0;
        _values[34] = 15.0;
        _values[35] = 22.0;
        _values[54] = 2.0;
        _values[55] = 2.0;
        break;
    }
    _selectedTurbulence = (_values[54] ?? 0.0).round();
    _selectedIcing = (_values[55] ?? 0.0).round();
    _precipType = (_values[56] ?? 0.0).round();
    _precipRate = (_values[57] ?? 0.0).round();
    _selectedWindTurbulence = _selectedTurbulence;
    _syncControllers(_controllers.keys.toList());
  }

  void _resetDraftAfterClear() {
    for (int i = 0; i < 3; i++) {
      final int c = 16 + i * 5;
      _values[c] = 0.0;
      _values[c + 1] = 2.0;
      _values[c + 2] = 0.0;
      _values[c + 3] = 1000.0 + i * 4000.0;
      _values[c + 4] = 5000.0 + i * 4000.0;
      final int w = 31 + i * 6;
      _values[w] = i == 0 ? 1.0 : 0.0;
      _values[w + 1] = i * 10000.0;
      _values[w + 2] = 270.0;
      _values[w + 3] = 0.0;
      _values[w + 4] = 0.0;
      _values[w + 5] = 0.0;
    }
    _values[49] = 20.0;
    _values[50] = 10.0;
    _values[51] = 1013.25;
    _values[52] = 40.0;
    _values[53] = 1000.0;
    _values[54] = 0.0;
    _values[55] = 0.0;
    _values[56] = 0.0;
    _values[57] = 0.0;
    _values[13] = 0.0;
    _selectedTurbulence = 0;
    _selectedIcing = 0;
    _precipType = 0;
    _precipRate = 0;
    _selectedWindTurbulence = 0;
    _syncControllers(_controllers.keys.toList());
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
          color: _card,
          border: Border(top: BorderSide(color: _border, width: 1))),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              _button('LOAD SAVED WEATHER',
                  compact: true,
                  icon: Icons.folder_open,
                  onPressed: () =>
                      _sendCommand(5, label: 'Load saved weather')),
              _button('SAVE WEATHER',
                  compact: true,
                  icon: Icons.save_outlined,
                  onPressed: () => _sendCommand(6, label: 'Save weather')),
              _button('CLEAR ALL WEATHER',
                  compact: true,
                  destructive: true,
                  icon: Icons.delete_sweep_outlined, onPressed: () async {
                await _sendCommand(7, label: 'Clear all weather');
                setState(() {
                  _resetDraftAfterClear();
                  _rvrModeDraft = false;
                });
              }),
              _button('APPLY SELECTED WEATHER',
                  compact: true,
                  selected: true,
                  icon: Icons.cloud_upload_outlined,
                  onPressed: () =>
                      _sendCommand(8, label: 'Apply selected weather')),
            ]),
        const SizedBox(height: 8),
        Row(children: <Widget>[
          Icon(
              _lastTx.startsWith('UDP') || _lastTx.startsWith('Invalid')
                  ? Icons.error_outline
                  : Icons.send,
              size: 13,
              color: _lastTx.startsWith('UDP') || _lastTx.startsWith('Invalid')
                  ? _danger
                  : _accent),
          const SizedBox(width: 6),
          Expanded(
              child: Text(_lastTx,
                  style: const TextStyle(color: _smallValue, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          const Text('PC PANEL',
              style: TextStyle(
                  color: _muted, fontSize: 9, fontWeight: FontWeight.w800)),
          Transform.scale(
              scale: 0.72,
              child: Switch.adaptive(
                value: _nativeWindowDraft,
                onChanged: (bool visible) async {
                  setState(() => _nativeWindowDraft = visible);
                  await _sendDataRef(11, visible ? 1.0 : 0.0,
                      label: visible
                          ? 'Show native plugin panel'
                          : 'Hide native plugin panel');
                },
                activeColor: _good,
                activeTrackColor: _good.withOpacity(0.25),
                inactiveThumbColor: _muted,
                inactiveTrackColor: _border,
              )),
          const SizedBox(width: 4),
          Text('TX $_sentPackets',
              style: const TextStyle(
                  color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  Widget _buildPageBody() {
    switch (_page) {
      case 0:
        return _buildTimePage();
      case 1:
        return _buildUserWeatherPage();
      case 2:
        return _buildRealWeatherPage();
      default:
        return _buildPresetsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 900,
      child: Material(
        color: _bg,
        child: Column(children: <Widget>[
          _buildHeader(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(bottom: BorderSide(color: _border, width: 1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List<Widget>.generate(
                      4,
                      (int i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _mainTabButton(i)))),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 320),
                child: _buildPageBody(),
              ),
            ),
          ),
          _buildActionFooter(),
        ]),
      ),
    );
  }
}
