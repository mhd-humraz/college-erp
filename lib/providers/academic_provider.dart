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
  Future<void> fetchStudentDashboard(String studentId, String token) async {
    // Skip if already loaded for this student
    if (_performanceCache != null && !_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getStudentPerformance(
        studentId: studentId,
        token: token,
      );

      // Backend returns { attendance: {...}, grades: [...] }
      // Map to the shape screens already expect inside performanceCache
      _performanceCache = {
        'attendance': data['attendance'],  // { totalSlots, presentSlots, percentage }
        'grades':     data['grades'],       // list of mark documents
      };

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

  /// Force a fresh fetch (call after submitting attendance etc.)
  void invalidateCache() {
    _performanceCache = null;
    notifyListeners();
  }
}