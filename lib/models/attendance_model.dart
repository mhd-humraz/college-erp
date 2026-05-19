// lib/models/attendance_model.dart

class AttendanceRecord {
  final String studentId;
  final String studentName;
  String status; // "Present" or "Absent" — mutable because teacher toggles it

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    this.status = 'Present', // Default: all present
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] ?? json['student']?['_id'] ?? '',
      studentName: json['studentName'] ?? json['student']?['name'] ?? '',
      status: json['status'] ?? 'Present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'status': status,
    };
  }
}

class TodaySchedule {
  final String subject;
  final String department;
  final String semester;
  final String time;
  final String room;
  final bool isCompleted;

  TodaySchedule({
    required this.subject,
    required this.department,
    required this.semester,
    this.time = '',
    this.room = '',
    this.isCompleted = false,
  });

  factory TodaySchedule.fromJson(Map<String, dynamic> json) {
    return TodaySchedule(
      subject: json['subject'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester']?.toString() ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class AttendanceOverview {
  final String studentId;
  final String studentName;
  final String department;
  final String semester;
  final double attendancePercentage;

  AttendanceOverview({
    required this.studentId,
    required this.studentName,
    required this.department,
    required this.semester,
    required this.attendancePercentage,
  });

  factory AttendanceOverview.fromJson(Map<String, dynamic> json) {
    return AttendanceOverview(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? json['student']?['name'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester']?.toString() ?? '',
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
    );
  }
}