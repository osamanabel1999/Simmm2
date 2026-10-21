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

/// Native Flutter doors UI.
///
/// Expects the original API on port 9005. No WebView, external JavaScript, or
/// changes to the SimConnect controller.
class AircraftDoorsWidget extends StatefulWidget {
  const AircraftDoorsWidget(
      {super.key, this.width, this.height, required this.ipAddress});
  final double? width;
  final double? height;
  final String ipAddress;
  @override
  State<AircraftDoorsWidget> createState() => _AircraftDoorsWidgetState();
}

class _DoorStyle {
  static const Color bg = Color(0xFF0B111A);
  static const Color card = Color(0xFF101923);
  static const Color field = Color(0xFF0B1521);
  static const Color border = Color(0xFF26364D);
  static const Color accent = Color(0xFF639DF0);
  static const Color selected = Color(0xFF15335E);
  static const Color inactive = Color(0xFF0A1420);
  static const Color dangerBg = Color(0xFF381C24);
  static const Color danger = Color(0xFFFF5252);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8B949E);
  static const Color heading = Color(0xFF9BB8E1);
  static const Color small = Color(0xFF8FA9CE);
  static const Color good = Color(0xFF69F0AE);
}

class _AircraftDoorsWidgetState extends State<AircraftDoorsWidget> {
  final http.Client _http = http.Client();
  Timer? _timer;
  Map<String, dynamic> _data = <String, dynamic>{};
  final Set<int> _busyDoors = <int>{};
  final Map<int, String> _feedback = <int, String>{};
  bool _bridgeReady = false;
  bool _polling = false;
  int _generation = 0;

  Map<String, dynamic> _map(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map<String, dynamic>(
          (dynamic k, dynamic v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> get _doors {
    final dynamic value = _data['doors'];
    if (value is! List) return <Map<String, dynamic>>[];
    return value.whereType<Map>().map(_map).toList(growable: false);
  }

  String _text(dynamic value, [String fallback = '—']) {
    if (value == null) return fallback;
    final String v = value.toString().trim();
    return v.isEmpty || v.toLowerCase() == 'null' ? fallback : v;
  }

  double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0.0;

  Uri? _url(String path) {
    String v = widget.ipAddress.trim();
    if (v.isEmpty) return null;
    if (!v.startsWith('http://') && !v.startsWith('https://')) v = 'http://$v';
    final Uri? parsed = Uri.tryParse(v);
    if (parsed == null || parsed.host.isEmpty) return null;
    final String base =
        '${parsed.scheme}://${parsed.host}:${parsed.hasPort ? parsed.port : 9005}';
    return Uri.tryParse('$base$path');
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer =
        Timer.periodic(const Duration(milliseconds: 1200), (_) => _refresh());
  }

  @override
  void didUpdateWidget(covariant AircraftDoorsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ipAddress != widget.ipAddress) {
      _generation++;
      _data = <String, dynamic>{};
      _bridgeReady = false;
      _feedback.clear();
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (!mounted || _polling) return;
    final Uri? u = _url('/api/state');
    if (u == null) {
      setState(() => _bridgeReady = false);
      return;
    }
    _polling = true;
    final int generation = _generation;
    try {
      final http.Response response = await _http.get(u,
          headers: const <String, String>{
            'Cache-Control': 'no-cache'
          }).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200)
        throw const FormatException('Status unavailable');
      final Map<String, dynamic> newData = _map(jsonDecode(response.body));
      if (!mounted || generation != _generation) return;
      setState(() {
        _bridgeReady = true;
        _data = newData;
        for (final Map<String, dynamic> door in _doors) {
          final int? id = door['id'] is int ? door['id'] as int : null;
          if (id != null &&
              !_busyDoors.contains(id) &&
              _map(door['pending']).isNotEmpty) {
            _feedback.remove(id);
          }
        }
      });
    } catch (_) {
      if (mounted && generation == _generation)
        setState(() => _bridgeReady = false);
    } finally {
      _polling = false;
    }
  }

  Future<void> _send(Map<String, dynamic> door, String action) async {
    final int? id = door['id'] is int ? door['id'] as int : null;
    final Uri? u = _url('/api/door');
    if (id == null || u == null || _busyDoors.contains(id)) return;
    setState(() {
      _busyDoors.add(id);
      _feedback[id] = action == 'open' ? 'OPENING…' : 'CLOSING…';
    });
    try {
      final http.Response response = await _http
          .post(
            u,
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{'index': id, 'action': action}),
          )
          .timeout(const Duration(seconds: 7));
      final Map<String, dynamic> result = _map(jsonDecode(response.body));
      if (!mounted) return;
      setState(() {
        _feedback[id] = response.statusCode >= 200 &&
                response.statusCode < 300 &&
                result['ok'] == true
            ? 'AWAITING DOOR STATUS'
            : 'ACTION NOT AVAILABLE';
      });
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _feedback[id] = 'ACTION NOT AVAILABLE');
    } finally {
      if (mounted) setState(() => _busyDoors.remove(id));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _http.close();
    super.dispose();
  }

  // Visual language matches the GSX Ground Operations widget supplied by the user.
  // All original HTTP/state methods above are intentionally unchanged.
  Text _label(String text,
          {double size = 11,
          Color color = _DoorStyle.white,
          FontWeight weight = FontWeight.w700,
          double? letterSpacing,
          int maxLines = 1,
          TextAlign? align}) =>
      Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        softWrap: false,
        style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            height: 1.25,
            letterSpacing: letterSpacing),
      );

  BoxDecoration _panel({bool active = false}) => BoxDecoration(
        color: active ? const Color(0xFF10233B) : _DoorStyle.inactive,
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: active ? _DoorStyle.accent : _DoorStyle.border),
      );

  Widget _miniPill(String text,
          {Color color = _DoorStyle.small, bool highlighted = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: highlighted ? _DoorStyle.selected : _DoorStyle.field,
          border: Border.all(
              color: highlighted ? _DoorStyle.accent : _DoorStyle.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: _label(text, size: 9, color: color, weight: FontWeight.w800),
      );

  Widget _header(double width) {
    final bool mobile = width < 600;
    // Same typography, vertical accent bar and bottom stroke as the GSX header.
    final Widget brand = Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
          height: 37,
          width: 4,
          decoration: BoxDecoration(
              color: _DoorStyle.accent,
              borderRadius: BorderRadius.circular(9))),
      const SizedBox(width: 12),
      Flexible(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
            _label('FLIGHT OPERATIONS / AIRCRAFT',
                size: 9.5,
                color: _DoorStyle.heading,
                weight: FontWeight.w800,
                letterSpacing: .7),
            const SizedBox(height: 4),
            _label('Aircraft Doors',
                size: mobile ? 15 : 18,
                weight: FontWeight.w900,
                letterSpacing: 1.1),
          ])),
    ]);
    final bool aircraftReady = _bridgeReady && _data['connected'] == true;
    final String aircraft = _text(_data['aircraft'], 'AIRCRAFT');
    final Widget? aircraftChip = aircraftReady
        ? Container(
            constraints:
                BoxConstraints(maxWidth: mobile ? width - 36 : width * .42),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: _DoorStyle.field,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _DoorStyle.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const Icon(Icons.airplanemode_active_outlined,
                  size: 13, color: _DoorStyle.accent),
              const SizedBox(width: 7),
              Flexible(
                  child: _label(aircraft,
                      size: 10,
                      color: _DoorStyle.heading,
                      weight: FontWeight.w800)),
            ]),
          )
        : null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: mobile ? 12 : 20, vertical: mobile ? 10 : 13),
      decoration: const BoxDecoration(
          color: _DoorStyle.card,
          border: Border(bottom: BorderSide(color: _DoorStyle.border))),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                  brand,
                  if (aircraftChip != null) ...<Widget>[
                    const SizedBox(height: 8),
                    aircraftChip,
                  ],
                ])
          : Row(children: <Widget>[
              Expanded(child: brand),
              if (aircraftChip != null) ...<Widget>[
                const SizedBox(width: 12),
                aircraftChip,
              ],
            ]),
    );
  }

  // Unboxed empty states: no huge bordered card and no technical API wording.
  Widget _empty({required bool noBridge}) => Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: _DoorStyle.selected,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _DoorStyle.border)),
                  child: const Icon(Icons.sensor_door_outlined,
                      color: _DoorStyle.accent, size: 24)),
              const SizedBox(height: 17),
              _label(
                  noBridge
                      ? 'Simulator Station Bridge'
                      : 'Waiting for Simulator',
                  size: 17,
                  weight: FontWeight.w900,
                  maxLines: 2,
                  align: TextAlign.center,
                  letterSpacing: .4),
              const SizedBox(height: 8),
              Text(
                  noBridge
                      ? 'Please start Simulator Station Bridge to access aircraft doors.'
                      : 'Open a flight in Microsoft Flight Simulator to load aircraft doors.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _DoorStyle.muted, fontSize: 12, height: 1.5)),
              const SizedBox(height: 18),
              Container(
                  width: 38,
                  height: 2,
                  decoration: BoxDecoration(
                      color: _DoorStyle.accent,
                      borderRadius: BorderRadius.circular(2))),
            ])),
      ));

  String _status(Map<String, dynamic> door) {
    final int? id = door['id'] is int ? door['id'] as int : null;
    if (id != null && _busyDoors.contains(id)) return 'SENDING…';
    final Map<String, dynamic> pending = _map(door['pending']);
    final String p = _text(pending['result'], '').toLowerCase();
    if (p == 'sent')
      return pending['desired'] == true ? 'OPENING…' : 'CLOSING…';
    if (p == 'failed') return 'ACTION UNAVAILABLE';
    if (p == 'unconfirmed') return 'NOT CONFIRMED';
    final String state = _text(door['status'], '').toLowerCase();
    if (state == 'open') return 'OPEN';
    if (state == 'closed') return 'CLOSED';
    if (state == 'moving') return 'IN MOTION';
    return id != null && _feedback.containsKey(id)
        ? _feedback[id]!
        : 'STATE UNAVAILABLE';
  }

  Color _statusColor(Map<String, dynamic> door) {
    final String p = _text(_map(door['pending'])['result'], '').toLowerCase();
    final String s = _text(door['status'], '').toLowerCase();
    if (p == 'failed' || p == 'unconfirmed') return _DoorStyle.danger;
    if (p == 'sent' || s == 'moving') return _DoorStyle.accent;
    if (s == 'open') return _DoorStyle.good;
    return _DoorStyle.small;
  }

  IconData _icon(String type) {
    if (type == 'cargo') return Icons.inventory_2_outlined;
    if (type == 'emergency') return Icons.exit_to_app_rounded;
    if (type == 'drop exit') return Icons.arrow_downward_rounded;
    return Icons.meeting_room_outlined;
  }

  Widget _doorAction(Map<String, dynamic> door, String action,
      {required bool dense}) {
    final int id = door['id'] is int ? door['id'] as int : -1;
    final String state = _text(door['status'], '').toLowerCase();
    final bool selected = state == (action == 'open' ? 'open' : 'closed');
    final bool pending =
        _text(_map(door['pending'])['result'], '').toLowerCase() == 'sent';
    // Original constraints and permissions, verbatim.
    final bool safe =
        _data['on_ground'] == true && _number(_data['airspeed_kt']) <= 5;
    final bool enabled = _bridgeReady &&
        _data['connected'] == true &&
        safe &&
        !selected &&
        !pending &&
        !_busyDoors.contains(id);
    final Color fill = selected ? _DoorStyle.selected : _DoorStyle.inactive;
    return Expanded(
        child: Opacity(
      opacity: enabled || selected ? 1 : .48,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? () => _send(door, action) : null,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            alignment: Alignment.center,
            height: dense ? 29 : 34,
            decoration: BoxDecoration(
              border: Border.all(
                  color: selected ? _DoorStyle.accent : _DoorStyle.border),
              borderRadius: BorderRadius.circular(6),
              boxShadow: selected
                  ? const <BoxShadow>[
                      BoxShadow(
                          color: Color(0x1F639DF0),
                          blurRadius: 12,
                          spreadRadius: 1),
                    ]
                  : null,
            ),
            child: _label(action.toUpperCase(),
                size: dense ? 9.2 : 10,
                color: _DoorStyle.white,
                weight: FontWeight.w800),
          ),
        ),
      ),
    ));
  }

  Widget _doorCard(Map<String, dynamic> door, int order,
      {required bool dense, required double extent}) {
    final int? id = door['id'] is int ? door['id'] as int : null;
    final String category = _text(door['category'], 'Cabin').toLowerCase();
    final String state = _text(door['status'], '').toLowerCase();
    final bool pending =
        _text(_map(door['pending'])['result'], '').toLowerCase() == 'sent';
    final bool active = state == 'open' ||
        state == 'moving' ||
        pending ||
        (id != null && _busyDoors.contains(id));
    final Color color = _statusColor(door);
    final bool ultraDense = extent < 105;
    final double pad = dense || ultraDense ? 8.0 : 10.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding:
          EdgeInsets.symmetric(horizontal: pad, vertical: ultraDense ? 6 : pad),
      decoration: _panel(active: active),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            SizedBox(
                width: 20,
                child: _label((order + 1).toString().padLeft(2, '0'),
                    size: 9,
                    color: _DoorStyle.heading,
                    weight: FontWeight.w800)),
            Icon(_icon(category),
                color: _DoorStyle.accent, size: dense ? 17 : 19),
            const SizedBox(width: 7),
            Expanded(
                child: _label(_text(door['name'], 'AIRCRAFT DOOR'),
                    size: dense ? 10.5 : 11.7,
                    weight: FontWeight.w800,
                    maxLines: 1)),
          ]),
          Row(children: <Widget>[
            Expanded(
                child: _label(category.toUpperCase(),
                    size: 8.5,
                    color: _DoorStyle.muted,
                    weight: FontWeight.w800,
                    letterSpacing: .45)),
            const SizedBox(width: 4),
            Container(
                width: 5,
                height: 5,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(
                child: _label(_status(door),
                    size: ultraDense ? 8.0 : 8.8,
                    color: color,
                    weight: FontWeight.w800,
                    align: TextAlign.right)),
          ]),
          Row(children: <Widget>[
            _doorAction(door, 'open', dense: dense || ultraDense),
            const SizedBox(width: 6),
            _doorAction(door, 'close', dense: dense || ultraDense),
          ]),
        ],
      ),
    );
  }

  Widget _doorGrid(
      List<Map<String, dynamic>> doors, double width, double height) {
    // Room for 6-8 doors on iPad, no artificial minimum tile height that forces
    // a scroll.  Scroll is reserved for a genuinely larger set of doors.
    final bool phone = width < 600;
    final int columns = width >= 1200
        ? 5
        : width >= 890
            ? 4
            : width >= 610
                ? 3
                : width >= 305
                    ? 2
                    : 1;
    final int rows = (doors.length / columns).ceil();
    final double gap = phone ? 8.0 : 10.0;
    final double ideal = rows == 0
        ? 120.0
        : (height - math.max(0, rows - 1).toDouble() * gap) / rows;
    final double minTile = phone ? 94.0 : 105.0;
    final double tile = ideal.clamp(minTile, phone ? 125.0 : 145.0).toDouble();
    final bool needsScroll =
        rows * tile + math.max(0, rows - 1) * gap > height + 0.5;
    return GridView.builder(
      primary: false,
      padding: EdgeInsets.zero,
      physics: needsScroll
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: doors.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        mainAxisExtent: tile,
      ),
      itemBuilder: (BuildContext context, int index) => _doorCard(
          doors[index], index,
          dense: phone || tile < 119, extent: tile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fallbackHeight = math.max(360.0, screenHeight * .77);
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? fallbackHeight,
      child: Material(
        color: _DoorStyle.bg,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewport) {
          final double width =
              viewport.maxWidth.isFinite ? viewport.maxWidth : 390.0;
          final bool phone = width < 600;
          final bool connected = _bridgeReady && _data['connected'] == true;
          final List<Map<String, dynamic>> doors = _doors;
          return Column(children: <Widget>[
            _header(width),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(phone ? 10 : 18, phone ? 10 : 15,
                  phone ? 10 : 18, connected ? 3 : 12),
              child: !_bridgeReady
                  ? _empty(noBridge: true)
                  : !connected
                      ? _empty(noBridge: false)
                      : doors.isEmpty
                          ? _empty(noBridge: false)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Expanded(
                                      child: _label('AIRCRAFT DOORS',
                                          size: 11,
                                          color: _DoorStyle.heading,
                                          weight: FontWeight.w800,
                                          letterSpacing: 1.1)),
                                  _miniPill('${doors.length} DOORS'),
                                ]),
                                const SizedBox(height: 9),
                                Expanded(
                                    child: LayoutBuilder(
                                        builder: (BuildContext context,
                                                BoxConstraints gridBox) =>
                                            _doorGrid(doors, gridBox.maxWidth,
                                                gridBox.maxHeight))),
                              ],
                            ),
            )),
            // As requested: no compatibility note when Bridge/sim is offline.
            if (connected)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    phone ? 12 : 18, 2, phone ? 12 : 18, phone ? 9 : 12),
                child: const Text(
                  'Door availability and operation may vary by aircraft.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _DoorStyle.muted, fontSize: 10, height: 1.35),
                ),
              ),
          ]);
        }),
      ),
    );
  }
}
