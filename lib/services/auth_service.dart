import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:college_erp/models/user_model.dart';
import 'package:college_erp/services/api_service.dart'; // Import our custom service
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<User> login({required String email, required String password}) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await _apiService.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Login response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success']) {
        final userData = response.data['data']['user'];
        final token = response.data['data']['token'];
        
        print('🔑 Received token: ${token.substring(0, 20)}...');
        
        // ⭐ CRITICAL: Save token using our ApiService method
        await _apiService.saveToken(token);
        
        // Also save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', userData['role'] ?? 'student');
        await prefs.setString('user_id', userData['_id'] ?? userData['id'] ?? '');
        await prefs.setString('user_name', '${userData['firstName']} ${userData['lastName']}');

        print('💾 Login data saved successfully');

        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('❌ Dio Error during login: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please check if backend is running on port 5000.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Server is taking too long to respond.');
      } else if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('📝 Attempting registration for: $email');
      
      final response = await _apiService.post(
        '/api/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      print('✅ Registration response: ${response.statusCode}');

      if (response.statusCode == 201 && response.data['success']) {
        final userData = response.data['data']['user'];
        final token = response.data['data']['token'];
        
        // Save token
        await _apiService.saveToken(token);

        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      print('❌ Registration error: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final apiService = ApiService();
      await apiService.clearToken(); // Clear token   ✅ CORRECT      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      
      print('👋 User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'student';
      final userId = prefs.getString('user_id') ?? '';
      final userName = prefs.getString('user_name') ?? '';
      
      if (email.isEmpty) return null;
      
      return User(
        id: userId,
        firstName: userName.split(' ').first,
        lastName: userName.split(' ').length > 1 ? userName.split(' ').last : '',
        email: email,
        role: role,
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please start the backend server first.';
    } else if (e.response != null) {
      return e.response?.data['message'] ?? 'Server error occurred';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}