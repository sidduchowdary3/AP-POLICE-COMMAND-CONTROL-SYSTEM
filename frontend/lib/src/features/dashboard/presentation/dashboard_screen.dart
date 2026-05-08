import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:police_command_system/src/features/auth/presentation/login_screen.dart';
import 'widgets/sidebar.dart';
import 'widgets/stat_card.dart';
import 'widgets/alert_feed.dart';
import 'widgets/patrol_table.dart';
import 'widgets/interactive_map.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late IO.Socket socket;
  List<dynamic> activeUnits = [];
  List<dynamic> alerts = [];
  int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _loggedInEmail = 'Officer';
  String _loggedInRole = 'COMMAND_OFFICER';

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _loggedInEmail = prefs.getString('email') ?? 'Officer';
        _loggedInRole = prefs.getString('role') ?? 'COMMAND_OFFICER';
      });
    }
  }

  void _initSocket() {
    // Connect to the local NestJS backend simulator
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Command Center Backend');
    });

    // Listen for live unit updates from the map simulator
    socket.on('syncUnits', (data) {
      if (mounted) {
        setState(() {
          activeUnits = List<dynamic>.from(data);
        });
      }
    });

    // Listen for incoming 911 emergencies / alerts
    socket.on('newAlert', (data) {
      if (mounted) {
        setState(() {
          alerts.insert(0, data);
          // Keep only the last 15 alerts to prevent memory bloat
          if (alerts.length > 15) {
            alerts.removeLast();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter units based on search query
    final filteredUnits = activeUnits.where((u) {
      final query = _searchQuery.toLowerCase();
      return u['id'].toString().toLowerCase().contains(query) || 
             u['officer'].toString().toLowerCase().contains(query);
    }).toList();

    // Calculate live stats
    final totalUnits = filteredUnits.length;
    final available = filteredUnits.where((u) => u['status'] == 'AVAILABLE').length;
    final enRoute = filteredUnits.where((u) => u['status'] == 'EN ROUTE').length;
    final criticalAlerts = alerts.where((a) => a['isCritical'] == true).length;

    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Sidebar
          Sidebar(
            selectedIndex: _selectedIndex,
            alertCount: criticalAlerts,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                _buildTopBar(),
                
                // Dynamic Content based on selection
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildMainContent(filteredUnits, totalUnits, available, enRoute, criticalAlerts),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<dynamic> filteredUnits, int totalUnits, int available, int enRoute, int criticalAlerts) {
    switch (_selectedIndex) {
      case 0: // Dashboard Overview
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: StatCard(title: 'Active Units', value: totalUnits.toString(), icon: Icons.local_police, color: AppTheme.accentCyan)),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'Critical Alerts', value: criticalAlerts.toString(), icon: Icons.warning_rounded, color: AppTheme.accentRed)),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'En Route', value: enRoute.toString(), icon: Icons.directions_car, color: AppTheme.accentYellow)),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'Available', value: available.toString(), icon: Icons.check_circle, color: AppTheme.accentGreen)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(flex: 2, child: InteractiveMap(units: filteredUnits)),
                  const SizedBox(height: 24),
                  Expanded(flex: 1, child: PatrolTable(units: filteredUnits)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: AlertFeed(alerts: alerts)),
          ],
        );
      
      case 1: // Live Map Full Screen
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('GLOBAL TACTICAL MAP', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            Expanded(child: InteractiveMap(units: filteredUnits)),
          ],
        );

      case 2: // Patrol Units Full Screen
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('GLOBAL PATROL ROSTER', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            Expanded(child: PatrolTable(units: filteredUnits)),
          ],
        );

      case 3: // Active Alerts Full Screen
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('CRITICAL EMERGENCY FEED', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: AlertFeed(alerts: alerts.where((a) => a['isCritical'] == true).toList())),
                  const SizedBox(width: 24),
                  Expanded(child: AlertFeed(alerts: alerts.where((a) => a['isCritical'] != true).toList())),
                ],
              ),
            ),
          ],
        );
        
      case 4: // Incident History - real alert log
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('INCIDENT HISTORY LOG', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            Expanded(
              child: alerts.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.history, size: 80, color: AppTheme.surfaceLight),
                    SizedBox(height: 16),
                    Text('No incidents recorded this session.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
                  ]))
                : ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[alerts.length - 1 - index]; // Newest first
                      final isCritical = alert['isCritical'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isCritical ? AppTheme.accentRed.withOpacity(0.5) : AppTheme.surfaceLight),
                        ),
                        child: Row(
                          children: [
                            Icon(isCritical ? Icons.warning_rounded : Icons.info_outline,
                                color: isCritical ? AppTheme.accentRed : AppTheme.accentCyan, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(alert['message'] ?? 'Alert', style: TextStyle(color: isCritical ? AppTheme.accentRed : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Unit: ${alert['unitId'] ?? 'Unknown'} | Lat: ${(alert['lat'] ?? 0.0).toStringAsFixed(4)}, Lng: ${(alert['lng'] ?? 0.0).toStringAsFixed(4)}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: isCritical ? AppTheme.accentRed.withOpacity(0.1) : AppTheme.accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(isCritical ? 'CRITICAL' : 'INFO',
                                style: TextStyle(color: isCritical ? AppTheme.accentRed : AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        );

      case 5: // Manage Personnel - Command Officer creates PERSONNEL accounts
        return _buildManagePersonnelView();

      case 6: // Settings
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.settings, size: 100, color: AppTheme.surfaceLight),
              SizedBox(height: 24),
              Text('SYSTEM PREFERENCES', style: TextStyle(color: AppTheme.textSecondary, fontSize: 24, letterSpacing: 2.0)),
              SizedBox(height: 8),
              Text('Module locked. Administrator clearance required.', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildManagePersonnelView() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isCreating = false;

    return StatefulBuilder(builder: (context, setLocalState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('MANAGE POLICE PERSONNEL', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create Personnel Account', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Officers you create will be locked to your station and can only use the Mobile Patrol App.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Officer Email / Badge ID',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.badge, color: AppTheme.accentCyan),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password / Clearance Code',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.lock, color: AppTheme.accentCyan),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: isCreating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.person_add, color: Colors.white),
                          label: const Text('CREATE OFFICER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          onPressed: isCreating ? null : () async {
                            setLocalState(() => isCreating = true);
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('jwt');
                              final dio = Dio();
                              await dio.post(
                                'http://localhost:3000/api/users',
                                data: {'email': emailCtrl.text, 'password': passCtrl.text, 'role': 'PERSONNEL'},
                                options: Options(headers: {'Authorization': 'Bearer \$token'}),
                              );
                              emailCtrl.clear();
                              passCtrl.clear();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Police Personnel account created successfully!'), backgroundColor: AppTheme.accentGreen),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Failed to create account. Check credentials or token.'), backgroundColor: AppTheme.accentRed),
                                );
                              }
                            } finally {
                              setLocalState(() => isCreating = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Instructions', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInstStep('1', 'Create an account using the officer\'s badge ID as their email.'),
                      _buildInstStep('2', 'Share the password with the officer securely.'),
                      _buildInstStep('3', 'The officer opens the Police Patrol App and logs in.'),
                      _buildInstStep('4', 'They tap "START PATROL" to activate always-on tracking.'),
                      _buildInstStep('5', 'Their GPS location appears live on your Command Map.'),
                      _buildInstStep('6', 'If they press REQUEST BACKUP, a critical alert fires on your dashboard instantly.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildInstStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentCyan),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.surfaceLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Command Center Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 16),
              // Mobile View Preview Button
              ElevatedButton.icon(
                onPressed: () {
                  _showMobilePreview(context);
                },
                icon: const Icon(Icons.phone_iphone),
                label: const Text('Mobile Patrol View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan.withOpacity(0.2),
                  foregroundColor: AppTheme.accentCyan,
                  elevation: 0,
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                width: 250,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                    hintText: 'Search units...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 24),
              PopupMenuButton<String>(
                color: AppTheme.surface,
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else if (value == 'settings') {
                    setState(() {
                      _selectedIndex = 5; // Go to settings screen
                    });
                  } else if (value == 'profile') {
                    _showProfileDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline, color: AppTheme.accentCyan),
                      title: Text('My Profile', style: TextStyle(color: AppTheme.textPrimary)),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined, color: AppTheme.accentCyan),
                      title: Text('Account Settings', style: TextStyle(color: AppTheme.textPrimary)),
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppTheme.accentRed),
                      title: Text('Secure Logout', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.accentCyan,
                      child: Icon(Icons.person, color: AppTheme.background),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_loggedInEmail, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        Text(_loggedInRole.replaceAll('_', ' '), style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMobilePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 375, // Standard mobile width
          height: 812, // Standard mobile height
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[800]!, width: 12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Patrol Unit App'),
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.satellite_alt, size: 60, color: AppTheme.accentCyan),
                    const SizedBox(height: 24),
                    const Text('GPS Tracking Active', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Streaming location to Command Center...', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        // Emit emergency backup request to backend!
                        socket.emit('triggerBackup', {'unitId': 'MY-MOBILE-UNIT'});
                        
                        // Close the mobile view modal
                        Navigator.of(context).pop();
                        
                        // Show a snackbar on the dashboard confirming it was sent
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup request sent to Command Center!'),
                            backgroundColor: AppTheme.accentRed,
                          ),
                        );
                      },
                      child: const Text('REQUEST BACKUP', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.accentCyan,
                child: Icon(Icons.person, size: 50, color: AppTheme.background),
              ),
              const SizedBox(height: 24),
              Text(_loggedInEmail, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_loggedInRole.replaceAll('_', ' '), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 32),
              
              _buildProfileDetailRow(Icons.badge, 'Badge ID', _loggedInEmail.split('@').first.toUpperCase()),
              const SizedBox(height: 16),
              _buildProfileDetailRow(Icons.security, 'Clearance', _loggedInRole == 'SUPER_ADMIN' ? 'Level 5 (Admin)' : 'Level 3 (Officer)'),
              const SizedBox(height: 16),
              _buildProfileDetailRow(Icons.timer, 'Shift Status', 'Active (0800 - 2000)'),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CLOSE', style: TextStyle(color: AppTheme.background, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCyan, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
