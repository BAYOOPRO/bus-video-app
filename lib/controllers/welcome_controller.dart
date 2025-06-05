import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/video_screen.dart';

class WelcomeController {
  Future<void> handleGuestNavigation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final busNumber = prefs.getString('bus_number');

    if (!context.mounted) return; // ✅ مهم جداً بعد async

    if (busNumber != null && busNumber.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            videoUrl: null,
            cameFromGuest: true,
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/enterBus');
    }
  }
}
