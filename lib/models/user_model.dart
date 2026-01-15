// Database-ready User model
import 'membership_model.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final Membership membership;
  final DateTime createdAt;
  final bool isAdmin;
  final bool isAgent;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membership,
    required this.createdAt,
    this.isAdmin = false,
    this.isAgent = false,
  });

  // Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'membership': membership.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isAdmin': isAdmin,
      'isAgent': isAgent,
    };
  }

  // Create from JSON (database)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      membership: Membership.fromJson(json['membership'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAdmin: json['isAdmin'] as bool? ?? false,
      isAgent: json['isAgent'] as bool? ?? false,
    );
  }
}
