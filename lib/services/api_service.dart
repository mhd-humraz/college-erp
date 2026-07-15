// lib/services/api_service.dart
//
// CENTRAL API SERVICE — single source of truth for every backend call.
// All routes are mapped from the Express route files.
//
// Base URL is read from a const so you change it in one place:
//   • Android emulator  → http://10.0.2.2:5000
//   • iOS simulator     → http://localhost:5000
//   • Physical device   → http://<your-machine-LAN-IP>:5000
//   • Production        → https://your-deployed-api.com

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
 
class ApiService {
  // ─────────────────────────────────────────────
  // CONFIGURE BASE URL HERE
  // ─────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:5000/api';
  static const String aiV2BaseUrl = 'http://localhost:5000/api-v2';

  // ─────────────────────────────────────────────
  // INTERNAL HELPERS
  // ─────────────────────────────────────────────

  static Map<String, String> _headers({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Throws an [ApiException] when the server responds with a non-2xx status.
  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final message = body['error'] ?? body['message'] ?? 'Server error ${res.statusCode}';
    throw ApiException(message, res.statusCode);
  }

  // ─────────────────────────────────────────────
  // AUTH  →  /api/auth/*
  // ─────────────────────────────────────────────

  /// POST /api/auth/login
  /// Returns { accessToken, user: { id, email, role } }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(res);
  }

  /// PUT /api/auth/change-password
  static Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: _headers(token: token),
      body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
    );
    _parse(res);
  }

  // ─────────────────────────────────────────────
  // ACADEMIC  →  /api/academic/*
  // ─────────────────────────────────────────────

  /// GET /api/academic/student/performance/:studentId
  /// Returns { attendance: { totalSlots, presentSlots, percentage }, grades: [...] }
  static Future<Map<String, dynamic>> getStudentPerformance({
    required String studentId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/academic/student/performance/$studentId'),
      headers: _headers(token: token),
    );
    return _parse(res);
  }
  /// GET /api/academic/student/:studentId/results?semester=1
  static Future<Map<String, dynamic>> getStudentSemesterResult({
    required String studentId,
    required int semester,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/academic/student/$studentId/results?semester=$semester',
      ),
      headers: _headers(token: token),
    );

    return _parse(res);
  }
// teacher profile is a more detailed view of the teacher, used in the admin panel and for generating the PDF report. It includes academic, attendance, and portfolio data in one response.
  /// GET /api/teacher/profile
  static Future<Map<String, dynamic>>
  getTeacherProfile(String token) async {

    final response = await http.get(
      Uri.parse("$baseUrl/teacher/profile"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load teacher profile");
  }
  
 static Future<Map<String, dynamic>> getStudents(
  String token,
) async {
  final url = Uri.parse(
    "$baseUrl/teacher/students",
  );

  debugPrint("GET STUDENTS URL: $url");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  debugPrint(
    "STUDENTS STATUS: ${response.statusCode}",
  );

  debugPrint(
    "STUDENTS RESPONSE: ${response.body}",
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    "Failed to load students: "
    "${response.statusCode} ${response.body}",
  );
}

  static Future<Map<String, dynamic>> submitAttendance({
    required String token,
    required String subjectId,
    required String facultyId,
    required int hour,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/academic/attendance/submit',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subjectId': subjectId,
        'facultyId': facultyId,
        'hour': hour,
        'date': date,
        'records': records,
      }),
    );

    debugPrint(
      'ATTENDANCE STATUS: ${response.statusCode}',
    );

    debugPrint(
      'ATTENDANCE RESPONSE: ${response.body}',
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Failed to submit attendance',
    );
  }

   

  /// POST /api/academic/marks/submit   (Teacher / HOD)
  /// body: { subjectId, examType, maxMarks, scores: [{student, marksObtained}] }
  static Future<Map<String, dynamic>> submitMarks({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/academic/marks/submit'),
      headers: _headers(token: token),
      body: jsonEncode(payload),
    );
    return _parse(res);
  }

  // ─────────────────────────────────────────────
  // AI V2  →  /api/ai-v2/*
  // ─────────────────────────────────────────────

  /// GET /api/ai-v2/predictive-risk/:studentId
  /// Returns { analytics: { currentAttendanceRate, predictedSemesterEndAttendance,
  ///                         riskLevel, recommendationText, ... } }
 static Future<Map<String, dynamic>> getPredictiveRisk({
    required String studentId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$aiV2BaseUrl/predictive-risk/$studentId'),
      headers: _headers(token: token),
    );

    return _parse(res);
  }
  // ─────────────────────────────────────────────
  // TICKETS  →  /api/tickets/*
  // ─────────────────────────────────────────────

  /// POST /api/tickets/raise
  /// body: { title, category, description }
  static Future<Map<String, dynamic>> raiseTicket({
    required String token,
    required String title,
    required String category,
    required String description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tickets/raise'),
      headers: _headers(token: token),
      body: jsonEncode({'title': title, 'category': category, 'description': description}),
    );
    return _parse(res);
  }

  /// GET /api/tickets/list
  static Future<List<dynamic>> getTickets({required String token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/tickets/list'),
      headers: _headers(token: token),
    );
    final body = _parse(res);
    return body['data'] as List;
  }

  // ─────────────────────────────────────────────
  // TIMETABLE  →  /api/timetable/*
  // ─────────────────────────────────────────────

  /// GET /api/timetable/class/:courseId/:semesterNum
  static Future<List<dynamic>> getClassSchedule({
    required String courseId,
    required int semesterNum,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/timetable/class/$courseId/$semesterNum'),
      headers: _headers(token: token),
    );
    final body = _parse(res);
    return body['data'] as List;
  }

  // ─────────────────────────────────────────────
  // PORTFOLIO  →  /api/portfolio/*
  // ─────────────────────────────────────────────

  /// GET /api/portfolio/summary/:studentId
  static Future<Map<String, dynamic>> getPortfolioSummary({
    required String studentId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/portfolio/summary/$studentId'),
      headers: _headers(token: token),
    );
    final body = _parse(res);
    return body['summary'] as Map<String, dynamic>;
  }
  /// student profile is a more detailed view of the student, used in the admin panel and for generating the PDF report. It includes academic, attendance, and portfolio data in one response.
   /// GET /api/portfolio/student-profile/:studentId
   /// Returns { profile: { name, email, course, semester, attendance: {...}, grades: [...], achievements: [...] } }
  static Future<Map<String, dynamic>> getStudentProfile({
    required String studentId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/profile/$studentId'),
      headers: _headers(token: token),
    );

    return _parse(res);
  }
 
  /// POST /api/portfolio/add
  static Future<Map<String, dynamic>> addAchievement({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portfolio/add'),
      headers: _headers(token: token),
      body: jsonEncode(payload),
    );
    return _parse(res);
  }

  static Future<void> uploadProfilePhoto({
    required File image,
    required String token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/student/upload-photo',
      ),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        image.path,
      ),
    );

    await request.send();
  }
  // ─────────────────────────────────────────────
  // FEES  →  /api/fees/*
  // ─────────────────────────────────────────────

  /// GET /api/fees/student/:studentId
  static Future<List<dynamic>> getStudentFees({
    required String studentId,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/fees/student/$studentId'),
      headers: _headers(token: token),
    );
    final body = _parse(res);
    return body['data'] as List;
  }

  // ─────────────────────────────────────────────
  // ADMIN  →  /api/admin/*
  // ─────────────────────────────────────────────

  /// GET /api/admin/dashboard
  static Future<Map<String, dynamic>> getAdminDashboard({required String token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _headers(token: token),
    );
    return _parse(res);
  }

  // ─────────────────────────────────────────────
  // AI QUERY  →  /api/ai/*
  // ─────────────────────────────────────────────

  /// POST /api/ai/ask-intelligence
  /// body: { query }
  static Future<Map<String, dynamic>> askAi({
    required String token,
    required String query,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/ai/ask-intelligence'),
      headers: _headers(token: token),
      body: jsonEncode({'query': query}),
    );
    return _parse(res);
  }
}

// ─────────────────────────────────────────────
// TYPED ERROR — catch this in providers/UI
// ─────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}