import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class PatrolTable extends StatelessWidget {
  final List<dynamic> units;

  const PatrolTable({super.key, required this.units});

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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.surfaceLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Patrol Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Row(
                  children: [
                    _buildFilterTab('All', true),
                    _buildFilterTab('Available', false),
                    _buildFilterTab('En Route', false),
                    _buildFilterTab('Busy', false),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                dataTextStyle: const TextStyle(color: AppTheme.textPrimary),
                columns: const [
                  DataColumn(label: Text('UNIT ID')),
                  DataColumn(label: Text('OFFICER(S)')),
                  DataColumn(label: Text('LOCATION')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: units.map((unit) {
                  return _buildRow(
                    unit['id'],
                    unit['officer'],
                    'Lat: ${unit['lat'].toStringAsFixed(3)}, Lng: ${unit['lng'].toStringAsFixed(3)}',
                    unit['status'],
                    _getStatusColor(unit['status']),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accentCyan.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.accentCyan : AppTheme.surfaceLight),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? AppTheme.accentCyan : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  DataRow _buildRow(String unit, String officers, String location, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(unit, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(officers)),
        DataCell(Text(location)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ),
      ],
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
