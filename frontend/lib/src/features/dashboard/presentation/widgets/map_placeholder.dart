import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A), // Even darker for map background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Grid Pattern to look like a tactical map
          CustomPaint(
            painter: GridPainter(),
            child: Container(),
          ),
          
          // Radar sweep effect overlay
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentCyan.withOpacity(0.1), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentCyan.withOpacity(0.2), width: 1),
                  ),
                ),
              ),
            ),
          ),
          
          // Simulated unit markers
          _buildMarker(context, 0.4, 0.3, 'U-4A', AppTheme.accentRed),
          _buildMarker(context, 0.6, 0.5, 'U-2B', AppTheme.accentGreen),
          _buildMarker(context, 0.3, 0.7, 'U-7C', AppTheme.accentYellow),
          _buildMarker(context, 0.7, 0.8, 'U-1A', AppTheme.accentRed),
          _buildMarker(context, 0.8, 0.2, 'U-3D', AppTheme.accentGreen),
          
          // Overlay UI
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: const Text('TACTICAL MAP VIEW', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
          
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: AppTheme.surface,
              onPressed: () {},
              child: const Icon(Icons.my_location, color: AppTheme.accentCyan),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMarker(BuildContext context, double x, double y, String label, Color color) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.5 * x,
      top: MediaQuery.of(context).size.height * 0.4 * y,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(Icons.local_police, size: 16, color: color),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCyan.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
