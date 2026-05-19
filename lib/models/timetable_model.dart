// lib/models/timetable_model.dart

class TimetableEntry {
  final String subject;
  final String teacher;
  final String time;
  final String room;

  TimetableEntry({
    required this.subject,
    required this.teacher,
    required this.time,
    this.room = '',
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
    );
  }
}

class Timetable {
  final String id;
  final String department;
  final String semester;
  final Map<String, List<TimetableEntry>> schedule;

  Timetable({
    required this.id,
    required this.department,
    required this.semester,
    required this.schedule,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    Map<String, List<TimetableEntry>> scheduleMap = {};

    final scheduleJson = json['schedule'] as Map<String, dynamic>? ?? {};
    scheduleJson.forEach((day, entries) {
      scheduleMap[day] = (entries as List)
          .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return Timetable(
      id: json['_id'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester']?.toString() ?? '',
      schedule: scheduleMap,
    );
  }
}