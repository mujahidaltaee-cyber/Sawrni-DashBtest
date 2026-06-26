class AppConfig {
  /// Pass in build command:
  /// --dart-define=SAWRNI_API_BASE_URL=https://your-domain.com/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'SAWRNI_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8010/api/v1',
  );

  static const bool isProduction = bool.fromEnvironment(
    'SAWRNI_PRODUCTION',
    defaultValue: false,
  );
}
