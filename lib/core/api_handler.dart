// lib/core/api_handler.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ms/core/app_link.dart';

class ApiHandler {
  static const String _baseUrl = AppLink.server;

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = endpoint.startsWith("http")
        ? Uri.parse(endpoint)
        : Uri.parse(_baseUrl + endpoint);

    final response = await http.get(url);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final url = endpoint.startsWith("http")
        ? Uri.parse(endpoint)
        : Uri.parse(_baseUrl + endpoint);

    final response = await http.post(url, body: body);
    return _handleResponse(response);
  }


  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      return {"status": "failure", "message": "Invalid response"};
    }
  }
}
