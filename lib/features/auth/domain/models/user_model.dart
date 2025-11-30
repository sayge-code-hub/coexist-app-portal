import 'package:equatable/equatable.dart';

/// Model representing an authenticated user
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
    this.lastSignInAt,
    this.metadata,
  });

  /// Create a UserModel from Supabase User data
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      name: data['user_metadata']?['name'],
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : null,
      lastSignInAt: data['last_sign_in_at'] != null 
          ? DateTime.parse(data['last_sign_in_at']) 
          : null,
      metadata: data['user_metadata'],
    );
  }

  /// Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a UserModel from a stored map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      lastSignInAt: map['last_sign_in_at'] != null 
          ? DateTime.parse(map['last_sign_in_at']) 
          : null,
      metadata: map['metadata'],
    );
  }

  @override
  List<Object?> get props => [id, email, name, createdAt, lastSignInAt];
}
