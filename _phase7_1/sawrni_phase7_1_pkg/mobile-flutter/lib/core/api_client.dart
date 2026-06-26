import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  ApiException(this.statusCode, this.message, [this.body]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = _normalize(baseUrl ?? const String.fromEnvironment('SAWRNI_API_BASE_URL', defaultValue: 'http://127.0.0.1:8010/api/v1/mobile'));

  final String baseUrl;

  static String _normalize(String value) {
    var result = value.trim();
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await http.get(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> payload, {String? token}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Uri _uri(String path) {
    final cleaned = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleaned');
  }

  Map<String, String> _headers(String? token) {
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final Map<String, dynamic> body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = (body['message_ar'] ?? body['message_en'] ?? body['message'] ?? 'API error').toString();
      throw ApiException(response.statusCode, message, body);
    }

    return body;
  }
}
