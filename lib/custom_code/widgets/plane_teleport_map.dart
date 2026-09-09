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

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

class PlaneTeleportMap extends StatefulWidget {
  const PlaneTeleportMap({
    Key? key,
    this.width,
    this.height,
    this.initialLat,
    this.initialLng,
    this.initialZoom,
    this.onLocationSelected,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double? initialLat;
  final double? initialLng;
  final double? initialZoom;

  // تم تغيير أسماء المتغيرات هنا لحل مشكلة تعليق فلاتر فلو
  final Future Function(double? selectedLatitude, double? selectedLongitude)?
      onLocationSelected;

  @override
  _PlaneTeleportMapState createState() => _PlaneTeleportMapState();
}

class _PlaneTeleportMapState extends State<PlaneTeleportMap> {
  final MapController _mapController = MapController();
  ll.LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
              ll.LatLng(widget.initialLat ?? 30.0, widget.initialLng ?? 31.0),
          initialZoom: widget.initialZoom ?? 6.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedLocation = point;
            });

            // إرسال الإحداثيات بالأسماء الجديدة
            if (widget.onLocationSelected != null) {
              widget.onLocationSelected!(point.latitude, point.longitude);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: ['a', 'b', 'c', 'd'],
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
