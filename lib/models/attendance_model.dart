// lib/models/attendance_model.dart
class AttendanceModel {
  final String subjectName;
  final int totalSlots;
  final int presentSlots;
  final double percentage;

  AttendanceModel({
    required this.subjectName,
    required this.totalSlots,
    required this.presentSlots,
    required this.percentage,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      subjectName: json['subjectName'] ?? '',
      totalSlots: json['totalSlots'] ?? 0,
      presentSlots: json['presentSlots'] ?? 0,
      percentage: double.parse((json['percentage'] ?? "0.0").toString()),
    );
  }
}