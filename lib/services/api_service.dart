import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    // ✅ CORRECT - Change TO THIS:
    baseUrl: 'http://192.168.30.5:5000/api', 
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET Request
  static Future<Response> get(String endpoint) async {
    final headers = await getAuthHeaders();
    return await _dio.get(endpoint, options: Options(headers: headers));
  }

  // POST Request
  static Future<Response> post(String endpoint, {dynamic data}) async {
    final headers = await getAuthHeaders();
    return await _dio.post(endpoint, data: data, options: Options(headers: headers));
  }

  // POST with File (for CSV upload)
  static Future<Response> postWithFile(String endpoint, String filePath) async {
    final token = await getToken();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'data.csv'),
    });
    
    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // PUT Request
  static Future<Response> put(String endpoint, {dynamic data}) async {
    final headers = await getAuthHeaders();
    return await _dio.put(endpoint, data: data, options: Options(headers: headers));
  }

  // DELETE Request
  static Future<Response> delete(String endpoint) async {
    final headers = await getAuthHeaders();
    return await _dio.delete(endpoint, options: Options(headers: headers));
  }
}