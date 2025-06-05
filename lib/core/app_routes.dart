import 'package:flutter/material.dart';
import 'package:ms/screens/admin_home_screen.dart';
import 'package:ms/screens/select_video_screen.dart';
import 'package:ms/screens/upload_video_screen.dart';
import 'package:ms/screens/video_screen.dart';
import 'package:ms/screens/welcome_screen.dart';

import '../screens/enter_bus_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const WelcomeScreen(),
    '/admin': (context) => const AdminHomeScreen(),
    '/video': (context) => const VideoScreen(),
    '/enterBus': (context) => const EnterBusScreen(),
    '/upload_video': (context) => const UploadVideoScreen(),
    '/select_video': (context) => const SelectVideoScreen(),
  };
}
