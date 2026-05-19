import 'dart:convert';
import 'dart:io';
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
  // LOGIN ✅ KEEP AS-IS
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
  // TOKEN ✅ KEEP AS-IS
  // ==============================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get headers with token (helper for new methods)
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-auth-token': token,
    };
  }


  // ==============================
  // CURRENT USER ✅ KEEP AS-IS
  // ==============================

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


  // ==========================================
  // 🆕 HOD DASHBOARD API (NEW!)
  // ==========================================

  /// Fetch all HOD Dashboard data in one call
  /// Returns: { stats, attendanceOverview, facultyMonitoring, pendingApprovals }
  static Future<Map<String, dynamic>?> fetchHODDashboard() async {
    try {
      print('📊 Fetching HOD Dashboard...');

      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/hod'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('📡 Dashboard Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('✅ Dashboard data loaded!');
          return data['data'];
        } else {
          print('❌ API returned success: false');
          return null;
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Unauthorized - Token expired');
        return null;
      } else if (response.statusCode == 403) {
        print('🚫 Forbidden - Not HOD');
        return null;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Dashboard Error: $e');
      return null;
    }
  }


  // ==========================================
  // 🆕 APPROVAL API (NEW!)
  // ==========================================

  /// Approve or Reject a leave request
  /// [requestId] - ID of the leave request
  /// [action] - 'approve' or 'reject'
  static Future<bool> processApproval({
    required String requestId,
    required String action,
  }) async {
    try {
      print('🔄 Processing $action for: $requestId');

      final response = await put('/approvals/$requestId', {
        'action': action,
      });

      if (response['success'] == true) {
        print('✅ Request ${action}d!');
        return true;
      }

      print('❌ Approval failed');
      return false;

    } catch (e) {
      print('❌ Approval Error: $e');
      return false;
    }
  }


  // ==========================================
  // 🆕 UPLOAD API (NEW!)
  // ==========================================

  /// Upload profile image
  /// Returns image URL string on success, null on failure
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final token = await getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/profile'),
      );

      request.headers['x-auth-token'] = token ?? '';
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', imageFile.path),
      );

      print('📤 Uploading profile image...');

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);

      if (result['success'] == true) {
        print('✅ Image uploaded: ${result['imageUrl']}');
        return result['imageUrl'];
      }

      print('❌ Upload failed: $result');
      return null;

    } catch (e) {
      print('❌ Upload Error: $e');
      return null;
    }
  }


  // ==============================
  // USERS ✅ KEEP AS-IS
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
  // GENERIC GET ✅ KEEP AS-IS
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


  // ==============================
  // GENERIC POST ✅ KEEP AS-IS
  // ==============================

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data) async {

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


  // ==============================
  // GENERIC PUT ✅ KEEP AS-IS
  // ==============================

  static Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> data) async {

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


  // ==============================
  // GENERIC DELETE ✅ KEEP AS-IS
  // ==============================

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
  // LOGOUT ✅ KEEP AS-IS
  // ==============================

  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('user');
  }


  // ==============================
  // CHECK LOGIN ✅ KEEP AS-IS
  // ==============================

  static Future<bool> isLoggedIn() async {

    final token = await getToken();

    return token != null;
  }


  // ==============================
  // RESPONSE HANDLER ✅ KEEP AS-IS
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