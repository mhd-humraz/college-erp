import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  SharedPreferences _prefs;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _token;

  AuthProvider(this._prefs) {
    _loadUserData();
  }

  void _loadUserData() {
    final userData = _prefs.getString('user');
    _token = _prefs.getString('token');
    if (userData != null) {
      _user = jsonDecode(userData);
    }
  }

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get role => _user?['role'];
  bool get isLoggedIn => _token != null && _user != null;
  String? get departmentId => _user?['departmentId'];
  String? get classId => _user?['classId'];

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _user = data['data'];

        await _prefs.setString('token', _token!);
        await _prefs.setString('user', jsonEncode(_user));

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _prefs.remove('token');
    await _prefs.remove('user');
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final response = await ApiService.get('/auth/me');
      if (response.statusCode == 200) {
        _user = response.data['data'];
        await _prefs.setString('user', jsonEncode(_user));
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
}