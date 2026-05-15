class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, or your local machine's IP (e.g., 192.168.1.5) for physical devices.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
