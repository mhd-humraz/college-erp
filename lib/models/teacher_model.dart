// lib/models/teacher_model.dart

class Teacher {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String subject;
  final String designation;
  final String teacherId;
  final bool isFirstLogin;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.department,
    required this.subject,
    this.designation = '',
    required this.teacherId,
    this.isFirstLogin = false,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      subject: json['subject'] ?? '',
      designation: json['designation'] ?? '',
      teacherId: json['teacherId'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? false,
    );
  }
}