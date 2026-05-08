import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:police_command_system/src/core/services/background_location_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:police_command_system/src/core/theme/app_theme.dart';
import 'package:police_command_system/src/features/auth/presentation/login_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service for location tracking only on mobile
  if (!kIsWeb) {
    await BackgroundLocationService.initializeService();
  }

  runApp(
    const ProviderScope(
      child: PoliceCommandApp(),
    ),
  );
}

class PoliceCommandApp extends StatelessWidget {
  const PoliceCommandApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Police Command Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SelectionArea(child: LoginScreen()),
    );
  }
}
