// lib/screens/sponsor_screen.dart
import 'package:flutter/material.dart';
import 'package:ms/controllers/sponsor_controller.dart';

class SponsorScreen extends StatefulWidget {
  const SponsorScreen({super.key});

  @override
  State<SponsorScreen> createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  late final SponsorController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = SponsorController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.fetchAllBuses();
    setState(() => _loading = false);
  }

  Color getStatusColor(bool isOnline) {
    return isOnline ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("سبونسر - حالة الأتوبيسات")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.buses.length,
        itemBuilder: (context, index) {
          final bus = _controller.buses[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getStatusColor(bus.isOnline),
                child: Text(bus.busNumber),
              ),
              title: Text('أتوبيس رقم ${bus.busNumber}'),
              subtitle: Text('آخر ظهور: ${bus.lastSeen ?? "-"}'),
              trailing: Text(
                bus.isOnline ? "أونلاين" : "أوفلاين",
                style: TextStyle(
                  color: getStatusColor(bus.isOnline),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
