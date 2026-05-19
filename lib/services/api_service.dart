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

        // Save token
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

    if (token == null) {
      throw Exception('Not authenticated');
    }

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

  static Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> userData) async {
    return await post('/users', userData);
  }

  static Future<Map<String, dynamic>> updateUser(
      String userId,
      Map<String, dynamic> userData) async {

    return await put('/users/$userId', userData);
  }

  static Future<void> deleteUser(String userId) async {
    await delete('/users/$userId');
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      return data;

    } else {

      throw Exception(
        data['message'] ?? 'API request failed',
      );
    }
  }
}