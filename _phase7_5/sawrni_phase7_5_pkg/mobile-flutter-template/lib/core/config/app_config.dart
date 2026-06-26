class AppConfig {
  // In development, point this to your Laravel API.
  // Codespaces example:
  // https://YOUR-CODESPACE-8010.app.github.dev/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'SAWRNI_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8010/api/v1',
  );

  static const int platformCommissionPercent = 15;
  static const int debtThresholdIqd = 75000;
  static const int customerEditWindowHoursAfterDeposit = 3;
  static const int customerCancelWindowHoursAfterDeposit = 1;
}
