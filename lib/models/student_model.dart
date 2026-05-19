// lib/models/student_model.dart

class Student {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String guardianPhone;
  final String department;
  final String semester;
  final String batch;
  final String studentId;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.guardianPhone = '',
    required this.department,
    required this.semester,
    this.batch = '',
    required this.studentId,
  });

  /// Convert JSON from backend → Dart object
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      guardianPhone: json['guardianPhone'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester']?.toString() ?? '',
      batch: json['batch'] ?? '',
      studentId: json['studentId'] ?? '',
    );
  }

  /// Convert Dart object → JSON for backend
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'guardianPhone': guardianPhone,
      'department': department,
      'semester': semester,
      'batch': batch,
      'studentId': studentId,
    };
  }
}