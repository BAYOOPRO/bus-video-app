import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/video_screen.dart'; // ✅ مهم تستورد الشاشة

class WelcomeController {
  Future<void> handleGuestNavigation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final busNumber = prefs.getString('bus_number');

    if (busNumber != null && busNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            videoUrl: null, // أو هات لينك الفيديو حسب ما بتجيبه
            cameFromGuest: true,
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/enter_bus');
    }
  }
}
