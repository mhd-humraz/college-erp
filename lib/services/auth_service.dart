import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:college_erp/models/user_model.dart';
import 'package:college_erp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // ==================== LOGIN ====================
  
  Future<User> login({required String email, required String password}) async {
    try {
      print('🔐 Attempting login for: $email');
      print('🌐 Server: http://192.168.30.5:5000');
      
      // ✅ FIXED: Removed '/api' prefix - baseUrl already includes it
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Login response status: ${response.statusCode}');
      print('📦 Response data keys: ${response.data.keys.toList()}');
      
      // Debug full response (be careful with sensitive data)
      if (kDebugMode) {
        print('📋 Full response: $response');
      }

      // ✅ FIXED: Handle multiple response formats
      if (response.statusCode == 200) {
        String token;
        Map<String, dynamic> userData;
        
        // Format 1: { success: true, data: { token: "...", user: {...} } }
        if (response.data['success'] == true && response.data['data'] != null) {
          token = response.data['data']['token'];
          userData = response.data['data']['user'] ?? response.data['data'];
        }
        // Format 2: { token: "...", user: {...} } 
        else if (response.data['token'] != null) {
          token = response.data['token'];
          userData = response.data['user'] ?? response.data;
        }
        // Format 3: Other structures
        else {
          throw Exception('Unexpected response format: ${response.data}');
        }
        
        print('🔑 Received token: ${token.substring(0, 20)}...');
        print('👤 User: ${userData['email']} (${userData['role']})');
        
        // ⭐ CRITICAL: Save token using our ApiService method
        await _apiService.saveToken(token);
        
        // Save user info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', userData['role'] ?? 'student');
        await prefs.setString('user_id', userData['_id'] ?? userData['id'] ?? '');
        
        // Handle name fields (could be firstName/lastName or just name)
        String userName;
        if (userData['firstName'] != null) {
          userName = '${userData['firstName']} ${userData['lastName'] ?? ''}'.trim();
        } else {
          userName = userData['name'] ?? email.split('@')[0];
        }
        await prefs.setString('user_name', userName);
        
        // Additional user data
        if (userData['departmentName'] != null) {
          await prefs.setString('user_department', userData['departmentName']);
        }

        print('💾 Login data saved successfully:');
        print('   - Email: $email');
        print('   - Role: ${userData['role']}');
        print('   - Name: $userName');

        return User.fromJson(userData);
      } else {
        String errorMsg = response.data['message'] ?? response.data['error'] ?? 'Login failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      print('❌ Dio Error during login:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          '❌ Cannot connect to server!\n'
          '• Is backend running?\n'
          '• URL: http://192.168.30.5:5000\n'
          '• Phone & PC on same WiFi?'
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('⏱️ Connection timeout. Server is taking too long to respond.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('⏱️ Receive timeout. Server response too slow.');
      } else if (e.response != null) {
        int? statusCode = e.response?.statusCode;
        dynamic responseData = e.response?.data;
        
        switch (statusCode) {
          case 401:
            throw Exception('🔒 Invalid email or password');
          case 404:
            throw Exception('📍 Login endpoint not found (404)');
          case 500:
            throw Exception('💥 Server error. Check backend logs.');
          default:
            String msg = responseData?['message'] 
                     ?? responseData?['error'] 
                     ?? 'Server error: $statusCode';
            throw Exception(msg);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected login error: $e');
      if (e is Exception) rethrow;
      throw Exception('Login failed: $e');
    }
  }

  // ==================== REGISTER ====================
  
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
        '/auth/register',
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

        // Save user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_role', role);
        await prefs.setString('user_id', userData['_id'] ?? '');
        await prefs.setString('user_name', '$firstName $lastName');

        print('✅ Registration successful!');
        return User.fromJson(userData);
      } else {
        String errorMsg = response.data['message'] ?? 'Registration failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      print('❌ Registration error:');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e.response?.statusCode == 400) {
        // Validation errors
        dynamic data = e.response?.data;
        if (data is Map && data['errors'] != null) {
          List<String> errors = [];
          data['errors'].forEach((key, value) {
            errors.add(value.toString());
          });
          throw Exception(errors.join('\n'));
        }
        throw Exception(data?['message'] ?? 'Invalid registration data');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Email already registered. Try logging in instead.');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Unexpected registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // ==================== LOGOUT ====================
  
  Future<void> logout() async {
    try {
      print('👋 Logging out...');
      
      // Clear token using ApiService
      await ApiService.clearToken();
      
      // Clear all user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = [
        'user_email',
        'user_role',
        'user_id',
        'user_name',
        'user_department',
      ];
      
      for (String key in keysToRemove) {
        await prefs.remove(key);
      }
      
      print('✅ All user data cleared successfully');
      print('   Cleared keys: $keysToRemove + auth_token');
      
    } catch (e) {
      print('⚠️ Error during logout: $e');
      // Continue even if logout fails - still clear local data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}
    }
  }

  // ==================== CHECK AUTH STATUS ====================
  
  Future<bool> isLoggedIn() async {
    try {
      return await ApiService.isLoggedIn();
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // ==================== GET CURRENT USER ====================
  
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'student';
      final userId = prefs.getString('user_id') ?? '';
      final userName = prefs.getString('user_name') ?? '';
      final department = prefs.getString('user_department') ?? '';
      
      if (email.isEmpty) {
        print('⚠️ No user email found in storage');
        return null;
      }
      
      print('👤 Loading current user from storage:');
      print('   Email: $email');
      print('   Name: $userName');
      print('   Role: $role');
      
      // Parse name
      String firstName = '';
      String lastName = '';
      if (userName.contains(' ')) {
        List<String> parts = userName.split(' ');
        firstName = parts.first;
        lastName = parts.sublist(1).join(' ');
      } else {
        firstName = userName;
        lastName = '';
      }
      
      return User(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        departmentName: department,
      );
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // ==================== TOKEN REFRESH (Optional) ====================
  
  Future<bool> refreshToken() async {
    try {
      print('🔄 Attempting token refresh...');
      
      final response = await _apiService.post('/auth/refresh-token');
      
      if (response.statusCode == 200 && response.data['token'] != null) {
        String newToken = response.data['token'];
        await _apiService.saveToken(newToken);
        print('✅ Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return false;
    }
  }

  // ==================== VERIFY TOKEN (Optional) ====================
  
  Future<bool> verifyToken() async {
    try {
      print('🔍 Verifying token validity...');
      
      final response = await _apiService.get('/auth/verify-token');
      
      if (response.statusCode == 200) {
        print('✅ Token is valid');
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('⚠️ Token expired or invalid');
        return false;
      }
      print('❌ Token verification error: $e');
      return false;
    } catch (e) {
      print('❌ Unexpected verification error: $e');
      return false;
    }
  }

  // ==================== HELPER: Handle Dio Errors ====================
  
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection or server unreachable';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] 
               ?? e.response?.data['error'] 
               ?? 'Server error (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
      default:
        return 'Network error: ${e.message}';
    }
  }
}