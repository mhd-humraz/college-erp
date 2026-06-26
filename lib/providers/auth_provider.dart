import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userEmail;
  String? _userRole;
  String? _courseId;
  int? _semester;
  String? _studentId;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get token => _token;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  String? get courseId => _courseId;
  int? get semester => _semester;
  String? get studentId => _studentId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  // Restore saved session
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('auth_token');
    _userId = prefs.getString('auth_userId');
    _userEmail = prefs.getString('auth_userEmail');
    _userRole = prefs.getString('auth_userRole');
    _courseId = prefs.getString('auth_courseId');
    _semester = prefs.getInt('auth_semester');
    _studentId = prefs.getString('auth_studentId');

    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);

      _token = data['accessToken'];
      _userId = data['user']['id'];
      _userEmail = data['user']['email'];
      _userRole = data['user']['role'];
      _courseId = data['user']['courseId'];
      _semester = data['user']['semester'];
      _studentId = data['user']['studentId'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_userId', _userId!);
      await prefs.setString('auth_userEmail', _userEmail!);
      await prefs.setString('auth_userRole', _userRole!);
      if (_studentId != null) {
        await prefs.setString('auth_studentId', _studentId!);
      }

      if (_courseId != null) {
        await prefs.setString('auth_courseId', _courseId!);
      }

      if (_semester != null) {
        await prefs.setInt('auth_semester', _semester!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection failed. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> terminateSession() async {
    _token = null;
    _userId = null;
    _userEmail = null;
    _userRole = null;
    _courseId = null;
    _semester = null;
    _studentId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}