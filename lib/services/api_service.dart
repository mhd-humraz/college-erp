import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // ==============================
  // BASE URL
  // ==============================

  // Windows / Flutter Web
  static const String baseUrl = 'http://localhost:3000/api';

  // Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Physical Device
  // static const String baseUrl = 'http://192.168.1.x:3000/api';


  // ==============================
  // LOGIN
  // ==============================

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'role': role,
        }),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));

        return data;

      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }

    } catch (e) {
      print('Login Error: $e');
      throw Exception('Connection error: $e');
    }
  }


  // ==============================
  // TOKEN & AUTH
  // ==============================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
  
  // Helper to get saved user directly from cache
  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }


  // ==============================
  // USERS (Existing)
  // ==============================

  static Future<List<dynamic>> getUsers() async {
    return await get('/users');
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return await post('/users', userData);
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    return await put('/users/$userId', userData);
  }

  static Future<void> deleteUser(String userId) async {
    await delete('/users/$userId');
  }


  // ==========================================================
  // TEACHER SPECIFIC ENDPOINTS (NEW)
  // ==========================================================

  // ------------------------------
  // ATTENDANCE
  // ------------------------------

  /// Get Today's Schedule for logged-in teacher
  static Future<List<dynamic>> getTodaySchedule() async {
    final response = await get('/attendance/today-schedule');
    // Assuming backend returns { data: [...] }
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  /// Get Students by Department and Semester
  static Future<List<dynamic>> getStudentsByDeptSem({
    required String department,
    required String semester,
  }) async {
    final response = await get('/attendance/students?department=$department&semester=$semester');
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  /// Save Attendance
  static Future<Map<String, dynamic>> saveAttendance(Map<String, dynamic> attendanceData) async {
    return await post('/attendance/save', attendanceData);
  }

  /// Get Attendance Overview (Low Attendance Students)
  static Future<List<dynamic>> getAttendanceOverview({
    String? department,
    String? semester,
  }) async {
    String endpoint = '/attendance/overview';
    if (department != null) endpoint += '?department=$department';
    if (semester != null) endpoint += '&semester=$semester';

    final response = await get(endpoint);
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  // ------------------------------
  // TIMETABLE
  // ------------------------------

  /// Get Timetable for teacher
  static Future<List<dynamic>> getTimetable({
    String? department,
    String? semester,
  }) async {
    String endpoint = '/timetable';
    if (department != null) endpoint += '?department=$department';
    if (semester != null) endpoint += '&semester=$semester';

    final response = await get(endpoint);
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  // ------------------------------
  // NOTIFICATIONS / ANNOUNCEMENTS
  // ------------------------------

  /// Get Notifications
  static Future<List<dynamic>> getNotifications({String? targetRole}) async {
    String endpoint = '/notifications';
    if (targetRole != null) endpoint += '?targetRole=$targetRole';

    final response = await get(endpoint);
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  /// Create Notification / Announcement
  static Future<Map<String, dynamic>> createNotification(Map<String, dynamic> notifData) async {
    return await post('/notifications', notifData);
  }

  // ------------------------------
  // STUDENTS
  // ------------------------------

  /// Get All Students (with optional filters)
  static Future<List<dynamic>> getStudents({
    String? department,
    String? semester,
  }) async {
    String endpoint = '/students';
    List<String> params = [];
    if (department != null) params.add('department=$department');
    if (semester != null) params.add('semester=$semester');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await get(endpoint);
    if (response is Map && response.containsKey('data')) {
      return response['data'] as List<dynamic>;
    }
    return response as List<dynamic>;
  }

  // ------------------------------
  // PROFILE & REPORTS
  // ------------------------------

  /// Get User Profile
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    return await put('/users/$userId', {}); // Using PUT with empty body, or change to get if backend allows
  }

  /// Update Profile
  static Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> updateData) async {
    return await put('/users/$userId', updateData);
  }

  /// Get Reports Summary (for dashboard stats)
  static Future<Map<String, dynamic>> getReportsSummary() async {
    final response = await get('/reports/summary');
    if (response is Map && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }


  // ==============================
  // GENERIC HTTP METHODS (Existing)
  // ==============================

  static Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }


  // ==============================
  // RESPONSE HANDLER
  // ==============================

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'API request failed');
    }
  }
}