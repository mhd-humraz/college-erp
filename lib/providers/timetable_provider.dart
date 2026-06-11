// lib/providers/timetable_provider.dart
//
// GET /api/timetable/class/:courseId/:semesterNum
// Consumed by: timetable_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TimetableProvider extends ChangeNotifier {
  List<dynamic> _currentSchedule = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get currentSchedule => _currentSchedule;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  Future<void> fetchClassSchedule(
    String courseId,
    int semesterNum,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSchedule = await ApiService.getClassSchedule(
        courseId: courseId,
        semesterNum: semesterNum,
        token: token,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}