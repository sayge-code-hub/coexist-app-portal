import 'package:equatable/equatable.dart';

/// Model representing an authenticated user
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final DateTime? joinedAt;
  final String? role;
  final String? mobileNumber;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
    this.lastSignInAt,
    this.joinedAt,
    this.role,
    this.mobileNumber,
    this.metadata,
  });

  /// Create a UserModel from Supabase User data
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      lastSignInAt: data['last_sign_in_at'] != null
          ? DateTime.parse(data['last_sign_in_at'])
          : null,
      joinedAt: data['joined_at'] != null
          ? DateTime.parse(data['joined_at'])
          : null,
      role: data['role'] ?? 'user',
      mobileNumber: data['mobile_number'],
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
      'joined_at': joinedAt?.toIso8601String(),
      'role': role,
      'mobile_number': mobileNumber,
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
      joinedAt: map['joined_at'] != null
          ? DateTime.parse(map['joined_at'])
          : null,
      role: map['role'] ?? 'user',
      mobileNumber: map['mobile_number'],
      metadata: map['metadata'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    createdAt,
    lastSignInAt,
    joinedAt,
    role,
    mobileNumber,
  ];
}
