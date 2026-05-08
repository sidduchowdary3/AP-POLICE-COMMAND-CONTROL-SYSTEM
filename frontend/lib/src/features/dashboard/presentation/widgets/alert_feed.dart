import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class AlertFeed extends StatelessWidget {
  final List<dynamic> alerts;

  const AlertFeed({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.surfaceLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppTheme.accentYellow),
                    const SizedBox(width: 8),
                    const Text('Live Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${alerts.where((a) => a['isCritical'] == true).length} Critical', style: const TextStyle(color: AppTheme.accentRed, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Feed
          Expanded(
            child: alerts.isEmpty
                ? const Center(child: Text("No active alerts", style: TextStyle(color: AppTheme.textSecondary)))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: alerts.map((alert) {
                      return _buildAlertCard(
                        type: alert['type'],
                        unit: alert['unit'],
                        location: alert['location'],
                        time: alert['time'],
                        isCritical: alert['isCritical'],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String type,
    required String unit,
    required String location,
    required String time,
    bool isCritical = false,
  }) {
    final color = isCritical ? AppTheme.accentRed : AppTheme.accentCyan;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: color.withOpacity(0.3)),
                right: BorderSide(color: color.withOpacity(0.3)),
                bottom: BorderSide(color: color.withOpacity(0.3)),
                left: BorderSide(color: color, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(unit, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
