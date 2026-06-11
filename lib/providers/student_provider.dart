import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5000/api/academic';

  Map<String, dynamic>? performanceData;
  bool isLoading = false;

  Future<void> fetchPerformance(
    String studentId,
    String token,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/student/performance/$studentId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        performanceData = jsonDecode(response.body);
      }

      print(response.body);
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}