import 'package:equatable/equatable.dart';
import '../../domain/models/auth_credentials.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status
class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

/// Event to register a new user
class RegisterEvent extends AuthEvent {
  final AuthCredentials credentials;

  const RegisterEvent({required this.credentials});

  @override
  List<Object?> get props => [credentials];
}

/// Event to login an existing user
class LoginEvent extends AuthEvent {
  final AuthCredentials credentials;

  const LoginEvent({required this.credentials});

  @override
  List<Object?> get props => [credentials];
}

/// Event to logout the current user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event to mark that the user has completed their first carbon footprint calculation
class MarkFirstCalculationCompleteEvent extends AuthEvent {
  const MarkFirstCalculationCompleteEvent();
}

/// Event to update user profile information
class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String? mobileNumber;

  const UpdateProfileEvent({
    required this.name,
    this.mobileNumber,
  });

  @override
  List<Object?> get props => [name, mobileNumber];
}
