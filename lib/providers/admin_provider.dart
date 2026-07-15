// lib/providers/admin_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5000/api/admin';
  Map<String, dynamic>? _metricsCache;
  bool _isLoading = false;

  Map<String, dynamic>? get metricsCache => _metricsCache;
  bool get isLoading => _isLoading;

  Future<void> fetchGlobalMetrics(String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('TOKEN: $authToken');
      print('URL: $_baseUrl/dashboard');

      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _metricsCache = decoded['metrics'];

        print('METRICS LOADED: $_metricsCache');
      }
    } catch (e) {
      debugPrint("Admin Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}