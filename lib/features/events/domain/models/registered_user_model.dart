import 'package:equatable/equatable.dart';
import '../../../auth/domain/models/user_model.dart';

/// Model representing a user registered for an event with their profile information
class RegisteredUserModel extends Equatable {
  final String registrationId;
  final String eventId;
  final String userId;
  final DateTime registeredAt;
  final UserModel? user;

  const RegisteredUserModel({
    required this.registrationId,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
    this.user,
  });

  /// Create a RegisteredUserModel from registration data and user profile
  factory RegisteredUserModel.fromRegistrationAndUser(
    Map<String, dynamic> registrationData,
    UserModel? user,
  ) {
    return RegisteredUserModel(
      registrationId: registrationData['id'] ?? '',
      eventId: registrationData['event_id'] ?? '',
      userId: registrationData['user_id'] ?? '',
      registeredAt: registrationData['registered_at'] != null
          ? DateTime.parse(registrationData['registered_at'])
          : DateTime.now(),
      user: user,
    );
  }

  @override
  List<Object?> get props => [
    registrationId,
    eventId,
    userId,
    registeredAt,
    user,
  ];
}
