import 'dart:convert';
import 'package:http/http.dart' as http;

class SawrniApiClient {
  SawrniApiClient({
    required this.baseUrl,
    this.bearerToken,
  });

  final String baseUrl;
  final String? bearerToken;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (bearerToken != null && bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $bearerToken',
      };

  Uri _uri(String path) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath');
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await http.get(_uri(path), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(_uri(path), headers: _headers, body: jsonEncode(body));
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded;

    final message = decoded['message_ar'] ?? decoded['message_en'] ?? decoded['message'] ?? 'Request failed';
    throw SawrniApiException(response.statusCode, message.toString(), decoded);
  }
}

class SawrniApiException implements Exception {
  SawrniApiException(this.statusCode, this.message, this.payload);

  final int statusCode;
  final String message;
  final Map<String, dynamic> payload;

  @override
  String toString() => 'SawrniApiException($statusCode): $message';
}
