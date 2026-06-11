// lib/models/ticket_model.dart
class TicketModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String status;

  TicketModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Open',
    );
  }
}