import '../models/auth_credentials.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

/// Result of an authentication operation
class AuthResult {
  final UserModel? user;
  final UserProfileModel? userProfile;
  final bool requiresEmailVerification;
  final String? errorMessage;
  final bool isNewUser;

  AuthResult({
    this.user,
    this.userProfile,
    this.requiresEmailVerification = false,
    this.errorMessage,
    this.isNewUser = false,
  });
}

/// Interface for authentication operations
abstract class AuthRepository {
  /// Register a new user
  Future<AuthResult> register(AuthCredentials credentials);

  /// Login an existing user
  Future<AuthResult> login(AuthCredentials credentials);

  /// Logout the current user
  Future<void> logout();

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Resend verification email
  Future<bool> resendVerificationEmail(String email);

  /// Save email verification status
  Future<void> saveEmailVerificationStatus(String email);

  /// Get email that needs verification
  Future<String?> getEmailVerificationStatus();

  /// Clear email verification status
  Future<void> clearEmailVerificationStatus();

  /// Check if email is verified
  Future<bool> checkEmailVerified(String email);

  /// Get user profile from local cache
  Future<UserProfileModel?> getUserProfileFromCache();

  /// Update user profile
  Future<UserProfileModel?> updateProfile({
    required String userId,
    required String name,
    String? mobileNumber,
  });
}
