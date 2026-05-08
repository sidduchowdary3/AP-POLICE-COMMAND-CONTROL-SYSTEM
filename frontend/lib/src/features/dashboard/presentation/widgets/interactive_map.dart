import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class InteractiveMap extends StatelessWidget {
  final List<dynamic> units;

  const InteractiveMap({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(15.9129, 79.7400), // Andhra Pradesh, India
            initialZoom: 7.0, // State-level view of AP
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              // Using CartoDB Dark Matter for a beautiful dark tactical map
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.police.commandsystem',
            ),
            MarkerLayer(
              markers: units.map((unit) {
                final color = _getStatusColor(unit['status']);
                return Marker(
                  point: LatLng(unit['lat'], unit['lng']),
                  width: 80,
                  height: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.5), blurRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.directions_car, color: Colors.white, size: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Text(
                          unit['id'],
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return AppTheme.accentGreen;
      case 'EN ROUTE':
        return AppTheme.accentYellow;
      case 'BUSY':
        return AppTheme.accentRed;
      default:
        return AppTheme.accentCyan;
    }
  }
}
