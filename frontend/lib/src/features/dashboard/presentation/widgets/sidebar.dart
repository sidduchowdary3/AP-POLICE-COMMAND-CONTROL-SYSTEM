import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:police_command_system/src/features/auth/presentation/login_screen.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int alertCount;

  const Sidebar({
    super.key, 
    required this.selectedIndex, 
    required this.onItemSelected,
    this.alertCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.surfaceLight, width: 1)),
            ),
            child: Row(
              children: [
                // AP Police Logo
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Image.asset(
                    'assets/ap_police_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: AppTheme.accentCyan, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AP POLICE',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          // Sub-label under logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            color: AppTheme.accentCyan.withOpacity(0.08),
            child: const Text(
              'ANDHRA PRADESH POLICE COMMUNITY',
              style: TextStyle(color: AppTheme.accentCyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Navigation Links
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, isActive: selectedIndex == 0),
          _buildNavItem(Icons.map_outlined, 'Live Map', 1, isActive: selectedIndex == 1),
          _buildNavItem(Icons.people_outline, 'Patrol Units', 2, isActive: selectedIndex == 2),
          _buildNavItem(Icons.warning_amber_rounded, 'Active Alerts', 3, isActive: selectedIndex == 3, badge: alertCount > 0 ? alertCount.toString() : null),
          _buildNavItem(Icons.history_outlined, 'Incident History', 4, isActive: selectedIndex == 4),
          _buildNavItem(Icons.person_add_outlined, 'Manage Personnel', 5, isActive: selectedIndex == 5),
          
          const Spacer(),
          
          // Bottom Links
          _buildNavItem(Icons.settings_outlined, 'Settings', 6, isActive: selectedIndex == 6),
          
          // Secure Logout
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.accentRed),
              title: const Text('Secure Logout', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
              onTap: () async {
                // Clear the stored JWT token on logout
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index, {bool isActive = false, String? badge, Color? color}) {
    final itemColor = color ?? (isActive ? AppTheme.accentCyan : AppTheme.textSecondary);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accentCyan.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: AppTheme.accentCyan.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: itemColor),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : itemColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () => onItemSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
