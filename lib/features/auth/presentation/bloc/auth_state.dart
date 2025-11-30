import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_profile_model.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class Authenticated extends AuthState {
  final UserModel user;
  final UserProfileModel? userProfile;
  final bool isNewUser;
  final bool isLoading;
  final String? error;

  const Authenticated({
    required this.user,
    this.userProfile,
    this.isNewUser = false,
    this.isLoading = false,
    this.error,
  });

  /// Creates a copy of this state with the given fields replaced by the new values
  Authenticated copyWith({
    UserModel? user,
    UserProfileModel? userProfile,
    bool? isNewUser,
    bool? hasCompletedCalculation,
    bool? isLoading,
    String? error,
  }) {
    return Authenticated(
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      isNewUser: isNewUser ?? this.isNewUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    user,
    userProfile,
    isNewUser,
    isLoading,
    error,
  ];
  
  /// Returns a copy of this state with the given fields replaced by the new values
  Authenticated withLoading(bool isLoading) => copyWith(isLoading: isLoading);
  
  /// Returns a copy of this state with the error message set
  Authenticated withError(String? error) => copyWith(error: error);
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication fails
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when email verification is required
class EmailVerificationRequired extends AuthState {
  final String email;

  const EmailVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}
