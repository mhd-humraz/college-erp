import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TeacherProvider extends ChangeNotifier {
  Map<String, dynamic>? teacher;

  List<dynamic> students = [];

  bool profileLoading = false;
  bool studentsLoading = false;

  String? get facultyId {
    return teacher?['id']?.toString();
  }

  Future<void> loadProfile(String token) async {
    profileLoading = true;
    notifyListeners();

    try {
      final response =
          await ApiService.getTeacherProfile(token);

      teacher = response['teacher'];

      debugPrint(
        'TEACHER PROFILE: $teacher',
      );

      debugPrint(
        'FACULTY ID: $facultyId',
      );
    } catch (e) {
      debugPrint(
        'LOAD TEACHER PROFILE ERROR: $e',
      );
    }

    profileLoading = false;
    notifyListeners();
  }

  Future<void> loadStudents(String token) async {
    studentsLoading = true;
    notifyListeners();

    try {
      final response =
          await ApiService.getStudents(token);

      students = response['students'] ?? [];

      debugPrint(
        'TEACHER STUDENTS: $students',
      );
    } catch (e) {
      debugPrint(
        'LOAD STUDENTS ERROR: $e',
      );
    }

    studentsLoading = false;
    notifyListeners();
  }
}