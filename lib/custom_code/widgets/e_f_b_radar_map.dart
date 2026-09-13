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

import 'dart:ui' as ui;

import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_tts/flutter_tts.dart';
import '/app_state.dart';
import '/custom_code/actions/get_offline_navaid_data.dart';
import '/custom_code/actions/get_offline_waypoint_data.dart';
import '/custom_code/actions/get_offline_high_airways.dart' as high_airways;
import '/custom_code/actions/get_offline_low_airways.dart' as low_airways;

class EFBRadarMap extends StatefulWidget {
  const EFBRadarMap({
    Key? key,
    this.width,
    this.height,
    this.userNetworkId,
    this.depIcao,
    this.arrIcao,
    this.initialLat,
    this.initialLng,
    this.initialZoom,
    this.onLocationSelected,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? userNetworkId;
  final String? depIcao;
  final String? arrIcao;

  final double? initialLat;
  final double? initialLng;
  final double? initialZoom;

  final Future Function(
    double? selectedLatitude,
    double? selectedLongitude,
    double? altitudeFt,
    double? headingDeg,
    double? speedKnots,
  )? onLocationSelected;

  @override
  _EFBRadarMapState createState() => _EFBRadarMapState();
}

class _EfbMetricScalePainter extends CustomPainter {
  const _EfbMetricScalePainter({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height - 13;
    final left = 4.0;
    final right = size.width - 4.0;
    final usable = right - left;

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      shadows: [Shadow(color: Colors.black, blurRadius: 3)],
    );

    // Match the aviation-style scale appearance: cyan start, white body,
    // crisp ticks, and no opaque card behind it.
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square;

    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.square
      ..color = const Color(0xFF00D9FF);

    final whitePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..color = Colors.white;

    canvas.drawLine(Offset(left, lineY), Offset(right, lineY), whitePaint);
    canvas.drawLine(
        Offset(left, lineY), Offset(left + usable * 0.24, lineY), cyanPaint);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white;
    final cyanTickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFF00D9FF);

    for (int i = 0; i < values.length; i++) {
      final x = left + usable * (i / (values.length - 1));
      final tickHeight = i == 0 ? 18.0 : (i == values.length - 1 ? 18.0 : 13.0);
      canvas.drawLine(
          Offset(x, lineY - tickHeight / 2),
          Offset(x, lineY + tickHeight / 2),
          i == 0 ? cyanTickPaint : tickPaint);

      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      double textX = x - tp.width / 2;
      if (i == 0) textX = x - 1;
      if (i == values.length - 1) textX = x - tp.width + 1;
      tp.paint(canvas, Offset(textX, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _EfbMetricScalePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}

class _EFBRadarMapState extends State<EFBRadarMap> {
  late final WebViewController _webviewController;

  bool showVatsim = true;
  bool showIvao = true;
  bool showAirports = false;
  bool showNavaids = false;
  bool showCallsigns = false;
  bool showRadarMode = false;

  bool showLeftMenu = false;
  bool showRightMenu = false;
  String currentMapStyle = 'DARK';
  String activeWeatherLayer = 'NONE';

  Map<String, dynamic>? selectedItem;
  Timer? _refreshTimer;
  Timer? _clockTimer;
  String zuluTime = "";

  List<dynamic> rawVatsimPlanes = [];
  List<dynamic> rawIvaoPlanes = [];
  List<dynamic> rawAirports = [];
  List<Map<String, dynamic>> rawNavaids = [];

  final TextEditingController _searchController = TextEditingController();
  bool showSearchDropdown = false;
  List<Map<String, dynamic>> searchResults = [];

  bool teleportMode = false;
  bool showTeleportControls = false;
  double? manualLat;
  double? manualLng;
  final TextEditingController _speedCtrl = TextEditingController(text: "450");
  final TextEditingController _altCtrl = TextEditingController(text: "36000");
  final TextEditingController _hdgCtrl = TextEditingController(text: "90");
  bool showFlightPath = false;

  // NAV AIDS
  bool showWaypoints = false;
  String activeAirwayMode = 'NONE'; // NONE / HIGH / LOW
  List<Map<String, dynamic>> rawWaypoints = [];
  List<Map<String, dynamic>> rawAirwaySegments = [];

  // SEGMENTS / SIGMET overlay
  bool showSegments = false;
  List<Map<String, dynamic>> rawSegments = [];
  Timer? _segmentRefreshTimer;

  bool _isMapReady = false;
  double _mapZoom = 1.8;
  double _mapCenterLat = 0.0;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    _loadNavaidsLocally();
    _loadWaypointsAndAirwaysLocally();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAirportsForSearch();
      _fetchPlanesForSearch();
    });
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 30), (_) => _fetchPlanesForSearch());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSegments();
    });
    _segmentRefreshTimer =
        Timer.periodic(const Duration(seconds: 60), (_) => _fetchSegments());

    String mapUrl =
        "https://osamanabel1999.github.io/EFB-Map/?lat=${widget.initialLat ?? 20.0}&lon=${widget.initialLng ?? 20.0}&zoom=${widget.initialZoom ?? 1.8}";

    _webviewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _webviewController.runJavaScript(r'''
              // Robust EFB map bridge: never lose data if Mapbox loads before/after Flutter.
              window.__efbMapReady = false;
              window.__efbPendingPayload = null;
              window.__efbIconsReady = false;
              window.__efbIconsPromise = null;

               function postZoomLevel() {
                 try {
                   if (typeof map !== 'undefined' && map) {
                     var z = map.getZoom();
                     var centerLat = 0;
                     try { centerLat = map.getCenter().lat; } catch (e) {}
                     if (window.EFBMapChannel) {
                       window.EFBMapChannel.postMessage(JSON.stringify({ action: 'ZOOM_CHANGED', zoom: z, centerLat: centerLat }));
                     }
                   }
                 } catch (e) {}
               }

               function postMapReady() {
                if (window.__efbMapReady) return;
                window.__efbMapReady = true;
                if (typeof map !== 'undefined' && map) {
                  try { map.on('zoomend', postZoomLevel); } catch (e) {}
                }
                postZoomLevel();
                if (window.EFBMapChannel) {
                  window.EFBMapChannel.postMessage(JSON.stringify({ action: 'MAP_READY' }));
                }
                if (window.__efbPendingPayload) {
                  var pending = window.__efbPendingPayload;
                  window.__efbPendingPayload = null;
                  window.renderEFBData(pending);
                }
              }

              function makeSvgImage(svg) {
                return new Promise(function(resolve, reject) {
                  var img = new Image();
                  img.onload = function() { resolve(img); };
                  img.onerror = reject;
                  img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
                });
              }

              async function ensureEfbIcons() {
                if (window.__efbIconsReady) return;
                if (window.__efbIconsPromise) return window.__efbIconsPromise;

                window.__efbIconsPromise = (async function() {
                var planePath = 'M21,16V14L13,9V3.5A1.5,1.5 0 0,0 11.5,2A1.5,1.5 0 0,0 10,3.5V9L2,14V16L10,13.5V19L8,20.5V22L11.5,21L15,22V20.5L13,19V13.5L21,16Z';
                var planeSvg = function(color) {
                  return '<svg width="32" height="32" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="' + planePath + '" fill="' + color + '" stroke="#000000" stroke-width="0.5"/></svg>';
                };
                var airportSvg = '<svg width="16" height="16" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="8" fill="#00FFFF" stroke="#000000" stroke-width="2"/></svg>';
                var navaidSvg = '<svg width="16" height="16" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><polygon points="12,2 22,7 22,17 12,22 2,17 2,7" fill="#D946EF" stroke="#000000" stroke-width="2"/></svg>';
                var waypointSvg = '<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><polygon points=\"12,2 22,21 2,21\" fill=\"#FFD166\" stroke=\"#111827\" stroke-width=\"1.5\"/></svg>';

                var items = [
                  ['plane-vatsim', planeSvg('#FFB300')],
                  ['plane-ivao', planeSvg('#00E676')],
                  ['plane-user', planeSvg('#E040FB')],
                  ['airport-icon', airportSvg],
                  ['navaid-icon', navaidSvg],
                  ['waypoint-icon', waypointSvg]
                ];

                for (var i = 0; i < items.length; i++) {
                  var id = items[i][0];
                  if (!map.hasImage(id)) {
                    var image = await makeSvgImage(items[i][1]);
                    if (!map.hasImage(id)) map.addImage(id, image);
                  }
                }
                window.__efbIconsReady = true;
                })();
                try {
                  await window.__efbIconsPromise;
                } catch (e) {
                  window.__efbIconsPromise = null;
                  throw e;
                }
              }

              // Flutter overlay zoom buttons call these functions directly.
              // Mapbox GL JS exposes zoomIn/zoomOut on the Map camera API.
              window.efbZoomIn = function() {
                try {
                  if (typeof map !== 'undefined' && map && map.isStyleLoaded()) {
                    map.zoomIn({ duration: 200 });
                  }
                } catch (e) {}
              };

              window.efbZoomOut = function() {
                try {
                  if (typeof map !== 'undefined' && map && map.isStyleLoaded()) {
                    map.zoomOut({ duration: 200 });
                  }
                } catch (e) {}
              };

              window.renderEFBData = async function(payload) {
                  if (typeof map === 'undefined' || !map.isStyleLoaded()) {
                    window.__efbPendingPayload = payload;
                    return;
                  }

                  try {
                    await ensureEfbIcons();
                  } catch (e) {
                    window.__efbPendingPayload = payload;
                    return;
                  }

                  // تحديث طيارات شبكات الطيران
                  updateLayer('efb-planes-source', 'efb-planes-layer', payload.planes || [], payload.planesVisible, {
                      'icon-image': ['get', 'icon'],
                      'icon-size': 0.8,
                      'icon-rotate': ['get', 'hdg'],
                      'icon-rotation-alignment': 'map',
                      'icon-allow-overlap': true,
                      'text-field': ['get', 'label'],
                      'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
                      'text-size': 11,
                      'text-offset': [0, 1.5],
                      'text-anchor': 'top',
                      'text-allow-overlap': true
                  }, {
                      'text-color': ['get', 'textColor'],
                      'text-halo-color': '#000000',
                      'text-halo-width': 2
                  });
                  updateLayer('efb-airports-source', 'efb-airports-layer', payload.airports || [], payload.airportsVisible, {
                      'icon-image': 'airport-icon',
                      'icon-size': 0.7,
                      'text-field': ['get', 'icao'],
                      'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
                      'text-size': 10,
                      'text-offset': [0, 1.2],
                      'text-anchor': 'top',
                      'icon-allow-overlap': true,
                      'text-allow-overlap': true
                  }, {
                      'text-color': '#00FFFF',
                      'text-halo-color': '#000000',
                      'text-halo-width': 2
                  });
                  updateLayer('efb-navaids-source', 'efb-navaids-layer', payload.navaids || [], payload.navaidsVisible, {
                      'icon-image': 'navaid-icon',
                      'icon-size': 0.8,
                      'text-field': ['get', 'name'],
                      'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
                      'text-size': 10,
                      'text-offset': [0, 1.2],
                      'text-anchor': 'top',
                      'icon-allow-overlap': true,
                      'text-allow-overlap': true
                  }, {
                      'text-color': '#D946EF',
                      'text-halo-color': '#000000',
                      'text-halo-width': 2
                  });
                  updateLayer('efb-waypoints-source', 'efb-waypoints-layer', payload.waypoints || [], payload.waypointsVisible, {
                      'icon-image': 'waypoint-icon',
                      'icon-size': 0.75,
                      'text-field': ['get', 'name'],
                      'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
                      'text-size': 9,
                      'text-offset': [0, 1.35],
                      'text-anchor': 'top',
                      'icon-allow-overlap': true,
                      'text-allow-overlap': true
                  }, {
                      'text-color': '#FFD166',
                      'text-halo-color': '#111827',
                      'text-halo-width': 2
                  });

                  updateLineLayer('efb-airways-source', 'efb-airways-layer',
                      payload.airways || [], payload.airwaysVisible, '#FFD166');

                  updateSegmentLayers(payload.segments || [], payload.segmentsVisible);
              };

              function updateLayer(sourceId, layerId, dataArr, isVisible, layout, paint) {
                  if (!map.getSource(sourceId)) {
                      map.addSource(sourceId, { type: 'geojson', data: { type: 'FeatureCollection', features: [] } });
                      map.addLayer({ id: layerId, type: 'symbol', source: sourceId, layout: layout, paint: paint });
                      map.on('click', layerId, function(e) {
                          if (window.EFBMapChannel && e.features && e.features.length) {
                              var actionType = sourceId.includes('planes')
                                ? 'PLANE_CLICKED'
                                : (sourceId.includes('airports')
                                  ? 'AIRPORT_CLICKED'
                                  : (sourceId.includes('waypoints')
                                    ? 'WAYPOINT_CLICKED'
                                    : 'NAVAID_CLICKED'));
                              window.EFBMapChannel.postMessage(JSON.stringify({ action: actionType, data: e.features[0].properties }));
                          }
                      });
                      map.on('mouseenter', layerId, function() { map.getCanvas().style.cursor = 'pointer'; });
                      map.on('mouseleave', layerId, function() { map.getCanvas().style.cursor = ''; });
                  }

                  Object.keys(layout || {}).forEach(function(key) {
                    try { map.setLayoutProperty(layerId, key, layout[key]); } catch (e) {}
                  });
                  Object.keys(paint || {}).forEach(function(key) {
                    try { map.setPaintProperty(layerId, key, paint[key]); } catch (e) {}
                  });

                  if (isVisible) {
                      var features = dataArr.map(function(item) {
                          return { type: 'Feature', geometry: { type: 'Point', coordinates: [Number(item.lon), Number(item.lat)] }, properties: item };
                      }).filter(function(f) { return isFinite(f.geometry.coordinates[0]) && isFinite(f.geometry.coordinates[1]); });
                      map.getSource(sourceId).setData({ type: 'FeatureCollection', features: features });
                      map.setLayoutProperty(layerId, 'visibility', 'visible');
                  } else {
                      map.setLayoutProperty(layerId, 'visibility', 'none');
                  }
              }

              function updateLineLayer(sourceId, layerId, dataArr, isVisible, color) {
                  if (!map.getSource(sourceId)) {
                      map.addSource(sourceId, {
                          type: 'geojson',
                          data: { type: 'FeatureCollection', features: [] }
                      });
                      map.addLayer({
                          id: layerId,
                          type: 'line',
                          source: sourceId,
                          layout: { 'line-join': 'round', 'line-cap': 'round' },
                          paint: {
                              'line-color': color,
                              'line-width': 2.2,
                              'line-opacity': 0.9
                          }
                      });
                  } else {
                      try { map.setPaintProperty(layerId, 'line-color', color); } catch (e) {}
                      try { map.setPaintProperty(layerId, 'line-width', 2.2); } catch (e) {}
                      try { map.setPaintProperty(layerId, 'line-opacity', 0.9); } catch (e) {}
                  }
                  if (isVisible) {
                      map.getSource(sourceId).setData({
                          type: 'FeatureCollection',
                          features: dataArr || []
                      });
                      map.setLayoutProperty(layerId, 'visibility', 'visible');
                  } else {
                      map.getSource(sourceId).setData({
                          type: 'FeatureCollection',
                          features: []
                      });
                      map.setLayoutProperty(layerId, 'visibility', 'none');
                  }
              }

              function updateSegmentLayers(dataArr, isVisible) {
                var fillSourceId = 'efb-segments-fill-source';
                var lineSourceId = 'efb-segments-line-source';
                var labelSourceId = 'efb-segments-label-source';
                var fillLayerId = 'efb-segments-fill-layer';
                var lineLayerId = 'efb-segments-line-layer';
                var labelLayerId = 'efb-segments-label-layer';

                function emptyCollection() {
                  return { type: 'FeatureCollection', features: [] };
                }

                if (!map.getSource(fillSourceId)) {
                  map.addSource(fillSourceId, { type: 'geojson', data: emptyCollection() });
                }
                if (!map.getSource(lineSourceId)) {
                  map.addSource(lineSourceId, { type: 'geojson', data: emptyCollection() });
                }
                if (!map.getSource(labelSourceId)) {
                  map.addSource(labelSourceId, { type: 'geojson', data: emptyCollection() });
                }

                if (!map.getLayer(fillLayerId)) {
                  map.addLayer({
                    id: fillLayerId,
                    type: 'fill',
                    source: fillSourceId,
                    paint: {
                      'fill-color': '#E65A4F',
                      'fill-opacity': 0.22
                    }
                  });
                } else {
                  try { map.setPaintProperty(fillLayerId, 'fill-color', '#E65A4F'); } catch (e) {}
                  try { map.setPaintProperty(fillLayerId, 'fill-opacity', 0.22); } catch (e) {}
                }

                if (!map.getLayer(lineLayerId)) {
                  map.addLayer({
                    id: lineLayerId,
                    type: 'line',
                    source: lineSourceId,
                    layout: {
                      'line-join': 'round',
                      'line-cap': 'round'
                    },
                    paint: {
                      'line-color': '#FF6B5E',
                      'line-width': 2,
                      'line-opacity': 0.72,
                      'line-dasharray': [5, 4]
                    }
                  });
                } else {
                  try { map.setPaintProperty(lineLayerId, 'line-color', '#FF6B5E'); } catch (e) {}
                  try { map.setPaintProperty(lineLayerId, 'line-width', 2); } catch (e) {}
                  try { map.setPaintProperty(lineLayerId, 'line-opacity', 0.72); } catch (e) {}
                  try { map.setPaintProperty(lineLayerId, 'line-dasharray', [5, 4]); } catch (e) {}
                }

                if (!map.getLayer(labelLayerId)) {
                  map.addLayer({
                    id: labelLayerId,
                    type: 'symbol',
                    source: labelSourceId,
                    layout: {
                      'symbol-placement': 'point',
                      'text-field': ['get', 'segmentLabel'],
                      'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
                      'text-size': 15,
                      'text-allow-overlap': true,
                      'text-ignore-placement': true
                    },
                    paint: {
                      'text-color': '#FF6B5E',
                      'text-halo-color': '#2A1111',
                      'text-halo-width': 2.2
                    }
                  });
                } else {
                  try { map.setLayoutProperty(labelLayerId, 'text-field', ['get', 'segmentLabel']); } catch (e) {}
                  try { map.setPaintProperty(labelLayerId, 'text-color', '#FF6B5E'); } catch (e) {}
                  try { map.setPaintProperty(labelLayerId, 'text-halo-color', '#2A1111'); } catch (e) {}
                  try { map.setPaintProperty(labelLayerId, 'text-halo-width', 2.2); } catch (e) {}
                }

                if (!map.__efbSegmentClickBound) {
                  map.__efbSegmentClickBound = true;
                  map.on('click', fillLayerId, function(e) {
                    if (window.EFBMapChannel && e.features && e.features.length) {
                      window.EFBMapChannel.postMessage(JSON.stringify({
                        action: 'SEGMENT_CLICKED',
                        data: e.features[0].properties
                      }));
                    }
                  });
                  map.on('mouseenter', fillLayerId, function() {
                    map.getCanvas().style.cursor = 'pointer';
                  });
                  map.on('mouseleave', fillLayerId, function() {
                    map.getCanvas().style.cursor = '';
                  });
                }

                var features = Array.isArray(dataArr) ? dataArr : [];
                var fc = { type: 'FeatureCollection', features: features };
                map.getSource(fillSourceId).setData(fc);
                map.getSource(lineSourceId).setData(fc);

                var labelFeatures = features.filter(function(feature) {
                  return feature &&
                    feature.geometry &&
                    (feature.geometry.type === 'Polygon' ||
                     feature.geometry.type === 'MultiPolygon');
                });
                map.getSource(labelSourceId).setData({
                  type: 'FeatureCollection',
                  features: labelFeatures
                });

                var visibility = isVisible ? 'visible' : 'none';
                try { map.setLayoutProperty(fillLayerId, 'visibility', visibility); } catch (e) {}
                try { map.setLayoutProperty(lineLayerId, 'visibility', visibility); } catch (e) {}
                try { map.setLayoutProperty(labelLayerId, 'visibility', visibility); } catch (e) {}
              }

              window.teleportMarker = null;
              window.triggerTeleport = function(lat, lon, hdg) {
                  if (typeof map === 'undefined' || typeof mapboxgl === 'undefined') return;
                  if (!window.teleportMarker) {
                      var el = document.createElement('div');
                      el.style.width = '36px';
                      el.style.height = '36px';
                      el.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24"><path d="M21,16V14L13,9V3.5A1.5,1.5 0 0,0 11.5,2A1.5,1.5 0 0,0 10,3.5V9L2,14V16L10,13.5V19L8,20.5V22L11.5,21L15,22V20.5L13,19V13.5L21,16Z" fill="#FF3B30" stroke="white" stroke-width="1"/></svg>';
                      window.teleportMarker = new mapboxgl.Marker({element: el, rotationAlignment: 'map'}).setLngLat([lon, lat]).addTo(map);
                  } else {
                      window.teleportMarker.setLngLat([lon, lat]);
                  }
                  window.teleportMarker.setRotation(hdg);
              };

              window.drawFlightPath = function(coords) {
                  if (typeof map === 'undefined' || !map.isStyleLoaded()) return;
                  var flightPathColor = '#00E5FF';

                  if (!map.getSource('flight-path-source')) {
                      map.addSource('flight-path-source', {
                          type: 'geojson',
                          data: {
                              type: 'Feature',
                              geometry: { type: 'LineString', coordinates: coords || [] }
                          }
                      });
                  } else {
                      map.getSource('flight-path-source').setData({
                          type: 'Feature',
                          geometry: { type: 'LineString', coordinates: coords || [] }
                      });
                  }

                  if (!map.getLayer('flight-path-layer')) {
                      map.addLayer({
                          id: 'flight-path-layer',
                          type: 'line',
                          source: 'flight-path-source',
                          layout: { 'line-join': 'round', 'line-cap': 'round' },
                          paint: {
                              'line-color': flightPathColor,
                              'line-width': 4,
                              'line-opacity': 0.95
                          }
                      });
                  } else {
                      try { map.setPaintProperty('flight-path-layer', 'line-color', flightPathColor); } catch (e) {}
                      try { map.setPaintProperty('flight-path-layer', 'line-width', 4); } catch (e) {}
                      try { map.setPaintProperty('flight-path-layer', 'line-opacity', 0.95); } catch (e) {}
                  }
                  try { map.setLayoutProperty('flight-path-layer', 'visibility', 'visible'); } catch (e) {}
              };
              window.clearFlightPath = function() {
                  if (typeof map !== 'undefined' && map.getSource('flight-path-source')) {
                      map.getSource('flight-path-source').setData({
                          type: 'Feature',
                          geometry: { type: 'LineString', coordinates: [] }
                      });
                      try { map.setLayoutProperty('flight-path-layer', 'visibility', 'none'); } catch (e) {}
                  }
              };

              // Mapbox may finish style loading before onPageFinished, so check immediately and also listen.
              function checkEfbMapReady() {
                try {
                  if (typeof map !== 'undefined' && map && map.isStyleLoaded()) {
                    postMapReady();
                    return true;
                  }
                } catch (e) {}
                return false;
              }

              if (!checkEfbMapReady() && typeof map !== 'undefined') {
                map.once('style.load', postMapReady);
              }

              var efbReadyPoll = setInterval(function() {
                if (checkEfbMapReady()) clearInterval(efbReadyPoll);
              }, 250);
              setTimeout(function() { clearInterval(efbReadyPoll); }, 20000);
            ''');
          },
        ),
      )
      ..addJavaScriptChannel(
        'EFBMapChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final parsed = jsonDecode(message.message);
          final action = parsed['action'];

          if (action == 'MAP_READY') {
            setState(() {
              _isMapReady = true;
              final z = parsed['zoom'];
              if (z is num) _mapZoom = z.toDouble();
              final centerLat = parsed['centerLat'];
              if (centerLat is num) _mapCenterLat = centerLat.toDouble();
            });

            _pushDataToMap(); // رسم الداتا فوراً عند جاهزية الخريطة
            if (showFlightPath) _drawFlightPathIfEnabled();
          } else if (action == 'ZOOM_CHANGED') {
            final z = parsed['zoom'];

            if (z is num && mounted) {
              setState(() => _mapZoom = z.toDouble());
            }
          } else {
            final data = parsed['data'];
            if (action == 'PLANE_CLICKED') {
              setState(() => selectedItem = {
                    'type': 'PLANE',
                    'data': jsonDecode(data['raw']),
                    'net': data['net'],
                    'isVatsim': data['isVatsim']
                  });
            } else if (action == 'AIRPORT_CLICKED') {
              setState(() => selectedItem = {
                    'type': 'AIRPORT',
                    'data': jsonDecode(data['raw'])
                  });
            } else if (action == 'NAVAID_CLICKED') {
              setState(() => selectedItem = {
                    'type': 'NAVAID',
                    'data': jsonDecode(data['raw'])
                  });
            } else if (action == 'WAYPOINT_CLICKED') {
              setState(() => selectedItem = {
                    'type': 'WAYPOINT',
                    'data': jsonDecode(data['raw'])
                  });
            } else if (action == 'SEGMENT_CLICKED') {
              setState(() => selectedItem = {'type': 'SEGMENT', 'data': data});
            } else if (action == 'TELEPORT_CLICKED') {
              setState(() {
                manualLat = data['lat'];
                manualLng = data['lon'];
              });
              _webviewController.runJavaScript(
                  "window.triggerTeleport(${data['lat']}, ${data['lon']}, ${_hdgCtrl.text});");
            } else if (action == 'MAP_CLICKED') {
              setState(() {
                selectedItem = null;
                showSearchDropdown = false;
              });
              FocusScope.of(context).unfocus();
            }
          }
        },
      )
      ..loadRequest(Uri.parse(mapUrl));
  }

  // 🔴 دالة معالجة وإرسال البيانات للرسم
  void _pushDataToMap() {
    if (!_isMapReady) return;

    List<Map<String, dynamic>> planeFeatures = [];

    void processPlanes(List<dynamic> planes, bool isVatsim) {
      for (var p in planes) {
        double lat = isVatsim
            ? (p['latitude'] ?? 0.0).toDouble()
            : (p['lastTrack']?['latitude'] ?? 0.0).toDouble();
        double lon = isVatsim
            ? (p['longitude'] ?? 0.0).toDouble()
            : (p['lastTrack']?['longitude'] ?? 0.0).toDouble();
        double hdg = isVatsim
            ? (p['heading'] ?? 0.0).toDouble()
            : (p['lastTrack']?['heading'] ?? 0.0).toDouble();
        String callsign = p['callsign'] ?? "N/A";
        int alt = isVatsim
            ? (p['altitude'] ?? 0).toInt()
            : (p['lastTrack']?['altitude'] ?? 0).toInt();
        int gs = isVatsim
            ? (p['groundspeed'] ?? 0).toInt()
            : (p['lastTrack']?['groundSpeed'] ?? 0).toInt();
        int vs = isVatsim
            ? (p['vertical_speed'] ?? 0).toInt()
            : (p['lastTrack']?['verticalSpeed'] ?? 0).toInt();
        String pilotId = isVatsim
            ? p['cid']?.toString() ?? ""
            : p['userId']?.toString() ?? "";

        bool isUser = widget.userNetworkId != null &&
            widget.userNetworkId!.isNotEmpty &&
            pilotId == widget.userNetworkId;

        String iconType =
            isUser ? "plane-user" : (isVatsim ? "plane-vatsim" : "plane-ivao");

        // 🔴 تحديد لون النص ليتطابق مع الأيقونة
        String textColor =
            isUser ? "#E040FB" : (isVatsim ? "#FFB300" : "#00E676");

        String label = "";
        if (showRadarMode) {
          label =
              "$callsign\nALT: $alt | HDG: ${hdg.toInt()}°\nGS: $gs | VS: $vs";
        } else if (showCallsigns) {
          label = callsign;
        }

        planeFeatures.add({
          "lat": lat,
          "lon": lon,
          "hdg": hdg,
          "icon": iconType,
          "label": label,
          "textColor": textColor,
          "net": isVatsim ? "VATSIM" : "IVAO",
          "isVatsim": isVatsim,
          "raw": jsonEncode(p)
        });
      }
    }

    if (showVatsim) processPlanes(rawVatsimPlanes, true);
    if (showIvao) processPlanes(rawIvaoPlanes, false);

    List<Map<String, dynamic>> airportFeatures = [];
    if (showAirports) {
      for (var a in rawAirports) {
        airportFeatures.add({
          "lat": double.tryParse(a['lat'].toString()) ?? 0.0,
          "lon": double.tryParse(a['lon'].toString()) ?? 0.0,
          "icao": a['icao'] ?? "",
          "raw": jsonEncode(a)
        });
      }
    }

    List<Map<String, dynamic>> navaidFeatures = [];
    if (showNavaids) {
      for (var n in rawNavaids) {
        final nLat =
            double.tryParse((n['lat'] ?? n['latitude'] ?? 0.0).toString()) ??
                0.0;
        final nLon = double.tryParse(
                (n['lon'] ?? n['lng'] ?? n['longitude'] ?? 0.0).toString()) ??
            0.0;
        final nIdent =
            (n['ident'] ?? n['id'] ?? n['identifier'] ?? n['code'] ?? '')
                .toString();
        final nName = (n['name'] ?? nIdent).toString();
        navaidFeatures.add({
          "lat": nLat,
          "lon": nLon,
          "name": nIdent.isNotEmpty ? nIdent : nName,
          "raw": jsonEncode(n)
        });
      }
    }

    List<Map<String, dynamic>> waypointFeatures = [];
    if (showWaypoints) {
      for (var w in rawWaypoints) {
        final wLat = double.tryParse((w['lat'] ?? 0.0).toString()) ?? 0.0;
        final wLon = double.tryParse((w['lon'] ?? 0.0).toString()) ?? 0.0;
        final wName = (w['name'] ?? '').toString().trim();
        if (wLat.isFinite && wLon.isFinite && wName.isNotEmpty) {
          waypointFeatures.add({
            "lat": wLat,
            "lon": wLon,
            "name": wName,
            "raw": jsonEncode(w),
          });
        }
      }
    }

    List<Map<String, dynamic>> airwayFeatures = [];
    if (activeAirwayMode != 'NONE') {
      airwayFeatures = rawAirwaySegments
          .where((segment) =>
              (segment['mode'] ?? '').toString() == activeAirwayMode)
          .map((segment) => {
                "type": "Feature",
                "geometry": {
                  "type": "LineString",
                  "coordinates": segment["coordinates"]
                },
                "properties": {
                  "name": segment["name"] ?? "",
                  "from": segment["from"] ?? "",
                  "to": segment["to"] ?? "",
                  "base": segment["base"] ?? 0,
                  "top": segment["top"] ?? 0
                }
              })
          .toList();

      airwayFeatures = airwayFeatures.where((feature) {
        final coords = feature["geometry"]?["coordinates"];
        return coords is List && coords.length >= 2;
      }).toList();
    }

    List<Map<String, dynamic>> segmentFeatures = [];
    if (showSegments) {
      segmentFeatures = rawSegments
          .map((segment) {
            final geometry = segment['geometry'];
            if (geometry is! Map) return null;

            final geometryType = geometry['type']?.toString() ?? '';
            if (geometryType != 'Polygon' && geometryType != 'MultiPolygon') {
              return null;
            }

            return <String, dynamic>{
              "type": "Feature",
              "geometry": geometry,
              "properties": {
                "region": segment["region"] ?? "",
                "fir": segment["fir"] ?? "",
                "hazard": segment["hazard"] ?? "SIGMET",
                "qualifier": segment["qualifier"] ?? "",
                "activeTime": segment["activeTime"] ?? "",
                "levelAltitude": segment["levelAltitude"] ?? "",
                "movementDirection": segment["movementDirection"] ?? "",
                "movementSpeed": segment["movementSpeed"] ?? "",
                "statusChange": segment["statusChange"] ?? "",
                "rawText": segment["rawText"] ?? "",
                "segmentLabel": segment["segmentLabel"] ?? "SIGMET",
              }
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    String jsonPayload = jsonEncode({
      "planesVisible": (showVatsim || showIvao),
      "airportsVisible": showAirports,
      "navaidsVisible": showNavaids,
      "waypointsVisible": showWaypoints,
      "airwaysVisible": activeAirwayMode != 'NONE',
      "segmentsVisible": showSegments,
      "planes": planeFeatures,
      "airports": airportFeatures,
      "navaids": navaidFeatures,
      "waypoints": waypointFeatures,
      "airways": airwayFeatures,
      "segments": segmentFeatures,
    });

    _webviewController.runJavaScript('''
      window.lastPayload = $jsonPayload;
      if (window.renderEFBData) window.renderEFBData(window.lastPayload);
    ''');
  }

  void _drawFlightPathIfEnabled() {
    if (showFlightPath && widget.depIcao != null && widget.arrIcao != null) {
      var dep = rawAirports.firstWhere((a) => a['icao'] == widget.depIcao,
          orElse: () => null);
      var arr = rawAirports.firstWhere((a) => a['icao'] == widget.arrIcao,
          orElse: () => null);
      if (dep != null && arr != null) {
        double lat1 = double.parse(dep['lat'].toString());
        double lon1 = double.parse(dep['lon'].toString());
        double lat2 = double.parse(arr['lat'].toString());
        double lon2 = double.parse(arr['lon'].toString());
        List<List<double>> pathCoords = _getCurvedPath(lat1, lon1, lat2, lon2);
        String coordsJson = jsonEncode(pathCoords);
        _webviewController.runJavaScript('''
             window.lastFlightPath = $coordsJson;
             if(window.drawFlightPath) window.drawFlightPath(window.lastFlightPath);
          ''');
      }
    } else {
      _webviewController.runJavaScript('''
             window.lastFlightPath = null;
             if(window.clearFlightPath) window.clearFlightPath();
        ''');
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _refreshTimer?.cancel();
    _segmentRefreshTimer?.cancel();
    _searchController.dispose();
    _speedCtrl.dispose();
    _altCtrl.dispose();
    _hdgCtrl.dispose();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now().toUtc();
    if (mounted) {
      setState(() {
        zuluTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ZULU";
      });
    }
  }

  void _loadWaypointsAndAirwaysLocally() {
    try {
      final List<Map<String, dynamic>> waypointTemp = [];
      final Map<String, Map<String, dynamic>> waypointLookup =
          <String, Map<String, dynamic>>{};

      // Waypoints remain sourced from the existing Waypoint custom action.
      for (String key in WaypointData.keys) {
        final list = WaypointData.getWaypointData(key);
        if (list == null) continue;

        for (final waypoint in list) {
          final mapped = waypoint.toMap();
          final name = (mapped['name'] ?? key).toString().trim().toUpperCase();
          final lat = double.tryParse((mapped['lat'] ?? 0.0).toString()) ?? 0.0;
          final lon = double.tryParse((mapped['lon'] ?? 0.0).toString()) ?? 0.0;

          if (!lat.isFinite || !lon.isFinite || name.isEmpty) continue;

          final item = <String, dynamic>{
            'name': name,
            'lat': lat,
            'lon': lon,
          };

          waypointTemp.add(item);
          waypointLookup[name] ??= item;
        }
      }

      final List<Map<String, dynamic>> airwayTemp = [];

      // HIGH AIRWAYS are now read only from the dedicated HighAirways action.
      for (String airwayName in high_airways.HighAirwayData.keys) {
        final segments = high_airways.HighAirwayData.getAirway(airwayName);
        if (segments == null || segments.isEmpty) continue;

        final ordered = List.of(segments)
          ..sort((a, b) => a.seq.compareTo(b.seq));

        for (int i = 0; i < ordered.length - 1; i++) {
          final from = ordered[i].ident.trim().toUpperCase();
          final to = ordered[i + 1].ident.trim().toUpperCase();
          final fromPoint = waypointLookup[from];
          final toPoint = waypointLookup[to];

          if (fromPoint == null || toPoint == null) continue;

          airwayTemp.add({
            'name': airwayName.trim().toUpperCase(),
            'from': from,
            'to': to,
            'dir': ordered[i].dir,
            'level': ordered[i].level,
            'base': ordered[i].base,
            'top': ordered[i].top,
            'mode': 'HIGH',
            'coordinates': [
              [fromPoint['lon'], fromPoint['lat']],
              [toPoint['lon'], toPoint['lat']],
            ],
          });
        }
      }

      // LOW AIRWAYS are now read only from the dedicated LowAirways action.
      for (String airwayName in low_airways.LowAirwayData.keys) {
        final segments = low_airways.LowAirwayData.getAirway(airwayName);
        if (segments == null || segments.isEmpty) continue;

        final ordered = List.of(segments)
          ..sort((a, b) => a.seq.compareTo(b.seq));

        for (int i = 0; i < ordered.length - 1; i++) {
          final from = ordered[i].ident.trim().toUpperCase();
          final to = ordered[i + 1].ident.trim().toUpperCase();
          final fromPoint = waypointLookup[from];
          final toPoint = waypointLookup[to];

          if (fromPoint == null || toPoint == null) continue;

          airwayTemp.add({
            'name': airwayName.trim().toUpperCase(),
            'from': from,
            'to': to,
            'dir': ordered[i].dir,
            'level': ordered[i].level,
            'base': ordered[i].base,
            'top': ordered[i].top,
            'mode': 'LOW',
            'coordinates': [
              [fromPoint['lon'], fromPoint['lat']],
              [toPoint['lon'], toPoint['lat']],
            ],
          });
        }
      }

      if (!mounted) return;

      setState(() {
        rawWaypoints = waypointTemp;
        rawAirwaySegments = airwayTemp;
      });

      if (_isMapReady) {
        _pushDataToMap();
      }
    } catch (e) {
      print("Error parsing Waypoints/Airways: $e");
    }
  }

  void _loadNavaidsLocally() {
    List<Map<String, dynamic>> temp = [];
    try {
      for (String k in NavaidData.keys) {
        var list = NavaidData.getNavaidData(k);
        if (list != null) {
          for (var n in list) {
            final Map<String, dynamic> mapped = n.toMap();

            mapped['ident'] = k.toUpperCase();

            temp.add(mapped);
          }
        }
      }
      rawNavaids = temp;
      if (_searchController.text.trim().isNotEmpty) {
        _onSearchChanged(_searchController.text);
      }
    } catch (e) {
      print("Error parsing Navaids: $e");
    }
  }

  List<List<double>> _getCurvedPath(
      double lat1, double lon1, double lat2, double lon2) {
    List<List<double>> points = [];
    for (int i = 0; i <= 30; i++) {
      double t = i / 30.0;
      double lat = lat1 + (lat2 - lat1) * t;
      double lon = lon1 + (lon2 - lon1) * t;

      double bulge = (lon2 - lon1).abs() * 0.15;
      if (bulge > 12) bulge = 12;
      lat += math.sin(t * math.pi) * bulge;

      points.add([lon, lat]);
    }
    return points;
  }

  dynamic _segmentFirstValue(Map<String, dynamic> map, List<String> keys,
      [dynamic fallback]) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        final value = map[key];
        if (value is String && value.trim().isEmpty) continue;
        return value;
      }
    }
    return fallback;
  }

  String _segmentText(dynamic value, [String fallback = "—"]) {
    if (value == null) return fallback;
    if (value is String) {
      final v = value.trim();
      return v.isEmpty ? fallback : v;
    }
    return value.toString();
  }

  String _segmentLevelText(Map<String, dynamic> props) {
    final direct = _segmentFirstValue(props, [
      'flightLevels',
      'flight_levels',
      'level',
      'levelsText',
      'levelAltitude'
    ]);
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }

    final low = _segmentFirstValue(props,
        ['altitudeLow', 'altitude_low', 'base', 'baseAltitude', 'bottom']);
    final high = _segmentFirstValue(
        props, ['altitudeHi', 'altitude_hi', 'top', 'topAltitude', 'upper']);

    final lowText = low == null ? "" : low.toString();
    final highText = high == null ? "" : high.toString();

    if (lowText.isNotEmpty && highText.isNotEmpty) {
      return "$lowText / $highText";
    }
    if (highText.isNotEmpty) return "TOP $highText";
    if (lowText.isNotEmpty) return "FROM $lowText";
    return "—";
  }

  String _segmentActiveTimeText(Map<String, dynamic> props) {
    final direct = _segmentFirstValue(props,
        ['activeTime', 'active_time', 'validTime', 'valid_time', 'valid']);
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }

    final from = _segmentFirstValue(
        props, ['validTimeFrom', 'valid_time_from', 'startTime', 'start_time']);
    final to = _segmentFirstValue(
        props, ['validTimeTo', 'valid_time_to', 'endTime', 'end_time']);

    if (from != null && to != null) {
      return "${from.toString()} → ${to.toString()}";
    }
    if (from != null) return from.toString();
    if (to != null) return to.toString();
    return "—";
  }

  String _segmentMovementText(Map<String, dynamic> props) {
    final direct = _segmentFirstValue(props, ['movement', 'movementText']);
    if (direct != null && direct.toString().trim().isNotEmpty) {
      if (direct is Map) {
        final movementMap = Map<String, dynamic>.from(direct);
        final dir = _segmentFirstValue(movementMap, ['direction', 'dir']);
        final speed =
            _segmentFirstValue(movementMap, ['speed_kt', 'speed', 'speedKt']);
        if (dir != null && speed != null) {
          return "${dir.toString()} ${speed.toString()} KT";
        }
        if (dir != null) return dir.toString();
        if (speed != null) return "${speed.toString()} KT";
      } else {
        return direct.toString();
      }
    }

    final dir = _segmentFirstValue(props,
        ['movementDir', 'movement_dir', 'movementDirection', 'direction']);
    final speed = _segmentFirstValue(
        props, ['movementSpd', 'movement_spd', 'movementSpeed', 'speed']);

    if (dir != null && speed != null) {
      return "${dir.toString()} ${speed.toString()}";
    }
    if (dir != null) return dir.toString();
    if (speed != null) return speed.toString();
    return "—";
  }

  String _segmentMovementDirectionText(Map<String, dynamic> props) {
    final direct = _segmentFirstValue(props, ['movement', 'movementText']);
    if (direct is Map) {
      final movementMap = Map<String, dynamic>.from(direct);
      final dir = _segmentFirstValue(movementMap, ['direction', 'dir']);
      if (dir != null) return dir.toString();
    }

    final dir = _segmentFirstValue(props,
        ['movementDir', 'movement_dir', 'movementDirection', 'direction']);
    return _segmentText(dir);
  }

  String _segmentMovementSpeedText(Map<String, dynamic> props) {
    final direct = _segmentFirstValue(props, ['movement', 'movementText']);
    if (direct is Map) {
      final movementMap = Map<String, dynamic>.from(direct);
      final speed =
          _segmentFirstValue(movementMap, ['speed_kt', 'speed', 'speedKt']);
      if (speed != null) return "${speed.toString()} KT";
    }

    final speed = _segmentFirstValue(
        props, ['movementSpd', 'movement_spd', 'movementSpeed', 'speed']);
    return _segmentText(speed);
  }

  List<Map<String, dynamic>> _normaliseSegmentGeoJson(dynamic decoded) {
    final List<Map<String, dynamic>> result = [];

    dynamic sourceFeatures;
    if (decoded is Map && decoded['type'] == 'FeatureCollection') {
      sourceFeatures = decoded['features'];
    } else if (decoded is List) {
      sourceFeatures = decoded;
    } else if (decoded is Map && decoded['features'] is List) {
      sourceFeatures = decoded['features'];
    } else {
      sourceFeatures = const [];
    }

    if (sourceFeatures is! List) return result;

    for (final item in sourceFeatures) {
      if (item is! Map) continue;

      final feature = Map<String, dynamic>.from(item);
      final rawGeometry = feature['geometry'];
      if (rawGeometry is! Map) continue;

      final geometry = Map<String, dynamic>.from(rawGeometry);
      final geometryType = geometry['type']?.toString() ?? '';
      if (geometryType != 'Polygon' && geometryType != 'MultiPolygon') {
        continue;
      }

      final rawProperties = feature['properties'];
      final props = rawProperties is Map
          ? Map<String, dynamic>.from(rawProperties)
          : <String, dynamic>{};

      final region = _segmentText(
          _segmentFirstValue(
              props, ['region', 'regionId', 'region_id', 'icaoId', 'icao_id']),
          "");
      final fir = _segmentText(
          _segmentFirstValue(
              props, ['fir', 'firId', 'fir_id', 'icaoId', 'icao_id']),
          "");
      final hazard = _segmentText(
          _segmentFirstValue(props, ['hazard', 'hazardCode', 'hazard_code']),
          "SIGMET");
      final qualifier = _segmentText(
          _segmentFirstValue(
              props, ['qualifier', 'qualifierType', 'qualifier_type']),
          "");
      final activeTime = _segmentActiveTimeText(props);
      final levelAltitude = _segmentLevelText(props);
      final movement = _segmentMovementText(props);
      final movementDirection = _segmentMovementDirectionText(props);
      final movementSpeed = _segmentMovementSpeedText(props);
      final statusChange = _segmentText(_segmentFirstValue(props, [
        'statusChange',
        'status_change',
        'intensityChange',
        'intensity_change',
        'trend',
        'evolution'
      ]));
      final rawText = _segmentText(_segmentFirstValue(
          props, ['rawSigmet', 'raw_sigmet', 'rawText', 'raw_text', 'raw']));

      final label = hazard.isEmpty || hazard == "—" ? "SIGMET" : hazard;

      result.add({
        'geometry': geometry,
        'region': region.isEmpty ? fir : region,
        'fir': fir.isEmpty ? region : fir,
        'hazard': hazard,
        'qualifier': qualifier,
        'activeTime': activeTime,
        'levelAltitude': levelAltitude,
        'movementDirection':
            movementDirection == "—" ? movement : movementDirection,
        'movementSpeed': movementSpeed,
        'statusChange': statusChange,
        'rawText': rawText,
        'segmentLabel': label.isEmpty ? 'SIGMET' : label,
      });
    }

    return result;
  }

  Future<void> _fetchSegments() async {
    try {
      // International SIGMETs are worldwide; domestic SIGMETs cover the US.
      const endpoints = [
        'https://aviationweather.gov/api/data/isigmet?format=geojson',
        'https://aviationweather.gov/api/data/airsigmet?format=geojson',
      ];

      final List<Map<String, dynamic>> combined = [];

      for (final endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: const {
              'Accept': 'application/geo+json, application/json',
            },
          ).timeout(const Duration(seconds: 15));

          if (response.statusCode == 204) continue;
          if (response.statusCode != 200 || response.body.trim().isEmpty) {
            continue;
          }

          final decoded = jsonDecode(response.body);
          combined.addAll(_normaliseSegmentGeoJson(decoded));
        } catch (_) {
          // Keep the other source alive if one endpoint is temporarily unavailable.
        }
      }

      if (!mounted) return;

      final seen = <String>{};
      final unique = <Map<String, dynamic>>[];
      for (final segment in combined) {
        final key = [
          segment['fir'],
          segment['hazard'],
          segment['qualifier'],
          segment['activeTime'],
          segment['rawText']
        ].join('|');

        if (seen.add(key)) {
          unique.add(segment);
        }
      }

      setState(() {
        rawSegments = unique;
      });

      _pushDataToMap();
    } catch (_) {
      // Never break the map if the live weather feed is unavailable.
    }
  }

  Future<void> _fetchAirportsForSearch() async {
    try {
      final response = await http.get(Uri.parse(
          'https://gist.githubusercontent.com/tdreyno/4278655/raw/airports.json'));
      if (response.statusCode == 200) {
        rawAirports = json.decode(response.body);
        _pushDataToMap();
      }
    } catch (e) {}
  }

  Future<void> _fetchPlanesForSearch() async {
    bool updated = false;
    if (showVatsim) {
      try {
        final res = await http
            .get(Uri.parse('https://data.vatsim.net/v3/vatsim-data.json'));
        if (res.statusCode == 200) {
          rawVatsimPlanes = json.decode(res.body)['pilots'] as List;
          updated = true;
        }
      } catch (e) {}
    }
    if (showIvao) {
      try {
        final res = await http
            .get(Uri.parse('https://api.ivao.aero/v2/tracker/whazzup'));
        if (res.statusCode == 200) {
          rawIvaoPlanes = json.decode(res.body)['clients']['pilots'] as List;
          updated = true;
        }
      } catch (e) {}
    }
    if (updated) _pushDataToMap();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchDropdown = false;
      });
      return;
    }

    String q = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    for (var ap in rawAirports) {
      String icao = (ap['icao'] ?? "").toString().toLowerCase();
      String iata = (ap['iata'] ?? "").toString().toLowerCase();
      String name = (ap['name'] ?? "").toString().toLowerCase();
      if (icao.contains(q) || iata.contains(q) || name.contains(q)) {
        results.add({
          'type': 'AIRPORT',
          'title': '${ap['icao']} - ${ap['name']}',
          'data': ap
        });
      }
    }

    for (var p in rawVatsimPlanes) {
      String callsign = (p['callsign'] ?? "").toString().toLowerCase();
      if (callsign.contains(q)) {
        results.add({
          'type': 'PLANE',
          'title': '${p['callsign']} (VATSIM)',
          'data': p,
          'net': 'VATSIM',
          'isVatsim': true
        });
      }
    }

    for (var p in rawIvaoPlanes) {
      String callsign = (p['callsign'] ?? "").toString().toLowerCase();
      if (callsign.contains(q)) {
        results.add({
          'type': 'PLANE',
          'title': '${p['callsign']} (IVAO)',
          'data': p,
          'net': 'IVAO',
          'isVatsim': false
        });
      }
    }

    for (var n in rawNavaids) {
      final navaidSearchText = [
        n['id'],
        n['ident'],
        n['identifier'],
        n['code'],
        n['name'],
        n['type'],
        n['frequency'],
        n['freq'],
      ]
          .where((v) => v != null)
          .map((v) => v.toString().toLowerCase())
          .join(' ');
      if (navaidSearchText.contains(q)) {
        final ident =
            (n['ident'] ?? n['id'] ?? n['identifier'] ?? n['code'] ?? '')
                .toString();
        final name = (n['name'] ?? ident).toString();
        final type = (n['type'] ?? 'NAVAID').toString();
        results.add({
          'type': 'NAVAID',
          'title':
              ident.isNotEmpty ? '$ident - $name ($type)' : '$name ($type)',
          'data': n
        });
      }
    }

    setState(() {
      searchResults = results.take(6).toList();
      showSearchDropdown = results.isNotEmpty;
    });
  }

  void _onSearchResultSelected(Map<String, dynamic> result) {
    setState(() {
      showSearchDropdown = false;
      _searchController.clear();
      FocusScope.of(context).unfocus();

      selectedItem = {
        'type': result['type'],
        'data': result['data'],
        if (result['type'] == 'PLANE') 'net': result['net'],
        if (result['type'] == 'PLANE') 'isVatsim': result['isVatsim']
      };
    });

    double lat = 0.0;
    double lon = 0.0;

    if (result['type'] == 'AIRPORT' || result['type'] == 'NAVAID') {
      final d = result['data'];
      lat =
          double.tryParse((d['lat'] ?? d['latitude'] ?? 0.0).toString()) ?? 0.0;
      lon = double.tryParse(
              (d['lon'] ?? d['lng'] ?? d['longitude'] ?? 0.0).toString()) ??
          0.0;
    } else if (result['type'] == 'PLANE') {
      bool isVatsim = result['isVatsim'];
      lat = isVatsim
          ? (result['data']['latitude'] ?? 0.0).toDouble()
          : (result['data']['lastTrack']?['latitude'] ?? 0.0).toDouble();
      lon = isVatsim
          ? (result['data']['longitude'] ?? 0.0).toDouble()
          : (result['data']['lastTrack']?['longitude'] ?? 0.0).toDouble();
    }
    _webviewController.runJavaScript("window.flyToCoords($lat, $lon, 11.0);");
  }

  void _sendMapState(String key, dynamic value) {
    String valStr = value is String ? "'$value'" : value.toString();
    _webviewController.runJavaScript(
        "if(window.setMapState) window.setMapState('$key', $valStr);");
  }

  void _triggerTeleportAction() {
    if (manualLat != null && manualLng != null) {
      double alt = double.tryParse(_altCtrl.text) ?? 36000.0;
      double hdg = double.tryParse(_hdgCtrl.text) ?? 90.0;
      double spd = double.tryParse(_speedCtrl.text) ?? 450.0;

      FFAppState().msfsTeleportLat = manualLat!;
      FFAppState().msfsTeleportLng = manualLng!;
      FFAppState().msfsTeleportAlt = alt;
      FFAppState().msfsTeleportHdg = hdg;
      FFAppState().msfsTeleportSpd = spd;

      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(
          manualLat!,
          manualLng!,
          alt,
          hdg,
          spd,
        );
      }
    }
  }

  void _zoomIn() {
    _webviewController
        .runJavaScript("if(window.efbZoomIn) window.efbZoomIn();");
  }

  void _zoomOut() {
    _webviewController
        .runJavaScript("if(window.efbZoomOut) window.efbZoomOut();");
  }

  String _formatScaleMetric(double meters) {
    if (!meters.isFinite || meters <= 0) return '0 m';
    if (meters >= 1000) {
      final km = meters / 1000.0;
      if (km >= 10) return '${km.round()} km';
      if ((km - km.round()).abs() < 0.05) return '${km.round()} km';
      return '${km.toStringAsFixed(1)} km';
    }
    if (meters >= 100) return '${meters.round()} m';
    if (meters >= 10) return '${(meters / 10).round() * 10} m';
    return '${meters.round()} m';
  }

  double _niceScaleDistanceMeters() {
    // Mapbox GL JS uses a 512px world tile. At the current zoom and latitude,
    // this gives the real-world distance represented by one screen pixel.
    const earthCircumferenceMeters = 40075016.686;
    final latitudeRad = (_mapCenterLat.clamp(-85.0, 85.0)) * math.pi / 180.0;
    final metersPerPixel = earthCircumferenceMeters *
        math.cos(latitudeRad) /
        (512.0 * math.pow(2.0, _mapZoom));

    const targetPixels = 190.0;
    final rawMeters = metersPerPixel * targetPixels;
    if (!rawMeters.isFinite || rawMeters <= 0) return 1000.0;

    final exponent = math.pow(10.0, (math.log(rawMeters) / math.ln10).floor());
    final normalized = rawMeters / exponent;
    final niceNormalized =
        normalized >= 5 ? 5.0 : (normalized >= 2 ? 2.0 : 1.0);
    return niceNormalized * exponent;
  }

  Widget _buildMapScaleBar() {
    final double totalMeters = _niceScaleDistanceMeters();
    final List<double> values = [
      0,
      totalMeters / 3,
      totalMeters * 2 / 3,
      totalMeters
    ];

    return SizedBox(
      width: 220,
      height: 58,
      child: CustomPaint(
        painter: _EfbMetricScalePainter(
          values: values,
          labels: values.map(_formatScaleMetric).toList(),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      width: 42,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.84),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.6), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, spreadRadius: 1)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              onTap: _zoomIn,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.add, color: Colors.cyanAccent, size: 22),
              ),
            ),
          ),
          Container(height: 1, color: Colors.white12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              onTap: _zoomOut,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.remove, color: Colors.cyanAccent, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox(
            width: widget.width ?? MediaQuery.of(context).size.width,
            height: widget.height ?? MediaQuery.of(context).size.height,
            child: WebViewWidget(controller: _webviewController),
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.6), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4)
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search ICAO, Callsign, Navaid...",
                      hintStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.cyanAccent, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white70, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  showSearchDropdown = false;
                                  searchResults.clear();
                                });
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (showSearchDropdown)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final res = searchResults[index];
                        IconData icn = res['type'] == 'AIRPORT'
                            ? Icons.location_city
                            : (res['type'] == 'NAVAID'
                                ? Icons.cell_tower
                                : Icons.flight);
                        Color icnColor = res['type'] == 'AIRPORT'
                            ? Colors.cyanAccent
                            : (res['type'] == 'NAVAID'
                                ? Colors.purpleAccent
                                : (res['isVatsim'] == true
                                    ? Colors.amber
                                    : Colors.greenAccent));
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          leading: Icon(icn, color: icnColor, size: 20),
                          title: Text(res['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          onTap: () => _onSearchResultSelected(res),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            bottom: 92,
            right: 15,
            child: _buildZoomControls(),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: IgnorePointer(
              child: _buildMapScaleBar(),
            ),
          ),
          Positioned(
            bottom: 25,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.6),
                    width: 1.5),
              ),
              child: Text(
                zuluTime,
                style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    shadows: [Shadow(blurRadius: 5, color: Color(0xFF00E5FF))]),
              ),
            ),
          ),
          if (teleportMode)
            Positioned(
              bottom: 6,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4), width: 1),
                ),
                child: const Text(
                  "* Teleport feature currently works with MSFS only",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 65,
            left: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLeftMenu)
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(color: Colors.white24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _menuBtn("VATSIM", showVatsim, () {
                        setState(() => showVatsim = !showVatsim);
                        _pushDataToMap();
                      }),
                      _menuBtn("IVAO", showIvao, () {
                        setState(() => showIvao = !showIvao);
                        _pushDataToMap();
                      }),
                      _menuBtn("AIRPORT", showAirports, () {
                        setState(() => showAirports = !showAirports);
                        _pushDataToMap();
                      }),
                      _navaidMenuBtn("NAVAIDS", showNavaids, () {
                        setState(() => showNavaids = !showNavaids);
                        _pushDataToMap();
                      }),
                      _navAidOverlayBtn("WAYPOINTS", showWaypoints, () {
                        setState(() {
                          showWaypoints = !showWaypoints;
                        });
                        _pushDataToMap();
                      }),
                      _navAidOverlayBtn(
                          "HIGH AIRWAY", activeAirwayMode == 'HIGH', () {
                        setState(() {
                          activeAirwayMode =
                              activeAirwayMode == 'HIGH' ? 'NONE' : 'HIGH';
                        });
                        _pushDataToMap();
                      }),
                      _navAidOverlayBtn("LOW AIRWAY", activeAirwayMode == 'LOW',
                          () {
                        setState(() {
                          activeAirwayMode =
                              activeAirwayMode == 'LOW' ? 'NONE' : 'LOW';
                        });
                        _pushDataToMap();
                      }),
                      _menuBtn("CALLSIGN", showCallsigns, () {
                        setState(() {
                          showCallsigns = !showCallsigns;
                          if (showCallsigns) showRadarMode = false;
                        });
                        _pushDataToMap();
                      }),
                      _menuBtn("RADAR", showRadarMode, () {
                        setState(() {
                          showRadarMode = !showRadarMode;
                          if (showRadarMode) showCallsigns = false;
                        });
                        _pushDataToMap();
                      }),
                      _menuBtn("TELEPORT", teleportMode, () {
                        setState(() {
                          teleportMode = !teleportMode;
                          if (teleportMode) showTeleportControls = true;
                        });
                        _sendMapState('teleportMode', teleportMode);
                      }),
                      _menuBtn("FLIGHT PATH", showFlightPath, () {
                        setState(() => showFlightPath = !showFlightPath);
                        _drawFlightPathIfEnabled();
                      }),
                    ]),
                  ),
                GestureDetector(
                  onTap: () => setState(() => showLeftMenu = !showLeftMenu),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24)),
                    child: Icon(showLeftMenu ? Icons.chevron_left : Icons.menu,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 65,
            right: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => showRightMenu = !showRightMenu),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24)),
                    child: Icon(
                        showRightMenu ? Icons.chevron_right : Icons.layers,
                        color: Colors.white,
                        size: 20),
                  ),
                ),
                if (showRightMenu)
                  Container(
                    width: 110,
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(color: Colors.white24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _menuBtn("DARK", currentMapStyle == 'DARK', () {
                        setState(() => currentMapStyle = 'DARK');
                        _sendMapState('mapStyle', 'DARK');
                      }),
                      _menuBtn("SATELLITE", currentMapStyle == 'SATELLITE', () {
                        setState(() => currentMapStyle = 'SATELLITE');
                        _sendMapState('mapStyle', 'SATELLITE');
                      }),
                      const Divider(color: Colors.white24, height: 1),
                      _weatherMenuBtn("RAIN", activeWeatherLayer == 'RAIN', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'RAIN' ? 'NONE' : 'RAIN');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                      _weatherMenuBtn("TEMP", activeWeatherLayer == 'TEMP', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'TEMP' ? 'NONE' : 'TEMP');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                      _weatherMenuBtn("WIND", activeWeatherLayer == 'WIND', () {
                        setState(() => activeWeatherLayer =
                            activeWeatherLayer == 'WIND' ? 'NONE' : 'WIND');
                        _sendMapState('weather', activeWeatherLayer);
                      }),
                      const Divider(color: Colors.white24, height: 1),
                      _segmentMenuBtn("SEGMENT", showSegments, () {
                        setState(() => showSegments = !showSegments);
                        _pushDataToMap();
                      }),
                    ]),
                  ),
              ],
            ),
          ),
          if (teleportMode && showTeleportControls)
            Positioned(
              bottom: 80,
              left: 15,
              child: _buildTeleportControls(),
            ),
          if (teleportMode && !showTeleportControls)
            Positioned(
              bottom: 25,
              left: 15,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                onPressed: () => setState(() => showTeleportControls = true),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          if (selectedItem != null && selectedItem!['type'] == 'PLANE')
            _buildInfoBox(selectedItem!['data'], selectedItem!['net'],
                selectedItem!['isVatsim'], isLandscape),
          if (selectedItem != null && selectedItem!['type'] == 'AIRPORT')
            _buildAirportInfoBox(selectedItem!['data'], isLandscape),
          if (selectedItem != null && selectedItem!['type'] == 'NAVAID')
            _buildNavaidInfoBox(selectedItem!['data'], isLandscape),
          if (selectedItem != null && selectedItem!['type'] == 'SEGMENT')
            _buildSegmentInfoBox(selectedItem!['data'], isLandscape),
        ],
      ),
    );
  }

  Widget _buildTeleportControls() {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.orangeAccent.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TELEPORT SETTINGS",
                  style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => setState(() => showTeleportControls = false),
                child: const Icon(Icons.close, color: Colors.white70, size: 16),
              )
            ],
          ),
          const Divider(color: Colors.white24),
          _buildInputRow("ALT", _altCtrl),
          _buildInputRow("SPD", _speedCtrl),
          _buildInputRow("HDG", _hdgCtrl),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              minimumSize: const Size.fromHeight(28),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              if (manualLat != null && manualLng != null) {
                _triggerTeleportAction();
              }
            },
            child: const Text("SEND TELEPORT",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 35,
              child: Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10))),
          Expanded(
            child: SizedBox(
              height: 24,
              child: TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  setState(() {});
                  if (manualLat != null && manualLng != null) {
                    _webviewController.runJavaScript(
                        "if(window.triggerTeleport) window.triggerTeleport($manualLat, $manualLng, ${_hdgCtrl.text});");
                  }
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentInfoBox(dynamic segment, bool isLandscape) {
    final Map<String, dynamic> data = segment is Map
        ? Map<String, dynamic>.from(segment)
        : <String, dynamic>{};

    final String region = _segmentText(data['region']);
    final String fir = _segmentText(data['fir']);
    final String hazard = _segmentText(data['hazard'], "SIGMET");
    final String qualifier = _segmentText(data['qualifier']);
    final String activeTime = _segmentText(data['activeTime']);
    final String levelAltitude = _segmentText(data['levelAltitude']);
    final String movementDirection = _segmentText(data['movementDirection']);
    final String movementSpeed = _segmentText(data['movementSpeed']);
    final String statusChange = _segmentText(data['statusChange']);
    final String rawText = _segmentText(data['rawText']);

    final double? boxWidth =
        isLandscape ? MediaQuery.of(context).size.width * 0.52 : null;

    Widget row(String title, String value, {bool mono = false}) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFF6B5E),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: mono ? 'monospace' : null,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Positioned(
      bottom: 15,
      right: 15,
      left: isLandscape ? null : 15,
      child: SizedBox(
        width: boxWidth,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF160D0D).withOpacity(0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF6B5E).withOpacity(0.58),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B5E).withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B5E).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF6B5E).withOpacity(0.45),
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B5E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hazard,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fir.isNotEmpty && fir != "—"
                                ? "SIGMET • $fir"
                                : "SIGMET ADVISORY",
                            style: const TextStyle(
                              color: Color(0xFFFF8D83),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (qualifier != "—" && qualifier.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B5E).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFF6B5E).withOpacity(0.7),
                          ),
                        ),
                        child: Text(
                          qualifier,
                          style: const TextStyle(
                            color: Color(0xFFFF8D83),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    const SizedBox(width: 3),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white54, size: 20),
                      onPressed: () => setState(() => selectedItem = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                row(
                  "REGION / FIR",
                  region == "—" && fir == "—"
                      ? "—"
                      : (region == "—"
                          ? fir
                          : (fir == "—" || region == fir
                              ? region
                              : "$region / $fir")),
                ),
                row("HAZARD", hazard),
                row("QUALIFIER", qualifier),
                row("ACTIVE TIME", activeTime),
                row("LEVEL / ALTITUDE", levelAltitude),
                row("MOVEMENT DIRECTION", movementDirection),
                row("MOVEMENT SPEED", movementSpeed),
                row("STATUS CHANGE", statusChange),
                const SizedBox(height: 2),
                const Text(
                  "RAW TEXT",
                  style: TextStyle(
                    color: Color(0xFFFF6B5E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.32),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SelectableText(
                    rawText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      height: 1.35,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavaidInfoBox(dynamic nav, bool isLandscape) {
    String name = nav['name']?.toString() ?? "Unknown";
    String type = nav['type']?.toString() ?? "NAV";
    String lat = nav['lat']?.toString() ?? "-";
    String lon = nav['lon']?.toString() ?? "-";
    String elev = nav['elev']?.toString() ?? "-";
    String country = nav['country']?.toString() ?? "-";
    String airport = nav['airport']?.toString() ?? "-";
    String power = nav['power']?.toString() ?? "-";

    String rawFreq = nav['freq']?.toString() ?? "0";
    double fVal = double.tryParse(rawFreq) ?? 0.0;
    if (fVal > 1000) fVal = fVal / 1000.0;
    String freq = fVal.toStringAsFixed(3);

    double? boxWidth =
        isLandscape ? MediaQuery.of(context).size.width * 0.45 : null;

    return Positioned(
      bottom: 15,
      right: 15,
      left: isLandscape ? null : 15,
      child: SizedBox(
        width: boxWidth,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.purpleAccent.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cell_tower,
                      color: Colors.purpleAccent, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Text("Navaid Station",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: Text(type,
                        style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white54, size: 20),
                      onPressed: () => setState(() => selectedItem = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                ],
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white10, height: 1)),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                children: [
                  _stat("FREQ", freq),
                  _stat("ELEV", "$elev ft"),
                  _stat("POWER", power),
                  _stat("LAT", lat),
                  _stat("LON", lon),
                  _stat("COUNTRY", country),
                ],
              ),
              if (airport.isNotEmpty &&
                  airport != "null" &&
                  airport != "-") ...[
                const SizedBox(height: 12),
                const Text("ASSOCIATED AIRPORT:",
                    style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10)),
                  child: Text(airport,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirportInfoBox(dynamic ap, bool isLandscape) {
    double? boxWidth =
        isLandscape ? MediaQuery.of(context).size.width * 0.45 : null;

    return Positioned(
      bottom: 15,
      right: 15,
      left: isLandscape ? null : 15,
      child: SizedBox(
        width: boxWidth,
        child: AdvancedAirportInfoBox(
          ap: ap,
          onClose: () => setState(() => selectedItem = null),
        ),
      ),
    );
  }

  Widget _buildInfoBox(dynamic p, String net, bool isVatsim, bool isLandscape) {
    String call = p['callsign'] ?? "N/A";
    String dep = isVatsim
        ? (p['flight_plan']?['departure'] ?? "N/A")
        : (p['flightPlan']?['departureId'] ?? "N/A");
    String arr = isVatsim
        ? (p['flight_plan']?['arrival'] ?? "N/A")
        : (p['flightPlan']?['arrivalId'] ?? "N/A");
    String acft = isVatsim
        ? (p['flight_plan']?['aircraft_short'] ?? "ACFT")
        : (p['flightPlan']?['aircraft']['icaoCode'] ?? "ACFT");
    int alt = isVatsim
        ? (p['altitude'] ?? 0).toInt()
        : (p['lastTrack']?['altitude'] ?? 0).toInt();
    int gs = isVatsim
        ? (p['groundspeed'] ?? 0).toInt()
        : (p['lastTrack']?['groundSpeed'] ?? 0).toInt();
    int vs = isVatsim
        ? (p['vertical_speed'] ?? 0).toInt()
        : (p['lastTrack']?['verticalSpeed'] ?? 0).toInt();
    int hdg = isVatsim
        ? (p['heading'] ?? 0).toInt()
        : (p['lastTrack']?['heading'] ?? 0).toInt();
    String squawk = isVatsim
        ? "${p['transponder'] ?? '7000'}"
        : "${p['lastTrack']?['squawk'] ?? '7000'}";
    String pilot =
        isVatsim ? (p['name'] ?? "Unknown Pilot") : "Pilot ID: ${p['userId']}";
    String route = isVatsim
        ? (p['flight_plan']?['route'] ?? "N/A")
        : (p['flightPlan']?['route'] ?? "N/A");

    String cleanCall = call.trim().toUpperCase();
    String icao3 = "GEN";
    final match = RegExp(r'^[A-Z]{3}').firstMatch(cleanCall);
    if (match != null) {
      icao3 = match.group(0)!;
    } else if (cleanCall.length >= 3) {
      icao3 = cleanCall.substring(0, 3);
    }
    String logoUrl =
        "https://www.flightaware.com/images/airline_logos/90p/$icao3.png";

    String startTime =
        isVatsim ? (p['logon_time'] ?? "") : (p['createdAt'] ?? "");
    int onlineMinutes = 0;
    if (startTime.isNotEmpty) {
      try {
        DateTime start = DateTime.parse(startTime);
        Duration diff = DateTime.now().toUtc().difference(start);
        onlineMinutes = diff.inMinutes;
      } catch (e) {}
    }
    String timeOnline = "${onlineMinutes ~/ 60}h ${onlineMinutes % 60}m";

    int totalPlannedMins = 0;
    if (isVatsim) {
      String enroute = p['flight_plan']?['enroute_time'] ?? "0000";
      if (enroute.length == 4) {
        int h = int.tryParse(enroute.substring(0, 2)) ?? 0;
        int m = int.tryParse(enroute.substring(2, 4)) ?? 0;
        totalPlannedMins = h * 60 + m;
      }
    } else {
      int eet = int.tryParse(p['flightPlan']?['eet']?.toString() ?? '0') ?? 0;
      totalPlannedMins = eet > 1000 ? eet ~/ 60 : eet;
    }

    double progress = 0.5;
    String remaining = "N/A";
    if (totalPlannedMins > 0 && onlineMinutes > 0) {
      progress = onlineMinutes / totalPlannedMins;
      if (progress > 1.0) progress = 1.0;
      int remMins = totalPlannedMins - onlineMinutes;
      if (remMins < 0) remMins = 0;
      remaining = "${remMins ~/ 60}h ${remMins % 60}m";
    }

    double alignX = (progress * 2) - 1.0;
    int distFlown = (gs * (onlineMinutes / 60.0)).round();

    double? boxWidth =
        isLandscape ? MediaQuery.of(context).size.width * 0.45 : null;

    return Positioned(
      bottom: 15,
      right: 15,
      left: isLandscape ? null : 15,
      child: SizedBox(
        width: boxWidth,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(logoUrl,
                            width: 45,
                            height: 45,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(Icons.flight,
                                color: Colors.black54, size: 40)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(call,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(pilot,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text("Total Hrs: N/A (API) | Online: $timeOnline",
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isVatsim
                            ? Colors.amber.withOpacity(0.15)
                            : Colors.greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                isVatsim ? Colors.amber : Colors.greenAccent),
                      ),
                      child: Text(net,
                          style: TextStyle(
                              color:
                                  isVatsim ? Colors.amber : Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white54, size: 20),
                        onPressed: () => setState(() => selectedItem = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dep,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    const Icon(Icons.flight_takeoff,
                        color: Colors.white38, size: 16),
                    const Icon(Icons.flight_land,
                        color: Colors.white38, size: 16),
                    Text(arr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        height: 2,
                        width: double.infinity,
                        color: Colors.white24),
                    Align(
                      alignment: Alignment(alignX, 0),
                      child: Transform.rotate(
                          angle: 3.14159 / 2,
                          child: const Icon(Icons.airplanemode_active,
                              color: Colors.blueAccent, size: 24)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dist: $distFlown nm",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                    Text("ETA: $remaining",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10, height: 1)),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  children: [
                    _stat("GS", "$gs kts"),
                    _stat("ALT", "$alt ft"),
                    _stat("VS", "$vs fpm"),
                    _stat("HDG", "$hdg°"),
                    _stat("SQUAWK", squawk),
                    _stat("TYPE", acft),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("FLIGHT PLAN / ROUTE:",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10)),
                  child: Text(route,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String l, String v) => Column(children: [
        Text(l, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Text(v,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
      ]);

  Widget _segmentMenuBtn(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFE65A4F).withOpacity(0.18)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? const Color(0xFFFF6B5E) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: active ? const Color(0xFFFF6B5E) : Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active ? const Color(0xFFFF6B5E) : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn(String label, bool active, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: active ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: active ? Colors.blueAccent : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)))));

  Widget _navaidMenuBtn(String label, bool active, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: active
                  ? Colors.purpleAccent.withOpacity(0.2)
                  : Colors.transparent,
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          color: active ? Colors.purpleAccent : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)))));

  Widget _navAidOverlayBtn(String label, bool active, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: active
                  ? const Color(0xFFFFD166).withOpacity(0.18)
                  : Colors.transparent,
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          color:
                              active ? const Color(0xFFFFD166) : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)))));

  Widget _weatherMenuBtn(String label, bool active, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color:
                  active ? Colors.orange.withOpacity(0.2) : Colors.transparent,
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          color: active ? Colors.orangeAccent : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)))));
}

class AdvancedAirportInfoBox extends StatefulWidget {
  final dynamic ap;
  final VoidCallback onClose;

  const AdvancedAirportInfoBox({
    Key? key,
    required this.ap,
    required this.onClose,
  }) : super(key: key);

  @override
  _AdvancedAirportInfoBoxState createState() => _AdvancedAirportInfoBoxState();
}

class _AdvancedAirportInfoBoxState extends State<AdvancedAirportInfoBox> {
  bool isLoading = true;
  Map<String, dynamic>? fpdbData;

  List<dynamic> vatsimControllers = [];
  String vatsimAtis = "";
  String vatsimMetar = "";

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void didUpdateWidget(covariant AdvancedAirportInfoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ap['icao'] != widget.ap['icao']) {
      _fetchAllData();
    }
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    String icao = widget.ap['icao']?.toString().toUpperCase() ?? "";

    try {
      final fp = await http.get(
          Uri.parse('https://api.flightplandatabase.com/nav/airport/$icao'));
      if (fp.statusCode == 200) {
        fpdbData = json.decode(fp.body);
      }

      final vat = await http
          .get(Uri.parse('https://data.vatsim.net/v3/vatsim-data.json'));
      if (vat.statusCode == 200) {
        final vatData = json.decode(vat.body);
        final controllers = vatData['controllers'] as List;
        final atisList = vatData['atis'] as List;

        vatsimControllers = controllers.where((c) {
          String cs = c['callsign']?.toString() ?? "";
          return cs.startsWith("${icao}_");
        }).toList();

        var atisNode = atisList.firstWhere((a) {
          String cs = a['callsign']?.toString() ?? "";
          return cs.startsWith("${icao}_");
        }, orElse: () => null);

        if (atisNode != null && atisNode['text_atis'] != null) {
          if (atisNode['text_atis'] is List) {
            vatsimAtis = (atisNode['text_atis'] as List).join("\n");
          } else {
            vatsimAtis = atisNode['text_atis'].toString();
          }
        }

        final met = await http
            .get(Uri.parse('https://metar.vatsim.net/metar.php?id=$icao'));
        if (met.statusCode == 200) {
          vatsimMetar = met.body.trim();
        }
      }
    } catch (e) {}

    if (mounted) setState(() => isLoading = false);
  }

  String _str(dynamic val, [String def = "-"]) =>
      val != null ? val.toString() : def;

  String _parseLighting(dynamic l) {
    if (l == null) return "-";
    if (l is bool) return l ? "YES" : "NO";
    if (l is List) return l.join(", ");
    return l.toString();
  }

  String _formatFreq(dynamic freqVal) {
    if (freqVal == null) return "-";
    String s = freqVal.toString();
    double? d = double.tryParse(s);
    if (d == null) return s;
    if (d > 1000) {
      String str = d.toInt().toString();
      if (str.length >= 3) {
        String formatted = "${str.substring(0, 3)}.${str.substring(3)}";
        double? parsed = double.tryParse(formatted);
        if (parsed != null) d = parsed;
      }
    }
    return d.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.ap['name'] ?? "Unknown Airport";
    String icao = widget.ap['icao'] ?? "N/A";
    String city = widget.ap['city'] ?? "Unknown City";
    String country = widget.ap['country'] ?? "Unknown Country";

    String iata =
        widget.ap['IATA'] ?? widget.ap['iata'] ?? widget.ap['iata_code'] ?? "-";

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2)
        ],
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.local_airport,
                      color: Colors.cyanAccent, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text("$city, $country",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(icao,
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white54, size: 20),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white54,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "INFO"),
                Tab(text: "RUNWAYS"),
                Tab(text: "WEATHER"),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.cyanAccent))
                  : TabBarView(children: [
                      _buildInfoTab(iata),
                      _buildRunwaysTab(),
                      _buildWeatherTab()
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(String iataCode) {
    String elevStr = "-";
    if (fpdbData?['elevation'] != null) {
      double? el = double.tryParse(fpdbData!['elevation'].toString());
      if (el != null) elevStr = "${el.round()} ft";
    }

    String varStr = "-";
    if (fpdbData?['magneticVariation'] != null) {
      double? v = double.tryParse(fpdbData!['magneticVariation'].toString());
      if (v != null) varStr = v.toStringAsFixed(1);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            border: TableBorder.all(color: Colors.white10),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.8)
            },
            children: [
              _infoRow("ICAO", fpdbData?['icao'] ?? widget.ap['icao'] ?? "-"),
              _infoRow(
                  "IATA", fpdbData?['IATA'] ?? fpdbData?['iata'] ?? iataCode),
              _infoRow("COUNTRY",
                  fpdbData?['country'] ?? widget.ap['country'] ?? "-"),
              _infoRow("ELEVATION", elevStr),
              _infoRow("LATITUDE",
                  _str(fpdbData?['lat'], widget.ap['lat']?.toString() ?? "-")),
              _infoRow("LONGITUDE",
                  _str(fpdbData?['lon'], widget.ap['lon']?.toString() ?? "-")),
              _infoRow("VARIATION", varStr),
              _infoRow("TIMEZONE", _str(fpdbData?['timezone'])),
              _infoRow("SUNRISE", _str(fpdbData?['times']?['sunrise'])),
              _infoRow("SUNSET", _str(fpdbData?['times']?['sunset'])),
            ],
          ),
          const SizedBox(height: 16),
          if (fpdbData?['frequencies'] != null &&
                  (fpdbData!['frequencies'] as List).isNotEmpty ||
              vatsimControllers.isNotEmpty) ...[
            const Text("REAL WORLD FREQUENCIES",
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.white10),
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: Colors.cyan.withOpacity(0.1)),
                  children: [
                    _cell("TYPE", isHeader: true),
                    _cell("FREQ", isHeader: true),
                    _cell("NAME", isHeader: true)
                  ],
                ),
                ...vatsimControllers.map<TableRow>((c) => TableRow(children: [
                      _cell(c['callsign']?.toString().split('_').last ?? "ATC"),
                      _cell(_formatFreq(c['frequency'])),
                      _cell(c['name'] ?? "-")
                    ])),
                if (fpdbData?['frequencies'] != null)
                  ...(fpdbData!['frequencies'] as List)
                      .map<TableRow>((f) => TableRow(children: [
                            _cell(_str(f['type']).toUpperCase()),
                            _cell(_formatFreq(f['frequency'])),
                            _cell(_str(f['name']))
                          ]))
                      .toList()
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRunwaysTab() {
    if (fpdbData == null ||
        fpdbData!['runways'] == null ||
        (fpdbData!['runways'] as List).isEmpty) {
      return const Center(
          child: Text("No Runways Data Available",
              style: TextStyle(color: Colors.white54)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.white10),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1)),
              children: [
                _cell("R/W", isHeader: true),
                _cell("LENGTH", isHeader: true),
                _cell("WIDTH", isHeader: true),
                _cell("SURFACE", isHeader: true),
                _cell("BEARING", isHeader: true),
                _cell("LIGHTING", isHeader: true)
              ],
            ),
            ...(fpdbData!['runways'] as List).map<TableRow>((r) {
              String lenStr = "-";
              if (r['length'] != null) {
                double? lVal = double.tryParse(r['length'].toString());
                lenStr =
                    lVal != null ? "${lVal.round()} ft" : "${r['length']} ft";
              }
              String widStr = "-";
              if (r['width'] != null) {
                double? wVal = double.tryParse(r['width'].toString());
                widStr =
                    wVal != null ? "${wVal.round()} ft" : "${r['width']} ft";
              }

              String bearingStr = "-";
              dynamic bVal = r['bearing'] ?? r['heading'];
              if (bVal != null) {
                double? bDouble = double.tryParse(bVal.toString());
                if (bDouble != null) {
                  bearingStr = "${bDouble.round().toString().padLeft(3, '0')}°";
                } else {
                  String bString = bVal.toString().trim();
                  if (bString.isNotEmpty && bString != "null") {
                    bearingStr = "$bString°";
                  }
                }
              }

              return TableRow(children: [
                _cell(_str(r['ident'])),
                _cell(lenStr),
                _cell(widStr),
                _cell(_str(r['surface']).toUpperCase()),
                _cell(bearingStr),
                _cell(_parseLighting(r['lighting']))
              ]);
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("METAR",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            child: Text(
              vatsimMetar.isNotEmpty ? vatsimMetar : "No METAR available.",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text("VATSIM ATIS",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vatsimAtis.isNotEmpty
                      ? vatsimAtis
                      : "No ATIS available on VATSIM.",
                  style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4),
                ),
                if (vatsimAtis.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text("LISTEN TO ATIS"),
                      onPressed: () {
                        professionalAtis(vatsimAtis);
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _infoRow(String k, String v) => TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(k,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(v,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)))
      ]);
  Widget _cell(String txt, {bool isHeader = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(txt,
          style: TextStyle(
              color: isHeader ? Colors.cyanAccent : Colors.white,
              fontSize: 11,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)));
}

// ============================================================================
// 👇👇 كود الـ Custom Action المطلوب (professionalAtis) 👇👇
// ============================================================================

Future professionalAtis(String rawMetar) async {
  FlutterTts flutterTts = FlutterTts();

  if (rawMetar.isEmpty) return;

  String cleanText = rawMetar.replaceAll(RegExp(r'\(.*?\)'), '');
  cleanText = cleanText.replaceAll('[', ' ').replaceAll(']', ' ');

  cleanText = cleanText.toUpperCase();
  cleanText = cleanText.replaceAll(RegExp(r'[,;:\.]'), ' ');

  String speakDigit(String numStr) {
    Map<String, String> numbers = {
      '0': 'Zero',
      '1': 'One',
      '2': 'Two',
      '3': 'Three',
      '4': 'Four',
      '5': 'Five',
      '6': 'Six',
      '7': 'Seven',
      '8': 'Eight',
      '9': 'Niner'
    };
    return numStr.split('').map((char) => numbers[char] ?? char).join(' ');
  }

  Map<String, String> phonetics = {
    'A': 'Alpha',
    'B': 'Bravo',
    'C': 'Charlie',
    'D': 'Delta',
    'E': 'Echo',
    'F': 'Foxtrot',
    'G': 'Golf',
    'H': 'Hotel',
    'I': 'India',
    'J': 'Juliet',
    'K': 'Kilo',
    'L': 'Lima',
    'M': 'Mike',
    'N': 'November',
    'O': 'Oscar',
    'P': 'Papa',
    'Q': 'Quebec',
    'R': 'Romeo',
    'S': 'Sierra',
    'T': 'Tango',
    'U': 'Uniform',
    'V': 'Victor',
    'W': 'Whiskey',
    'X': 'X-ray',
    'Y': 'Yankee',
    'Z': 'Zulu'
  };

  cleanText = cleanText.replaceAll(RegExp(r'\bWIND\b'), ' wind ');
  cleanText = cleanText.replaceAll(RegExp(r'\bATIS\b'), ' atis ');
  cleanText = cleanText.replaceAll(RegExp(r'\bBOTH\b'), ' both ');
  cleanText = cleanText.replaceAll(RegExp(r'\bHAVE\b'), ' have ');
  cleanText = cleanText.replaceAll(RegExp(r'\bNEED\b'), ' need ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTO\b'), ' to ');
  cleanText = cleanText.replaceAll(RegExp(r'\bFROM\b'), ' from ');
  cleanText = cleanText.replaceAll(RegExp(r'\bHOLD\b'), ' hold ');
  cleanText = cleanText.replaceAll(RegExp(r'\bMODE\b'), ' mode ');
  cleanText = cleanText.replaceAll(RegExp(r'\bALL\b'), ' all ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d{3})V(\d{3})'), (match) {
    return " variable between ${speakDigit(match.group(1)!)} and ${speakDigit(match.group(2)!)} ";
  });

  cleanText = cleanText.replaceAll(RegExp(r'\+SHRA\b'), ' heavy shower rain ');
  cleanText = cleanText.replaceAll(RegExp(r'\-SHRA\b'), ' light shower rain ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTDZ\b'), ' touch down zone ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLRC\b'), ' clearance ');
  cleanText = cleanText.replaceAll(RegExp(r'\bREQ\b'), ' request ');
  cleanText =
      cleanText.replaceAll(RegExp(r'\bTOBT\b'), ' target off block time ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRNAV\b'), ' r nav ');
  cleanText = cleanText.replaceAll(RegExp(r'\bACK\b'), ' acknowledge ');
  cleanText = cleanText.replaceAll(RegExp(r'\bSQK\b'), ' squawk ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCTC\b'), ' contact ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLD\b'), ' cloud ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTEMP\b'), ' temperature ');

  cleanText = cleanText.replaceAll(RegExp(r'\bAPP\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPR\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPCH\b'), ' approach ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPCHS\b'), ' approaches ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAPRS\b'), ' approaches ');

  cleanText =
      cleanText.replaceAll(RegExp(r'\b9999\b'), ' ten kilometers or more ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVRB\b'), ' variable ');
  cleanText = cleanText.replaceAll(RegExp(r'\bBTN\b'), ' between ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVIS\b'), ' visibility ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCMB\b'), ' climb ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEG\b'), ' degrees ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTCU\b'), ' towering cumulus ');

  cleanText = cleanText.replaceAll(RegExp(r'\bILS\b'), ' i l s ');
  cleanText = cleanText.replaceAll(RegExp(r'\bVHF\b'), ' v h f ');
  cleanText = cleanText.replaceAll(RegExp(r'\bATC\b'), ' a t c ');
  cleanText = cleanText.replaceAll(RegExp(r'\bGLS\b'), ' glide slope ');
  cleanText = cleanText.replaceAll(RegExp(r'\bTRL\b'), ' transition level ');
  cleanText =
      cleanText.replaceAll(RegExp(r'\bNOSIG\b'), ' no significant change ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARRS\b'), ' arrivals ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARR\b'), ' arrival ');
  cleanText = cleanText.replaceAll(RegExp(r'\bARPT\b'), ' airport ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEP\b'), ' departure ');
  cleanText = cleanText.replaceAll(RegExp(r'\bAVBL\b'), ' available ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDRCTN\b'), ' direction ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCLSD\b'), ' closed ');
  cleanText = cleanText.replaceAll(RegExp(r'\bEXP\b'), ' expect ');
  cleanText = cleanText.replaceAll(RegExp(r'\bEQPT\b'), ' equipment ');
  cleanText = cleanText.replaceAll(RegExp(r'\bCAUT\b'), ' caution ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEPG\b'), ' departure ');
  cleanText = cleanText.replaceAll(RegExp(r'\bDEPS\b'), ' departures ');
  cleanText = cleanText.replaceAll(RegExp(r'\bLDG\b'), ' landing ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)KT\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num knots ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)KM\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num kilometers ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d*)HPA\b'), (match) {
    String num = match.group(1) ?? "";
    return "$num hectopascals ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'(\d+)FT\b'), (match) {
    return "${match.group(1)} feet ";
  });
  cleanText = cleanText.replaceAll(RegExp(r'\bFT\b'), ' feet ');
  cleanText = cleanText.replaceAll(RegExp(r'\bKT\b'), ' knots ');
  cleanText = cleanText.replaceAll(RegExp(r'\bKM\b'), ' kilometers ');

  cleanText = cleanText.replaceAll('FEW', ' few ');
  cleanText = cleanText.replaceAll('BKN', ' broken ');
  cleanText = cleanText.replaceAll('SCT', ' scattered ');
  cleanText = cleanText.replaceAll('OVC', ' overcast ');
  cleanText = cleanText.replaceAll('CLR', ' clear ');
  cleanText = cleanText.replaceAll('SKC', ' sky clear ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRWY\b'), ' runway ');
  cleanText = cleanText.replaceAll(RegExp(r'\bRWYS\b'), ' runways ');
  cleanText = cleanText.replaceAll(RegExp(r'\bINFO\b'), ' information ');
  cleanText = cleanText.replaceAll(RegExp(r'\bSIMUL\b'), ' simultaneous ');
  cleanText = cleanText.replaceAll(RegExp(r'\bADVS\b'), ' advice ');

  cleanText = cleanText.replaceAllMapped(RegExp(r'\bT(\d{2})\b'), (match) {
    return " temperature ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\bDP(\d{2})\b'), (match) {
    return " dew point ${speakDigit(match.group(1)!)} ";
  });

  cleanText = cleanText.replaceAllMapped(
      RegExp(r'INFORMATION\s+([A-Z])\b', caseSensitive: false), (match) {
    String letter = match.group(1)!.toUpperCase();
    return " information ${phonetics[letter] ?? letter} ";
  });

  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\bQNH[:\s]*(\d{4})\b'), (match) {
    return " q n h ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\bA(\d{4})\b'), (match) {
    return " altimeter ${speakDigit(match.group(1)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(
      RegExp(r'\b(\d{3}|VARIABLE)(\d{2,3})(G(\d{2,3}))?KNOTS\b'), (match) {
    String dir =
        match.group(1) == 'VARIABLE' ? 'Variable' : speakDigit(match.group(1)!);
    String speed = speakDigit(match.group(2)!);
    String gusts =
        match.group(4) != null ? " gusts ${speakDigit(match.group(4)!)}" : "";
    return " wind $dir at $speed $gusts knots ";
  });
  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\b(\d{2})\/(\d{2})\b'), (match) {
    return " temperature ${speakDigit(match.group(1)!)} dewpoint ${speakDigit(match.group(2)!)} ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'\b(\d+)SM\b'), (match) {
    return " visibility ${speakDigit(match.group(1)!)} statute miles ";
  });
  cleanText = cleanText.replaceAllMapped(RegExp(r'([0-9])(L|R|C)\b'), (match) {
    String side = match.group(2) == 'L'
        ? 'left'
        : (match.group(2) == 'R' ? 'right' : 'center');
    return " ${match.group(1)} $side ";
  });

  cleanText =
      cleanText.replaceAll(RegExp(r'\bCAVOK\b'), ' ceiling and visibility ok ');
  cleanText = cleanText.replaceAll('/', ' ');

  cleanText =
      cleanText.replaceAllMapped(RegExp(r'\b(TIME\s+)?(\d{4})Z\b'), (match) {
    return " time ${speakDigit(match.group(2)!)} zulu ";
  });

  List<String> words = cleanText.split(RegExp(r'\s+'));
  List<String> finalWords = [];
  bool foundIcaoCode = false;

  for (String word in words) {
    if (word.isEmpty) continue;

    if (!foundIcaoCode &&
        word.length == 4 &&
        RegExp(r'^[A-Z]{4}$').hasMatch(word)) {
      String phoneticIcao = "";
      for (int i = 0; i < word.length; i++) {
        phoneticIcao += (phonetics[word[i]] ?? word[i]) + " ";
      }
      finalWords.add(phoneticIcao.trim());
      foundIcaoCode = true;
      continue;
    }

    if (word.length == 1) {
      if (RegExp(r'^[A-Z]$').hasMatch(word) && phonetics.containsKey(word)) {
        finalWords.add(phonetics[word]!);
      } else {
        finalWords.add(word);
      }
    } else if (word.contains(RegExp(r'[0-9]'))) {
      String processedWord = "";
      for (int i = 0; i < word.length; i++) {
        String char = word[i];
        if (RegExp(r'[0-9]').hasMatch(char)) {
          processedWord += speakDigit(char) + " ";
        } else if (RegExp(r'^[A-Z]$').hasMatch(char) &&
            phonetics.containsKey(char)) {
          processedWord += phonetics[char]! + " ";
        } else {
          processedWord += char;
        }
      }
      finalWords.add(processedWord.trim());
    } else {
      finalWords.add(word);
    }
  }

  String finalSpeech = finalWords.join(' ').toLowerCase();

  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(0.85);
  await flutterTts.setSpeechRate(0.42);
  await flutterTts.setVolume(1.0);
  await flutterTts.speak(finalSpeech);
}
