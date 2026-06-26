// lib/providers/academic_provider.dart
//
// Calls GET /api/academic/student/performance/:studentId
// Consumed by: attendance_screen.dart, marks_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AcademicProvider extends ChangeNotifier {
  Map<String, dynamic>? _performanceCache;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get performanceCache => _performanceCache;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  /// Fetches attendance + grades for [studentId].
  /// Existing screens call this with (studentId, token).
  Future<void> fetchStudentDashboard(
    String studentId,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("STUDENT ID: $studentId");
      print("TOKEN: $token");

      final data = await ApiService.getStudentPerformance(
        studentId: studentId,
        token: token,
      );

      print("API RESPONSE:");
      print(data);

      _performanceCache = data;
    } catch (e) {
      print("ACADEMIC ERROR: $e");
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  
  /// Force a fresh fetch (call after submitting attendance etc.)
  void invalidateCache() {
    _performanceCache = null;
    notifyListeners();
  }
}