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
import 'dart:convert';
import 'dart:ui' show FontFeature;
import 'package:http/http.dart' as http;

// FlutterFlow widget name: FailuresWidgetMSFS
// Widget parameters: width (double), height (double),
// serverAddress (String, required).
//
// Backend: SimDataStation Failures Lab v0.8.0-beta, API-only edition.
// All failure IDs, names, supported versions, and modes come from /catalog.
// The widget does not display API addresses or flight telemetry.

class FailuresWidgetMSFS extends StatefulWidget {
  const FailuresWidgetMSFS({
    super.key,
    this.width,
    this.height,
    required this.serverAddress,
  });

  final double? width;
  final double? height;
  final String serverAddress;

  @override
  State<FailuresWidgetMSFS> createState() => _FailuresWidgetMSFSState();
}

class _FailureItem {
  const _FailureItem({
    required this.id,
    required this.label,
    required this.category,
    required this.versions,
    required this.engine,
    required this.engineType,
  });

  final String id;
  final String label;
  final String category;
  final List<String> versions;
  final int engine;
  final String engineType;

  factory _FailureItem.fromJson(Map<String, dynamic> json) {
    final rawVersions = json['versions'];
    return _FailureItem(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      versions: rawVersions is List
          ? rawVersions.map((e) => e.toString()).toList()
          : const <String>['2020', '2024'],
      engine: (json['engine'] is num) ? (json['engine'] as num).toInt() : 0,
      engineType: (json['engine_type'] ?? 'any').toString(),
    );
  }
}

class _FailuresWidgetMSFSState extends State<FailuresWidgetMSFS> {
  static const Color _bg = Color(0xFF0B111A);
  static const Color _panel = Color(0xFF101923);
  static const Color _panel2 = Color(0xFF0B1521);
  static const Color _stroke = Color(0xFF26364D);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _blue = Color(0xFF639DF0);
  static const Color _red = Color(0xFFFF5252);
  static const Color _amber = Color(0xFFE9B65F);

  final http.Client _http = http.Client();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _seconds = TextEditingController(text: '30');
  final TextEditingController _ias = TextEditingController(text: '240');
  final TextEditingController _altitude = TextEditingController(text: '8000');
  final TextEditingController _afterThreshold =
      TextEditingController(text: '0');

  Timer? _timer;
  List<_FailureItem> _catalog = const [];
  Map<String, dynamic> _states = const {};
  String _simVersion = '';
  String _selectedCategory = 'ALL';
  String _activationMode = 'now';
  bool _connected = false;
  bool _loading = true;
  bool _refreshInFlight = false;
  bool _fixingAll = false;
  String _loadMessage = '';
  int? _engineCount;
  int? _engineType;
  final Set<String> _sending = <String>{};

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _initialize();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshStatus();
    });
  }

  @override
  void didUpdateWidget(covariant FailuresWidgetMSFS oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverAddress != widget.serverAddress) {
      setState(() {
        _catalog = const [];
        _states = const {};
        _loading = true;
        _connected = false;
        _loadMessage = '';
        _selectedCategory = 'ALL';
      });
      _initialize();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _seconds.dispose();
    _ias.dispose();
    _altitude.dispose();
    _afterThreshold.dispose();
    _http.close();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Uri _uri(String route) {
    final raw = widget.serverAddress.trim();
    if (raw.isEmpty) throw const FormatException('Missing server address');
    final complete = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'http://$raw';
    final given = Uri.parse(complete);
    if (given.host.isEmpty)
      throw const FormatException('Invalid server address');
    final port = given.hasPort ? given.port : 9010;
    return Uri(
      scheme: given.scheme,
      host: given.host,
      port: port,
      path: '/api/v1/$route',
    );
  }

  Map<String, String> _headers() {
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _get(String route) async {
    final response = await _http
        .get(_uri(route), headers: _headers())
        .timeout(const Duration(seconds: 7));
    if (response.statusCode != 200) {
      throw StateError('Request rejected (${response.statusCode})');
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map) throw const FormatException('Invalid response');
    return Map<String, dynamic>.from(json);
  }

  Future<Map<String, dynamic>> _post(
    String route,
    Map<String, dynamic> payload,
  ) async {
    final response = await _http
        .post(
          _uri(route),
          headers: _headers(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 9));
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw const FormatException('Invalid response');
    final answer = Map<String, dynamic>.from(decoded);
    if (response.statusCode != 200) {
      throw StateError((answer['error'] ?? 'Request rejected').toString());
    }
    return answer;
  }

  Future<void> _initialize() async {
    try {
      final result = await _get('catalog');
      final raw = result['items'];
      if (raw is! List) throw const FormatException('Missing controls');
      final parsed = <_FailureItem>[];
      for (final row in raw) {
        if (row is Map) {
          final control = _FailureItem.fromJson(Map<String, dynamic>.from(row));
          if (control.id.isNotEmpty && control.label.isNotEmpty) {
            parsed.add(control);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _catalog = parsed;
        _loading = false;
        _loadMessage = '';
        final categories = _categories(parsed);
        if (_selectedCategory != 'ALL' &&
            !categories.contains(_selectedCategory)) {
          _selectedCategory = 'ALL';
        }
      });
      await _refreshStatus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadMessage = 'Unable to load failure controls';
        _connected = false;
      });
    }
  }

  Future<void> _refreshStatus() async {
    if (_refreshInFlight || !mounted) return;
    _refreshInFlight = true;
    try {
      final status = await _get('status');
      if (!mounted) return;
      final rawStates = status['states'];
      final nextStates = rawStates is Map
          ? Map<String, dynamic>.from(rawStates)
          : <String, dynamic>{};
      setState(() {
        _states = nextStates;
        _connected = status['connected'] == true && status['handshake'] == true;
        _simVersion = (status['sim_version'] ?? '').toString();
        _engineCount = status['engines'] is num
            ? (status['engines'] as num).toInt()
            : null;
        _engineType = status['engine_type'] is num
            ? (status['engine_type'] as num).toInt()
            : null;
      });
    } catch (_) {
      if (mounted) setState(() => _connected = false);
    } finally {
      _refreshInFlight = false;
    }
  }

  Map<String, dynamic> _stateFor(_FailureItem item) {
    final raw = _states[item.id];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  String _stateName(_FailureItem item) {
    final state = _stateFor(item);
    final name = (state['ui_state'] ?? '').toString();
    if (name == 'active' || name == 'armed' || name == 'error') {
      return name;
    }
    return 'idle';
  }

  bool _wrongVersion(_FailureItem item) {
    if (_simVersion != '2020' && _simVersion != '2024') return false;
    return !item.versions.contains(_simVersion);
  }

  bool _wrongAircraft(_FailureItem item) {
    if (_engineCount != null && item.engine > _engineCount!) return true;
    if (_engineType != null) {
      if (item.engineType == 'piston' && _engineType != 0) return true;
      if (item.engineType == 'turbine' &&
          _engineType != 1 &&
          _engineType != 3 &&
          _engineType != 5) {
        return true;
      }
    }
    return false;
  }

  // UI grouping only: classification is derived from real catalog entries.
  String _category(_FailureItem item) {
    final id = item.id.toLowerCase();
    final label = item.label.toLowerCase();
    final cat = item.category.toLowerCase();
    if (id.contains('apu') || label.contains('apu') || cat.contains('apu')) {
      return 'APU';
    }
    if (id.contains('flap') || label.contains('flap') || cat.contains('flap')) {
      return 'FLAPS';
    }
    if (id.contains('spoiler') ||
        label.contains('spoiler') ||
        cat.contains('spoiler')) return 'SPOILERS';
    if (id.startsWith('panel_engine_') ||
        cat.contains('engine') ||
        label.startsWith('engine ') ||
        id.startsWith('turb_') ||
        id.startsWith('piston_') ||
        id.startsWith('ramp_turb_')) {
      return 'ENGINE';
    }
    if (id.contains('fuel') || cat.contains('fuel')) return 'FUEL';
    if (id.contains('hydraulic') || cat.contains('hydraulic')) {
      return 'HYDRAULICS';
    }
    if (id.contains('electrical') ||
        cat.contains('electrical') ||
        id.contains('battery') ||
        cat.contains('electrical')) {
      return 'ELECTRICAL';
    }
    if (cat.contains('flight control') ||
        id.contains('aileron') ||
        id.contains('rudder') ||
        id.contains('elevator')) {
      return 'FLIGHT CONTROLS';
    }
    if (cat.contains('brake') ||
        cat.contains('gear') ||
        id.contains('gear') ||
        id.contains('brake')) return 'LANDING GEAR';
    if (cat.contains('navigation') ||
        cat == 'nav' ||
        id.startsWith('nav_') ||
        label.contains('navigation')) {
      return 'NAVIGATION';
    }
    if (cat.contains('instrument') || cat.contains('panel')) {
      return 'INSTRUMENTS';
    }
    return 'OTHER SYSTEMS';
  }

  List<String> _categories(List<_FailureItem> items) {
    const order = <String>[
      'ENGINE',
      'APU',
      'FUEL',
      'HYDRAULICS',
      'ELECTRICAL',
      'FLIGHT CONTROLS',
      'FLAPS',
      'SPOILERS',
      'LANDING GEAR',
      'INSTRUMENTS',
      'NAVIGATION',
      'OTHER SYSTEMS',
    ];
    final present = items.map(_category).toSet();
    return order.where(present.contains).toList();
  }

  bool _matchesSearch(_FailureItem item) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return item.label.toLowerCase().contains(query) ||
        item.id.toLowerCase().contains(query) ||
        _category(item).toLowerCase().contains(query);
  }

  void _notice(String message, {bool warning = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(
      backgroundColor:
          warning ? const Color(0xFF381C24) : const Color(0xFF15335E),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      content: Text(message, style: const TextStyle(color: _white)),
    ));
  }

  double? _numeric(TextEditingController controller, {required String name}) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || !value.isFinite) {
      _notice('Enter a valid $name', warning: true);
      return null;
    }
    return value;
  }

  Future<void> _controlTapped(_FailureItem item) async {
    if (!_connected ||
        _wrongVersion(item) ||
        _wrongAircraft(item) ||
        _fixingAll ||
        _sending.contains(item.id)) {
      return;
    }
    final state = _stateName(item);
    final payload = <String, dynamic>{'id': item.id};
    if (state == 'armed') {
      payload['action'] = 'cancel';
    } else if (state == 'active') {
      payload['action'] = 'switch';
      payload['enabled'] = false;
    } else if (_activationMode == 'now') {
      payload['action'] = 'switch';
      payload['enabled'] = true;
    } else {
      double? trigger;
      double? extraDelay;
      switch (_activationMode) {
        case 'delay':
          trigger = _numeric(_seconds, name: 'delay (seconds)');
          if (trigger == null) return;
          if (trigger < 1 || trigger > 3600) {
            _notice('Choose 1–3600 seconds', warning: true);
            return;
          }
          break;
        case 'airspeed':
          trigger = _numeric(_ias, name: 'IAS (knots)');
          if (trigger == null) return;
          break;
        case 'altitude':
          trigger = _numeric(_altitude, name: 'altitude (feet)');
          if (trigger == null) return;
          break;
        default:
          return;
      }
      if (trigger == null) return;
      if (trigger < 0 || trigger > 100000) {
        _notice('Value must be between 0 and 100000', warning: true);
        return;
      }
      if (_activationMode == 'airspeed' || _activationMode == 'altitude') {
        extraDelay = _numeric(_afterThreshold, name: 'additional seconds');
        if (extraDelay == null) return;
        if (extraDelay < 0 || extraDelay > 3600) {
          _notice('Choose 0–3600 additional seconds', warning: true);
          return;
        }
      }
      payload['action'] = 'arm';
      payload['mode'] = _activationMode;
      payload['value'] = trigger;
      if (extraDelay != null) payload['delay_seconds'] = extraDelay;
    }

    setState(() => _sending.add(item.id));
    try {
      await _post('action', payload);
      await _refreshStatus();
    } catch (_) {
      _notice('Unable to apply ${item.label}', warning: true);
      await _refreshStatus();
    } finally {
      if (mounted) setState(() => _sending.remove(item.id));
    }
  }

  Future<void> _fixAll() async {
    if (!_connected || _fixingAll) return;
    setState(() => _fixingAll = true);
    try {
      final reply = await _post('fix-all', <String, dynamic>{});
      await _refreshStatus();
      final failed = reply['failed'];
      final unverified = reply['unverified'];
      final failedCount =
          failed is List ? failed.length : (failed is num ? failed.toInt() : 0);
      final uncertainCount = unverified is List
          ? unverified.length
          : (unverified is num ? unverified.toInt() : 0);
      if (failedCount > 0 || uncertainCount > 0 || reply['ok'] == false) {
        _notice('Some failures may still require attention', warning: true);
      } else {
        _notice('All available resets requested');
      }
    } catch (_) {
      _notice('Unable to complete Fix All', warning: true);
      await _refreshStatus();
    } finally {
      if (mounted) setState(() => _fixingAll = false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // INSTRUCTOR UI. Only the visual layer below this point is restyled.
  // HTTP, catalog, state decoding and all POST payloads above are unchanged.
  // ──────────────────────────────────────────────────────────────────────

  static const Color _card = Color(0xFF101923);
  static const Color _fieldBg = Color(0xFF0B1521);
  static const Color _border = Color(0xFF26364D);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _buttonDark = Color(0xFF15335E);
  static const Color _directionInactive = Color(0xFF0A1420);
  static const Color _dangerBg = Color(0xFF381C24);
  static const Color _danger = Color(0xFFFF5252);
  static const Color _heading = Color(0xFF9BB8E1);
  static const Color _smallValue = Color(0xFF8FA9CE);
  static const Color _good = Color(0xFF69F0AE);
  static const Color _caution = Color(0xFFE9B65F);

  TextStyle _type(
    double size, {
    Color color = _white,
    FontWeight weight = FontWeight.w400,
    double tracking = 0,
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: tracking,
      height: 1.3,
    );
  }

  TextStyle _sectionType() =>
      _type(12, color: _heading, weight: FontWeight.w800, tracking: 1.1);

  TextStyle _smallType() =>
      _type(10, color: _heading, weight: FontWeight.w800, tracking: 0.7);

  BoxDecoration _panelDecoration() => BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      );

  BoxDecoration _buttonDecoration({
    bool selected = false,
    bool destructive = false,
    Color? customBorder,
    Color? customBackground,
  }) {
    final background = customBackground ??
        (destructive
            ? _dangerBg
            : selected
                ? _buttonDark
                : _directionInactive);
    final stroke = customBorder ??
        (destructive
            ? _danger
            : selected
                ? _accent
                : _border);
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: stroke, width: 1),
      boxShadow: selected && !destructive
          ? const [
              BoxShadow(
                color: Color(0x1F639DF0),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ]
          : const [],
    );
  }

  IconData _systemIcon(String category) {
    switch (category) {
      case 'ENGINE':
        return Icons.settings_input_component_rounded;
      case 'APU':
        return Icons.power_rounded;
      case 'FUEL':
        return Icons.local_gas_station_outlined;
      case 'HYDRAULICS':
        return Icons.water_drop_outlined;
      case 'ELECTRICAL':
        return Icons.bolt_rounded;
      case 'FLIGHT CONTROLS':
        return Icons.tune_rounded;
      case 'FLAPS':
        return Icons.flight_takeoff_rounded;
      case 'SPOILERS':
        return Icons.airplanemode_active_rounded;
      case 'LANDING GEAR':
        return Icons.tire_repair_rounded;
      case 'INSTRUMENTS':
        return Icons.speed_rounded;
      case 'NAVIGATION':
        return Icons.explore_outlined;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Widget _header(bool narrow) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: _buttonDecoration(selected: true),
            child: const Icon(
              Icons.flight_rounded,
              color: _accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FLIGHT FAILURES',
                  style: _type(18, weight: FontWeight.w900, tracking: 1.1),
                  maxLines: 2,
                  softWrap: true,
                ),
                const SizedBox(height: 3),
                Text(
                  'INSTRUCTOR OPERATIONS',
                  style: _type(10, color: _muted),
                  maxLines: 2,
                  softWrap: true,
                ),
              ],
            ),
          ),
          if (!narrow) ...[
            const SizedBox(width: 12),
            const Icon(Icons.flight_takeoff_rounded,
                color: _smallValue, size: 22),
          ],
        ],
      ),
    );
  }

  Widget _emptyState({required bool needsSimulator}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 60,
            height: 60,
            decoration: _buttonDecoration(selected: true),
            child: const Icon(Icons.flight_takeoff_rounded,
                color: _accent, size: 30),
          ),
          const SizedBox(height: 16),
          Text('FLIGHT FAILURES',
              textAlign: TextAlign.center, style: _sectionType()),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Text(
              needsSimulator
                  ? 'Connect to Microsoft Flight Simulator to access flight failures.'
                  : 'Flight failures are temporarily unavailable.',
              textAlign: TextAlign.center,
              style: _type(11, color: _muted),
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () async {
                if (_catalog.isEmpty) await _initialize();
                await _refreshStatus();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: _buttonDecoration(selected: true),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.refresh_rounded, size: 17, color: _accent),
                  const SizedBox(width: 8),
                  Text('RETRY', style: _type(11, weight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: _type(13, weight: FontWeight.w700),
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.search_rounded, color: _smallValue, size: 19),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 42, minHeight: 40),
          hintText: 'Search failures',
          hintStyle: _type(11, color: _muted),
          filled: true,
          fillColor: _fieldBg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _accent)),
        ),
      ),
    );
  }

  Widget _fixAllButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: (!_connected || _fixingAll) ? null : _fixAll,
        child: Opacity(
          opacity: (!_connected || _fixingAll) ? 0.5 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: _buttonDecoration(destructive: true),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_fixingAll)
                const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _danger))
              else
                const Icon(Icons.restart_alt_rounded, size: 17, color: _danger),
              const SizedBox(width: 7),
              Text('FIX ALL',
                  style: _type(11, color: _danger, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tools(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('FAILURE LIBRARY', style: _sectionType()),
                  const SizedBox(height: 3),
                  Text('${_catalog.length} AVAILABLE CONTROLS',
                      style: _type(10,
                          color: _smallValue, weight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 9),
            _fixAllButton(),
          ]),
          const SizedBox(height: 14),
          _searchField(),
        ],
      ),
    );
  }

  Widget _categorySelector() {
    final options = <String>['ALL', ..._categories(_catalog)];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FAILURE CATEGORIES', style: _sectionType()),
          const SizedBox(height: 11),
          SizedBox(
            height: 39,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final category = options[index];
                final selected = _selectedCategory == category;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: _buttonDecoration(selected: selected),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            category == 'ALL'
                                ? Icons.apps_rounded
                                : _systemIcon(category),
                            color: selected ? _accent : _smallValue,
                            size: 16),
                        const SizedBox(width: 7),
                        Text(category,
                            style: _type(11, weight: FontWeight.w700)),
                      ]),
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

  void _failurePressed(_FailureItem item) {
    if (!_connected ||
        _wrongVersion(item) ||
        _wrongAircraft(item) ||
        _fixingAll ||
        _sending.contains(item.id)) return;
    final state = _stateName(item);
    if (state == 'active' || state == 'armed') {
      // The existing OFF/CANCEL implementation handles active and armed items.
      _controlTapped(item);
    } else {
      _showActivationSheet(item);
    }
  }

  Widget _failureTile(_FailureItem item,
      {required bool incompatible, required bool compact}) {
    final wrongAircraft = _wrongAircraft(item);
    final unavailable = incompatible || wrongAircraft;
    final busy = _sending.contains(item.id);
    final state = _stateName(item);
    final active = state == 'active';
    final armed = state == 'armed';
    final errored = state == 'error';
    final actionable = !unavailable && _connected && !_fixingAll && !busy;
    final targetVersion = item.versions.length == 1
        ? 'MSFS ${item.versions.first}'
        : 'NOT SUPPORTED';
    final statusColor = active
        ? _danger
        : armed
            ? _caution
            : errored
                ? _danger
                : _smallValue;
    final tileBackground = active
        ? _dangerBg
        : armed
            ? const Color(0xFF302817)
            : _directionInactive;
    final tileBorder = active || errored
        ? _danger
        : armed
            ? _caution
            : _border;
    return Opacity(
      opacity: unavailable ? 0.46 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: actionable ? () => _failurePressed(item) : null,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 64),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 14,
              vertical: compact ? 7 : 11,
            ),
            decoration: _buttonDecoration(
              customBackground: tileBackground,
              customBorder: tileBorder,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_systemIcon(_category(item)),
                    color: statusColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label,
                          softWrap: true,
                          style: _type(12,
                              color: _white, weight: FontWeight.w700)),
                      if (unavailable || active || armed || errored) ...[
                        const SizedBox(height: 4),
                        Text(
                            incompatible
                                ? targetVersion
                                : wrongAircraft
                                    ? 'UNAVAILABLE'
                                    : active
                                        ? 'ACTIVE'
                                        : armed
                                            ? 'ARMED'
                                            : 'ATTENTION',
                            softWrap: true,
                            style: _type(10,
                                color: statusColor,
                                weight: FontWeight.w800,
                                tracking: 0.7)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                if (busy)
                  SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: statusColor))
                else
                  Icon(
                      active
                          ? Icons.stop_circle_outlined
                          : armed
                              ? Icons.close_rounded
                              : unavailable
                                  ? Icons.lock_outline_rounded
                                  : Icons.chevron_right_rounded,
                      size: 18,
                      color: statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _systemSection(
      String category, List<_FailureItem> visible, double outerWidth) {
    // Layout is calculated INSIDE the panel so padding cannot cause overflow.
    final items = visible.where((item) => _category(item) == category).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    items.sort((a, b) {
      final aWrong = _wrongVersion(a) ? 1 : 0;
      final bWrong = _wrongVersion(b) ? 1 : 0;
      return aWrong.compareTo(bWrong);
    });
    final contentWidth =
        (outerWidth - 36).clamp(1.0, double.infinity).toDouble();
    final columns = contentWidth >= 1150
        ? 4
        : contentWidth >= 810
            ? 3
            : contentWidth >= 520
                ? 2
                : 1;
    const gap = 10.0;
    final tileWidth = (contentWidth - (columns - 1) * gap) / columns;
    final compact = contentWidth < 520;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: _buttonDecoration(selected: true),
              child: Icon(_systemIcon(category), color: _accent, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(category, style: _sectionType(), softWrap: true)),
            const SizedBox(width: 8),
            Text('${items.length}',
                style: _type(11, color: _smallValue, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: 13),
          Wrap(spacing: gap, runSpacing: gap, children: [
            for (final item in items)
              SizedBox(
                  width: tileWidth,
                  child: _failureTile(item,
                      incompatible: _wrongVersion(item), compact: compact)),
          ]),
        ],
      ),
    );
  }

  Widget _sheetMode({
    required String value,
    required String chosen,
    required String title,
    required IconData icon,
    required VoidCallback onSelected,
  }) {
    final selected = chosen == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 51),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: _buttonDecoration(selected: selected),
          child: Row(children: [
            Icon(icon, color: selected ? _accent : _smallValue, size: 19),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    softWrap: true, style: _type(12, weight: FontWeight.w700))),
            const SizedBox(width: 4),
            Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 17,
                color: selected ? _accent : _muted),
          ]),
        ),
      ),
    );
  }

  void _adjustValue(TextEditingController controller, double amount,
      double minimum, double maximum) {
    final current = double.tryParse(controller.text.trim()) ?? minimum;
    final updated = (current + amount).clamp(minimum, maximum).toDouble();
    final value = updated == updated.roundToDouble()
        ? updated.toInt().toString()
        : updated.toString();
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Widget _sheetNumber({
    required TextEditingController controller,
    required String title,
    required String units,
    required double step,
    required double minimum,
    required double maximum,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(title.toUpperCase(), style: _smallType())),
        const SizedBox(width: 8),
        Text(units,
            style: _type(10, color: _smallValue, weight: FontWeight.w700)),
      ]),
      const SizedBox(height: 7),
      Container(
        height: 40,
        decoration: BoxDecoration(
          color: _fieldBg,
          border: Border.all(color: _border, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
              onTap: () => _adjustValue(controller, -step, minimum, maximum),
              child: const SizedBox(
                  width: 40,
                  height: 38,
                  child:
                      Icon(Icons.remove_rounded, color: _smallValue, size: 17)),
            ),
          ),
          Container(height: 38, width: 1, color: _border),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              textInputAction: TextInputAction.done,
              style: _type(14, weight: FontWeight.w700)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              ),
            ),
          ),
          Container(height: 38, width: 1, color: _border),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              onTap: () => _adjustValue(controller, step, minimum, maximum),
              child: const SizedBox(
                  width: 40,
                  height: 38,
                  child: Icon(Icons.add_rounded, color: _smallValue, size: 17)),
            ),
          ),
        ]),
      ),
    ]);
  }

  String? _validateSheetValues(String mode) {
    if (mode == 'now') return null;
    final controller = mode == 'delay'
        ? _seconds
        : mode == 'airspeed'
            ? _ias
            : _altitude;
    final value = double.tryParse(controller.text.trim());
    if (value == null || !value.isFinite) return 'Enter a valid number.';
    if (mode == 'delay' && (value < 1 || value > 3600)) {
      return 'Choose a delay between 1 and 3600 seconds.';
    }
    if (value < 0 || value > 100000) return 'Choose a value from 0 to 100000.';
    if (mode == 'airspeed' || mode == 'altitude') {
      final extra = double.tryParse(_afterThreshold.text.trim());
      if (extra == null || !extra.isFinite || extra < 0 || extra > 3600) {
        return 'Additional delay must be between 0 and 3600 seconds.';
      }
    }
    return null;
  }

  Future<void> _showActivationSheet(_FailureItem item) async {
    if (!mounted || !_connected || _sending.contains(item.id)) return;
    String chosen = 'now';
    String? validation;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xC60B111A),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, modalSetState) {
          final metrics = MediaQuery.of(modalContext);
          final maxHeight = (metrics.size.height -
                  metrics.viewInsets.bottom -
                  metrics.padding.top -
                  12)
              .clamp(120.0, metrics.size.height)
              .toDouble();
          return Padding(
            padding: EdgeInsets.only(bottom: metrics.viewInsets.bottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 550, maxHeight: maxHeight),
                child: Material(
                  color: _card,
                  elevation: 12,
                  shadowColor: const Color(0x16000000),
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9)),
                      side: BorderSide(color: _border)),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          const Icon(Icons.tune_rounded,
                              color: _accent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text('FAILURE ACTIVATION',
                                  style: _sectionType())),
                          IconButton(
                            onPressed: () => Navigator.of(modalContext).pop(),
                            icon: const Icon(Icons.close_rounded,
                                color: _muted, size: 20),
                            tooltip: 'Close',
                            visualDensity: VisualDensity.compact,
                          ),
                        ]),
                        const SizedBox(height: 7),
                        Text(item.label,
                            softWrap: true,
                            style: _type(18,
                                weight: FontWeight.w900, tracking: 1.1)),
                        const SizedBox(height: 16),
                        Text('ACTIVATION METHOD', style: _smallType()),
                        const SizedBox(height: 9),
                        LayoutBuilder(builder: (context, constraints) {
                          final useTwoColumns = constraints.maxWidth >= 425;
                          const gap = 9.0;
                          final width = useTwoColumns
                              ? (constraints.maxWidth - gap) / 2
                              : constraints.maxWidth;
                          return Wrap(spacing: gap, runSpacing: gap, children: [
                            SizedBox(
                                width: width,
                                child: _sheetMode(
                                    value: 'now',
                                    chosen: chosen,
                                    title: 'Immediately',
                                    icon: Icons.bolt_rounded,
                                    onSelected: () => modalSetState(() {
                                          chosen = 'now';
                                          validation = null;
                                        }))),
                            SizedBox(
                                width: width,
                                child: _sheetMode(
                                    value: 'delay',
                                    chosen: chosen,
                                    title: 'After Delay',
                                    icon: Icons.timer_outlined,
                                    onSelected: () => modalSetState(() {
                                          chosen = 'delay';
                                          validation = null;
                                        }))),
                            SizedBox(
                                width: width,
                                child: _sheetMode(
                                    value: 'airspeed',
                                    chosen: chosen,
                                    title: 'At Airspeed',
                                    icon: Icons.speed_rounded,
                                    onSelected: () => modalSetState(() {
                                          chosen = 'airspeed';
                                          validation = null;
                                        }))),
                            SizedBox(
                                width: width,
                                child: _sheetMode(
                                    value: 'altitude',
                                    chosen: chosen,
                                    title: 'At Altitude',
                                    icon: Icons.alt_route_rounded,
                                    onSelected: () => modalSetState(() {
                                          chosen = 'altitude';
                                          validation = null;
                                        }))),
                          ]);
                        }),
                        if (chosen != 'now') ...[
                          const SizedBox(height: 15),
                          if (chosen == 'delay')
                            _sheetNumber(
                                controller: _seconds,
                                title: 'Delay',
                                units: 'SECONDS',
                                step: 5,
                                minimum: 1,
                                maximum: 3600),
                          if (chosen == 'airspeed')
                            _sheetNumber(
                                controller: _ias,
                                title: 'Indicated Airspeed',
                                units: 'KNOTS IAS',
                                step: 5,
                                minimum: 0,
                                maximum: 100000),
                          if (chosen == 'altitude')
                            _sheetNumber(
                                controller: _altitude,
                                title: 'Indicated Altitude — ft MSL',
                                units: 'FEET',
                                step: 100,
                                minimum: 0,
                                maximum: 100000),
                          if (chosen == 'airspeed' || chosen == 'altitude') ...[
                            const SizedBox(height: 13),
                            _sheetNumber(
                                controller: _afterThreshold,
                                title: 'Additional Delay After Threshold',
                                units: 'SECONDS',
                                step: 5,
                                minimum: 0,
                                maximum: 3600),
                          ],
                        ],
                        if (validation != null) ...[
                          const SizedBox(height: 10),
                          Text(validation!, style: _type(11, color: _danger)),
                        ],
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(modalContext).pop(),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 11),
                                decoration: _buttonDecoration(),
                                child: Text('CANCEL',
                                    style: _type(11, weight: FontWeight.w700)),
                              ),
                            ),
                          )),
                          const SizedBox(width: 9),
                          Expanded(
                              flex: 2,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final error = _validateSheetValues(chosen);
                                    if (error != null) {
                                      modalSetState(() => validation = error);
                                      return;
                                    }
                                    // If status changed while modal was open,
                                    // do not accidentally send an OFF/CANCEL.
                                    if (!_connected ||
                                        _fixingAll ||
                                        _sending.contains(item.id) ||
                                        _stateName(item) == 'active' ||
                                        _stateName(item) == 'armed') {
                                      Navigator.of(modalContext).pop();
                                      _notice(
                                          'Failure status changed. Please try again.',
                                          warning: true);
                                      return;
                                    }
                                    Navigator.of(modalContext).pop();
                                    _activationMode = chosen;
                                    _controlTapped(item);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 11),
                                    decoration:
                                        _buttonDecoration(selected: true),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              chosen == 'now'
                                                  ? Icons.bolt_rounded
                                                  : Icons.schedule_rounded,
                                              size: 17,
                                              color: _accent),
                                          const SizedBox(width: 7),
                                          Flexible(
                                              child: Text(
                                                  chosen == 'now'
                                                      ? 'ACTIVATE FAILURE'
                                                      : 'ARM FAILURE',
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                  style: _type(11,
                                                      weight:
                                                          FontWeight.w700))),
                                        ]),
                                  ),
                                ),
                              )),
                        ]),
                        SizedBox(
                            height: metrics.padding.bottom > 0
                                ? metrics.padding.bottom
                                : 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bounds) {
      final availableWidth = bounds.maxWidth.isFinite
          ? bounds.maxWidth
          : MediaQuery.of(context).size.width;
      final narrow = availableWidth < 570;
      final pagePadding = availableWidth < 460
          ? 12.0
          : availableWidth < 800
              ? 18.0
              : 24.0;
      final contentWidth = (availableWidth - pagePadding * 2)
          .clamp(1.0, double.infinity)
          .toDouble();
      final hasControls = !_loading && _connected && _catalog.isNotEmpty;
      final visible = _catalog
          .where((item) =>
              _matchesSearch(item) &&
              (_selectedCategory == 'ALL' ||
                  _category(item) == _selectedCategory))
          .toList();
      final categories = _categories(visible);
      return Container(
        width: widget.width,
        height: widget.height ?? 820,
        color: _bg,
        child: RefreshIndicator(
          color: _accent,
          backgroundColor: _card,
          onRefresh: () async {
            if (_catalog.isEmpty) await _initialize();
            await _refreshStatus();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(pagePadding, 14, pagePadding, 20),
            children: [
              _header(narrow),
              const SizedBox(height: 12),
              if (_loading)
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: _panelDecoration(),
                  child: const Center(
                      child: CircularProgressIndicator(color: _accent)),
                )
              else if (!hasControls)
                _emptyState(needsSimulator: !_connected)
              else ...[
                _tools(contentWidth),
                const SizedBox(height: 12),
                _categorySelector(),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    decoration: _panelDecoration(),
                    child: Text('No matching failures',
                        textAlign: TextAlign.center,
                        style: _type(11, color: _muted)),
                  )
                else
                  for (final category in categories) ...[
                    _systemSection(category, visible, contentWidth),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 10),
                Text(
                  'Failure availability and behavior may vary depending on the aircraft.',
                  textAlign: TextAlign.center,
                  style: _type(10, color: _muted),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
    });
  }
}
