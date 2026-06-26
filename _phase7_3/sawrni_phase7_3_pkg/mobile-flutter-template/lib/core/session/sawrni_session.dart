class SawrniSession {
  static String? token;
  static String? role;
  static String? phone;
  static String? name;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void save({required String newToken, required String newRole, required String newPhone, String? displayName}) {
    token = newToken;
    role = newRole;
    phone = newPhone;
    name = displayName;
  }

  static void clear() {
    token = null;
    role = null;
    phone = null;
    name = null;
  }
}
