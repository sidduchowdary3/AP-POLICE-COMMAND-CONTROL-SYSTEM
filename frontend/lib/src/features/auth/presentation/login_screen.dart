import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:police_command_system/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:police_command_system/src/features/dashboard/presentation/super_admin_screen.dart';
import 'package:police_command_system/src/features/dashboard/presentation/mobile_patrol_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _badgeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'COMMAND_OFFICER';

  final Map<String, Map<String, dynamic>> _roles = {
    'SUPER_ADMIN': {
      'label': 'Super Admin',
      'icon': Icons.admin_panel_settings,
      'color': const Color(0xFFFF6B6B),
    },
    'COMMAND_OFFICER': {
      'label': 'Command Officer',
      'icon': Icons.manage_accounts,
      'color': const Color(0xFF00E5FF),
    },
    'PERSONNEL': {
      'label': 'Police Personnel',
      'icon': Icons.directions_run,
      'color': const Color(0xFF69FF47),
    },
  };

  void _handleLogin() async {
    if (_badgeIdController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Badge ID and Clearance Code'), backgroundColor: Color(0xFFFF3B3B)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      final response = await dio.post('http://localhost:3000/auth/login', data: {
        'email': _badgeIdController.text.trim(),
        'password': _passwordController.text,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final actualRole = data['user']['role'] as String;

        if (actualRole != _selectedRole) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Access Denied: Your credentials are for ${_roles[actualRole]?['label'] ?? actualRole}. Select the correct role.'),
                backgroundColor: const Color(0xFFFF3B3B),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', data['access_token']);
        await prefs.setString('role', actualRole);
        await prefs.setString('email', data['user']['email']);
        await prefs.setString('stationId', data['user']['stationId'] ?? '');

        if (mounted) {
          if (actualRole == 'SUPER_ADMIN') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SuperAdminScreen()));
          } else if (actualRole == 'PERSONNEL') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MobilePatrolScreen()));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Badge ID or Clearance Code. Access Denied.'), backgroundColor: Color(0xFFFF3B3B)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleData = _roles[_selectedRole]!;
    final roleColor = roleData['color'] as Color;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // ─── LEFT PANEL ───────────────────────────────────────────────
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.surface, AppTheme.background],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AP Police Logo — dark circle clips white background
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.accentCyan.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(color: AppTheme.accentCyan.withOpacity(0.3), blurRadius: 40, spreadRadius: 8),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/ap_police_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 80, color: AppTheme.accentCyan),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'AP POLICE',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ANDHRA PRADESH\nPOLICE COMMUNITY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.surfaceLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '"SAFETY  •  SECURITY  •  SERVICE"',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── RIGHT PANEL ──────────────────────────────────────────────
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: roleColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: roleColor.withOpacity(0.08), blurRadius: 40, spreadRadius: 5),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SECURE LOGIN', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 3)),
                      const SizedBox(height: 4),
                      const Text('Command Center Access', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      // ── ROLE SELECTOR ──
                      const Text('SELECT YOUR ROLE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ..._roles.entries.map((entry) {
                        final isSelected = _selectedRole == entry.key;
                        final rColor = entry.value['color'] as Color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRole = entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? rColor.withOpacity(0.1) : AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? rColor : AppTheme.surfaceLight,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? rColor.withOpacity(0.2) : AppTheme.surfaceLight,
                                  ),
                                  child: Icon(entry.value['icon'] as IconData, color: isSelected ? rColor : AppTheme.textSecondary, size: 17),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? rColor : AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: rColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      // ── BADGE ID ──
                      const Text('BADGE ID / EMAIL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _badgeIdController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. siddhartha@appolice.gov.in',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          prefixIcon: Icon(Icons.badge, color: roleColor),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: roleColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── CLEARANCE CODE ──
                      const Text('CLEARANCE CODE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.lock, color: roleColor),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: roleColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── LOGIN BUTTON ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roleColor,
                            foregroundColor: AppTheme.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(roleData['icon'] as IconData, color: AppTheme.background, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'AUTHORIZE ${(roleData['label'] as String).toUpperCase()} ACCESS',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
