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

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '/custom_code/actions/get_offline_navaid_data.dart';

class GeoMath {
  static double calculateBearing(
      double lat1, double lon1, double lat2, double lon2) {
    double lat1Rad = lat1 * math.pi / 180.0;
    double lon1Rad = lon1 * math.pi / 180.0;
    double lat2Rad = lat2 * math.pi / 180.0;
    double lon2Rad = lon2 * math.pi / 180.0;
    double dLon = lon2Rad - lon1Rad;
    double y = math.sin(dLon) * math.cos(lat2Rad);
    double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);
    return ((math.atan2(y, x) * 180.0 / math.pi) + 360.0) % 360.0;
  }

  static Map<String, double> getClosestPointOnSegment(double pLat, double pLon,
      double aLat, double aLon, double bLat, double bLon) {
    double kX = math.cos(pLat * math.pi / 180.0) * 111320.0;
    double kY = 110540.0;
    double px = pLon * kX;
    double py = pLat * kY;
    double ax = aLon * kX;
    double ay = aLat * kY;
    double bx = bLon * kX;
    double by = bLat * kY;
    double dx = bx - ax;
    double dy = by - ay;
    double lenSq = dx * dx + dy * dy;
    if (lenSq == 0) {
      return {
        'lat': aLat,
        'lon': aLon,
        'dist': math.sqrt((px - ax) * (px - ax) + (py - ay) * (py - ay))
      };
    }
    double t = (((px - ax) * dx + (py - ay) * dy) / lenSq).clamp(0.0, 1.0);
    double cx = ax + t * dx;
    double cy = ay + t * dy;
    return {
      'lat': cy / kY,
      'lon': cx / kX,
      'dist': math.sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy))
    };
  }
}

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

class NavaidResult {
  final String ident;
  final NavaidModel model;
  NavaidResult(this.ident, this.model);
}

class OSMWay {
  final List<Map<String, double>> geom;
  final Map<String, dynamic> tags;
  OSMWay({required this.geom, required this.tags});
}

class OSMNode {
  final double lat;
  final double lon;
  final Map<String, dynamic> tags;
  String name = '';
  double heading = 0.0;
  OSMNode({required this.lat, required this.lon, required this.tags});
}

class StraightPointerPainter extends CustomPainter {
  final double dy;
  StraightPointerPainter({required this.dy});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF6B87A8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(size.width / 2, size.height / 2 + (dy > 0 ? 25 : -25)),
        Offset(size.width / 2, size.height / 2 + dy),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MasterILSPainter extends CustomPainter {
  final String runwayName;
  MasterILSPainter({required this.runwayName});
  @override
  void paint(Canvas canvas, Size size) {
    double rW = size.width * 0.42;
    double rH = 40.0;
    double rL = size.width * 0.52;
    double cY = size.height * 0.50;
    double rT = cY - (rH / 2);
    double iL = size.width * 0.45;
    double iH = 45.0;
    Path oF = Path();
    oF.moveTo(rL, cY);
    oF.lineTo(rL - iL, cY - iH);
    oF.lineTo(rL - iL + 90, cY);
    oF.lineTo(rL - iL, cY + iH);
    oF.close();
    Path iF = Path();
    double sc = 0.65;
    iF.moveTo(rL, cY);
    iF.lineTo(rL - (iL * sc), cY - (iH * sc));
    iF.lineTo(rL - (iL * sc) + (90 * sc), cY);
    iF.lineTo(rL - (iL * sc), cY + (iH * sc));
    iF.close();
    canvas.drawPath(
        oF,
        Paint()
          ..color = const Color(0xFF4370AC)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    canvas.drawPath(
        iF,
        Paint()
          ..color = const Color(0xFF4370AC).withOpacity(0.6)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);
    canvas.drawLine(
        Offset(rL - iL, cY),
        Offset(rL, cY),
        Paint()
          ..color = const Color(0xFFF09819)
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0));
    canvas.drawLine(
        Offset(rL - iL, cY),
        Offset(rL, cY),
        Paint()
          ..color = const Color(0xFFFFD460)
          ..strokeWidth = 1.5);
    final rR = Rect.fromLTWH(rL, rT, rW, rH);
    canvas.drawRect(rR, Paint()..color = const Color(0xFF13171C));
    canvas.drawRect(
        rR,
        Paint()
          ..color = const Color(0xFF5A7494)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    double dX = rL + 45;
    while (dX < rL + rW - 20) {
      canvas.drawLine(
          Offset(dX, cY),
          Offset(dX + 20, cY),
          Paint()
            ..color = const Color(0xFF8B9FB6)
            ..strokeWidth = 2.0);
      dX += 35;
    }
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(rL + 4, rT + 6 + (i * 6.5)),
          Offset(rL + 16, rT + 6 + (i * 6.5)),
          Paint()
            ..color = const Color(0xFFD9E2EC)
            ..strokeWidth = 2.5);
    }
    final tP = TextPainter(
        text: TextSpan(
            text: runwayName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        textDirection: ui.TextDirection.ltr)
      ..layout();
    canvas.save();
    canvas.translate(rL + 25, cY);
    canvas.rotate(math.pi / 2);
    tP.paint(canvas, Offset(-tP.width / 2, -tP.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ExactScaleBarPainter extends CustomPainter {
  final Color color;
  ExactScaleBarPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), p);
    double th = size.width / 3;
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), p);
    canvas.drawLine(Offset(th, 0), Offset(th, size.height), p);
    canvas.drawLine(Offset(th * 2, 0), Offset(th * 2, size.height), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), p);
    double mH = size.height / 2.5;
    double sx = size.width / 6;
    canvas.drawLine(Offset(sx, mH), Offset(sx, size.height), p);
    canvas.drawLine(Offset(sx * 3, mH), Offset(sx * 3, size.height), p);
    canvas.drawLine(Offset(sx * 5, mH), Offset(sx * 5, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AdvancedChartPainter extends CustomPainter {
  final double centerLat, centerLon, mapScale;
  final List<OSMWay> runways, taxiways, aprons, buildings;
  final List<OSMNode> holdShorts, windsocks;
  AdvancedChartPainter(
      {required this.centerLat,
      required this.centerLon,
      required this.runways,
      required this.taxiways,
      required this.aprons,
      required this.buildings,
      required this.holdShorts,
      required this.windsocks,
      required this.mapScale});

  Offset _project(double lat, double lon, Size size) => Offset(
      size.width / 2 +
          (lon - centerLon) * mapScale * math.cos(centerLat * math.pi / 180.0),
      size.height / 2 + (centerLat - lat) * mapScale);

  double _distToSeg(Offset p, Offset v, Offset w) {
    double l2 = (w.dx - v.dx) * (w.dx - v.dx) + (w.dy - v.dy) * (w.dy - v.dy);
    if (l2 == 0) return (p - v).distance;
    double t = math.max(
        0,
        math.min(
            1,
            ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) /
                l2));
    return (p - Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy)))
        .distance;
  }

  bool _isNearRunway(Offset pt, Size size) {
    for (var r in runways) {
      if (r.geom.isEmpty) continue;
      for (int i = 0; i < r.geom.length - 1; i++) {
        if (_distToSeg(pt, _project(r.geom[i]['lat']!, r.geom[i]['lon']!, size),
                _project(r.geom[i + 1]['lat']!, r.geom[i + 1]['lon']!, size)) <
            100.0) return true;
      }
    }
    return false;
  }

  bool _isOverlapping(Rect candidate, List<Rect> exist) {
    Rect inf = candidate.inflate(15.0);
    for (Rect r in exist) {
      if (inf.overlaps(r)) return true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint apronP = Paint()
      ..color = const Color(0xFF131A26)
      ..style = PaintingStyle.fill;
    for (var w in aprons) {
      if (w.geom.length < 3) continue;
      Path p = Path();
      var f = _project(w.geom[0]['lat']!, w.geom[0]['lon']!, size);
      p.moveTo(f.dx, f.dy);
      for (int i = 1; i < w.geom.length; i++) {
        var pt = _project(w.geom[i]['lat']!, w.geom[i]['lon']!, size);
        p.lineTo(pt.dx, pt.dy);
      }
      p.close();
      canvas.drawPath(p, apronP);
    }
    Paint bShad = Paint()
      ..color = const Color(0xFF040810).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    Paint bRoof = Paint()
      ..color = const Color(0xFF1A2436)
      ..style = PaintingStyle.fill;
    Paint bEdge = Paint()
      ..color = const Color(0xFF2C3E5B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var w in buildings) {
      if (w.geom.length < 3) continue;
      Path sP = Path();
      Path rP = Path();
      var f = _project(w.geom[0]['lat']!, w.geom[0]['lon']!, size);
      sP.moveTo(f.dx + 12, f.dy + 12);
      rP.moveTo(f.dx, f.dy);
      for (int i = 1; i < w.geom.length; i++) {
        var pt = _project(w.geom[i]['lat']!, w.geom[i]['lon']!, size);
        sP.lineTo(pt.dx + 12, pt.dy + 12);
        rP.lineTo(pt.dx, pt.dy);
      }
      sP.close();
      rP.close();
      canvas.drawPath(sP, bShad);
      canvas.drawPath(rP, bRoof);
      canvas.drawPath(rP, bEdge);
    }
    Paint tBase = Paint()
      ..color = const Color(0xFF0F1724)
      ..strokeWidth = 45.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    Paint tYEdge = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 52.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    Paint tGlow = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
      ..style = PaintingStyle.stroke;
    Paint tSolid = Paint()
      ..color = const Color(0xFF8BBFFF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    for (var w in taxiways) {
      Path p = Path();
      var f = _project(w.geom[0]['lat']!, w.geom[0]['lon']!, size);
      p.moveTo(f.dx, f.dy);
      for (int i = 1; i < w.geom.length; i++) {
        var pt = _project(w.geom[i]['lat']!, w.geom[i]['lon']!, size);
        p.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(p, tYEdge);
      canvas.drawPath(p, tBase);
      canvas.drawPath(p, tGlow);
      canvas.drawPath(p, tSolid);
    }
    Paint rBase = Paint()
      ..color = const Color(0xFF080D17)
      ..strokeWidth = 80.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    Paint rEdge = Paint()
      ..color = Colors.white
      ..strokeWidth = 84.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    Paint rCenter = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    for (var w in runways) {
      if (w.geom.length < 2) continue;
      Path p = Path();
      var p1 = _project(w.geom[0]['lat']!, w.geom[0]['lon']!, size);
      var p2 = _project(w.geom.last['lat']!, w.geom.last['lon']!, size);
      p.moveTo(p1.dx, p1.dy);
      p.lineTo(p2.dx, p2.dy);
      canvas.drawPath(p, rEdge);
      canvas.drawPath(p, rBase);
      double dist = (p2 - p1).distance;
      Offset dir = (p2 - p1) / dist;
      _drawThresh(canvas, p1, dir, 80.0);
      _drawThresh(canvas, p2, dir * -1, 80.0);
      String ref = w.tags['ref'] ?? '';
      if (ref.isNotEmpty) {
        List<String> rfs = ref.split('/');
        if (rfs.isNotEmpty) {
          _drawTxtRot(canvas, rfs[0], p1, dir, 110.0);
          if (rfs.length > 1) _drawTxtRot(canvas, rfs[1], p2, dir * -1, 110.0);
        }
      }
      double cD = 180.0;
      while (cD < dist - 180.0) {
        Offset s = p1 + dir * cD;
        cD += 40.0;
        if (cD > dist - 180.0) cD = dist - 180.0;
        canvas.drawLine(s, p1 + dir * cD, rCenter);
        cD += 40.0;
      }
    }
    for (var n in holdShorts) {
      _drawHold(canvas, _project(n.lat, n.lon, size), size);
    }
    List<Rect> dL = [];
    for (var w in taxiways) {
      String r = w.tags['ref'] ?? '';
      if (r.isEmpty || w.geom.length < 2) continue;
      double mL = 0;
      Offset? bS, bE;
      for (int i = 0; i < w.geom.length - 1; i++) {
        var p1 = _project(w.geom[i]['lat']!, w.geom[i]['lon']!, size);
        var p2 = _project(w.geom[i + 1]['lat']!, w.geom[i + 1]['lon']!, size);
        double d = (p2 - p1).distance;
        if (d > mL) {
          mL = d;
          bS = p1;
          bE = p2;
        }
      }
      if (mL >= 120.0 && bS != null && bE != null) {
        _attLbl(canvas, r, bS, bE, dL, size);
      }
    }
    for (var n in windsocks) {
      _drawWind(canvas, _project(n.lat, n.lon, size));
    }
  }

  void _attLbl(
      Canvas c, String txt, Offset p1, Offset p2, List<Rect> dL, Size s) {
    Offset m = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    double dx = p2.dx - p1.dx,
        dy = p2.dy - p1.dy,
        dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    Offset d = Offset(dx / dist, dy / dist),
        pr1 = Offset(-d.dy, d.dx),
        pr2 = Offset(d.dy, -d.dx);
    final tP = TextPainter(
        text: TextSpan(
            text: txt,
            style: const TextStyle(
                color: Color(0xFFFFD460),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier')),
        textDirection: ui.TextDirection.ltr)
      ..layout();
    double bw = tP.width + 40, bh = tP.height + 20;
    List<Offset> cands = [
      m + pr1 * 90.0,
      m + pr2 * 90.0,
      m + pr1 * 150.0,
      m + pr2 * 150.0
    ];
    for (Offset cd in cands) {
      Rect r = Rect.fromCenter(center: cd, width: bw, height: bh);
      if (!_isOverlapping(r, dL) && !_isNearRunway(cd, s)) {
        c.drawLine(
            m,
            cd,
            Paint()
              ..color = Colors.white.withOpacity(0.4)
              ..strokeWidth = 2.0
              ..style = PaintingStyle.stroke);
        c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)),
            Paint()..color = Colors.black);
        c.drawRRect(
            RRect.fromRectAndRadius(r, const Radius.circular(8)),
            Paint()
              ..color = const Color(0xFFFFD460)
              ..strokeWidth = 6.0
              ..style = PaintingStyle.stroke);
        tP.paint(c, Offset(cd.dx - tP.width / 2, cd.dy - tP.height / 2));
        dL.add(r);
        return;
      }
    }
  }

  void _drawThresh(Canvas c, Offset p, Offset d, double w) {
    Offset pr = Offset(-d.dy, d.dx);
    Paint pt = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5;
    double sp = (w / 2) / 7;
    for (int i = -6; i <= 6; i++) {
      if (i == 0) continue;
      Offset s = p + (pr * (i * sp)) + (d * 10.0);
      c.drawLine(s, s + (d * 45.0), pt);
    }
  }

  void _drawHold(Canvas c, Offset pt, Size s) {
    Offset? d;
    for (var w in taxiways) {
      for (int i = 0; i < w.geom.length - 1; i++) {
        var p1 = _project(w.geom[i]['lat']!, w.geom[i]['lon']!, s);
        var p2 = _project(w.geom[i + 1]['lat']!, w.geom[i + 1]['lon']!, s);
        if (_distToSeg(pt, p1, p2) < 30.0) {
          double l = (p2 - p1).distance;
          if (l > 0) {
            d = Offset((p2.dx - p1.dx) / l, (p2.dy - p1.dy) / l);
            break;
          }
        }
      }
      if (d != null) break;
    }
    d ??= const Offset(1, 0);
    Offset pr = Offset(-d.dy, d.dx);
    Offset? cR;
    double mD = double.infinity;
    for (var r in runways) {
      if (r.geom.isEmpty) continue;
      var rp = _project(r.geom[r.geom.length ~/ 2]['lat']!,
          r.geom[r.geom.length ~/ 2]['lon']!, s);
      double dst = (pt - rp).distance;
      if (dst < mD) {
        mD = dst;
        cR = rp;
      }
    }
    if (cR != null) {
      Offset tr = cR - pt;
      if (d!.dx * tr.dx + d.dy * tr.dy < 0) d = Offset(-d.dx, -d.dy);
    }
    Paint rG = Paint()
      ..color = Colors.redAccent.withOpacity(0.6)
      ..strokeWidth = 35.0
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0)
      ..style = PaintingStyle.stroke;
    Paint rS = Paint()
      ..color = const Color(0xFF990000)
      ..strokeWidth = 25.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    double bW = 60.0;
    c.drawLine(pt - pr * (bW / 2), pt + pr * (bW / 2), rG);
    c.drawLine(pt - pr * (bW / 2), pt + pr * (bW / 2), rS);
    Paint yL = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    Offset sl1 = pt - d! * 6.0, sl2 = pt - d * 2.0;
    c.drawLine(sl1 - pr * (bW / 2), sl1 + pr * (bW / 2), yL);
    c.drawLine(sl2 - pr * (bW / 2), sl2 + pr * (bW / 2), yL);
    Offset dl1 = pt + d * 2.0, dl2 = pt + d * 6.0;
    _dDL(c, dl1 - pr * (bW / 2), dl1 + pr * (bW / 2), yL);
    _dDL(c, dl2 - pr * (bW / 2), dl2 + pr * (bW / 2), yL);
  }

  void _dDL(Canvas c, Offset s, Offset e, Paint p) {
    double dW = 8.0, dS = 6.0, dst = (e - s).distance;
    if (dst == 0) return;
    Offset d = (e - s) / dst;
    double cD = 0;
    while (cD < dst) {
      double eD = math.min(cD + dW, dst);
      c.drawLine(s + d * cD, s + d * eD, p);
      cD = eD + dS;
    }
  }

  void _drawTxtRot(Canvas c, String t, Offset p, Offset d, double o) {
    final tP = TextPainter(
        text: TextSpan(
            text: t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900)),
        textDirection: ui.TextDirection.ltr)
      ..layout();
    double a = math.atan2(d.dy, d.dx) + math.pi / 2;
    c.save();
    Offset oP = p + d * o;
    c.translate(oP.dx, oP.dy);
    c.rotate(a);
    tP.paint(c, Offset(-tP.width / 2, -tP.height / 2));
    c.restore();
  }

  void _drawWind(Canvas c, Offset p) {
    c.drawCircle(
        p,
        50.0,
        Paint()
          ..color = const Color(0xFF4A90E2).withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0));
    c.drawCircle(
        p,
        20.0,
        Paint()
          ..color = const Color(0xFFFF6B00).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0));
    c.drawCircle(p, 8.0, Paint()..color = Colors.white);
    Path t = Path()
      ..moveTo(p.dx, p.dy - 15)
      ..lineTo(p.dx + 70, p.dy - 6)
      ..lineTo(p.dx + 70, p.dy + 6)
      ..lineTo(p.dx, p.dy + 15)
      ..close();
    c.drawPath(
        t,
        Paint()
          ..color = const Color(0xFFFF6B00)
          ..style = PaintingStyle.fill);
    Path w = Path()
      ..moveTo(p.dx + 70, p.dy - 6)
      ..lineTo(p.dx + 85, p.dy - 4)
      ..lineTo(p.dx + 85, p.dy + 4)
      ..lineTo(p.dx + 70, p.dy + 6)
      ..close();
    c.drawPath(
        w,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AirplaneShapePainter extends CustomPainter {
  final bool isHovered;
  _AirplaneShapePainter({required this.isHovered});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    Path p = Path()
      ..moveTo(0, -20)
      ..lineTo(4, -12)
      ..lineTo(4, 4)
      ..lineTo(24, 12)
      ..lineTo(24, 18)
      ..lineTo(4, 12)
      ..lineTo(4, 28)
      ..lineTo(12, 34)
      ..lineTo(12, 38)
      ..lineTo(0, 36)
      ..lineTo(-12, 38)
      ..lineTo(-12, 34)
      ..lineTo(-4, 28)
      ..lineTo(-4, 12)
      ..lineTo(-24, 18)
      ..lineTo(-24, 12)
      ..lineTo(-4, 4)
      ..lineTo(-4, -12)
      ..close();
    canvas.drawPath(
        p,
        Paint()
          ..color = isHovered ? Colors.white : const Color(0xFF7A9BBF)
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
      if (i % 2 == 0)
        canvas.drawLine(
            Offset(
                cx + (r - 2) * math.cos(angle), cy + (r - 2) * math.sin(angle)),
            Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
            dashPaint);
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
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFE5B064).withOpacity(0.15)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0));
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
    Paint tickMajor = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;
    Paint tickMinor = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;
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
        textPainter.paint(
            canvas,
            Offset(cx + lblRadius * math.cos(a) - textPainter.width / 2,
                cy + lblRadius * math.sin(a) - textPainter.height / 2));
      }
    }
    double radAngle = (angle - 90) * math.pi / 180;
    Paint arcPaint = Paint()
      ..color = const Color(0xFFF09819)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.82),
        -math.pi / 2, angle * math.pi / 180, false, arcPaint);
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

class ChartAirplaneWidget extends StatefulWidget {
  final OSMNode gate;
  final VoidCallback onTap;
  const ChartAirplaneWidget({Key? key, required this.gate, required this.onTap})
      : super(key: key);
  @override
  _ChartAirplaneWidgetState createState() => _ChartAirplaneWidgetState();
}

class _ChartAirplaneWidgetState extends State<ChartAirplaneWidget> {
  bool _isHovered = false;
  void _handleTap() {
    setState(() => _isHovered = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isHovered = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => setState(() => _isHovered = false),
      child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
                top: 20,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: _isHovered
                            ? const Color(0xFF223E63)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(widget.gate.name,
                        style: TextStyle(
                            color: _isHovered ? Colors.white : Colors.white70,
                            fontSize: _isHovered ? 24 : 20,
                            fontWeight: FontWeight.bold)))),
            AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 70,
                height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 5)
                ]),
                child: Center(
                    child: Transform.rotate(
                        angle: widget.gate.heading * math.pi / 180.0,
                        child: CustomPaint(
                            size: const Size(60, 60),
                            painter: _AirplaneShapePainter(
                                isHovered: _isHovered))))),
          ]),
    );
  }
}

class EFBConfigButton extends StatefulWidget {
  final String title;
  final Future Function()? onTap;
  const EFBConfigButton({required this.title, required this.onTap});
  @override
  _EFBConfigButtonState createState() => _EFBConfigButtonState();
}

class _EFBConfigButtonState extends State<EFBConfigButton> {
  bool _isPressed = false;
  void _handleTap() async {
    setState(() => _isPressed = true);
    if (widget.onTap != null) widget.onTap!();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _isPressed
                  ? const Color(0xFF7AA5D2)
                  : const Color(0xFF16263B),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF5A94E3), width: 1.0),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                          color: const Color(0xFF7AA5D2).withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]
                  : []),
          child: Text(widget.title,
              style: TextStyle(
                  color: _isPressed
                      ? const Color(0xFF070B14)
                      : const Color(0xFF7AA5D2),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5))),
    );
  }
}

class RadarPlane extends StatefulWidget {
  final BoxConstraints constraints;
  final double xPct, yPct;
  final String text1, text2;
  final double angle, txtDy;
  final Future Function()? onTap;
  const RadarPlane(
      {required this.constraints,
      required this.xPct,
      required this.yPct,
      required this.text1,
      required this.text2,
      required this.angle,
      required this.txtDy,
      required this.onTap});
  @override
  _RadarPlaneState createState() => _RadarPlaneState();
}

class _RadarPlaneState extends State<RadarPlane> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.constraints.maxWidth * widget.xPct - 100,
      top: widget.constraints.maxHeight * widget.yPct - 100,
      width: 200,
      height: 200,
      child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IgnorePointer(
                child: CustomPaint(
                    size: const Size(200, 200),
                    painter: StraightPointerPainter(dy: widget.txtDy))),
            IgnorePointer(
                child: Transform.translate(
                    offset:
                        Offset(0, widget.txtDy + (widget.txtDy > 0 ? 28 : -28)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.text1.isNotEmpty)
                        Text(widget.text1,
                            style: const TextStyle(
                                color: Color(0xFF7AA5D2),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 3)
                                ])),
                      if (widget.text2.isNotEmpty)
                        Text(widget.text2,
                            style: const TextStyle(
                                color: Color(0xFFE5B064),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 3)
                                ]))
                    ]))),
            GestureDetector(
              onTap: () {
                setState(() => _isHovered = true);
                if (widget.onTap != null) widget.onTap!();
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) setState(() => _isHovered = false);
                });
              },
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5)
                  ]),
                  child: Transform.rotate(
                      angle: widget.angle,
                      child: Icon(Icons.airplanemode_active,
                          color: _isHovered
                              ? Colors.white
                              : const Color(0xFF7AA5D2),
                          size: 50,
                          shadows: [
                            Shadow(
                                color: const Color(0xFF7AA5D2).withOpacity(0.6),
                                blurRadius: 6)
                          ]))),
            ),
          ]),
    );
  }
}

class _AirportChartWidget extends StatefulWidget {
  final double centerLat, centerLon;
  final Function(String name, double lat, double lon, double heading)?
      onChartGateSelected;
  const _AirportChartWidget(
      {Key? key,
      required this.centerLat,
      required this.centerLon,
      this.onChartGateSelected})
      : super(key: key);
  @override
  _AirportChartWidgetState createState() => _AirportChartWidgetState();
}

class _AirportChartWidgetState extends State<_AirportChartWidget> {
  List<OSMWay> _runways = [], _taxiways = [], _aprons = [], _buildings = [];
  List<OSMNode> _holdShorts = [], _gates = [], _windsocks = [];
  final TransformationController _transformationController =
      TransformationController();
  final double mapScaleFactor = 150000.0, canvasSize = 6000.0;

  @override
  void initState() {
    super.initState();
    _fetchAllAirportData();
    _centerCamera();
  }

  @override
  void didUpdateWidget(covariant _AirportChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerLat != widget.centerLat ||
        oldWidget.centerLon != widget.centerLon) {
      _fetchAllAirportData();
      _centerCamera();
    }
  }

  void _centerCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformationController.value = Matrix4.identity()
        ..translate(-canvasSize * 0.15 + 400, -canvasSize * 0.15 + 200)
        ..scale(0.15);
    });
  }

  Future<void> _fetchAllAirportData() async {
    _runways.clear();
    _taxiways.clear();
    _aprons.clear();
    _buildings.clear();
    _holdShorts.clear();
    _gates.clear();
    _windsocks.clear();
    await _fetchLayer(
        '[out:json];way["aeroway"="runway"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'runway');
    if (mounted) setState(() {});
    await _fetchLayer(
        '[out:json];way["aeroway"~"taxiway|taxilane"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'taxiway');
    if (mounted) setState(() {});
    await _fetchLayer(
        '[out:json];way["aeroway"="apron"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'apron');
    if (mounted) setState(() {});
    await _fetchLayer(
        '[out:json];way["building"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'building');
    await _fetchLayer(
        '[out:json];node["aeroway"="holding_position"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'holdshort');
    await _fetchLayer(
        '[out:json];node["aeroway"="windsock"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'windsock');
    if (mounted) setState(() {});
    await _fetchLayer(
        '[out:json];node["aeroway"="parking_position"](around:4000,${widget.centerLat},${widget.centerLon});out geom;',
        'gate');
    _calculateGateHeadings();
    if (mounted) setState(() {});
  }

  Future<void> _fetchLayer(String query, String layerName) async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://overpass.openstreetmap.fr/api/interpreter?data=${Uri.encodeComponent(query)}'),
          headers: {'User-Agent': 'SimulatorStationApp/1.0'});
      if (response.statusCode == 200)
        _parseOSMData(jsonDecode(response.body), layerName);
    } catch (e) {
      debugPrint('Error $layerName: $e');
    }
  }

  void _parseOSMData(Map<String, dynamic> data, String layerName) {
    final elements = data['elements'] as List?;
    if (elements == null) return;
    for (var el in elements) {
      final tags = el['tags'] ?? {};
      final type = el['type'];
      if (type == 'way' && el['geometry'] != null) {
        List<Map<String, double>> geom = [];
        for (var pt in el['geometry'])
          geom.add({
            'lat': (pt['lat'] as num).toDouble(),
            'lon': (pt['lon'] as num).toDouble()
          });
        OSMWay way = OSMWay(geom: geom, tags: tags);
        if (layerName == 'runway')
          _runways.add(way);
        else if (layerName == 'taxiway')
          _taxiways.add(way);
        else if (layerName == 'apron')
          _aprons.add(way);
        else if (layerName == 'building') _buildings.add(way);
      } else if (type == 'node') {
        OSMNode node = OSMNode(
            lat: (el['lat'] as num).toDouble(),
            lon: (el['lon'] as num).toDouble(),
            tags: tags);
        if (layerName == 'holdshort')
          _holdShorts.add(node);
        else if (layerName == 'gate')
          _gates.add(node);
        else if (layerName == 'windsock') _windsocks.add(node);
      }
    }
  }

  void _calculateGateHeadings() {
    List<List<Map<String, double>>> taxiwaySegments = [];
    for (var twy in _taxiways) taxiwaySegments.add(twy.geom);
    int unnamedCounter = 1;
    for (var node in _gates) {
      String name = node.tags['ref'] ?? node.tags['name'] ?? '';
      if (name.isEmpty) {
        name = 'GATE $unnamedCounter';
        unnamedCounter++;
      }
      node.name = name.toUpperCase();
      double heading = 0.0;
      bool hasRealHeading = false;
      String? headingTag = node.tags['heading'] ??
          node.tags['direction'] ??
          node.tags['orientation'] ??
          node.tags['angle'] ??
          node.tags['airplane:heading'];
      if (headingTag != null) {
        try {
          String cleaned = headingTag.replaceAll(RegExp(r'[^0-9\.\-]'), '');
          if (cleaned.isNotEmpty) {
            heading = double.parse(cleaned);
            hasRealHeading = true;
          }
        } catch (_) {}
      }
      if (!hasRealHeading && taxiwaySegments.isNotEmpty) {
        bool connectionFound = false;
        double calculatedHeading = 0.0;
        for (var way in taxiwaySegments) {
          for (int i = 0; i < way.length; i++) {
            if ((way[i]['lat']! - node.lat).abs() < 0.000001 &&
                (way[i]['lon']! - node.lon).abs() < 0.000001) {
              connectionFound = true;
              if (i > 0)
                calculatedHeading = GeoMath.calculateBearing(
                    way[i - 1]['lat']!, way[i - 1]['lon']!, node.lat, node.lon);
              else if (i < way.length - 1)
                calculatedHeading = GeoMath.calculateBearing(
                    way[1]['lat']!, way[1]['lon']!, node.lat, node.lon);
              break;
            }
          }
          if (connectionFound) break;
        }
        if (!connectionFound) {
          double minDistance = double.infinity,
              bestProjLat = 0.0,
              bestProjLon = 0.0;
          for (var way in taxiwaySegments) {
            for (int i = 0; i < way.length - 1; i++) {
              var proj = GeoMath.getClosestPointOnSegment(
                  node.lat,
                  node.lon,
                  way[i]['lat']!,
                  way[i]['lon']!,
                  way[i + 1]['lat']!,
                  way[i + 1]['lon']!);
              if (proj['dist']! < minDistance) {
                minDistance = proj['dist']!;
                bestProjLat = proj['lat']!;
                bestProjLon = proj['lon']!;
              }
            }
          }
          if (minDistance <= 250.0)
            calculatedHeading = GeoMath.calculateBearing(
                bestProjLat, bestProjLon, node.lat, node.lon);
        }
        heading = double.parse(calculatedHeading.toStringAsFixed(1));
      }
      node.heading = heading;
    }
  }

  Offset _projectToCanvas(double lat, double lon) => Offset(
      canvasSize / 2 +
          (lon - widget.centerLon) *
              mapScaleFactor *
              math.cos(widget.centerLat * math.pi / 180.0),
      canvasSize / 2 + (widget.centerLat - lat) * mapScaleFactor);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          minScale: 0.02,
          maxScale: 10.0,
          boundaryMargin: const EdgeInsets.all(2000),
          child: SizedBox(
              width: canvasSize,
              height: canvasSize,
              child: Stack(clipBehavior: Clip.none, children: [
                CustomPaint(
                    size: Size(canvasSize, canvasSize),
                    painter: AdvancedChartPainter(
                        centerLat: widget.centerLat,
                        centerLon: widget.centerLon,
                        runways: _runways,
                        taxiways: _taxiways,
                        aprons: _aprons,
                        buildings: _buildings,
                        holdShorts: _holdShorts,
                        windsocks: _windsocks,
                        mapScale: mapScaleFactor)),
                ..._gates.map((gate) {
                  Offset pos = _projectToCanvas(gate.lat, gate.lon);
                  return Positioned(
                      left: pos.dx - 100,
                      top: pos.dy - 100,
                      width: 200,
                      height: 200,
                      child: ChartAirplaneWidget(
                          gate: gate,
                          onTap: () {
                            if (widget.onChartGateSelected != null)
                              widget.onChartGateSelected!(
                                  gate.name, gate.lat, gate.lon, gate.heading);
                          }));
                }).toList(),
              ]))),
      Positioned(
          bottom: 30,
          right: 30,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: const Color(0xFF09121F).withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF4A90E2).withOpacity(0.3),
                        width: 1.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.navigation,
                          color: Color(0xFF4A90E2), size: 20),
                      Text('N',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))
                    ])),
            const SizedBox(height: 20),
            AnimatedBuilder(
                animation: _transformationController,
                builder: (context, child) {
                  double metersPerPixel = (111320.0 / mapScaleFactor) /
                      _transformationController.value.getMaxScaleOnAxis();
                  double rawStep = (250.0 * metersPerPixel) / 3;
                  int step = rawStep <= 0
                      ? 1
                      : ((rawStep /
                                          math.pow(
                                              10,
                                              (math.log(rawStep) / math.ln10)
                                                  .floorToDouble()) <
                                      1.5
                                  ? 1
                                  : rawStep /
                                              math.pow(
                                                  10,
                                                  (math.log(rawStep) /
                                                          math.ln10)
                                                      .floorToDouble()) <
                                          3
                                      ? 2
                                      : rawStep /
                                                  math.pow(
                                                      10,
                                                      (math.log(rawStep) /
                                                              math.ln10)
                                                          .floorToDouble()) <
                                              7
                                          ? 5
                                          : 10) *
                              math.pow(
                                  10,
                                  (math.log(rawStep) / math.ln10)
                                      .floorToDouble()))
                          .round();
                  double barWidth = (step * 3) / metersPerPixel;
                  return Container(
                      width: barWidth + 20,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('0',
                                      style: TextStyle(
                                          color: Color(0xFF638BB8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text('$step',
                                      style: const TextStyle(
                                          color: Color(0xFF638BB8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text('${step * 2}',
                                      style: const TextStyle(
                                          color: Color(0xFF638BB8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text('${step * 3} m',
                                      style: const TextStyle(
                                          color: Color(0xFF638BB8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500))
                                ]),
                            const SizedBox(height: 4),
                            CustomPaint(
                                size: Size(barWidth, 8),
                                painter: ExactScaleBarPainter(
                                    color: const Color(0xFF638BB8))),
                          ]));
                }),
          ])),
    ]);
  }
}

class NavaidTeleportWidget extends StatefulWidget {
  final Future Function()? onTeleportTap;
  const NavaidTeleportWidget({Key? key, this.onTeleportTap}) : super(key: key);
  @override
  _NavaidTeleportWidgetState createState() => _NavaidTeleportWidgetState();
}

class _NavaidTeleportWidgetState extends State<NavaidTeleportWidget> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _radialCtrl = TextEditingController(text: "060");
  final TextEditingController _hdgCtrl = TextEditingController(text: "060");
  final TextEditingController _distCtrl = TextEditingController(text: "25.0");
  final TextEditingController _altCtrl = TextEditingController(text: "10000");
  final TextEditingController _spdCtrl =
      TextEditingController(text: "250"); // خانة السرعة الجديدة

  List<NavaidResult> _searchResults = [];
  NavaidResult? _selectedNavaid;
  double _dialAngle = 60.0;
  double _targetLat = 0.0;
  double _targetLon = 0.0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _radialCtrl.dispose();
    _hdgCtrl.dispose();
    _distCtrl.dispose();
    _altCtrl.dispose();
    _spdCtrl.dispose(); // إغلاق متغير السرعة
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (val.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    String q = val.toUpperCase();
    try {
      List<NavaidResult> exactMatches = [];
      List<NavaidResult> nameMatches = [];
      for (String k in NavaidData.keys) {
        var list = NavaidData.getNavaidData(k);
        if (list == null) continue;
        if (k.startsWith(q)) {
          exactMatches.addAll(list.map((m) => NavaidResult(k, m)));
        } else {
          for (var nv in list) {
            if (nv.name.toUpperCase().startsWith(q) ||
                nv.country.toUpperCase().startsWith(q) ||
                nv.airport.toUpperCase().startsWith(q)) {
              nameMatches.add(NavaidResult(k, nv));
            }
          }
        }
      }
      setState(() {
        _searchResults = [...exactMatches, ...nameMatches].take(8).toList();
      });
    } catch (_) {
      setState(() => _searchResults = []);
    }
  }

  void _selectNavaid(NavaidResult nr) {
    setState(() {
      _selectedNavaid = nr;
      _searchCtrl.text = nr.ident;
      _altCtrl.text = (nr.model.elev + 10000).toInt().toString();
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
      String formattedAngle = angle.round().toString().padLeft(3, '0');
      _radialCtrl.text = formattedAngle;
      _hdgCtrl.text = formattedAngle;
      _recalcTarget();
    });
  }

  void _updateDialFromText(String val) {
    double? a = double.tryParse(val);
    if (a != null) {
      setState(() {
        _dialAngle = a % 360;
        _hdgCtrl.text = _dialAngle.round().toString().padLeft(3, '0');
        _recalcTarget();
      });
    }
  }

  void _recalcTarget() {
    if (_selectedNavaid == null) return;
    double dist = double.tryParse(_distCtrl.text) ?? 0.0;
    double radial = double.tryParse(_radialCtrl.text) ?? 0.0;
    double lat1 = _selectedNavaid!.model.lat * math.pi / 180.0;
    double lon1 = _selectedNavaid!.model.lon * math.pi / 180.0;
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
      FFAppState().efbNavaidTeleportHeading =
          double.tryParse(_hdgCtrl.text) ?? 0.0;
      FFAppState().efbNavaidTeleportAltitude =
          double.tryParse(_altCtrl.text) ?? 10000.0;
      FFAppState().efbNavaidTeleportSpeed =
          double.tryParse(_spdCtrl.text) ?? 250.0; // حفظ السرعة الجديدة
    });
    if (widget.onTeleportTap != null) widget.onTeleportTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(
              child: Column(children: [
                Text('Navigational Aids (Navaids) Teleport',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                    'Quickly jump to any VOR / NDB and set your radial and distance.',
                    style: TextStyle(color: Color(0xFF6B87A8), fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 24),
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
                        hintText:
                            'SEARCH NAVAID IDENT OR NAME (e.g. CVO, CAIRO)',
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
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0C1627),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A2C42))),
                  child: Row(children: [
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
                              painter:
                                  _selectedNavaid!.model.type.contains('VOR')
                                      ? GlowingVORPainter()
                                      : GlowingNDBPainter()),
                          Positioned(
                              bottom: 15,
                              child: Text(_selectedNavaid!.model.type,
                                  style: const TextStyle(
                                      color: Color(0xFF4A90E2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5)))
                        ])),
                    const SizedBox(width: 24),
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
                                      Text(_selectedNavaid!.model.type,
                                          style: const TextStyle(
                                              color: Color(0xFF4A90E2),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold))
                                    ])),
                                if (_selectedNavaid!.model.airport.isNotEmpty ||
                                    _selectedNavaid!.model.country.isNotEmpty)
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
                                            '${_selectedNavaid!.model.airport} | ${_selectedNavaid!.model.country}'
                                                .trim()
                                                .replaceAll(
                                                    RegExp(r'^\|\s*|\s*\|\s*$'),
                                                    ''),
                                            style: const TextStyle(
                                                color: Color(0xFF6B87A8),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold))
                                      ]))
                              ]),
                          const SizedBox(height: 12),
                          Text(_selectedNavaid!.ident,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0)),
                          Text(
                              '${_selectedNavaid!.model.name} ${_selectedNavaid!.model.type.split('-')[0]}',
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
                            Text(formatFrequency(_selectedNavaid!.model.freq),
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
                                '${_selectedNavaid!.model.elev.toInt()} ft (${(_selectedNavaid!.model.elev * 0.3048).toInt()} m)',
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
                                '${toDMS(_selectedNavaid!.model.lat, true)}   ${toDMS(_selectedNavaid!.model.lon, false)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))
                          ])
                        ]))
                  ])),
              const SizedBox(height: 24),
              Container(
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
                                'Set the radial, heading, distance, altitude, and speed.',
                                style: TextStyle(
                                    color: Color(0xFF6B87A8), fontSize: 12))),
                        const SizedBox(height: 30),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  width: 1,
                                  height: 260,
                                  color: const Color(0xFF1E324A)),
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
                                            Row(children: [
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Row(children: const [
                                                      Icon(Icons.satellite_alt,
                                                          color:
                                                              Color(0xFF4A90E2),
                                                          size: 14),
                                                      SizedBox(width: 8),
                                                      Text('Radial (°)',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ]),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        height: 40,
                                                        child: TextField(
                                                            controller:
                                                                _radialCtrl,
                                                            onChanged:
                                                                _updateDialFromText,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: const Color(
                                                                    0xFF08111D),
                                                                suffixText:
                                                                    '° ',
                                                                suffixStyle: const TextStyle(
                                                                    color: Color(
                                                                        0xFF6B87A8),
                                                                    fontSize:
                                                                        10),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF1E324A))),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    borderSide: const BorderSide(color: Color(0xFF1E324A))))))
                                                  ])),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Row(children: const [
                                                      Icon(Icons.explore,
                                                          color:
                                                              Color(0xFF4A90E2),
                                                          size: 14),
                                                      SizedBox(width: 8),
                                                      Text('Heading (°)',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ]),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        height: 40,
                                                        child: TextField(
                                                            controller:
                                                                _hdgCtrl,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: const Color(
                                                                    0xFF08111D),
                                                                suffixText:
                                                                    '° ',
                                                                suffixStyle: const TextStyle(
                                                                    color: Color(
                                                                        0xFF6B87A8),
                                                                    fontSize:
                                                                        10),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF1E324A))),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    borderSide: const BorderSide(color: Color(0xFF1E324A))))))
                                                  ]))
                                            ]),
                                            const SizedBox(height: 16),
                                            // صف المسافة، الارتفاع، والسرعة الجديد
                                            Row(children: [
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Row(children: const [
                                                      Icon(Icons.radar,
                                                          color:
                                                              Color(0xFF4A90E2),
                                                          size: 14),
                                                      SizedBox(width: 8),
                                                      Text('Distance',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ]),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        height: 40,
                                                        child: TextField(
                                                            controller:
                                                                _distCtrl,
                                                            onChanged: (v) =>
                                                                _recalcTarget(),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    const Color(
                                                                        0xFF08111D),
                                                                suffixText:
                                                                    'NM ',
                                                                suffixStyle: const TextStyle(
                                                                    color: Color(
                                                                        0xFF6B87A8),
                                                                    fontSize:
                                                                        10),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Color(0xFF1E324A))),
                                                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E324A))))))
                                                  ])),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Row(children: const [
                                                      Icon(Icons.landscape,
                                                          color:
                                                              Color(0xFF4A90E2),
                                                          size: 14),
                                                      SizedBox(width: 8),
                                                      Text('Altitude',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ]),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        height: 40,
                                                        child: TextField(
                                                            controller:
                                                                _altCtrl,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: const Color(
                                                                    0xFF08111D),
                                                                suffixText:
                                                                    'FT ',
                                                                suffixStyle: const TextStyle(
                                                                    color: Color(
                                                                        0xFF6B87A8),
                                                                    fontSize:
                                                                        10),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF1E324A))),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    borderSide: const BorderSide(color: Color(0xFF1E324A))))))
                                                  ])),
                                              const SizedBox(width: 12),
                                              // خانة السرعة الجديدة
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Row(children: const [
                                                      Icon(Icons.speed,
                                                          color:
                                                              Color(0xFF4A90E2),
                                                          size: 14),
                                                      SizedBox(width: 8),
                                                      Text('Speed',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ]),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                        height: 40,
                                                        child: TextField(
                                                            controller:
                                                                _spdCtrl,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                            decoration: InputDecoration(
                                                                filled: true,
                                                                fillColor: const Color(
                                                                    0xFF08111D),
                                                                suffixText:
                                                                    'KT ',
                                                                suffixStyle: const TextStyle(
                                                                    color: Color(
                                                                        0xFF6B87A8),
                                                                    fontSize:
                                                                        10),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide: const BorderSide(
                                                                        color: Color(
                                                                            0xFF1E324A))),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    borderSide: const BorderSide(color: Color(0xFF1E324A))))))
                                                  ]))
                                            ]),
                                            const SizedBox(height: 24),
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
                                                          const Text('Hdg',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF6B87A8),
                                                                  fontSize:
                                                                      11)),
                                                          const SizedBox(
                                                              width: 12),
                                                          Text(
                                                              '${_hdgCtrl.text}°',
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
                                                          const Text('Dist/Spd',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF6B87A8),
                                                                  fontSize:
                                                                      11)),
                                                          const SizedBox(
                                                              width: 12),
                                                          Text(
                                                              '${_distCtrl.text} NM • ${_spdCtrl.text} KT',
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
                                            const SizedBox(height: 20),
                                            SizedBox(
                                                width: double.infinity,
                                                height: 45,
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
                            ])
                      ]))
            ]
          ])),
      if (_searchResults.isNotEmpty)
        Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Material(
                color: Colors.transparent,
                elevation: 20,
                child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
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
                                        nv.model.type.contains('VOR')
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
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(nv.ident,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 1),
                                                    child: Text(nv.model.name,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF6B87A8),
                                                            fontSize: 12)))
                                              ]),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${nv.model.airport.isNotEmpty ? nv.model.airport : nv.model.country}  •  ${nv.model.type}',
                                              style: const TextStyle(
                                                  color: Color(0xFF6B87A8),
                                                  fontSize: 11))
                                        ])),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(formatFrequency(nv.model.freq),
                                              style: const TextStyle(
                                                  color: Color(0xFF6B87A8),
                                                  fontSize: 12))
                                        ])
                                  ])));
                        }))))
    ]);
  }
}

class EliteAviationEFB extends StatefulWidget {
  final double? width;
  final double? height;
  final Future Function(double lat, double lon, double heading)?
      onRunwaySelected;
  final Future Function(double lat, double lon, double heading)? onGateSelected;
  final Future Function(String name, double lat, double lon, double heading)?
      onChartGateSelected;
  final Future Function(double speed)? onSpeedSet;
  final Future Function()? onRunwayActionTap;
  final Future Function()? onGateActionTap;
  final Future Function()? onChartActionTap;
  final Future Function()? onMapTeleportTap;
  final Future Function()? onWorldTourTap;
  final Future Function()? onNavaidActionTap;
  final Future Function()? onNavaidTeleportTap;
  final Future Function()? onTakeoffConfigTap;
  final Future Function()? onLandingConfigTap;
  final Future Function()? onPlane15nmTap;
  final Future Function()? onPlane10nmTap;
  final Future Function()? onPlane7nmTap;
  final Future Function()? onPlane4nmTap;
  final Future Function()? onPlaneHoldLeftTap;
  final Future Function()? onPlaneHoldRightTap;
  final Future Function()? onPlaneLeftDownwindTap;
  final Future Function()? onPlaneRightDownwindTap;
  final Future Function()? onPlaneCruiseTap;

  const EliteAviationEFB(
      {Key? key,
      this.width,
      this.height,
      this.onRunwaySelected,
      this.onGateSelected,
      this.onChartGateSelected,
      this.onSpeedSet,
      this.onRunwayActionTap,
      this.onGateActionTap,
      this.onChartActionTap,
      this.onMapTeleportTap,
      this.onWorldTourTap,
      this.onNavaidActionTap,
      this.onNavaidTeleportTap,
      this.onTakeoffConfigTap,
      this.onLandingConfigTap,
      this.onPlane15nmTap,
      this.onPlane10nmTap,
      this.onPlane7nmTap,
      this.onPlane4nmTap,
      this.onPlaneHoldLeftTap,
      this.onPlaneHoldRightTap,
      this.onPlaneLeftDownwindTap,
      this.onPlaneRightDownwindTap,
      this.onPlaneCruiseTap})
      : super(key: key);

  @override
  _EliteAviationEFBState createState() => _EliteAviationEFBState();
}

class _EliteAviationEFBState extends State<EliteAviationEFB> {
  final TextEditingController _icaoController = TextEditingController();
  final TextEditingController _speedController =
      TextEditingController(text: "150");
  int _selectedMode = 0;
  bool _isLoadingRunways = false;
  List<Map<String, dynamic>> _runways = [];
  Map<String, dynamic>? _selectedRunway;
  bool _isLoadingGates = false;
  String _gateErrorMessage = '';
  List<Map<String, dynamic>> _gatesList = [];
  int _selectedGateIndex = -1;
  double? _airportCenterLat, _airportCenterLon;

  @override
  void initState() {
    super.initState();
  }

  void _handleSearch() {
    final icao = _icaoController.text.trim().toUpperCase();
    if (icao.isEmpty) return;
    _fetchRunwayData(icao);
    _fetchGatesData(icao);
  }

  Future<void> _fetchRunwayData(String icao) async {
    setState(() {
      _isLoadingRunways = true;
      _runways = [];
      _selectedRunway = null;
    });
    try {
      final dynamic airportData = await getOfflineAirportData(icao);
      if (airportData != null && airportData['runways'] != null) {
        List<dynamic> rawRunways = airportData['runways'];
        List<Map<String, dynamic>> parsedRunways = [];
        double sumLat = 0.0, sumLon = 0.0;
        for (var r in rawRunways) {
          double rLat = double.tryParse(r['lat'].toString()) ?? 0.0;
          double rLon = double.tryParse(r['lon'].toString()) ?? 0.0;
          sumLat += rLat;
          sumLon += rLon;
          parsedRunways.add({
            'name': r['name'].toString(),
            'surface': r['surface'].toString(),
            'width': r['width'].toString(),
            'length': r['length'].toString(),
            'heading': r['heading'].toString(),
            'lat': rLat,
            'lon': rLon,
            'heading_raw': double.tryParse(r['heading_raw'].toString()) ?? 0.0
          });
        }
        parsedRunways.sort((a, b) => a['name'].compareTo(b['name']));
        setState(() {
          _runways = parsedRunways;
          _isLoadingRunways = false;
          if (parsedRunways.isNotEmpty) {
            _airportCenterLat = sumLat / parsedRunways.length;
            _airportCenterLon = sumLon / parsedRunways.length;
          }
        });
        if (parsedRunways.isNotEmpty)
          _selectRunway(parsedRunways[0], triggerCallback: _selectedMode == 0);
      } else {
        _showError("❌ ICAO Code '$icao' not found.");
        setState(() => _isLoadingRunways = false);
      }
    } catch (e) {
      _showError("❌ Error connecting to data.");
      setState(() => _isLoadingRunways = false);
    }
  }

  Future<void> _fetchGatesData(String icao) async {
    setState(() {
      _isLoadingGates = true;
      _gateErrorMessage = '';
      _gatesList = [];
      _selectedGateIndex = -1;
    });
    try {
      final dynamic airportData = await getOfflineAirportData(icao);
      if (airportData == null ||
          airportData['runways'] == null ||
          (airportData['runways'] as List).isEmpty) {
        if (mounted)
          setState(() {
            _gateErrorMessage = 'AIRPORT COORDS NOT FOUND';
            _isLoadingGates = false;
          });
        return;
      }
      double sumLat = 0.0, sumLon = 0.0;
      List<dynamic> rwys = airportData['runways'];
      for (var rwy in rwys) {
        sumLat += double.tryParse(rwy['lat'].toString()) ?? 0.0;
        sumLon += double.tryParse(rwy['lon'].toString()) ?? 0.0;
      }
      final double centerLat = sumLat / rwys.length,
          centerLon = sumLon / rwys.length;
      final String query =
          '[out:json];(node["aeroway"~"gate|parking_position"](around:6500,$centerLat,$centerLon);way["aeroway"~"taxiway|taxilane"](around:6500,$centerLat,$centerLon););out center geom;';
      final response = await http.get(
          Uri.parse(
              'https://overpass.openstreetmap.fr/api/interpreter?data=${Uri.encodeComponent(query)}'),
          headers: {'User-Agent': 'SimulatorStationApp/1'});
      if (response.statusCode != 200) {
        if (mounted)
          setState(() {
            _gateErrorMessage = 'API ERROR: ${response.statusCode}';
            _isLoadingGates = false;
          });
        return;
      }
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> elements = jsonResponse['elements'] ?? [];
      List<dynamic> gatesRaw = [];
      List<List<Map<String, double>>> taxiwaySegments = [];
      for (var el in elements) {
        if (el['tags'] != null && el['tags']['aeroway'] == 'parking_position')
          gatesRaw.add(el);
        else if (el['geometry'] != null) {
          List<Map<String, double>> currentWay = [];
          for (var pt in el['geometry'])
            currentWay.add({
              'lat': (pt['lat'] as num).toDouble(),
              'lon': (pt['lon'] as num).toDouble()
            });
          if (currentWay.length > 1) taxiwaySegments.add(currentWay);
        }
      }
      List<Map<String, dynamic>> tempGatesList = [];
      int unnamedCounter = 1;
      for (var element in gatesRaw) {
        final tags = element['tags'];
        double lat = 0.0, lon = 0.0;
        if (element['type'] == 'node') {
          lat = (element['lat'] as num).toDouble();
          lon = (element['lon'] as num).toDouble();
        } else if (element.containsKey('center')) {
          lat = (element['center']['lat'] as num).toDouble();
          lon = (element['center']['lon'] as num).toDouble();
        }
        String name = tags['ref'] ?? tags['name'] ?? '';
        if (name.isEmpty) {
          name = 'GATE $unnamedCounter';
          unnamedCounter++;
        }
        double heading = 0.0;
        bool hasRealHeading = false;
        String? headingTag = tags['heading'] ??
            tags['direction'] ??
            tags['orientation'] ??
            tags['angle'] ??
            tags['airplane:heading'];
        if (headingTag != null) {
          try {
            String cleaned = headingTag.replaceAll(RegExp(r'[^0-9\.\-]'), '');
            if (cleaned.isNotEmpty) {
              heading = double.parse(cleaned);
              hasRealHeading = true;
            }
          } catch (_) {}
        }
        if (!hasRealHeading &&
            lat != 0.0 &&
            lon != 0.0 &&
            taxiwaySegments.isNotEmpty) {
          bool connectionFound = false;
          double calculatedHeading = 0.0;
          for (var way in taxiwaySegments) {
            for (int i = 0; i < way.length; i++) {
              if ((way[i]['lat']! - lat).abs() < 0.000001 &&
                  (way[i]['lon']! - lon).abs() < 0.000001) {
                connectionFound = true;
                if (i > 0)
                  calculatedHeading = GeoMath.calculateBearing(
                      way[i - 1]['lat']!, way[i - 1]['lon']!, lat, lon);
                else if (i < way.length - 1)
                  calculatedHeading = GeoMath.calculateBearing(
                      way[1]['lat']!, way[1]['lon']!, lat, lon);
                break;
              }
            }
            if (connectionFound) break;
          }
          if (!connectionFound) {
            double minDistance = double.infinity,
                bestProjLat = 0.0,
                bestProjLon = 0.0;
            for (var way in taxiwaySegments) {
              for (int i = 0; i < way.length - 1; i++) {
                var proj = GeoMath.getClosestPointOnSegment(
                    lat,
                    lon,
                    way[i]['lat']!,
                    way[i]['lon']!,
                    way[i + 1]['lat']!,
                    way[i + 1]['lon']!);
                if (proj['dist']! < minDistance) {
                  minDistance = proj['dist']!;
                  bestProjLat = proj['lat']!;
                  bestProjLon = proj['lon']!;
                }
              }
            }
            if (minDistance <= 250.0)
              calculatedHeading =
                  GeoMath.calculateBearing(bestProjLat, bestProjLon, lat, lon);
          }
          heading = double.parse(calculatedHeading.toStringAsFixed(1));
        }
        if (lat != 0.0 && lon != 0.0)
          tempGatesList.add({
            'name': name.toUpperCase(),
            'lat': lat,
            'lon': lon,
            'heading': heading,
            'type': tags['aeroway'] ?? 'PARKING'
          });
      }
      tempGatesList
          .sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
      if (mounted)
        setState(() {
          _gatesList = tempGatesList;
          if (_gatesList.isEmpty)
            _gateErrorMessage = 'NO GATES FOUND IN DATABASE';
          _isLoadingGates = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _gateErrorMessage = 'DATALINK FAILED';
          _isLoadingGates = false;
        });
    }
  }

  void _selectRunway(Map<String, dynamic> runway,
      {bool triggerCallback = true}) {
    setState(() => _selectedRunway = runway);
    FFAppState().update(() {
      FFAppState().radarRwyName = runway['name'];
      FFAppState().radarLat = runway['lat'];
      FFAppState().radarLon = runway['lon'];
      FFAppState().radarHdgRaw = runway['heading_raw'];
    });
    if (triggerCallback && widget.onRunwaySelected != null)
      widget.onRunwaySelected!(
          runway['lat'], runway['lon'], runway['heading_raw']);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating));
  }

  void _setSpeed() {
    double? speed = double.tryParse(_speedController.text.trim());
    if (speed != null && widget.onSpeedSet != null) widget.onSpeedSet!(speed);
  }

  Widget _buildGlowingSection({required Widget child}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: const Color(0xFF070B14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E324A), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF5A94E3).withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 0))
            ]),
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C1421), Color(0xFF030508)])),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(children: [
        IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildGlowingSection(child: _buildCompactSearchAndSpeed()),
          const SizedBox(width: 14),
          Expanded(
              child: _buildGlowingSection(
                  child: _selectedMode == 0
                      ? _buildCompactRunwayDetails()
                      : _selectedMode == 2
                          ? _buildChartMiddleSection()
                          : _selectedMode == 5
                              ? const Center(
                                  child: Text("NAVAIDS TELEPORT",
                                      style: TextStyle(
                                          color: Color(0xFF4A90E2),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.5)))
                              : _buildEmptyMiddleSection())),
          const SizedBox(width: 14),
          _buildGlowingSection(
              child: Row(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              EFBConfigButton(
                  title: "TAKEOFF CONFIG", onTap: widget.onTakeoffConfigTap),
              const SizedBox(height: 8),
              EFBConfigButton(
                  title: "LANDING CONFIG", onTap: widget.onLandingConfigTap)
            ]),
            const SizedBox(width: 16),
            _buildRightRadioButtons()
          ])),
        ])),
        const SizedBox(height: 20),
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF070B14),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF1E324A), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF5A94E3).withOpacity(0.12),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 0))
                    ]),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(children: [
                      Offstage(
                          offstage: _selectedMode != 0,
                          child: _buildRunwayRadarArea()),
                      Offstage(
                          offstage: _selectedMode != 1,
                          child: _buildGatesArea()),
                      Offstage(
                          offstage: _selectedMode != 2,
                          child: _buildAirportChartArea()),
                      Offstage(
                          offstage: _selectedMode != 5,
                          child: NavaidTeleportWidget(
                              onTeleportTap: widget.onNavaidTeleportTap)),
                      if (_selectedMode == 3 || _selectedMode == 4)
                        const Center(
                            child: Text("SELECT A MODE",
                                style: TextStyle(color: Colors.white24))),
                    ])))),
      ]),
    );
  }

  Widget _buildCompactSearchAndSpeed() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(
                width: 70,
                height: 28,
                child: TextField(
                    controller: _icaoController,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                        hintText: 'ICAO',
                        hintStyle:
                            TextStyle(color: Colors.white30, fontSize: 11),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        filled: true,
                        fillColor: Color(0xFF0A121E),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1E2F45))),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF1E2F45)))))),
            const SizedBox(width: 6),
            SizedBox(
                width: 55,
                height: 28,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16263B),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: (_isLoadingRunways || _isLoadingGates)
                        ? null
                        : _handleSearch,
                    child: (_isLoadingRunways || _isLoadingGates)
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 1.5))
                        : const Icon(Icons.search,
                            size: 16, color: Color(0xFF7AA5D2))))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            SizedBox(
                width: 70,
                height: 28,
                child: TextField(
                    controller: _speedController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                        prefixText: 'SPD ',
                        prefixStyle:
                            TextStyle(color: Colors.white30, fontSize: 10),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        filled: true,
                        fillColor: Color(0xFF0A121E),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1E2F45))),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF1E2F45)))))),
            const SizedBox(width: 6),
            SizedBox(
                width: 55,
                height: 28,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16263B),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: _setSpeed,
                    child: const Text('SET',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7AA5D2),
                            fontWeight: FontWeight.bold))))
          ]),
        ]);
  }

  Widget _buildCompactRunwayDetails() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_runways.isEmpty)
            const Expanded(
                child: Center(
                    child: Text("NO AIRPORT LOADED",
                        style: TextStyle(
                            color: Colors.white24,
                            fontWeight: FontWeight.bold)))),
          if (_runways.isNotEmpty) ...[
            SizedBox(
                height: 32,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _runways.length,
                    itemBuilder: (context, index) {
                      final rw = _runways[index];
                      final isSel = _selectedRunway != null &&
                          _selectedRunway!['name'] == rw['name'];
                      return GestureDetector(
                          onTap: () => _selectRunway(rw),
                          child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF223E63)
                                      : const Color(0xFF0A121E),
                                  border: Border.all(
                                      color: isSel
                                          ? const Color(0xFF7AA5D2)
                                          : const Color(0xFF1E2F45)),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(rw['name'],
                                  style: TextStyle(
                                      color:
                                          isSel ? Colors.white : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))));
                    })),
            const SizedBox(height: 10),
            if (_selectedRunway != null)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1E2F45)),
                      color: const Color(0xFF0A121E),
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: 'SFC: ',
                              style: TextStyle(
                                  color: Color(0xFF537396), fontSize: 10)),
                          TextSpan(
                              text: _selectedRunway!['surface'],
                              style: const TextStyle(
                                  color: Color(0xFFA6C2DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: 'LEN: ',
                              style: TextStyle(
                                  color: Color(0xFF537396), fontSize: 10)),
                          TextSpan(
                              text: '${_selectedRunway!['length']} ft',
                              style: const TextStyle(
                                  color: Color(0xFFA6C2DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: 'WID: ',
                              style: TextStyle(
                                  color: Color(0xFF537396), fontSize: 10)),
                          TextSpan(
                              text: '${_selectedRunway!['width']} ft',
                              style: const TextStyle(
                                  color: Color(0xFFA6C2DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: 'HDG: ',
                              style: TextStyle(
                                  color: Color(0xFF537396), fontSize: 10)),
                          TextSpan(
                              text: '${_selectedRunway!['heading']}°',
                              style: const TextStyle(
                                  color: Color(0xFFA6C2DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))
                        ]))
                      ])),
          ]
        ]);
  }

  Widget _buildEmptyMiddleSection() => const Center(
      child: Text("GATES & STANDS MODE",
          style: TextStyle(
              color: Color(0xFF5A94E3),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5)));
  Widget _buildChartMiddleSection() => const Center(
      child: Text("ADVANCED AIRPORT CHART",
          style: TextStyle(
              color: Color(0xFFF09819),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5)));

  Widget _buildRightRadioButtons() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 0);
                if (widget.onRunwayActionTap != null)
                  widget.onRunwayActionTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 0
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 0
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('RUNWAY',
                        style: TextStyle(
                            color: _selectedMode == 0
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 0
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 1);
                if (widget.onGateActionTap != null) widget.onGateActionTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 1
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 1
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('GATE',
                        style: TextStyle(
                            color: _selectedMode == 1
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 1
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 2);
                if (widget.onChartActionTap != null) widget.onChartActionTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 2
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 2
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('AIRPORT CHART',
                        style: TextStyle(
                            color: _selectedMode == 2
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 2
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 5);
                if (widget.onNavaidActionTap != null)
                  widget.onNavaidActionTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 5
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 5
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('NAVAIDS',
                        style: TextStyle(
                            color: _selectedMode == 5
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 5
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 3);
                if (widget.onMapTeleportTap != null) widget.onMapTeleportTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 3
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 3
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('MAP TELEPORT',
                        style: TextStyle(
                            color: _selectedMode == 3
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 3
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
          GestureDetector(
              onTap: () {
                setState(() => _selectedMode = 4);
                if (widget.onWorldTourTap != null) widget.onWorldTourTap!();
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        _selectedMode == 4
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14,
                        color: _selectedMode == 4
                            ? const Color(0xFF7AA5D2)
                            : const Color(0xFF324866)),
                    const SizedBox(width: 8),
                    Text('WORLD TOUR',
                        style: TextStyle(
                            color: _selectedMode == 4
                                ? const Color(0xFFA6C2DF)
                                : const Color(0xFF537396),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: _selectedMode == 4
                                ? FontWeight.bold
                                : FontWeight.normal))
                  ]))),
        ]);
  }

  Widget _buildRunwayRadarArea() {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
                child: CustomPaint(
                    painter: MasterILSPainter(
                        runwayName: _selectedRunway != null
                            ? _selectedRunway!['name']
                            : 'RWY'))),
            RadarPlane(
                constraints: constraints,
                xPct: 0.12,
                yPct: 0.50,
                text1: '15nm OUT',
                text2: '3,000ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane15nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.26,
                yPct: 0.50,
                text1: '10nm OUT',
                text2: '2,500ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane10nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.39,
                yPct: 0.50,
                text1: '7nm',
                text2: '2,300ft',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane7nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.51,
                yPct: 0.50,
                text1: 'Takeoff',
                text2: 'ON RWY',
                angle: math.pi / 2,
                txtDy: 60,
                onTap: widget.onPlane4nmTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.26,
                yPct: 0.28,
                text1: 'Cruise',
                text2: '10,000ft',
                angle: math.pi / 2,
                txtDy: -40,
                onTap: widget.onPlaneCruiseTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.45,
                yPct: 0.30,
                text1: 'Left base',
                text2: '7000ft',
                angle: math.pi,
                txtDy: -40,
                onTap: widget.onPlaneHoldLeftTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.30,
                text1: 'Left Downwind',
                text2: '1000ft',
                angle: -math.pi / 2,
                txtDy: -40,
                onTap: widget.onPlaneLeftDownwindTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.45,
                yPct: 0.70,
                text1: 'Right base',
                text2: '7000ft',
                angle: 0,
                txtDy: 40,
                onTap: widget.onPlaneHoldRightTap),
            RadarPlane(
                constraints: constraints,
                xPct: 0.84,
                yPct: 0.70,
                text1: 'Right Downwind',
                text2: '1,000ft',
                angle: -math.pi / 2,
                txtDy: 40,
                onTap: widget.onPlaneRightDownwindTap),
          ]);
    });
  }

  Widget _buildGatesArea() {
    if (_isLoadingGates)
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                color: Color(0xFF7AA5D2), strokeWidth: 3)),
        SizedBox(height: 20),
        Text('LOADING GATES...',
            style: TextStyle(
                color: Color(0xFF5A94E3),
                letterSpacing: 3,
                fontWeight: FontWeight.bold))
      ]));
    if (_gateErrorMessage.isNotEmpty)
      return Center(
          child: Text(_gateErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2.0)));
    if (_gatesList.isEmpty)
      return const Center(
          child: Text("NO ICAO LOADED YET",
              style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)));
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 110,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12),
            itemCount: _gatesList.length,
            itemBuilder: (context, index) {
              final gate = _gatesList[index];
              final isSelected = _selectedGateIndex == index;
              return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGateIndex = index);
                    FFAppState().update(() {
                      FFAppState().gateName = gate['name'];
                      FFAppState().gateLat = gate['lat'];
                      FFAppState().gateLon = gate['lon'];
                      FFAppState().gateHdg = gate['heading'];
                    });
                    if (widget.onGateSelected != null)
                      widget.onGateSelected!(
                          gate['lat'], gate['lon'], gate['heading']);
                  },
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF223E63)
                              : const Color(0xFF0A121E),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7AA5D2)
                                  : const Color(0xFF1E2F45),
                              width: isSelected ? 1.5 : 1.0),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                      color: Color(0x335A94E3),
                                      blurRadius: 10,
                                      spreadRadius: 1)
                                ]
                              : []),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF7AA5D2),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color(0xFF7AA5D2),
                                            blurRadius: 4)
                                      ])),
                            Text(gate['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: isSelected ? 16 : 14,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Courier'))
                          ])));
            }));
  }

  Widget _buildAirportChartArea() {
    if (_airportCenterLat == null || _airportCenterLon == null)
      return const Center(
          child: Text("SEARCH ICAO TO LOAD CHART",
              style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)));
    return _AirportChartWidget(
        centerLat: _airportCenterLat!,
        centerLon: _airportCenterLon!,
        onChartGateSelected: (name, lat, lon, heading) {
          FFAppState().update(() {
            FFAppState().chartGateName = name;
            FFAppState().chartGateLat = lat;
            FFAppState().chartGateLon = lon;
            FFAppState().chartGateHdg = heading;
          });
          if (widget.onChartGateSelected != null)
            widget.onChartGateSelected!(name, lat, lon, heading);
        });
  }
}
