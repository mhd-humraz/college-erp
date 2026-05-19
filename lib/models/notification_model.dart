// lib/models/notification_model.dart

class Notification {
  final String id;
  final String title;
  final String message;
  final String sender;
  final String targetRole;
  final DateTime date;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    this.sender = '',
    this.targetRole = 'All',
    required this.date,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      sender: json['sender']?.toString() ?? '',
      targetRole: json['targetRole'] ?? 'All',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}