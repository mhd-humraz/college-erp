// lib/providers/auth_provider.dart
//
// Wires Flutter login/logout to POST /api/auth/login.
// Persists the token with shared_preferences so sessions survive app restarts.
// All other providers read token/userId/userRole from here.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userEmail;
  String? _userRole;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────────────────
  String? get token      => _token;
  String? get userId     => _userId;
  String? get userEmail  => _userEmail;
  String? get userRole   => _userRole;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;
  bool    get isLoggedIn => _token != null;

  // ── Boot: restore persisted session ──────────────────────────────────────
  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token     = prefs.getString('auth_token');
    _userId    = prefs.getString('auth_userId');
    _userEmail = prefs.getString('auth_userEmail');
    _userRole  = prefs.getString('auth_userRole');
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  /// Returns true on success, false on failure (error is set).
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);

      _token     = data['accessToken'];
      _userId    = data['user']['id'];
      _userEmail = data['user']['email'];
      _userRole  = data['user']['role'];

      // Persist for next app launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token',     _token!);
      await prefs.setString('auth_userId',    _userId!);
      await prefs.setString('auth_userEmail', _userEmail!);
      await prefs.setString('auth_userRole',  _userRole!);

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

  // ── Logout ────────────────────────────────────────────────────────────────
  /// Named terminateSession to match existing dashboard call sites.
  Future<void> terminateSession() async {
    _token = _userId = _userEmail = _userRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}