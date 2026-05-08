import 'package:flutter/material.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_command_system/src/features/auth/presentation/login_screen.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final _stationNameController = TextEditingController();
  final _stationLocationController = TextEditingController();
  
  final _officerEmailController = TextEditingController();
  final _officerPasswordController = TextEditingController();
  
  List<dynamic> _stations = [];
  String? _selectedStationId;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:3000/api/stations',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _stations = response.data;
      });
    } catch (e) {
      print('Error fetching stations: $e');
    }
  }

  Future<void> _createStation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final dio = Dio();
      await dio.post(
        'http://localhost:3000/api/stations',
        data: {
          'name': _stationNameController.text,
          'location': _stationLocationController.text,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _stationNameController.clear();
      _stationLocationController.clear();
      _fetchStations();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Station Created!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating station')));
    }
  }

  Future<void> _createCommandOfficer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final dio = Dio();
      await dio.post(
        'http://localhost:3000/api/users',
        data: {
          'email': _officerEmailController.text,
          'password': _officerPasswordController.text,
          'role': 'COMMAND_OFFICER',
          'stationId': _selectedStationId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _officerEmailController.clear();
      _officerPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Command Officer Created!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating officer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('SUPER ADMIN PORTAL', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.accentRed),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create Police Station', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextField(controller: _stationNameController, decoration: _inputDeco('Station Name (e.g., Central Station)')),
                      const SizedBox(height: 16),
                      TextField(controller: _stationLocationController, decoration: _inputDeco('Coordinates or City (e.g., New York, NY)')),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, minimumSize: const Size(double.infinity, 50)),
                        onPressed: _createStation,
                        child: const Text('CREATE STATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 40),
                      const Text('Existing Stations', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _stations.length,
                          itemBuilder: (context, index) {
                            final st = _stations[index];
                            return ListTile(
                              title: Text(st['name'], style: const TextStyle(color: AppTheme.textPrimary)),
                              subtitle: Text(st['location'], style: const TextStyle(color: AppTheme.textSecondary)),
                              leading: const Icon(Icons.local_police, color: AppTheme.accentCyan),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create Command Officer', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      TextField(controller: _officerEmailController, decoration: _inputDeco('Officer Email / Badge ID')),
                      const SizedBox(height: 16),
                      TextField(controller: _officerPasswordController, decoration: _inputDeco('Password'), obscureText: true),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        dropdownColor: AppTheme.surface,
                        decoration: _inputDeco('Assign to Station'),
                        items: _stations.map<DropdownMenuItem<String>>((st) {
                          return DropdownMenuItem<String>(
                            value: st['id'],
                            child: Text(st['name'], style: const TextStyle(color: AppTheme.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedStationId = val),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, minimumSize: const Size(double.infinity, 50)),
                        onPressed: _createCommandOfficer,
                        child: const Text('CREATE COMMAND OFFICER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
