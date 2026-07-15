// lib/providers/ai_provider.dart
//
// Calls GET /api/ai-v2/predictive-risk/:studentId
// Consumed by: student_dashboard.dart (AiRisk card)

import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Shape of the insight object returned by the backend
class AiInsightModel {
  final String currentAttendanceRate;
  final String predictedAttendance;
  final String riskLevel;
  final String recommendation;

  const AiInsightModel({
    required this.currentAttendanceRate,
    required this.predictedAttendance,
    required this.riskLevel,
    required this.recommendation,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      currentAttendanceRate: json['currentAttendanceRate']?.toString()  ?? '0',
      predictedAttendance:   json['predictedSemesterEndAttendance']?.toString() ?? '0',
      riskLevel:             json['riskLevel']    ?? 'Unknown',
      recommendation:        json['recommendationText'] ?? '',
    );
  }
}

class AiProvider extends ChangeNotifier {
  AiInsightModel? _currentInsight;
  bool _isLoading = false;
  String? _error;

  AiInsightModel? get currentInsight => _currentInsight;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  /// [studentId] is the MongoDB _id of the student document.
  /// [token] comes from AuthProvider.
  Future<void> fetchStudentPredictiveRisk(
    String studentId,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("AI STUDENT ID SENT: $studentId");

      final data = await ApiService.getPredictiveRisk(
        studentId: studentId,
        token: token,
      );

      print("AI RESPONSE:");
      print(data);

      if (data.containsKey('analytics')) {
        _currentInsight = AiInsightModel.fromJson(
          data['analytics'] as Map<String, dynamic>,
        );
      } else {
        _currentInsight = null;
        _error = data['message'] ?? 'No analytics data available';
      }
    } on ApiException catch (e) {
      _error = e.message;
      print("AI API ERROR: ${e.message}");
    } catch (e) {
      _error = 'Network error: $e';
      print("AI ERROR: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}