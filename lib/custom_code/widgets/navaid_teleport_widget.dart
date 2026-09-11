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

import '/custom_code/actions/get_offline_navaid_data.dart'; // استدعاء ملف الداتا المحدث

import 'dart:math' as math;
import 'dart:ui' as ui; // ضفنا المكتبة دي عشان الـ TextDirection
import 'package:flutter/services.dart';

// =========================================================
// 1. Formatters & Math Logic
// =========================================================
String formatFrequency(double freqKhz) {
  if (freqKhz > 10000) {
    return "${(freqKhz / 1000.0).toStringAsFixed(2)} MHz";
  } else {
    return "${freqKhz.toStringAsFixed(1)} kHz";
  }
}

String toDMS(double decimal, bool isLat) {
  String dir = decimal < 0 ? (isLat ? 'S' : 'W') : (isLat ? 'N' : 'E');
  double absDec = decimal.abs();
  int d = absDec.truncate();
  double minDec = (absDec - d) * 60;
  int m = minDec.truncate();
  double s = (minDec - m) * 60;
  return "$d° ${m.toString().padLeft(2, '0')}' ${s.toStringAsFixed(0).padLeft(2, '0')}\" $dir";
}

// =========================================================
// 2. Custom Painters for High-Tech Icons & Dial
// =========================================================
class GlowingVORPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = size.width / 2.2;
    Paint glow = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(Offset(cx, cy), r, glow);

    Paint dashPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 36; i++) {
      double angle = i * 10 * math.pi / 180;
      if (i % 2 == 0) {
        canvas.drawLine(
            Offset(
                cx + (r - 2) * math.cos(angle), cy + (r - 2) * math.sin(angle)),
            Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
            dashPaint);
      }
    }
    Paint innerCirc = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), r * 0.7, innerCirc);

    Path triangle = Path()
      ..moveTo(cx, cy - r * 0.4)
      ..lineTo(cx - r * 0.35, cy + r * 0.2)
      ..lineTo(cx + r * 0.35, cy + r * 0.2)
      ..close();
    canvas.drawPath(
        triangle,
        Paint()
          ..color = const Color(0xFF4A90E2)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(
        Offset(cx, cy),
        3.0,
        Paint()
          ..color = const Color(0xFF4A90E2)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlowingNDBPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = size.width / 2.2;
    Paint glow = Paint()
      ..color = const Color(0xFFE5B064).withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(Offset(cx, cy), r, glow);

    canvas.drawCircle(
        Offset(cx, cy),
        r * 0.75,
        Paint()
          ..color = const Color(0xFFE5B064)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
    Paint dots = Paint()
      ..color = const Color(0xFFE5B064)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 16; i++) {
      double angle = (22.5 * i) * math.pi / 180;
      canvas.drawCircle(
          Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
          2.0,
          dots);
    }
    canvas.drawCircle(Offset(cx, cy), 4.0, dots);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdvancedCompassDialPainter extends CustomPainter {
  final double angle;
  AdvancedCompassDialPainter({required this.angle});
  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2, cy = size.height / 2, r = size.width / 2;
    // Outer glow & dark base
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFF040A12)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFF1E324A)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(
        Offset(cx, cy),
        r * 0.65,
        Paint()
          ..color = const Color(0xFF122033)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);

    // Ticks & Labels
    Paint tickMajor = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;
    Paint tickMinor = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    // تم إصلاح TextDirection هنا
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < 36; i++) {
      double a = (i * 10 - 90) * math.pi / 180;
      bool isMajor = i % 3 == 0;
      double tickLen = isMajor ? 10 : 5;
      canvas.drawLine(
          Offset(cx + (r - tickLen) * math.cos(a),
              cy + (r - tickLen) * math.sin(a)),
          Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
          isMajor ? tickMajor : tickMinor);

      if (isMajor) {
        String label = (i * 10).toString();
        if (i == 0) label = "N";
        if (i == 9) label = "E";
        if (i == 18) label = "S";
        if (i == 27) label = "W";
        textPainter.text = TextSpan(
            text: label,
            style: TextStyle(
                color: (label == 'N' ||
                        label == 'E' ||
                        label == 'S' ||
                        label == 'W')
                    ? Colors.white
                    : const Color(0xFF6B87A8),
                fontSize: 12,
                fontWeight: FontWeight.bold));
        textPainter.layout();
        double lblRadius = r - 25;
        // تم إصلاح أمر الرسم هنا
        textPainter.paint(
            canvas,
            Offset(cx + lblRadius * math.cos(a) - textPainter.width / 2,
                cy + lblRadius * math.sin(a) - textPainter.height / 2));
      }
    }

    // Orange Arc from North to Current Radial
    double radAngle = (angle - 90) * math.pi / 180;
    Paint arcPaint = Paint()
      ..color = const Color(0xFFF09819)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.82),
        -math.pi / 2, angle * math.pi / 180, false, arcPaint);

    // Heading Bug (Orange Triangle on the edge)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(radAngle + math.pi / 2);
    Path bug = Path()
      ..moveTo(0, -r - 2)
      ..lineTo(-8, -r + 10)
      ..lineTo(8, -r + 10)
      ..close();
    canvas.drawPath(
        bug,
        Paint()
          ..color = const Color(0xFFF09819)
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ========================================================= 3.
///
/// Main Widget =========================================================
class NavaidTeleportWidget extends StatefulWidget {
  final double? width;
  final double? height;
  const NavaidTeleportWidget({Key? key, this.width, this.height})
      : super(key: key);
  @override
  _NavaidTeleportWidgetState createState() => _NavaidTeleportWidgetState();
}

class _NavaidTeleportWidgetState extends State<NavaidTeleportWidget> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _radialCtrl = TextEditingController(text: "060");
  final TextEditingController _distCtrl = TextEditingController(text: "25.0");

  List<NavaidModel> _searchResults = [];
  NavaidModel? _selectedNavaid;
  double _dialAngle = 60.0;

  // Computed Target Position
  double _targetLat = 0.0;
  double _targetLon = 0.0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _radialCtrl.dispose();
    _distCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (val.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    String q = val.toUpperCase();
    try {
      List<NavaidModel> results = [];
      for (String k in NavaidData.keys) {
        if (k.startsWith(q)) {
          var list = NavaidData.getNavaidData(k);
          if (list != null) results.addAll(list);
        }
      }
      setState(() {
        _searchResults = results.take(6).toList();
      });
    } catch (_) {
      setState(() => _searchResults = []);
    }
  }

  void _selectNavaid(NavaidModel nd) {
    setState(() {
      _selectedNavaid = nd;
      _searchCtrl.text = nd.name;
      _searchResults = [];
      _recalcTarget();
    });
  }

  void _updateDialFromPan(Offset localPos, Size size) {
    double dx = localPos.dx - size.width / 2;
    double dy = localPos.dy - size.height / 2;
    double angle = (math.atan2(dy, dx) * 180 / math.pi) + 90;
    if (angle < 0) angle += 360;
    setState(() {
      _dialAngle = angle;
      _radialCtrl.text = angle.round().toString().padLeft(3, '0');
      _recalcTarget();
    });
  }

  void _updateDialFromText(String val) {
    double? a = double.tryParse(val);
    if (a != null) {
      setState(() {
        _dialAngle = a % 360;
        _recalcTarget();
      });
    }
  }

  void _recalcTarget() {
    if (_selectedNavaid == null) return;
    double dist = double.tryParse(_distCtrl.text) ?? 0.0;
    double radial = double.tryParse(_radialCtrl.text) ?? 0.0;
    double lat1 = _selectedNavaid!.lat * math.pi / 180.0;
    double lon1 = _selectedNavaid!.lon * math.pi / 180.0;
    double brng = radial * math.pi / 180.0;
    double dRad = dist / 3440.065;

    double lat2 = math.asin(math.sin(lat1) * math.cos(dRad) +
        math.cos(lat1) * math.sin(dRad) * math.cos(brng));
    double lon2 = lon1 +
        math.atan2(math.sin(brng) * math.sin(dRad) * math.cos(lat1),
            math.cos(dRad) - math.sin(lat1) * math.sin(lat2));

    setState(() {
      _targetLat = lat2 * 180.0 / math.pi;
      _targetLon = (lon2 * 180.0 / math.pi + 540) % 360 - 180;
    });
  }

  void _teleport() {
    if (_selectedNavaid == null) return;

    FFAppState().update(() {
      FFAppState().efbNavaidTeleportLat = _targetLat;
      FFAppState().efbNavaidTeleportLon = _targetLon;
      FFAppState().efbNavaidTeleportRadialHdg =
          double.tryParse(_radialCtrl.text) ?? 0.0;
      FFAppState().efbNavaidTeleportAltitude =
          _selectedNavaid!.elev + 10000.0; // Default cruise above navaid
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('TELEPORT INITIATED TO: ${toDMS(_targetLat, true)}'),
        backgroundColor: const Color(0xFFF09819)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      // Main Background matching the UI Exactly
      Container(
          width: widget.width,
          height: widget.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF040A12), Color(0xFF091424)])),
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Header
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F1B2D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E324A))),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF7AA5D2), size: 16)),
              const SizedBox(width: 16),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Navigational Aids (Navaids) Teleport',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        'Quickly jump to any VOR / NDB and set your radial and distance.',
                        style:
                            TextStyle(color: Color(0xFF6B87A8), fontSize: 12)),
                  ]),
              const Spacer(),
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F1B2D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E324A))),
                  child: const Icon(Icons.location_on_outlined,
                      color: Color(0xFF4A90E2), size: 20)),
              const SizedBox(width: 12),
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F1B2D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E324A))),
                  child: const Icon(Icons.settings_outlined,
                      color: Color(0xFF7AA5D2), size: 20)),
            ]),
            const SizedBox(height: 24),

            // Search Bar
            SizedBox(
                height: 50,
                child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                        hintText: 'SEARCH NAVAID IDENT (e.g. HECA)',
                        hintStyle: const TextStyle(color: Color(0xFF455A75)),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF4A90E2)),
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel,
                                color: Color(0xFF455A75), size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchResults = []);
                            }),
                        filled: true,
                        fillColor: const Color(0xFF08111D),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF1E324A))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF1E324A))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF4A90E2), width: 1.5))))),
            const SizedBox(height: 24),

            if (_selectedNavaid != null) ...[
              // Middle Card: Navaid Details
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0C1627),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A2C42))),
                  child: Row(children: [
                    // Glowing Symbol Box
                    Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            color: const Color(0xFF070D18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1A2C42))),
                        child: Stack(alignment: Alignment.center, children: [
                          CustomPaint(
                              size: const Size(80, 80),
                              painter: _selectedNavaid!.type.contains('VOR')
                                  ? GlowingVORPainter()
                                  : GlowingNDBPainter()),
                          Positioned(
                              bottom: 15,
                              child: Text(_selectedNavaid!.type,
                                  style: const TextStyle(
                                      color: Color(0xFF4A90E2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5)))
                        ])),
                    const SizedBox(width: 24),

                    // Details
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF1A2C42)
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFF4A90E2)
                                                .withOpacity(0.5))),
                                    child: Row(children: [
                                      const Icon(Icons.wifi_tethering,
                                          color: Color(0xFF4A90E2), size: 12),
                                      const SizedBox(width: 6),
                                      Text(_selectedNavaid!.type,
                                          style: const TextStyle(
                                              color: Color(0xFF4A90E2),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold))
                                    ])),
                                if (_selectedNavaid!.airport.isNotEmpty)
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF1A2C42)
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Row(children: [
                                        const Icon(Icons.flight,
                                            color: Color(0xFF6B87A8), size: 12),
                                        const SizedBox(width: 6),
                                        Text(
                                            '${_selectedNavaid!.airport}  |  ${_selectedNavaid!.country}',
                                            style: const TextStyle(
                                                color: Color(0xFF6B87A8),
                                                fontSize: 10))
                                      ]))
                              ]),
                          const SizedBox(height: 12),
                          Text(_selectedNavaid!.name.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                          Text(
                              '${_selectedNavaid!.name} ${_selectedNavaid!.type.split('-')[0]}',
                              style: const TextStyle(
                                  color: Color(0xFF6B87A8), fontSize: 14)),
                          const SizedBox(height: 20),
                          Row(children: [
                            const Icon(Icons.graphic_eq,
                                color: Color(0xFF455A75), size: 16),
                            const SizedBox(width: 12),
                            const SizedBox(
                                width: 80,
                                child: Text('Frequency',
                                    style: TextStyle(
                                        color: Color(0xFF6B87A8),
                                        fontSize: 13))),
                            Text(formatFrequency(_selectedNavaid!.freq),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.landscape,
                                color: Color(0xFF455A75), size: 16),
                            const SizedBox(width: 12),
                            const SizedBox(
                                width: 80,
                                child: Text('Elevation',
                                    style: TextStyle(
                                        color: Color(0xFF6B87A8),
                                        fontSize: 13))),
                            Text(
                                '${_selectedNavaid!.elev.toInt()} ft (${(_selectedNavaid!.elev * 0.3048).toInt()} m)',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF455A75), size: 16),
                            const SizedBox(width: 12),
                            const SizedBox(
                                width: 80,
                                child: Text('Coordinates',
                                    style: TextStyle(
                                        color: Color(0xFF6B87A8),
                                        fontSize: 13))),
                            Text(
                                '${toDMS(_selectedNavaid!.lat, true)}   ${toDMS(_selectedNavaid!.lon, false)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))
                          ])
                        ]))
                  ])),
              const SizedBox(height: 24),

              // Bottom Card: Teleport Configuration
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0C1627),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1A2C42))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: const [
                              Icon(Icons.gps_fixed,
                                  color: Color(0xFF6B87A8), size: 20),
                              SizedBox(width: 12),
                              Text('Teleport Configuration',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            ]),
                            const Padding(
                                padding: EdgeInsets.only(left: 32, top: 4),
                                child: Text(
                                    'Set the radial and distance to teleport to this Navaid.',
                                    style: TextStyle(
                                        color: Color(0xFF6B87A8),
                                        fontSize: 12))),
                            const SizedBox(height: 30),
                            Expanded(
                                child: Row(children: [
                              // Dial Section
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onPanUpdate: (d) =>
                                                _updateDialFromPan(
                                                    d.localPosition,
                                                    const Size(220, 220)),
                                            child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CustomPaint(
                                                      size:
                                                          const Size(220, 220),
                                                      painter:
                                                          AdvancedCompassDialPainter(
                                                              angle:
                                                                  _dialAngle)),
                                                  Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            '${_dialAngle.round().toString().padLeft(3, '0')}°',
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFFF09819),
                                                                fontSize: 28,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        const Text('RADIAL',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF6B87A8),
                                                                fontSize: 10,
                                                                letterSpacing:
                                                                    2.0))
                                                      ])
                                                ])),
                                        const SizedBox(height: 20),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.sync,
                                                  color: Color(0xFF6B87A8),
                                                  size: 14),
                                              const SizedBox(width: 8),
                                              Text(
                                                  'Drag to rotate  •  Heading bug: ${_dialAngle.round().toString().padLeft(3, '0')}°',
                                                  style: const TextStyle(
                                                      color: Color(0xFF6B87A8),
                                                      fontSize: 11))
                                            ])
                                      ])),

                              Container(
                                  width: 1, color: const Color(0xFF1E324A)),

                              // Inputs & Action Section
                              Expanded(
                                  flex: 3,
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 40),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Radial Input
                                            Row(children: const [
                                              Icon(Icons.satellite_alt,
                                                  color: Color(0xFF4A90E2),
                                                  size: 16),
                                              SizedBox(width: 10),
                                              Text('Radial (°)',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 45,
                                                child: TextField(
                                                    controller: _radialCtrl,
                                                    onChanged:
                                                        _updateDialFromText,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: const Color(
                                                            0xFF08111D),
                                                        suffixIcon: const Icon(
                                                            Icons.cancel,
                                                            color: Color(
                                                                0xFF324866),
                                                            size: 16),
                                                        suffixText: '° ',
                                                        suffixStyle:
                                                            const TextStyle(
                                                                color: Color(
                                                                    0xFF6B87A8)),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color:
                                                                        Color(0xFF1E324A))),
                                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E324A)))))),
                                            const SizedBox(height: 20),

                                            // Distance Input
                                            Row(children: const [
                                              Icon(Icons.radar,
                                                  color: Color(0xFF4A90E2),
                                                  size: 16),
                                              SizedBox(width: 10),
                                              Text('Distance (NM)',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                                height: 45,
                                                child: TextField(
                                                    controller: _distCtrl,
                                                    onChanged: (v) =>
                                                        _recalcTarget(),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: const Color(
                                                            0xFF08111D),
                                                        suffixIcon: const Icon(
                                                            Icons.cancel,
                                                            color: Color(
                                                                0xFF324866),
                                                            size: 16),
                                                        suffixText: 'NM ',
                                                        suffixStyle:
                                                            const TextStyle(
                                                                color: Color(
                                                                    0xFF6B87A8)),
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    8),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Color(0xFF1E324A))),
                                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E324A)))))),
                                            const SizedBox(height: 24),

                                            // Teleport Summary Box
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF08111D),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFF1E324A))),
                                                child: Row(children: [
                                                  const Icon(Icons.my_location,
                                                      color: Color(0xFF455A75),
                                                      size: 24),
                                                  const SizedBox(width: 16),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                            'Teleport Position',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF6B87A8),
                                                                fontSize: 11)),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                            '${toDMS(_targetLat, true)}   ${toDMS(_targetLon, false)}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ]),
                                                  const Spacer(),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Row(children: [
                                                          const Text('Radial',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF6B87A8),
                                                                  fontSize:
                                                                      11)),
                                                          const SizedBox(
                                                              width: 12),
                                                          Text(
                                                              '${_dialAngle.round().toString().padLeft(3, '0')}°',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                        ]),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(children: [
                                                          const Text('Distance',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF6B87A8),
                                                                  fontSize:
                                                                      11)),
                                                          const SizedBox(
                                                              width: 12),
                                                          Text(
                                                              '${_distCtrl.text} NM',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                        ])
                                                      ])
                                                ])),
                                            const SizedBox(height: 24),

                                            // Teleport Button
                                            SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton.icon(
                                                    onPressed: _teleport,
                                                    icon: const Icon(
                                                        Icons.flight_takeoff,
                                                        color:
                                                            Color(0xFFF09819)),
                                                    label: const Text(
                                                        'Teleport',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFF09819),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing:
                                                                1.0)),
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF161F2C),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            side: const BorderSide(color: Color(0xFFF09819), width: 1.5)))))
                                          ])))
                            ]))
                          ])))
            ]
          ])),

      // Custom Styled Dropdown Search Results Overlay
      if (_searchResults.isNotEmpty)
        Positioned(
            top: 135,
            left: 24,
            right: 24,
            child: Material(
                color: Colors.transparent,
                elevation: 20,
                child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF0C1627),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4A90E2))),
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (ctx, i) =>
                            const Divider(color: Color(0xFF1A2C42), height: 1),
                        itemBuilder: (ctx, i) {
                          final nv = _searchResults[i];
                          return InkWell(
                              onTap: () => _selectNavaid(nv),
                              hoverColor: const Color(0xFF1E324A),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(children: [
                                    Icon(
                                        nv.type.contains('VOR')
                                            ? Icons.radar
                                            : Icons.adjust,
                                        color: const Color(0xFF4A90E2),
                                        size: 24),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Row(children: [
                                            Text(nv.name.toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            Text(nv.name,
                                                style: const TextStyle(
                                                    color: Color(0xFF6B87A8),
                                                    fontSize: 12))
                                          ]),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${nv.airport.isNotEmpty ? nv.airport : nv.country}  •  ${nv.type}',
                                              style: const TextStyle(
                                                  color: Color(0xFF6B87A8),
                                                  fontSize: 11))
                                        ])),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(formatFrequency(nv.freq),
                                              style: const TextStyle(
                                                  color: Color(0xFF6B87A8),
                                                  fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Row(children: const [
                                            Icon(Icons.gps_fixed,
                                                color: Color(0xFF455A75),
                                                size: 10),
                                            SizedBox(width: 4),
                                            Text('0.0 NM',
                                                style: TextStyle(
                                                    color: Color(0xFF6B87A8),
                                                    fontSize: 11))
                                          ])
                                        ])
                                  ])));
                        }))))
    ]);
  }
}
