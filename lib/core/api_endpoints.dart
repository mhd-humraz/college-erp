// lib/core/api_endpoints.dart
class ApiEndpoints {
  static const String login = "/auth/login";
  static const String changePassword = "/auth/change-password";
  
  static const String studentPerformance = "/academic/student/performance";
  static const String submitAttendance = "/academic/attendance/submit";
  static const String submitMarks = "/academic/marks/submit";
  
  static const String raiseTicket = "/tickets/raise";
  static const String listTickets = "/tickets/list";
  
  static const String globalStats = "/admin/dashboard-summary";
  static const String uploadStaff = "/admin/upload-staff";
}