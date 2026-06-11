// lib/models/ai_insight_model.dart
class AiInsight {
  final String studentId;
  final double currentAttendanceRate;
  final double predictedAttendance;
  final int academicScore;
  final bool hasPendingFees;
  final String riskLevel;
  final String recommendation;

  AiInsight({
    required this.studentId,
    required this.currentAttendanceRate,
    required this.predictedAttendance,
    required this.academicScore,
    required this.hasPendingFees,
    required this.riskLevel,
    required this.recommendation,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    final data = json['analytics'];
    return AiInsight(
      studentId: data['student'] ?? '',
      currentAttendanceRate: (data['currentAttendanceRate'] as num).toDouble(),
      predictedAttendance: (data['predictedSemesterEndAttendance'] as num).toDouble(),
      academicScore: data['academicPerformanceScore'] ?? 0,
      hasPendingFees: data['hasPendingFees'] ?? false,
      riskLevel: data['riskLevel'] ?? 'Low',
      recommendation: data['recommendationText'] ?? '',
    );
  }
}