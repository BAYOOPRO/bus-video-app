// lib/controllers/sponsor_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/app_link.dart';

class BusModel {
  final String busNumber;
  final bool isOnline;
  final String? lastSeen;

  BusModel({
    required this.busNumber,
    required this.isOnline,
    this.lastSeen,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      busNumber: json['bus_number'],
      isOnline: json['is_online'] == "1" || json['is_online'] == 1,
      lastSeen: json['last_seen'],
    );
  }
}

class SponsorController extends ChangeNotifier {
  List<BusModel> buses = [];
  bool isLoading = false;

  Future<void> fetchAllBuses() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppLink.getAllBuses));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        buses = (data['buses'] as List)
            .map((item) => BusModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching buses: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
