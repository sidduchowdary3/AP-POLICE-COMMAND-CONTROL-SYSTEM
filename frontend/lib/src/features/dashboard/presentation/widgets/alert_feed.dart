import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class AlertFeed extends StatelessWidget {
  final List<dynamic> alerts;
  final Function(String unitId)? onDispatch;

  const AlertFeed({super.key, required this.alerts, this.onDispatch});

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
                        context: context,
                        type: alert['type'] ?? 'ALERT',
                        unit: alert['unit'] ?? 'Unknown',
                        location: alert['location'] ?? '',
                        time: alert['time'] ?? 'Just now',
                        isCritical: alert['isCritical'] == true,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
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
                    Expanded(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    Expanded(child: Text(location, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                if (isCritical) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.local_police, size: 18),
                      label: const Text('ASSIGN BACKUP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      onPressed: () {
                        _showAssignBackupDialog(context, unit, location);
                      },
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignBackupDialog(BuildContext context, String requestingUnit, String location) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping, color: AppTheme.accentYellow, size: 32),
                  SizedBox(width: 16),
                  Text('DISPATCH BACKUP', style: TextStyle(color: AppTheme.accentYellow, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select an available nearby unit to dispatch to:', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Text(location, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Mock available units
              _buildUnitDispatchOption(context, 'VJA-2B', 'Suresh, P.', '2.4 km away'),
              _buildUnitDispatchOption(context, 'GNT-4D', 'Rao, M.', '5.1 km away'),
              _buildUnitDispatchOption(context, 'KKD-7G', 'Varma, B.', '8.0 km away'),
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDispatchOption(BuildContext context, String unitId, String officer, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: AppTheme.accentGreen, child: Icon(Icons.directions_car, color: Colors.white, size: 20)),
        title: Text(unitId, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text('$officer • $distance', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentYellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            if (onDispatch != null) {
              onDispatch!(unitId);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ $unitId successfully dispatched to assist!'),
                backgroundColor: AppTheme.accentGreen,
              ),
            );
          },
          child: const Text('DISPATCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
