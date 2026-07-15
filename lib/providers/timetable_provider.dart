import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TimetableProvider with ChangeNotifier {

  List<dynamic> currentSchedule = [];

  bool isLoading = false;

  String? error;

  Future<void> fetchClassSchedule(
    String courseId,
    int semester,
    String token,
  ) async {

    isLoading = true;
    error = null;

    notifyListeners();

    try {

      final response = await http.get(
        Uri.parse(
          'http://localhost:5000/api/timetable/class/$courseId/$semester',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {

        final decoded =
            jsonDecode(response.body);

        currentSchedule =
            decoded['data'];

      } else {

        error =
            'Failed to load timetable';

      }

    } catch (e) {

      error = e.toString();

    }

    isLoading = false;

    notifyListeners();
  }
}