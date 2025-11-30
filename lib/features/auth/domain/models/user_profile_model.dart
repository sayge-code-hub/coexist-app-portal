import 'package:equatable/equatable.dart';

/// Model representing a user profile with additional information
class UserProfileModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime joinedAt;
  final String role;
  final String? mobileNumber;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
    this.role = 'user',
    this.mobileNumber,
  });

  /// Create a UserProfileModel from Supabase data
  factory UserProfileModel.fromSupabase(Map<String, dynamic> data) {
    return UserProfileModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      joinedAt:
          data['joined_at'] != null
              ? DateTime.parse(data['joined_at'])
              : DateTime.now(),
      role: data['role'] ?? 'user',
      mobileNumber: data['mobile_number'],
    );
  }

  /// Convert to a map for storage or API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'joined_at': joinedAt.toIso8601String(),
      'role': role,
      'mobile_number': mobileNumber,
    };
  }

  /// Create a UserProfileModel from a stored map
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      joinedAt:
          map['joined_at'] != null
              ? DateTime.parse(map['joined_at'])
              : DateTime.now(),
      role: map['role'] ?? 'user',
      mobileNumber: map['mobile_number'],
    );
  }

  /// Create a map for inserting into Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'joined_at': joinedAt.toIso8601String(),
      'role': role,
      'mobile_number': mobileNumber,
    };
  }

  /// Creates a copy of this user profile with the given fields replaced by the new values
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinedAt,
    String? role,
    String? mobileNumber,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, email, joinedAt, role, mobileNumber];
}
