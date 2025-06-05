import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/app_link.dart';

class AdminLoginController {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(AppLink.adminLogin);
    final response = await http.post(url, body: {
      "email": email,
      "password": password,
    });

    return json.decode(response.body);
  }
}
