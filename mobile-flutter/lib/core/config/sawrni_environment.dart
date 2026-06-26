class SawrniEnvironment {
  static const String appNameAr = 'صورني';
  static const String appNameEn = 'Sawrni';
  static const String sloganAr = 'استوديو كامل بجيبك';

  /// Pass this at build/run time:
  /// flutter run --dart-define=SAWRNI_API_BASE_URL=http://10.0.2.2:8010/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'SAWRNI_API_BASE_URL',
    defaultValue: 'https://api.sawrni.com/api/v1',
  );

  static const String buildFlavor = String.fromEnvironment(
    'SAWRNI_FLAVOR',
    defaultValue: 'debug',
  );

  static bool get isProduction => buildFlavor == 'production';
}
