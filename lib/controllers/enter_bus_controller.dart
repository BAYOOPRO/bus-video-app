import 'package:flutter/material.dart';
import 'package:ms/core/app_link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EnterBusController {
  Future<bool> checkBusNumber(BuildContext context, String busNumber) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.checkBusNumber),
        body: {'bus_number': busNumber},
      );

      final result = response.body;
      print("📦 Response: $result");

      if (response.statusCode == 200 && result.contains('"valid":true')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bus_number', busNumber);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Error checking bus number: $e");
      return false;
    }
  }
}
