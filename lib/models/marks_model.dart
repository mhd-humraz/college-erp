// lib/models/marks_model.dart

class StudentMark {
  final String studentId;
  final String studentName;
  int marks; // Mutable so the teacher can edit it in the UI

  StudentMark({
    required this.studentId,
    required this.studentName,
    required this.marks,
  });

  /// Convert JSON from backend → Dart object
  factory StudentMark.fromJson(Map<String, dynamic> json) {
    return StudentMark(
      studentId: json['studentId'] ?? json['student']?['_id'] ?? '',
      studentName: json['studentName'] ?? json['student']?['name'] ?? '',
      marks: json['marks'] ?? 0,
    );
  }

  /// Convert Dart object → JSON (for individual student records)
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'marks': marks,
    };
  }
}

class MarksEntry {
  final String subject;
  final String examName;       // e.g., "Internal 1", "Semester Exam"
  final String department;
  final String semester;
  final List<StudentMark> records;

  MarksEntry({
    required this.subject,
    required this.examName,
    required this.department,
    required this.semester,
    required this.records,
  });

  /// Convert Dart object → JSON for backend POST request
  /// This is what you will send to /api/marks/save
  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'examName': examName,
      'department': department,
      'semester': semester,
      'records': records.map((r) => r.toJson()).toList(),
    };
  }
}