import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SawrniApiClient {
  SawrniApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    final response = await _client.get(
      _uri(path),
      headers: _headers(token),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
    if (response.statusCode >= 400) {
      throw SawrniApiException(response.statusCode, map);
    }
    return map;
  }
}

class SawrniApiException implements Exception {
  SawrniApiException(this.statusCode, this.body);
  final int statusCode;
  final Map<String, dynamic> body;

  @override
  String toString() => 'SawrniApiException($statusCode, $body)';
}
