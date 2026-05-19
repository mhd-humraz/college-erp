// lib/models/assignment_model.dart

class Assignment {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String? dueDate;       // Optional: if backend tracks due dates
  final String? department;    // Optional: if assigned to specific dept
  final String? semester;      // Optional: if assigned to specific semester
  final String? teacherId;     // Who uploaded it
  final String? fileUrl;       // If a file was attached
  final DateTime? createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    this.dueDate,
    this.department,
    this.semester,
    this.teacherId,
    this.fileUrl,
    this.createdAt,
  });

  /// Convert JSON from backend → Dart object
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'],
      department: json['department'],
      semester: json['semester']?.toString(),
      teacherId: json['teacherId'] ?? json['teacher']?['_id'],
      fileUrl: json['fileUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// Convert Dart object → JSON for backend POST/PUT requests
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'dueDate': dueDate,
      'department': department,
      'semester': semester,
      'teacherId': teacherId,
      'fileUrl': fileUrl,
    };
  }
}