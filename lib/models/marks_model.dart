class MarksModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final int marksObtained;
  final int maxMarks;
  final double percentage;
  final String grade;
  final String status;

  MarksModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.marksObtained,
    required this.maxMarks,
    required this.percentage,
    required this.grade,
    required this.status,
  });

  factory MarksModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarksModel(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      marksObtained:
          (json['marksObtained'] as num?)?.toInt() ?? 0,
      maxMarks:
          (json['maxMarks'] as num?)?.toInt() ?? 0,
      percentage:
          (json['percentage'] as num?)?.toDouble() ?? 0,
      grade: json['grade'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class MarksSummary {
  final int totalSubjects;
  final int passedSubjects;
  final int failedSubjects;
  final int totalObtained;
  final int totalMaximum;
  final double overallPercentage;
  final String overallStatus;

  MarksSummary({
    required this.totalSubjects,
    required this.passedSubjects,
    required this.failedSubjects,
    required this.totalObtained,
    required this.totalMaximum,
    required this.overallPercentage,
    required this.overallStatus,
  });

  factory MarksSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return MarksSummary(
      totalSubjects:
          (json['totalSubjects'] as num?)?.toInt() ?? 0,
      passedSubjects:
          (json['passedSubjects'] as num?)?.toInt() ?? 0,
      failedSubjects:
          (json['failedSubjects'] as num?)?.toInt() ?? 0,
      totalObtained:
          (json['totalObtained'] as num?)?.toInt() ?? 0,
      totalMaximum:
          (json['totalMaximum'] as num?)?.toInt() ?? 0,
      overallPercentage:
          (json['overallPercentage'] as num?)?.toDouble() ?? 0,
      overallStatus:
          json['overallStatus'] ?? 'No Result',
    );
  }
}