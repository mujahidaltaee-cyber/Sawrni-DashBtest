import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SawrniApiClient {
  final String token;
  final String baseUrl;

  SawrniApiClient({
    required this.token,
    this.baseUrl = AppConfig.apiBaseUrl,
  });

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    return _decode(res);
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final text = res.body.trim();
    if (text.isEmpty) {
      return {
        'status': res.statusCode >= 200 && res.statusCode < 300 ? 'ok' : 'error',
        'http_status': res.statusCode,
      };
    }

    final data = jsonDecode(text);
    if (data is Map<String, dynamic>) {
      data['http_status'] = res.statusCode;
      return data;
    }

    return {'status': 'error', 'http_status': res.statusCode, 'raw': data};
  }
}
