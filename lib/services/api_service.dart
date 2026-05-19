
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
  // TOKEN
  // ==============================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  // ==============================
  // CURRENT USER
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


  // ==============================
  // USERS
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
  // GENERIC GET
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
  // GENERIC POST
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
  // GENERIC PUT
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
  // GENERIC DELETE
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
  // LOGOUT
  // ==============================

  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('user');
  }


  // ==============================
  // CHECK LOGIN
  // ==============================

  static Future<bool> isLoggedIn() async {

    final token = await getToken();

    return token != null;
  }


  // ==============================
  // RESPONSE HANDLER
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

