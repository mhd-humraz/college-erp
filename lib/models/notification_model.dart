// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'System',
      isRead: json['isRead'] ?? false,
    );
  }
}