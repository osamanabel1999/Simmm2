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

import '/custom_code/widgets/index.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Native-Flutter counterpart of GSX Ground EFB v0.4.7 (no WebView).
///
/// The authoritative service state and all commands remain on GSX/Windows.
/// Provide the Windows PC's local IPv4 address in ipAddress (port 9050).
class GSXGroundOperationsWidget extends StatefulWidget {
  const GSXGroundOperationsWidget({
    super.key,
    this.width,
    this.height,
    required this.ipAddress,
  });
  final double? width;
  final double? height;
  final String ipAddress;

  @override
  State<GSXGroundOperationsWidget> createState() =>
      _GSXGroundOperationsWidgetState();
}

class _GsxStyle {
  static const Color bg = Color(0xFF0B111A);
  static const Color card = Color(0xFF101923);
  static const Color field = Color(0xFF0B1521);
  static const Color border = Color(0xFF26364D);
  static const Color accent = Color(0xFF639DF0);
  static const Color selected = Color(0xFF15335E);
  static const Color inactive = Color(0xFF0A1420);
  static const Color redBg = Color(0xFF381C24);
  static const Color danger = Color(0xFFFF5252);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8B949E);
  static const Color heading = Color(0xFF9BB8E1);
  static const Color small = Color(0xFF8FA9CE);
  static const Color success = Color(0xFF69F0AE);
  static const Color step = Color(0xFF10233B);
}

const Map<String, String> _gsxTitles = {
  'GPU': 'GROUND POWER UNIT',
  'Cleaning': 'CABIN CLEANING',
  'Lavatory': 'LAVATORY SERVICE',
  'Water': 'POTABLE WATER',
  'Catering': 'CATERING',
  'Refueling': 'REFUELING',
  'Boarding': 'BOARDING',
  'Deboarding': 'DEBOARDING',
  'Departure': 'DEPARTURE / PUSHBACK',
  'DeIce': 'DE-ICING',
  'OperateJetways': 'JETWAY',
  'OperateStairs': 'STAIRS',
};
const List<String> _boardingSteps = [
  'GPU',
  'Cleaning',
  'Lavatory',
  'Water',
  'Catering',
  'Refueling',
  'Boarding',
  'Departure',
  'DeIce',
];
const List<String> _deboardingSteps = [
  'GPU',
  'Deboarding',
  'Lavatory',
  'Water',
  'Cleaning',
];
const List<String> _mainTabs = [
  'QUICK OPERATIONS',
  'GSX MENU',
  'SETTINGS',
  'BILLING & SIMBRIEF',
];

Map<String, dynamic> _obj(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value
        .map((dynamic key, dynamic item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _items(dynamic value) => value is List ? value : <dynamic>[];
String _txt(dynamic value, [String fallback = '—']) {
  if (value == null || value == '' || value == 'null' || value == 'undefined')
    return fallback;
  return value.toString();
}

num? _num(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

bool _enabled(dynamic value) => value == true || value == 1;
String _pretty(String value) => value.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]} ${m[2]}');

class _GSXGroundOperationsWidgetState extends State<GSXGroundOperationsWidget> {
  http.Client _client = http.Client();
  Map<String, dynamic> _state = <String, dynamic>{};
  Map<String, dynamic> _bridge = <String, dynamic>{};
  final Map<String, String> _phaseOwner = <String, String>{};
  final Map<String, DateTime> _phasePending = <String, DateTime>{};
  final Set<String> _busy = <String>{};
  final List<String> _messageHistory = <String>[];
  final Map<String, String> _drafts = <String, String>{};
  final Map<String, double> _sliderDrafts = <String, double>{};
  final TextEditingController _aliasController = TextEditingController();
  final FocusNode _aliasFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final GlobalKey _interactionKey = GlobalKey();
  final GlobalKey _pageKey = GlobalKey();
  String _base = '';
  String _selectedGate = '';
  String? _selectedSettingsTab;
  String? _selectedSettingsSubtab;
  String _phase = 'boarding';
  int _screen = 0;
  bool _sendingDeIce = false;
  bool _acceptedDeIce = false;
  bool _hasLoadedAlias = false;
  bool _disposed = false;
  int _generation = 0;
  bool _dialogActive = false;
  String? _lastError;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _start(widget.ipAddress);
  }

  String _normalize(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return '';
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    Uri? parsed = Uri.tryParse(value);
    if (parsed == null ||
        parsed.host.isEmpty ||
        (parsed.scheme != 'http' && parsed.scheme != 'https')) return '';
    final port = parsed.hasPort ? parsed.port : 9050;
    return '${parsed.scheme}://${parsed.host}:$port';
  }

  void _start(String address) {
    _generation++;
    _reloadTimer?.cancel();
    _client.close();
    _client = http.Client();
    _base = _normalize(address);
    _state = <String, dynamic>{};
    _bridge = <String, dynamic>{};
    _acceptedDeIce = false;
    _sendingDeIce = false;
    _phaseOwner.clear();
    _phasePending.clear();
    _hasLoadedAlias = false;
    _lastError = null;
    if (_base.isNotEmpty) {
      final ticket = _generation;
      unawaited(_initialSnapshot(ticket));
      unawaited(_eventLoop(ticket));
    }
  }

  @override
  void didUpdateWidget(covariant GSXGroundOperationsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ipAddress != widget.ipAddress) {
      _start(widget.ipAddress);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _reloadTimer?.cancel();
    _client.close();
    _aliasController.dispose();
    _aliasFocus.dispose();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool _valid(int ticket) => !_disposed && mounted && ticket == _generation;

  Future<void> _initialSnapshot(int ticket) async {
    try {
      final r = await _client
          .get(Uri.parse('$_base/api/state'))
          .timeout(const Duration(seconds: 12));
      if (r.statusCode != 200 || !_valid(ticket)) return;
      final data = _obj(jsonDecode(r.body));
      if (!_valid(ticket)) return;
      setState(() {
        _bridge = _obj(data['bridge']);
        _state = _obj(data['state']);
        _observedMessage();
        _syncServices();
        _syncAlias();
      });
    } catch (_) {
      if (!_valid(ticket)) return;
      setState(() => _lastError = 'Waiting for the Windows GSX Bridge');
    }
  }

  Future<void> _eventLoop(int ticket) async {
    // SSE: one live stream, not a page refresh or periodic request loop.
    while (_valid(ticket) && _base.isNotEmpty) {
      try {
        final request = http.Request('GET', Uri.parse('$_base/api/events'));
        request.headers['Accept'] = 'text/event-stream';
        final response = await _client.send(request);
        if (response.statusCode != 200) {
          throw StateError('Live event endpoint rejected the connection');
        }
        String accumulated = '';
        await for (final line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (!_valid(ticket)) return;
          if (line.startsWith('data:')) {
            accumulated += line.substring(5).trimLeft();
          } else if (line.trim().isEmpty && accumulated.isNotEmpty) {
            try {
              _consume(_obj(jsonDecode(accumulated)));
            } catch (_) {
              // GSX supplied an invalid event; wait for the next valid frame.
            }
            accumulated = '';
          }
        }
      } catch (_) {
        if (_valid(ticket)) {
          setState(() => _bridge = {..._bridge, 'connected': false});
        }
      }
      if (!_valid(ticket)) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  void _consume(Map<String, dynamic> frame) {
    if (_disposed || !mounted) return;
    final kind = _txt(frame['kind'], '');
    setState(() {
      if (kind == 'bridge.status') {
        _bridge = _obj(frame['data']);
        if (_bridge['connected'] != true) {
          _acceptedDeIce = false;
          _sendingDeIce = false;
        }
      } else if (kind == 'snapshot') {
        _state = _obj(frame['data']);
        if (_state['services'] is! List) {
          _phaseOwner.clear();
          _phasePending.clear();
          _acceptedDeIce = false;
        }
      } else if (kind == 'patch') {
        final key = _txt(frame['key'], '');
        if (key.isNotEmpty) {
          if (frame['value'] == null) {
            _state.remove(key);
          } else {
            _state[key] = frame['value'];
          }
        }
      } else if (kind == 'event') {
        final event = _obj(frame['data']);
        if (event['topic'] == 'engine' && event['gsxRunning'] is bool) {
          _bridge = {..._bridge, 'gsxRunning': event['gsxRunning']};
        }
        if (event['topic'] == 'startup' && event['startup'] is Map) {
          _state['startup'] = event['startup'];
        }
      }
      _syncServices();
      _observedMessage();
      _syncAlias();
    });
  }

  void _observedMessage() {
    final message = _obj(_state['message']);
    if (message['visible'] != true) return;
    final text = _txt(message['text'], '').trim();
    if (text.isNotEmpty &&
        (_messageHistory.isEmpty || _messageHistory.first != text)) {
      _messageHistory.insert(0, text);
      if (_messageHistory.length > 4) _messageHistory.removeLast();
    }
  }

  void _syncServices() {
    final ice = _service('DeIce');
    final iceState = _txt(ice['state'], '').toLowerCase();
    if (ice.isEmpty ||
        <String>{
          'requested',
          'performing',
          'completing',
          'completed',
          'bypassed'
        }.contains(iceState)) {
      _acceptedDeIce = false;
    }
    for (final id in _phaseOwner.keys.toList()) {
      final svc = _service(id);
      final s = _txt(svc['state'], '').toLowerCase();
      if (<String>{'requested', 'performing', 'completing'}.contains(s)) {
        _phasePending.remove(id);
      }
      final pending = _phasePending[id];
      if (s == 'available' &&
          svc['canTrigger'] == true &&
          (pending == null ||
              DateTime.now().difference(pending).inMilliseconds > 3000)) {
        _phaseOwner.remove(id);
        _phasePending.remove(id);
      }
    }
  }

  void _syncAlias() {
    if (_hasLoadedAlias || _aliasFocus.hasFocus) return;
    final field = _aliasField();
    if (field.isEmpty) return;
    _aliasController.text = _txt(field['value'], '');
    _hasLoadedAlias = true;
  }

  Map<String, dynamic> _service(String id) {
    for (final item in _items(_state['services'])) {
      final svc = _obj(item);
      if (svc['id'] == id) return svc;
    }
    return <String, dynamic>{};
  }

  bool get _connected => _bridge['connected'] == true;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body,
      {bool silent = false}) async {
    if (!_connected) {
      if (!silent) _toast('GSX Bridge is not connected', error: true);
      return {
        'ok': false,
        'error': {'code': 'bridge_offline'}
      };
    }
    try {
      final response = await _client
          .post(
            Uri.parse('$_base$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 24));
      final payload = _obj(jsonDecode(response.body));
      if (payload['ok'] != true && !silent) {
        final error = _obj(payload['error']);
        _toast(
            _txt(error['message'],
                _txt(error['code'], 'GSX rejected the operation')),
            error: true);
      }
      return payload;
    } catch (_) {
      if (!silent) _toast('Unable to reach the Windows Bridge', error: true);
      return {
        'ok': false,
        'error': {'code': 'network_error'}
      };
    }
  }

  Future<Map<String, dynamic>> _command(String verb,
          [Map<String, dynamic> args = const {}]) =>
      _post('/api/command', {'verb': verb, 'args': args});

  Future<Map<String, dynamic>> _quick(String action, String service) =>
      _post('/api/quick', {'action': action, 'service': service});

  Future<void> _requestService(String id, String phase) async {
    if (_busy.contains(id) ||
        (id == 'DeIce' && (_acceptedDeIce || _sendingDeIce))) return;
    setState(() {
      _busy.add(id);
      if (id == 'DeIce') _sendingDeIce = true;
    });
    try {
      final response = await _command('service.trigger', {'service': id});
      if (!mounted) return;
      if (response['ok'] == true) {
        setState(() {
          _phaseOwner[id] = phase;
          _phasePending[id] = DateTime.now();
          if (id == 'DeIce') _acceptedDeIce = true;
        });
        _toast('${_gsxTitles[id] ?? id} request accepted by GSX');
      }
    } finally {
      if (mounted)
        setState(() {
          _busy.remove(id);
          _sendingDeIce = false;
        });
    }
  }

  Future<void> _quickService(String action, String id) async {
    final key = '$action/$id';
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      final response = await _quick(action, id);
      if (!mounted) return;
      if (response['ok'] == true) {
        _toast('${action.toUpperCase()} acknowledged by GSX');
      }
      if (response['needsInput'] == true) {
        _changeTab(1);
      }
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  Future<void> _menuCommand(String verb,
      [Map<String, dynamic> args = const {}]) async {
    await _command(verb, args);
  }

  Future<void> _pick(int index, String expected) async {
    await _menuCommand('menu.pick', {'index': index, 'expected': expected});
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(message,
          style: const TextStyle(color: _GsxStyle.white, fontSize: 12)),
      backgroundColor: error ? _GsxStyle.redBg : _GsxStyle.selected,
      duration: const Duration(seconds: 3),
    ));
  }

  void _changeTab(int index) {
    if (!mounted) return;
    setState(() => _screen = index);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    if (index == 1 && _connected && _state['menuShown'] != true) {
      unawaited(_menuCommand('menu.open'));
    }
    if (index == 2 &&
        _connected &&
        _items(_obj(_state['settings'])['tabs']).isEmpty) {
      unawaited(_menuCommand('settings.get'));
    }
  }

  // === The original EFB visual tokens, implemented as native Flutter widgets. ===
  Text _text(String s,
          {double size = 12,
          Color color = _GsxStyle.white,
          FontWeight weight = FontWeight.w500,
          double? spacing,
          int? maxLines,
          TextAlign? align}) =>
      Text(s,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          textAlign: align,
          softWrap: true,
          style: TextStyle(
              fontSize: size,
              color: color,
              fontWeight: weight,
              height: 1.35,
              letterSpacing: spacing));

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
          color: _GsxStyle.card,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _GsxStyle.border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x16000000), blurRadius: 15, offset: Offset(0, 5))
          ]),
      child: child);

  Widget _heading(String heading, {String? hint}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(
            child: _text(heading,
                size: 12,
                color: _GsxStyle.heading,
                weight: FontWeight.w800,
                spacing: 1.1)),
        if (hint != null)
          Flexible(
              child:
                  Align(alignment: Alignment.centerRight, child: _pill(hint))),
      ]));

  Widget _pill(String text, {Color color = _GsxStyle.small}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: _GsxStyle.field,
          border: Border.all(color: _GsxStyle.border),
          borderRadius: BorderRadius.circular(6)),
      child: _text(text,
          size: 9,
          color: color,
          weight: FontWeight.w700,
          maxLines: 2,
          align: TextAlign.center));

  Widget _button(String text, VoidCallback? action,
      {bool selected = false,
      bool danger = false,
      bool compact = true,
      IconData? icon}) {
    final bg = danger
        ? _GsxStyle.redBg
        : selected
            ? _GsxStyle.selected
            : _GsxStyle.inactive;
    final fg = danger ? _GsxStyle.danger : _GsxStyle.white;
    final stroke = danger
        ? _GsxStyle.danger
        : selected
            ? _GsxStyle.accent
            : _GsxStyle.border;
    return Opacity(
        opacity: action == null ? .42 : 1,
        child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: action,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 14,
                      vertical: compact ? 9 : 11),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: stroke),
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                  color: Color(0x1F639DF0),
                                  blurRadius: 12,
                                  spreadRadius: 1)
                            ]
                          : null),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 15),
                          const SizedBox(width: 5)
                        ],
                        Flexible(
                            child: _text(text,
                                size: compact ? 10 : 11,
                                color: fg,
                                weight: FontWeight.w700,
                                align: TextAlign.center)),
                      ])),
            )));
  }

  InputDecoration _inputStyle(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _GsxStyle.muted, fontSize: 12),
      isDense: true,
      filled: true,
      fillColor: _GsxStyle.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _GsxStyle.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _GsxStyle.accent)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)));

  Widget _twoColumn(List<Widget> children, double available,
      {double threshold = 720, double gap = 12, double? leftWeight}) {
    if (available < threshold) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ]
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(width: gap),
        Expanded(
            flex: i == 0 ? (leftWeight ?? 1).round() : 1, child: children[i]),
      ]
    ]);
  }

  IconData _serviceIcon(String name) {
    switch (name) {
      case 'GPU':
        return Icons.power_outlined;
      case 'Cleaning':
        return Icons.auto_awesome_outlined;
      case 'Lavatory':
        return Icons.delete_outline;
      case 'Water':
        return Icons.water_drop_outlined;
      case 'Catering':
        return Icons.restaurant_outlined;
      case 'Refueling':
        return Icons.local_gas_station_outlined;
      case 'Boarding':
        return Icons.groups_outlined;
      case 'Deboarding':
        return Icons.directions_walk;
      case 'Departure':
        return Icons.airport_shuttle_outlined;
      case 'DeIce':
        return Icons.ac_unit_outlined;
      case 'OperateJetways':
        return Icons.sensor_door_outlined;
      case 'OperateStairs':
        return Icons.stairs_outlined;
      default:
        return Icons.airplanemode_active_outlined;
    }
  }

  Widget _contextCard() {
    final hd = _obj(_state['handlerData']);
    final ac = _obj(hd['aircraft']);
    final airport = _obj(hd['airport']);
    final gate = _obj(hd['gate']);
    final aeroplane = _state['aircraft'] is String
        ? _txt(_state['aircraft'])
        : _txt(ac['title'], 'Aircraft not loaded');
    final icao = _txt(_obj(_state['airport'])['icao'] ?? airport['icao']);
    final place =
        _txt(_state['parking'] is String ? _state['parking'] : gate['uiName']);
    final count = _items(_state['services'])
        .where((dynamic s) => <String>{'requested', 'performing', 'completing'}
            .contains(_txt(_obj(s)['state'], '').toLowerCase()))
        .length;
    return _card(child: LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 460;
      Widget details = Row(children: [
        _contextValue('AIRPORT', icao),
        const SizedBox(width: 8),
        _contextValue('GATE', place),
        const SizedBox(width: 8),
        _contextValue('ACTIVE', '$count SERVICES'),
      ]);
      return compact
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _text('GROUND OPERATIONS · SESSION',
                  size: 10, color: _GsxStyle.heading, weight: FontWeight.w800),
              const SizedBox(height: 5),
              _text(aeroplane, size: 15, weight: FontWeight.w800),
              const SizedBox(height: 12),
              details,
            ])
          : Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _text('GROUND OPERATIONS · SESSION',
                        size: 10,
                        color: _GsxStyle.heading,
                        weight: FontWeight.w800),
                    const SizedBox(height: 4),
                    _text(aeroplane, size: 15, weight: FontWeight.w800),
                  ])),
              const SizedBox(width: 15),
              Flexible(child: details),
            ]);
    }));
  }

  Widget _contextValue(String label, String value) => Expanded(
      child: Container(
          padding: const EdgeInsets.only(left: 9),
          decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: _GsxStyle.border))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _text(label,
                size: 9, color: _GsxStyle.heading, weight: FontWeight.w800),
            const SizedBox(height: 4),
            _text(value, size: 11, weight: FontWeight.w800, maxLines: 2),
          ])));

  Widget _messages() {
    final message = _obj(_state['message']);
    final live = message['visible'] == true &&
        _txt(message['text'], '').trim().isNotEmpty;
    final content = live
        ? _txt(message['text'])
        : _messageHistory.isNotEmpty
            ? _messageHistory.first
            : 'No GSX message right now';
    return _card(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(children: [
          Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                  color: _GsxStyle.selected,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _GsxStyle.border)),
              child: const Icon(Icons.campaign_outlined,
                  size: 18, color: _GsxStyle.accent)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _text(live ? 'GSX MESSAGE · LIVE' : 'GSX MESSAGES',
                    size: 9,
                    color: _GsxStyle.heading,
                    weight: FontWeight.w800,
                    spacing: .7),
                const SizedBox(height: 4),
                _text(content, size: 12, weight: FontWeight.w700),
              ])),
        ]));
  }

  Widget _progressDetails(Map<String, dynamic> svc, String id) {
    final lines = _txt(svc['statusText'], '')
        .split(RegExp(r'\r?\n'))
        .map((String x) => x.trim())
        .where((String x) => x.isNotEmpty)
        .toList();
    final value = _txt(svc['progressText'], '').trim();
    final display = _txt(svc['displayName'], '').toLowerCase();
    final clean = <String>[];
    if (value.isNotEmpty && id != 'Boarding' && id != 'Deboarding') {
      clean.add(value);
    }
    for (final line in lines) {
      if (clean.length >= 2) break;
      if (line.toLowerCase() == display ||
          line.toLowerCase() == (_gsxTitles[id] ?? '').toLowerCase() ||
          clean.any((String x) => x.toLowerCase() == line.toLowerCase()))
        continue;
      clean.add(line);
    }
    final progress = _obj(svc['progress']);
    if (clean.isEmpty && svc['waiting'] == true) clean.add('Waiting for GSX');
    if (clean.isEmpty &&
        progress['unit'] != 'pax' &&
        _num(progress['total']) != null &&
        _num(progress['total'])! > 0) {
      clean.add(
          '${_txt(progress['current'])} / ${_txt(progress['total'])} ${_txt(progress['unit'], '')}');
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final line in clean.take(2))
        Padding(
            padding: const EdgeInsets.only(top: 3),
            child: _text(line, size: 10, color: _GsxStyle.small))
    ]);
  }

  Widget _paxLabel(Map<String, dynamic> svc, String id) {
    if (id != 'Boarding' && id != 'Deboarding') return const SizedBox.shrink();
    final progress = _obj(svc['progress']);
    final total = _num(progress['total']);
    final done = _num(progress['current']);
    if (total != null &&
        done != null &&
        total > 0 &&
        _txt(progress['unit'], 'pax').toLowerCase() == 'pax') {
      return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: _text(
              '${id == 'Boarding' ? 'BOARDED' : 'DEBOARDED'} '
              '${done.round()} / ${total.round()} PAX',
              size: 11,
              color: _GsxStyle.heading,
              weight: FontWeight.w800));
    }
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: _text('PASSENGER COUNT —', size: 10, color: _GsxStyle.muted));
  }

  Widget _step(String id, int index, String phase, double width) {
    final svc = _service(id);
    final state = _txt(svc['state'], 'unavailable').toLowerCase();
    final active =
        <String>{'requested', 'performing', 'completing'}.contains(state);
    final shared = _boardingSteps.contains(id) && _deboardingSteps.contains(id);
    final owner = _phaseOwner[id];
    final elsewhere = shared &&
        owner != null &&
        owner != phase &&
        (active || state == 'completed');
    final unknown = shared && owner == null && (active || state == 'completed');
    final ours = !shared || owner == phase;
    final awaiting = id == 'DeIce' &&
        !active &&
        state != 'completed' &&
        (_sendingDeIce || _acceptedDeIce);
    final pending = _phasePending[id];
    final recentPending = pending != null &&
        DateTime.now().difference(pending).inSeconds < 8 &&
        state == 'available';
    final running = active && ours && !elsewhere && !unknown;
    final allowRequest = svc['canTrigger'] == true && _connected;
    final textState = elsewhere
        ? 'SHARED · ${owner.toUpperCase()}'
        : unknown
            ? 'GSX SERVICE ACTIVE'
            : awaiting
                ? (_sendingDeIce
                    ? 'SENDING REQUEST'
                    : 'REQUEST ACCEPTED · AWAITING GSX')
                : recentPending
                    ? 'REQUEST SENT · AWAITING GSX'
                    : svc['waiting'] == true
                        ? 'AWAITING INPUT'
                        : _txt(
                            svc['progressText'],
                            state == 'requested'
                                ? 'REQUESTED'
                                : state == 'performing'
                                    ? 'IN PROGRESS'
                                    : state == 'completed'
                                        ? 'COMPLETED'
                                        : state == 'available'
                                            ? 'AVAILABLE'
                                            : state.toUpperCase());
    final canClose = running && _connected && id != 'GPU' && id != 'Departure';
    final narrow = width < 480;
    Widget control;
    if (elsewhere || unknown) {
      control = _pill(unknown ? 'LIVE GSX SERVICE' : 'OTHER WORKFLOW');
    } else if (canClose) {
      final completeKey = 'complete/$id';
      final abortKey = 'abort/$id';
      control = narrow
          ? Column(mainAxisSize: MainAxisSize.min, children: [
              _button(
                  'COMPLETE',
                  _busy.contains(completeKey)
                      ? null
                      : () => _quickService('complete', id)),
              const SizedBox(height: 4),
              _button(
                  'ABORT',
                  _busy.contains(abortKey)
                      ? null
                      : () => _quickService('abort', id),
                  danger: true),
            ])
          : Wrap(spacing: 4, runSpacing: 4, children: [
              _button(
                  'COMPLETE',
                  _busy.contains(completeKey)
                      ? null
                      : () => _quickService('complete', id)),
              _button(
                  'ABORT',
                  _busy.contains(abortKey)
                      ? null
                      : () => _quickService('abort', id),
                  danger: true),
            ]);
    } else if (awaiting) {
      control = _pill(_sendingDeIce ? 'SENDING…' : 'REQUESTED',
          color: _GsxStyle.heading);
    } else if (recentPending) {
      control = _pill('REQUEST SENT', color: _GsxStyle.heading);
    } else if (allowRequest && !_busy.contains(id)) {
      control =
          _button('REQUEST', () => _requestService(id, phase), selected: true);
    } else if (state == 'completed') {
      control = _pill('COMPLETED');
    } else if (active) {
      control = _pill('IN PROGRESS');
    } else {
      control = _pill(state == 'unavailable' ? 'NOT READY' : 'WAITING');
    }
    final progress = _obj(svc['progress']);
    final current = _num(progress['current'])?.toDouble();
    final total = _num(progress['total'])?.toDouble();
    final percent = current == null || total == null || total <= 0
        ? null
        : (current / total).clamp(0.0, 1.0).toDouble();
    return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 65),
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(horizontal: narrow ? 7 : 10, vertical: 8),
        decoration: BoxDecoration(
            color: running || awaiting ? _GsxStyle.step : _GsxStyle.inactive,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color:
                    running || awaiting ? _GsxStyle.accent : _GsxStyle.border)),
        child: Opacity(
            opacity: elsewhere || unknown ? .7 : 1,
            child: Row(children: [
              SizedBox(
                  width: narrow ? 18 : 23,
                  child: _text((index + 1).toString().padLeft(2, '0'),
                      size: 10,
                      color: _GsxStyle.heading,
                      weight: FontWeight.w800)),
              const SizedBox(width: 5),
              Icon(_serviceIcon(id),
                  color: _GsxStyle.accent, size: narrow ? 19 : 21),
              SizedBox(width: narrow ? 6 : 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _text(_gsxTitles[id] ?? id.toUpperCase(),
                        size: narrow ? 10 : 11, weight: FontWeight.w800),
                    const SizedBox(height: 3),
                    _text(textState,
                        size: narrow ? 9 : 10, color: _GsxStyle.muted),
                    if (running && !elsewhere && !unknown) ...[
                      _paxLabel(svc, id),
                      _progressDetails(svc, id),
                      if (percent != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 3,
                                    color: _GsxStyle.accent,
                                    backgroundColor: _GsxStyle.border))),
                    ],
                  ])),
              const SizedBox(width: 6),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: narrow ? 83 : 180),
                  child: control),
            ])));
  }

  Widget _phasePanel(String phase, double width) {
    final boarding = phase == 'boarding';
    final ids = boarding ? _boardingSteps : _deboardingSteps;
    return _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _GsxStyle.selected,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _GsxStyle.border)),
            child: _text(boarding ? '01' : '02',
                size: 11, color: _GsxStyle.heading, weight: FontWeight.w900)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _text(phase.toUpperCase(),
              size: 13,
              color: _GsxStyle.heading,
              weight: FontWeight.w900,
              spacing: 1.1),
          const SizedBox(height: 3),
          _text(boarding ? 'AUTO · DEPARTURE READY' : 'AUTO · ARRIVAL AT STAND',
              size: 10, color: _GsxStyle.muted),
        ])),
        _text('${ids.length} STEPS',
            size: 9, color: _GsxStyle.small, weight: FontWeight.w800),
      ]),
      const SizedBox(height: 15),
      for (var i = 0; i < ids.length; i++) _step(ids[i], i, phase, width),
    ]));
  }

  List<String> _gateNames() {
    final a = _obj(_obj(_state['handlerData'])['airport']);
    final result = <String>[];
    for (final item in _items(a['parkings'])) {
      final p = _obj(item);
      final label = item is String
          ? item
          : _txt(
              p['uiName'] ?? p['uiGateName'] ?? p['bglName'] ?? p['name'], '');
      if (label.isNotEmpty && !result.contains(label)) result.add(label);
    }
    return result;
  }

  Future<void> _selectGate(String name,
      {bool revoke = false, bool force = false}) async {
    final response = await _command('gate.select', {
      'gate': name,
      if (revoke) 'revokeServices': true,
      if (force) 'force': true,
    });
    if (response['ok'] == true) {
      if (!mounted) return;
      setState(() => _selectedGate = name);
      _toast('Gate selected. Checking next GSX action…');
      // The v0.4.7 flow waits for a real GSX submenu before opening options.
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (_state['menuShown'] != true) {
        await _menuCommand('menu.open');
      }
      _scrollToNext();
    } else {
      final e = _obj(response['error']);
      final code = _txt(e['code'], '');
      if (code == 'services_active' || code == 'assigned_to_other') {
        if (!mounted) return;
        final retry = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                    backgroundColor: _GsxStyle.card,
                    title: _text('CONFIRM GATE SELECTION',
                        size: 15, weight: FontWeight.w800),
                    content: _text(_txt(e['message'], code)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: _text('CANCEL')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: _text('CONFIRM', color: _GsxStyle.danger)),
                    ]));
        if (retry == true) {
          await _selectGate(name,
              revoke: code == 'services_active',
              force: code == 'assigned_to_other');
        }
      }
    }
  }

  void _scrollToNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_interactionKey.currentContext != null) {
        Scrollable.ensureVisible(_interactionKey.currentContext!,
            duration: const Duration(milliseconds: 260),
            alignment: .12,
            curve: Curves.easeOut);
      }
    });
  }

  Future<void> _openGates() async {
    final names = _gateNames();
    if (names.isEmpty || !mounted) {
      _toast('GSX has not published any airport gates yet', error: true);
      return;
    }
    final selected = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: _GsxStyle.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        builder: (ctx) => SafeArea(
            child: FractionallySizedBox(
                heightFactor: .75,
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _heading('SELECT ARRIVAL GATE',
                              hint: '${names.length} GATES'),
                          const SizedBox(height: 4),
                          Expanded(
                              child: ListView.separated(
                                  itemCount: names.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (_, i) => _button(names[i],
                                      () => Navigator.pop(ctx, names[i]),
                                      compact: false))),
                        ])))));
    if (selected != null && mounted) await _selectGate(selected);
  }

  Widget _gatePanel() {
    final names = _gateNames();
    final supported =
        _items(_obj(_bridge['hello'])['capabilities']).contains('gate');
    return _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('SELECT ARRIVAL GATE',
          hint: names.isEmpty ? 'AWAITING AIRPORT' : '${names.length} GATES'),
      SizedBox(
          width: double.infinity,
          child: _button(
              _selectedGate.isNotEmpty
                  ? _selectedGate
                  : names.isEmpty
                      ? 'NO GATES PUBLISHED YET'
                      : 'TAP TO VIEW ALL GATES',
              _connected && names.isNotEmpty && supported ? _openGates : null,
              icon: Icons.local_airport_outlined,
              compact: false)),
      const SizedBox(height: 10),
      _text(
          'Choose a gate from GSX’s airport list. The next GSX options '
          'will appear below.',
          size: 10,
          color: _GsxStyle.muted),
    ]));
  }

  Widget _promptCard() {
    final prompt = _obj(_state['prompt']);
    if (prompt['kind'] != 'text') return const SizedBox.shrink();
    final gen = prompt['gen'];
    return _card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading(_txt(prompt['title'], 'GSX INPUT REQUIRED')),
      _text(_txt(prompt['description'], 'Enter the value GSX requested'),
          size: 11, color: _GsxStyle.muted),
      const SizedBox(height: 12),
      TextFormField(
        key: ValueKey('gsx-prompt-$gen'),
        initialValue: _txt(prompt['default'], ''),
        maxLength:
            (_num(prompt['maxLength'])?.toInt() ?? 200).clamp(1, 500).toInt(),
        style: const TextStyle(color: _GsxStyle.white, fontSize: 12),
        decoration: _inputStyle('GSX input'),
        onChanged: (value) => _drafts['prompt-$gen'] = value,
      ),
      const SizedBox(height: 9),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _button('SUBMIT', () async {
          await _menuCommand('input.submit', {
            'gen': gen,
            'text': _drafts['prompt-$gen'] ?? _txt(prompt['default'], '')
          });
        }, selected: true),
        _button('CANCEL', () => _menuCommand('input.cancel', {'gen': gen})),
      ]),
    ]));
  }

  Widget _menuChoices({bool manual = false}) {
    final menu = _obj(_state['menu']);
    final entries = _items(menu['entries']);
    final disabled = _items(menu['disabled']);
    final shown = _state['menuShown'] == true;
    final allowed = <int>[
      for (var i = 0; i < entries.length; i++)
        if (i >= disabled.length || disabled[i] != true) i,
    ];
    final columns = manual ? 3 : 2;
    return LayoutBuilder(builder: (context, c) {
      final count = manual
          ? (c.maxWidth >= 950
              ? 3
              : c.maxWidth >= 570
                  ? 2
                  : 1)
          : (c.maxWidth >= 520 ? columns : 1);
      final target = (c.maxWidth - (count - 1) * 8) / count;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        for (final index in shown ? allowed : <int>[])
          SizedBox(
              width: target.clamp(100.0, c.maxWidth).toDouble(),
              child: _menuEntry(index, _txt(entries[index], ''))),
      ]);
    });
  }

  Widget _menuEntry(int index, String name) => _button(
      '${(index + 1).toString().padLeft(2, '0')}     $name',
      () => _pick(index, name),
      compact: false);

  Widget _nextAction() {
    final m = _obj(_state['menu']);
    final list = _items(m['entries']);
    final disabled = _items(m['disabled']);
    final available = <int>[
      for (var i = 0; i < list.length; i++)
        if (i >= disabled.length || disabled[i] != true) i,
    ];
    final hasOptions = _state['menuShown'] == true && available.isNotEmpty;
    return KeyedSubtree(
        key: _interactionKey,
        child: _card(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              _heading('NEXT REQUIRED ACTION',
                  hint: hasOptions ? 'OPTIONS READY' : 'WAITING'),
              _text(
                  hasOptions
                      ? _txt(m['title'], 'Select a GSX option')
                      : 'Options will appear here after GSX requests input.',
                  size: 10,
                  color: _GsxStyle.muted),
              const SizedBox(height: 11),
              if (hasOptions)
                _menuChoices()
              else
                Align(
                    alignment: Alignment.centerLeft,
                    child: _button('OPEN OPTIONS',
                        _connected ? () => _menuCommand('menu.open') : null,
                        selected: true)),
              if (_state['prompt'] is Map) ...[
                const SizedBox(height: 12),
                _promptCard()
              ],
            ])));
  }

  Widget _quickScreen(double available) {
    // Exact v0.4.7 lists. On narrow screens we switch entire workflows rather
    // than rendering two illegible side-by-side desktop columns.
    final small = available < 900;
    Widget phaseSwitch = small
        ? Row(children: [
            Expanded(
                child: _button(
                    'BOARDING', () => setState(() => _phase = 'boarding'),
                    selected: _phase == 'boarding', compact: false)),
            const SizedBox(width: 8),
            Expanded(
                child: _button(
                    'DEBOARDING', () => setState(() => _phase = 'deboarding'),
                    selected: _phase == 'deboarding', compact: false)),
          ])
        : const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _contextCard(),
      const SizedBox(height: 13),
      _messages(),
      const SizedBox(height: 13),
      if (small) ...[phaseSwitch, const SizedBox(height: 12)],
      if (small)
        _phasePanel(_phase, available)
      else
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _phasePanel('boarding', available / 2 - 8)),
          const SizedBox(width: 12),
          Expanded(child: _phasePanel('deboarding', available / 2 - 8)),
        ]),
      const SizedBox(height: 12),
      _twoColumn([_gatePanel(), _nextAction()], available, threshold: 820),
      const SizedBox(height: 18),
    ]);
  }

  Future<void> _showDocument(String title, String html,
      {bool invoice = false}) async {
    if (invoice) await _menuCommand('invoice.seen');
    // Pure native Flutter. The original GSX HTML/iframe markup is read-only;
    // render its textual content without embedding a browser/WebView.
    var plain = html
        .replaceAll(
            RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false),
            ' ')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
            RegExp(r'</(p|tr|div|h[1-6])\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'[ \t]+'), ' ');
    if (!mounted) return;
    await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
            backgroundColor: _GsxStyle.card,
            child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 700, maxHeight: 600),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _heading(title),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: SelectableText(
                                      plain.trim().isEmpty
                                          ? 'No document content.'
                                          : plain.trim(),
                                      style: const TextStyle(
                                          color: _GsxStyle.white,
                                          fontSize: 12,
                                          height: 1.45)))),
                          const SizedBox(height: 10),
                          Align(
                              alignment: Alignment.centerRight,
                              child:
                                  _button('CLOSE', () => Navigator.pop(ctx))),
                        ])))));
  }

  Future<void> _menuSearch(String value) async {
    // Only GSX's native gate-search flow uses menu.search. This does not change
    // the Quick Operations gate chooser (all gates remain directly selectable).
    await _menuCommand('menu.search', {'text': value});
  }

  Widget _manualScreen(double available) {
    final m = _obj(_state['menu']);
    final search = _obj(_state['search']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _contextCard(),
      const SizedBox(height: 13),
      _messages(),
      const SizedBox(height: 13),
      _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: _text(_txt(m['title'] ?? m['header'], 'GSX MENU'),
                  size: 12,
                  color: _GsxStyle.heading,
                  weight: FontWeight.w800,
                  spacing: .6)),
          _button(
              _state['menuShown'] == true ? 'MAIN MENU' : 'OPEN GSX MENU',
              _connected
                  ? () => _menuCommand(
                      _state['menuShown'] == true ? 'menu.home' : 'menu.open')
                  : null),
        ]),
        if (_txt(m['subtitle'], '').isNotEmpty) ...[
          const SizedBox(height: 9),
          _text(_txt(m['subtitle']), size: 10, color: _GsxStyle.muted),
        ],
        if (search['active'] == true) ...[
          const SizedBox(height: 12),
          TextField(
              controller: _searchController,
              onChanged: (value) => unawaited(_menuSearch(value)),
              style: const TextStyle(color: _GsxStyle.white, fontSize: 12),
              decoration: _inputStyle('GSX parking search')),
        ],
        if (_txt(m['document'], '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerLeft,
              child: _button(
                  'VIEW GSX DOCUMENT',
                  () => _showDocument(
                      _txt(m['title'], 'GSX DOCUMENT'), _txt(m['document'])))),
        ],
        const SizedBox(height: 12),
        _menuChoices(manual: true),
        if (_items(m['entries']).isEmpty || _state['menuShown'] != true)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _text('Waiting for GSX menu choices…',
                  size: 11, color: _GsxStyle.muted)),
        if (_state['prompt'] is Map) ...[
          const SizedBox(height: 12),
          _promptCard()
        ],
      ])),
      const SizedBox(height: 18),
    ]);
  }

  List<Map<String, dynamic>> _allSettingFields() {
    final out = <Map<String, dynamic>>[];
    for (final t in _items(_obj(_state['settings'])['tabs'])) {
      final tab = _obj(t);
      for (final item in _items(tab['fields'])) out.add(_obj(item));
      for (final sub in _items(tab['subtabs'])) {
        for (final item in _items(_obj(sub)['fields'])) out.add(_obj(item));
      }
    }
    return out;
  }

  Map<String, dynamic> _aliasField() {
    for (final f in _allSettingFields()) {
      if (f['type'] != 'text') continue;
      final key = _txt(f['key'], '').toLowerCase();
      final label = _txt(f['label'], '').toLowerCase();
      if ((key.contains('simbrief') &&
              (key.contains('user') || key.contains('alias'))) ||
          (label.contains('simbrief') &&
              (label.contains('user') || label.contains('alias')))) return f;
    }
    return <String, dynamic>{};
  }

  Future<void> _saveAlias() async {
    final field = _aliasField();
    final username = _aliasController.text.trim();
    final key = _txt(field['key'], '');
    if (key.isEmpty) {
      _toast('GSX has not published the SimBrief username setting',
          error: true);
      return;
    }
    if (username.isEmpty ||
        username.length > 80 ||
        RegExp(r'\s').hasMatch(username)) {
      _toast('Use a valid SimBrief username without spaces', error: true);
      return;
    }
    final result =
        await _command('settings.set', {'key': key, 'value': username});
    if (result['ok'] == true) {
      _toast('SimBrief Username saved in GSX');
      await _command('command.run', {'command': 'RELOAD_SIMBRIEF'});
    }
  }

  Map<String, dynamic> _simbriefPlan() {
    final plan = _obj(_state['simBrief']);
    if (plan.isNotEmpty) return plan;
    return _obj(_obj(_state['handlerData'])['simbrief']);
  }

  bool _hasSimbriefPlan() {
    final plan = _simbriefPlan();
    final status = _obj(_state['simbrief']);
    return status['status'] == 'loaded' ||
        plan.values.any((dynamic val) =>
            val is String && val.isNotEmpty && val != 'null' && val != '0');
  }

  Widget _simbriefPanel() {
    final fld = _aliasField();
    final plan = _simbriefPlan();
    final valid = _hasSimbriefPlan();
    final origin = valid
        ? _txt(plan['origin'] ?? plan['originIcao'] ?? plan['departure'])
        : '—';
    final destination = valid
        ? _txt(
            plan['destination'] ?? plan['destinationIcao'] ?? plan['arrival'])
        : '—';
    return _card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading('SIMBRIEF INTEGRATION', hint: 'GSX NATIVE SYNC'),
      _text('SIMBRIEF USERNAME / ALIAS',
          size: 10,
          color: _GsxStyle.heading,
          weight: FontWeight.w800,
          spacing: .7),
      const SizedBox(height: 7),
      LayoutBuilder(builder: (context, c) {
        final input = TextField(
            controller: _aliasController,
            focusNode: _aliasFocus,
            style: const TextStyle(color: _GsxStyle.white, fontSize: 12),
            decoration: _inputStyle('SimBrief username'));
        if (c.maxWidth < 390) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                input,
                const SizedBox(height: 8),
                _button('SAVE TO GSX',
                    fld.isNotEmpty && _connected ? _saveAlias : null,
                    selected: true, compact: false)
              ]);
        }
        return Row(children: [
          Expanded(child: input),
          const SizedBox(width: 8),
          _button(
              'SAVE TO GSX', fld.isNotEmpty && _connected ? _saveAlias : null,
              selected: true, compact: false),
        ]);
      }),
      const SizedBox(height: 11),
      Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
              color: _GsxStyle.field,
              border: Border.all(color: _GsxStyle.border),
              borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Expanded(
                child: _text(origin,
                    align: TextAlign.center,
                    size: 16,
                    weight: FontWeight.w900)),
            Expanded(
                child: _text('FLIGHT PLAN',
                    align: TextAlign.center,
                    color: _GsxStyle.heading,
                    size: 9,
                    weight: FontWeight.w800)),
            Expanded(
                child: _text(destination,
                    align: TextAlign.center,
                    size: 16,
                    weight: FontWeight.w900)),
          ])),
      const SizedBox(height: 8),
      _text(
          fld.isEmpty
              ? 'GSX has not published its SimBrief Username setting yet.'
              : 'Saved through the official GSX Settings API. Saving reloads the flight plan.',
          size: 10,
          color: _GsxStyle.muted),
    ]));
  }

  Widget _setting(Map<String, dynamic> f) {
    final type = _txt(f['type'], '');
    final key = _txt(f['key'], '');
    final name = _txt(f['label'], key);
    final disabled = f['disabled'] == true || !_connected;
    if (type == 'separator')
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Divider(color: _GsxStyle.border),
            _text(name,
                size: 11, color: _GsxStyle.heading, weight: FontWeight.w800)
          ]));
    Widget field;
    if (type == 'toggle') {
      field = Switch(
          value: _enabled(f['value']),
          activeColor: _GsxStyle.accent,
          onChanged: disabled
              ? null
              : (value) => unawaited(_command(
                  'settings.set', {'key': key, 'value': value ? 1 : 0})));
    } else if (type == 'range') {
      final lower = _num(f['min'])?.toDouble() ?? 0;
      final upper = _num(f['max'])?.toDouble() ?? 100;
      final max = upper > lower ? upper : lower + 1;
      final original =
          (_num(f['value'])?.toDouble() ?? lower).clamp(lower, max).toDouble();
      final value =
          (_sliderDrafts[key] ?? original).clamp(lower, max).toDouble();
      final step = _num(f['step'])?.toDouble() ?? 0;
      final count = step > 0 ? ((max - lower) / step).round() : 0;
      final channel = _num(f['audioCheck'])?.toInt();
      field = Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _text(
            '${value.toStringAsFixed(f['float'] == true ? 1 : 0)}'
            ' ${_txt(f['unit'], '')}',
            size: 12,
            color: _GsxStyle.white,
            weight: FontWeight.w800),
        Slider(
            value: value,
            min: lower,
            max: max,
            divisions: count >= 1 && count <= 600 ? count : null,
            activeColor: _GsxStyle.accent,
            onChangeStart: disabled
                ? null
                : (_) {
                    if (channel != null && channel > 0) {
                      unawaited(_command(
                          'settings.audioCheck', {'channel': channel}));
                    }
                  },
            onChanged: disabled
                ? null
                : (next) => setState(() => _sliderDrafts[key] = next),
            onChangeEnd: disabled
                ? null
                : (next) async {
                    await _command('settings.set', {'key': key, 'value': next});
                    _sliderDrafts.remove(key);
                    if (channel != null && channel > 0) {
                      await _command('settings.audioCheck', {'channel': 0});
                    }
                  }),
      ]);
    } else if (type == 'choice') {
      final choices = _items(f['choices']);
      int? selected;
      for (var i = 0; i < choices.length; i++) {
        final choice = _items(choices[i]);
        if (choice.isNotEmpty &&
            choice[0].toString() == f['value'].toString()) {
          selected = i;
          break;
        }
      }
      field = DropdownButtonFormField<int>(
        value: selected,
        dropdownColor: _GsxStyle.card,
        isExpanded: true,
        style: const TextStyle(color: _GsxStyle.white, fontSize: 12),
        decoration: _inputStyle('Choose option'),
        items: [
          for (var i = 0; i < choices.length; i++)
            DropdownMenuItem<int>(
                value: i,
                child: Text(
                    _txt(_items(choices[i]).length > 1
                        ? _items(choices[i])[1]
                        : i),
                    overflow: TextOverflow.ellipsis))
        ],
        onChanged: disabled
            ? null
            : (index) {
                if (index != null && index < choices.length) {
                  final c = _items(choices[index]);
                  if (c.isNotEmpty)
                    unawaited(
                        _command('settings.set', {'key': key, 'value': c[0]}));
                }
              },
      );
    } else if (type == 'text') {
      final content = _drafts.putIfAbsent(key, () => _txt(f['value'], ''));
      field = Row(children: [
        Expanded(
            child: TextFormField(
          key: ValueKey('setting-$key'),
          initialValue: content,
          enabled: !disabled,
          maxLength: _num(f['maxlength'])?.toInt(),
          style: const TextStyle(fontSize: 12, color: _GsxStyle.white),
          decoration: _inputStyle(_txt(f['placeholder'], 'Enter value')),
          onChanged: (value) => _drafts[key] = value,
          onFieldSubmitted: disabled
              ? null
              : (value) => unawaited(
                  _command('settings.set', {'key': key, 'value': value})),
        )),
        const SizedBox(width: 7),
        _button(
            'SAVE',
            disabled
                ? null
                : () => _command(
                    'settings.set', {'key': key, 'value': _drafts[key] ?? ''}),
            selected: true),
      ]);
    } else if (type == 'action') {
      field = _button(_txt(f['button'], 'RUN'),
          disabled ? null : () => _command('settings.action', {'key': key}),
          selected: true);
    } else if (type == 'info') {
      field = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _text(_txt(f['value']), size: 11, color: _GsxStyle.small),
        const SizedBox(height: 7),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final item in _items(f['buttons']))
            _button(
                _txt(_obj(item)['button'], 'ACTION'),
                disabled || _obj(item)['disabled'] == true
                    ? null
                    : () => _command(
                        'settings.action', {'key': _obj(item)['key']})),
        ]),
      ]);
    } else {
      // Forward-compatible GSX field: show the value without inventing writes.
      field = _text(_txt(f['value']), color: _GsxStyle.small, size: 11);
    }
    return Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
            color: _GsxStyle.inactive,
            border: Border.all(color: _GsxStyle.border),
            borderRadius: BorderRadius.circular(6)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _text(name,
              size: 10,
              color: _GsxStyle.heading,
              weight: FontWeight.w800,
              spacing: .5),
          if (_txt(f['tooltip'], '').isNotEmpty) ...[
            const SizedBox(height: 5),
            _text(_txt(f['tooltip']), size: 10, color: _GsxStyle.muted),
          ],
          const SizedBox(height: 9),
          field,
        ]));
  }

  Widget _settingsScreen(double available) {
    final tabs = _items(_obj(_state['settings'])['tabs']);
    if (tabs.isEmpty) {
      return Column(children: [
        _contextCard(),
        const SizedBox(height: 13),
        _simbriefPanel(),
        const SizedBox(height: 13),
        _card(
            child: _text('Waiting for the GSX Settings model.',
                color: _GsxStyle.muted))
      ]);
    }
    Map<String, dynamic> tab = _obj(tabs.first);
    for (final raw in tabs) {
      if (_obj(raw)['id'] == _selectedSettingsTab) tab = _obj(raw);
    }
    final subtabs = _items(tab['subtabs']);
    Map<String, dynamic> subtab =
        subtabs.isEmpty ? <String, dynamic>{} : _obj(subtabs.first);
    for (final raw in subtabs) {
      if (_obj(raw)['id'] == _selectedSettingsSubtab) subtab = _obj(raw);
    }
    final fields = _items(subtabs.isEmpty ? tab['fields'] : subtab['fields']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _contextCard(),
      const SizedBox(height: 13),
      _simbriefPanel(),
      const SizedBox(height: 13),
      _card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _heading('GSX SETTINGS'),
        _text('Every setting and input is supplied by your GSX installation.',
            size: 10, color: _GsxStyle.muted),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final raw in tabs)
            _button(
                _txt(_obj(raw)['label'], _txt(_obj(raw)['id'])),
                () => setState(() {
                      _selectedSettingsTab = _txt(_obj(raw)['id']);
                      _selectedSettingsSubtab = null;
                    }),
                selected: _obj(raw)['id'] == tab['id']),
        ]),
        if (subtabs.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final raw in subtabs)
              _button(
                  _txt(_obj(raw)['label'], _txt(_obj(raw)['id'])),
                  () => setState(
                      () => _selectedSettingsSubtab = _txt(_obj(raw)['id'])),
                  selected: _obj(raw)['id'] == subtab['id']),
          ]),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, c) {
          final columns = c.maxWidth >= 650 ? 2 : 1;
          final cellWidth = (c.maxWidth - (columns - 1) * 9) / columns;
          return Wrap(spacing: 9, runSpacing: 9, children: [
            for (var i = 0; i < fields.length; i++)
              SizedBox(
                  width: _txt(_obj(fields[i])['type']) == 'separator'
                      ? c.maxWidth
                      : cellWidth,
                  child: _setting(_obj(fields[i]))),
          ]);
        }),
      ])),
      const SizedBox(height: 18),
    ]);
  }

  Widget _billValue(String title, dynamic value, {bool valid = true}) =>
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _GsxStyle.field,
              border: Border.all(color: _GsxStyle.border),
              borderRadius: BorderRadius.circular(6)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _text(title,
                size: 9, color: _GsxStyle.heading, weight: FontWeight.w800),
            const SizedBox(height: 7),
            _text(valid ? _txt(value) : '—', size: 12, weight: FontWeight.w800),
          ]));

  Widget _billingGrid(List<MapEntry<String, dynamic>> fields) =>
      LayoutBuilder(builder: (context, constraints) {
        final n = constraints.maxWidth >= 430 ? 2 : 1;
        final w = (constraints.maxWidth - (n - 1) * 8) / n;
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final item in fields)
            SizedBox(width: w, child: _billValue(item.key, item.value)),
        ]);
      });

  Widget _billingScreen(double width) {
    final plan = _simbriefPlan();
    final valid = _hasSimbriefPlan();
    final values = <MapEntry<String, dynamic>>[
      MapEntry(
          'FLIGHT',
          valid
              ? (plan['callsign'] ??
                  plan['flight'] ??
                  plan['flightNumber'] ??
                  plan['flight_number'])
              : null),
      MapEntry(
          'ORIGIN',
          valid
              ? (plan['origin'] ?? plan['originIcao'] ?? plan['departure'])
              : null),
      MapEntry(
          'DESTINATION',
          valid
              ? (plan['destination'] ??
                  plan['destinationIcao'] ??
                  plan['arrival'])
              : null),
      MapEntry('ROUTE', valid ? plan['route'] : null),
      MapEntry(
          'PASSENGERS', valid ? (plan['passengers'] ?? plan['pax']) : null),
      MapEntry('FUEL', valid ? (plan['plan_ramp'] ?? plan['fuel']) : null),
      MapEntry('AIRCRAFT',
          valid ? (plan['aircraft'] ?? plan['aircraftType']) : null),
    ];
    final billing = _obj(_state['billing'])
        .entries
        .where((entry) =>
            entry.value != null &&
            entry.value.toString().isNotEmpty &&
            entry.value is! Map &&
            entry.value is! List)
        .take(28)
        .map((entry) => MapEntry(_pretty(entry.key).toUpperCase(), entry.value))
        .toList();
    final receipt = _obj(_state['receipt']);
    final invoice = receipt['html'];
    final summary = _card(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          _heading('SIMBRIEF FLIGHT PLAN'),
          _billingGrid(values)
        ]));
    final cost = _card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading('GSX BILLING'),
      billing.isEmpty
          ? _text('No billing information available.',
              color: _GsxStyle.muted, size: 11)
          : _billingGrid(billing)
    ]));
    final latest = _card(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _heading('LATEST INVOICE'),
      _text(
          invoice == null
              ? 'No invoice available.'
              : _txt(receipt['operator'], 'Ground handling'),
          color: _GsxStyle.muted,
          size: 11),
      if (invoice is String && invoice.isNotEmpty) ...[
        const SizedBox(height: 12),
        Align(
            alignment: Alignment.centerLeft,
            child: _button(
                'VIEW INVOICE',
                () => _showDocument('GROUND SERVICES INVOICE', invoice,
                    invoice: true),
                selected: true)),
      ],
    ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _contextCard(),
      const SizedBox(height: 13),
      _twoColumn([_simbriefPanel(), summary], width),
      const SizedBox(height: 13),
      _twoColumn([cost, latest], width),
      const SizedBox(height: 18),
    ]);
  }

  Widget _header(double width) {
    final narrow = width < 680;
    final tabs = <Widget>[
      for (var i = 0; i < _mainTabs.length; i++)
        _button(_mainTabs[i], () => _changeTab(i),
            selected: i == _screen, compact: true),
    ];
    final brand = Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          height: 37,
          width: 4,
          decoration: BoxDecoration(
              color: _GsxStyle.accent, borderRadius: BorderRadius.circular(9))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _text('FLIGHT OPERATIONS / GROUND',
            size: 10,
            color: _GsxStyle.heading,
            weight: FontWeight.w800,
            spacing: .7),
        const SizedBox(height: 3),
        _text('Ground Services',
            size: narrow ? 15 : 18, weight: FontWeight.w900, spacing: 1.1),
      ]),
    ]);
    final nav = Wrap(
        spacing: 4,
        runSpacing: 5,
        alignment: narrow ? WrapAlignment.start : WrapAlignment.end,
        children: tabs);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: narrow ? 11 : 20, vertical: narrow ? 10 : 13),
      decoration: const BoxDecoration(
          color: _GsxStyle.card,
          border: Border(bottom: BorderSide(color: _GsxStyle.border))),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [brand, const SizedBox(height: 12), nav])
          : Row(children: [
              brand,
              const SizedBox(width: 16),
              Expanded(
                  child: Align(alignment: Alignment.centerRight, child: nav))
            ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.sizeOf(context).height;
    final width = widget.width ?? MediaQuery.sizeOf(context).width;
    return SizedBox(
        width: width,
        height: height,
        child: Material(
            color: _GsxStyle.bg,
            child: LayoutBuilder(builder: (context, available) {
              final logicalWidth = available.maxWidth;
              final double contentWidth = math.max<double>(
                  0.0,
                  math.min<double>(
                      logicalWidth - (logicalWidth < 500 ? 20 : 36), 1510.0));
              return Column(children: [
                _header(logicalWidth),
                Expanded(
                  child: _base.isEmpty
                      ? Center(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _text(
                                  'Set the ipAddress parameter to the Windows PC LAN IP.',
                                  color: _GsxStyle.muted,
                                  align: TextAlign.center)))
                      : SingleChildScrollView(
                          controller: _scroll,
                          physics: const BouncingScrollPhysics(),
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1510),
                                  padding: EdgeInsets.fromLTRB(
                                      logicalWidth < 500 ? 10 : 18,
                                      16,
                                      logicalWidth < 500 ? 10 : 18,
                                      22),
                                  width: double.infinity,
                                  child: KeyedSubtree(
                                      key: _pageKey,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (_lastError != null &&
                                                !_connected) ...[
                                              _card(
                                                  child: _text(
                                                      'Awaiting GSX Bridge on Windows…',
                                                      color: _GsxStyle.muted)),
                                              const SizedBox(height: 12),
                                            ],
                                            if (_screen == 0)
                                              _quickScreen(contentWidth)
                                            else if (_screen == 1)
                                              _manualScreen(contentWidth)
                                            else if (_screen == 2)
                                              _settingsScreen(contentWidth)
                                            else
                                              _billingScreen(contentWidth),
                                          ]))))),
                ),
              ]);
            })));
  }
}
