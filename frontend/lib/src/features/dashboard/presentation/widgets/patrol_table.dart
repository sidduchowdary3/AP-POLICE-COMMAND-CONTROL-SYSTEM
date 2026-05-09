import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class PatrolTable extends StatefulWidget {
  final List<dynamic> units;

  const PatrolTable({super.key, required this.units});

  @override
  State<PatrolTable> createState() => _PatrolTableState();
}

class _PatrolTableState extends State<PatrolTable> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Apply filter
    final filteredUnits = widget.units.where((u) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Available') return u['status'] == 'AVAILABLE';
      if (_selectedFilter == 'En Route') return u['status'] == 'EN ROUTE';
      if (_selectedFilter == 'Busy') return u['status'] == 'BUSY';
      return true;
    }).toList();

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
                    _buildFilterTab('All'),
                    _buildFilterTab('Available'),
                    _buildFilterTab('En Route'),
                    _buildFilterTab('Busy'),
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
                rows: filteredUnits.map((unit) {
                  return _buildRow(
                    context,
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

  Widget _buildFilterTab(String title) {
    final isActive = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
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
      ),
    );
  }

  DataRow _buildRow(BuildContext context, String unit, String officers, String location, String status, Color statusColor) {
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'dispatch') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dispatching backup to Unit $unit...'), backgroundColor: AppTheme.accentCyan),
                );
              } else if (value == 'contact') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening secure comms with $officers...'), backgroundColor: AppTheme.accentGreen),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dispatch',
                child: Row(
                  children: const [
                    Icon(Icons.local_shipping, color: AppTheme.accentYellow, size: 20),
                    SizedBox(width: 8),
                    Text('Dispatch Backup', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: const [
                    Icon(Icons.mic, color: AppTheme.accentGreen, size: 20),
                    SizedBox(width: 8),
                    Text('Radio Contact', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
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
