import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'sawrni_mobile_token';
  static const _roleKey = 'sawrni_mobile_role';
  static const _phoneKey = 'sawrni_mobile_phone';

  Future<void> save({required String token, required String role, required String phone}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _phoneKey, value: phone);
  }

  Future<String?> token() => _storage.read(key: _tokenKey);
  Future<String?> role() => _storage.read(key: _roleKey);
  Future<String?> phone() => _storage.read(key: _phoneKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _phoneKey);
  }
}
