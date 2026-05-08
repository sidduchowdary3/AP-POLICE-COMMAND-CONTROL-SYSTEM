import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:police_command_system/src/features/auth/presentation/login_screen.dart';

class MobilePatrolScreen extends StatefulWidget {
  const MobilePatrolScreen({super.key});

  @override
  State<MobilePatrolScreen> createState() => _MobilePatrolScreenState();
}

class _MobilePatrolScreenState extends State<MobilePatrolScreen> {
  late IO.Socket socket;
  bool _isTracking = false;
  Timer? _locationTimer;
  double _lat = 40.7128; // Simulating NY start
  double _lng = -74.0060;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      // Simulate background location service
      _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        setState(() {
          _lat += 0.0001; // Move slightly
          _lng += 0.0001;
        });
        socket.emit('updateLocation', {
          'id': 'MOBILE-UNIT-1',
          'lat': _lat,
          'lng': _lng,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Always-On Location Tracking Started')));
    } else {
      _locationTimer?.cancel();
    }
  }

  void _requestBackup() {
    socket.emit('triggerBackup', {
      'unitId': 'MOBILE-UNIT-1',
      'lat': _lat,
      'lng': _lng,
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('EMERGENCY SENT', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
        content: const Text('Your coordinates and distress signal have been transmitted to Command.', style: TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ACKNOWLEDGED'))
        ],
      )
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Patrol App', style: TextStyle(color: AppTheme.textPrimary)),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isTracking ? Icons.gps_fixed : Icons.gps_off, size: 80, color: _isTracking ? AppTheme.accentGreen : AppTheme.textSecondary),
              const SizedBox(height: 24),
              Text('Location Tracking: ${_isTracking ? "ACTIVE" : "OFF"}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Lat: ${_lat.toStringAsFixed(4)}, Lng: ${_lng.toStringAsFixed(4)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? AppTheme.surfaceLight : AppTheme.accentCyan,
                  minimumSize: const Size(300, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow, color: Colors.white),
                label: Text(_isTracking ? 'STOP TRACKING' : 'START PATROL (ALWAYS-ON)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _toggleTracking,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  minimumSize: const Size(300, 80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                label: const Text('REQUEST BACKUP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                onPressed: _requestBackup,
              )
            ],
          ),
        ),
      ),
    );
  }
}
