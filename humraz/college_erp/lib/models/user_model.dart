class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      avatar: json['avatar'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'avatar': avatar,
      'phone': phone,
    };
  }
}