import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late Dio _dio;
  static String? _cachedToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: "http://localhost:5000",
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🌐 API Request: ${options.method} ${options.path}');
        
        // Get token from cache or storage
        String? token = await _getToken();
        
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Auth token attached');
        } else {
          print('⚠️ No auth token available');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        print('❌ API Error: ${error.type} - ${error.message}');
        
        // Handle specific errors
        if (error.response?.statusCode == 401) {
          print('🔒 Unauthorized - Token may be expired or invalid');
          clearToken();
        }
        
        if (error.response?.statusCode == 403) {
          print('🚫 Forbidden - Insufficient permissions');
        }
        
        return handler.next(error);
      },
    ));
  }

  // Get token from cache or storage
  Future<String?> _getToken() async {
    // First check cache (faster)
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }
    
    // Then check SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        return token;
      }
    } catch (e) {
      print('❌ Error getting token: $e');
    }
    
    return null;
  }

  // Save token to storage and cache
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _cachedToken = token;
      print('💾 Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // Clear token on logout (PUBLIC method so auth_service can call it)
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _cachedToken = null;
      print('🗑️ Token cleared');
    } catch (e) {
      print('❌ Error clearing token: $e');
    }
  }

  // HTTP Methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Dio get dio => _dio;
}