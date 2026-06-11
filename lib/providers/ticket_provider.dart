// lib/providers/ticket_provider.dart
//
// POST /api/tickets/raise
// GET  /api/tickets/list
// Consumed by: raise_ticket_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  bool _isSubmitting = false;
  String? _error;
  List<dynamic> _tickets = [];

  bool            get isSubmitting => _isSubmitting;
  String?         get error        => _error;
  List<dynamic>   get tickets      => _tickets;

  /// Returns true on success.
  Future<bool> raiseNewTicket(
    String title,
    String category,
    String description,
    String token,
  ) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.raiseTicket(
        token: token,
        title: title,
        category: category,
        description: description,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTickets(String token) async {
    try {
      _tickets = await ApiService.getTickets(token: token);
      notifyListeners();
    } catch (_) {}
  }
}