// lib/models/marks_model.dart
class MarksModel {
  final String subjectName;
  final String examType;
  final int marksObtained;
  final int maxMarks;

  MarksModel({
    required this.subjectName,
    required this.examType,
    required this.marksObtained,
    required this.maxMarks,
  });

  factory MarksModel.fromJson(Map<String, dynamic> json) {
    return MarksModel(
      subjectName: json['subject']['name'] ?? '',
      examType: json['examType'] ?? '',
      marksObtained: json['marksObtained'] ?? 0,
      maxMarks: json['maxMarks'] ?? 100,
    );
  }
}