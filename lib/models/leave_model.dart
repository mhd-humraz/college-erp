class LeaveRequest {
  final String id;
  final String applicantName;
  final String applicantRole;
  final String approverRole;
  final String department;
  final String? semester;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;

  LeaveRequest({
    required this.id,
    required this.applicantName,
    required this.applicantRole,
    required this.approverRole,
    required this.department,
    this.semester,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['_id'] ?? '',
      applicantName: json['applicant'] is Map 
          ? json['applicant']['name'] ?? 'Unknown' 
          : 'Unknown',
      applicantRole: json['applicantRole'] ?? '',
      approverRole: json['approverRole'] ?? '',
      department: json['department'] ?? '',
      semester: json['semester']?.toString(),
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }
}