import 'package:flutter/foundation.dart';
import 'package:college_erp/services/auth_service.dart';
import 'package:college_erp/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final authService = AuthService();
      _user = await authService.login(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      final authService = AuthService();
      _user = await authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService().logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}