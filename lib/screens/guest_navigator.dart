import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/enter_bus_screen.dart';
import '../screens/video_screen.dart';

class GuestNavigator {
  static Future<void> goToGuestFlow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final busNumber = prefs.getString('bus_number');

    if (busNumber != null && busNumber.isNotEmpty) {
      // لو الرقم محفوظ، روح على الفيديو عادي
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VideoScreen()),
      );
    } else {
      // لو مش محفوظ، خليه يدخل الرقم الأول
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnterBusScreen()),
      );
    }
  }
}
