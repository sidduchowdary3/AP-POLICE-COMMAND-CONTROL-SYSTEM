class ApiConfig {
  // Configured with the host machine's Wi-Fi IP address.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.31.239:3000',
  );
}
