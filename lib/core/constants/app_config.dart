/// Muhit sozlamalari. Ishga tushirishda quyidagicha ustiga yozish mumkin:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Android emulyatoridan lokal backendga
  );

  static const socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const enableNetworkLogs = bool.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: true);

  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
}
