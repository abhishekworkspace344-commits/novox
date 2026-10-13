import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeofenceMapPicker extends StatefulWidget {
  const GeofenceMapPicker({super.key, required this.initialPoint});
  final LatLng initialPoint;

  @override
  State<GeofenceMapPicker> createState() => _GeofenceMapPickerState();
}

class _GeofenceMapPickerState extends State<GeofenceMapPicker> {
  late LatLng selected = widget.initialPoint;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Choose campus location'),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(children: [
            const Text('Tap the map to place the campus center.'),
            const SizedBox(height: 8),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: widget.initialPoint,
                  initialZoom: 16,
                  onTap: (_, point) => setState(() => selected = point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.novox.mobile',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: selected,
                      width: 42,
                      height: 42,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 42),
                    ),
                  ]),
                  RichAttributionWidget(
                    attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                  ),
                ],
              ),
            ),
            Text('${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}'),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, selected), child: const Text('Use location')),
        ],
      );
}
