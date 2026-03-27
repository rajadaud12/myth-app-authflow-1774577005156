import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class HttpService {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network error: ${e.message}');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body) as Map<String, dynamic>;
      case 400:
        throw ApiException(400, 'Bad request');
      case 401:
        throw ApiException(401, 'Unauthorized');
      case 403:
        throw ApiException(403, 'Forbidden');
      case 404:
        throw ApiException(404, 'Not found');
      case 409:
        throw ApiException(409, 'Conflict - resource already exists');
      case 500:
        throw ApiException(500, 'Server error');
      default:
        throw ApiException(
          response.statusCode,
          'Unexpected error occurred',
        );
    }
  }
}