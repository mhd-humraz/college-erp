// lib/models/student_model.dart
class StudentModel {
  final String id;
  final String rollNumber;
  final String departmentId;
  final String courseId;
  final int currentSemester;

  StudentModel({
    required this.id,
    required this.rollNumber,
    required this.departmentId,
    required this.courseId,
    required this.currentSemester,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      departmentId: json['department'] ?? '',
      courseId: json['course'] ?? '',
      currentSemester: json['currentSemester'] ?? 1,
    );
  }
}