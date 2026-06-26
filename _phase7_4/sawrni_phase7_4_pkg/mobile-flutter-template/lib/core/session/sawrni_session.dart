class SawrniSession {
  static String? token;
  static String role = 'provider';
  static String apiBaseUrl = 'http://127.0.0.1:8010/api/v1';

  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}
