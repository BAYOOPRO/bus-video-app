// ✅ ملف: lib/screens/enter_bus_screen.dart
import 'package:flutter/material.dart';
import 'package:ms/core/AppLink.dart';
import 'package:ms/screens/video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EnterBusScreen extends StatefulWidget {
  const EnterBusScreen({super.key});

  @override
  State<EnterBusScreen> createState() => _EnterBusScreenState();
}

class _EnterBusScreenState extends State<EnterBusScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> checkBusNumber(String busNumber) async {
    setState(() => _loading = true);

    final response = await http.post(
      Uri.parse(AppLink.checkBusNumber),
      body: {'bus_number': busNumber},
    );

    final result = response.body;
    print("📦 Response: $result");

    if (response.statusCode == 200 && result.contains('"valid":true')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bus_number', busNumber);
      print("📦 busNumber: $busNumber");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VideoScreen()),
      );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ رقم الأتوبيس غير صحيح")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ادخل رقم الأتوبيس'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus_filled, size: 80, color: Colors.teal),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'رقم الأتوبيس',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.directions_bus),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    checkBusNumber(_controller.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'دخول',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
