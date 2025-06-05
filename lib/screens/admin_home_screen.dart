import 'package:flutter/material.dart';
import 'package:ms/screens/select_video_screen.dart';
import 'package:ms/screens/video_screen.dart';
import 'upload_video_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("لوحة تحكم الأدمن"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Colors.teal),
            const SizedBox(height: 30),
            _buildButton(
              context,
              title: "📤 رفع فيديو جديد",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadVideoScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              title: "🎥 مشاهدة الفيديو الحالي",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              title: "✅ اختيار الفيديو المعروض",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectVideoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String title, required VoidCallback onPressed}) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: size.width * 0.045),
        ),
      ),
    );
  }
}
