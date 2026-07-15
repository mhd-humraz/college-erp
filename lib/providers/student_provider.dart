import 'package:flutter/material.dart';

import '../models/marks_model.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  List<MarksModel> _semesterResults = [];

  MarksSummary? _marksSummary;

  bool _isLoading = false;

  String? _error;

  List<MarksModel> get semesterResults =>
      _semesterResults;

  MarksSummary? get marksSummary =>
      _marksSummary;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  Future<void> fetchSemesterResult({
    required String studentId,
    required int semester,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final data =
          await ApiService.getStudentSemesterResult(
        studentId: studentId,
        semester: semester,
        token: token,
      );

      final List<dynamic> resultData =
          data['results'] ?? [];

      _semesterResults = resultData
          .map(
            (item) => MarksModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      final summaryData = data['summary'];

      if (summaryData != null) {
        _marksSummary = MarksSummary.fromJson(
          Map<String, dynamic>.from(
            summaryData,
          ),
        );
      } else {
        _marksSummary = null;
      }
    } on ApiException catch (e) {
      _semesterResults = [];

      _marksSummary = null;

      _error = e.message;
    } catch (e) {
      _semesterResults = [];

      _marksSummary = null;

      _error =
          'Unable to load semester result';
    }

    _isLoading = false;

    notifyListeners();
  }

  void clearResult() {
    _semesterResults = [];

    _marksSummary = null;

    _error = null;

    notifyListeners();
  }
}