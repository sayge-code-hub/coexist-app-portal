import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_profile_model.dart';

/// Interface for local authentication data operations
abstract class AuthLocalDatasource {
  /// Save user data to local storage
  Future<void> saveUser(UserModel user);

  /// Get user data from local storage
  Future<UserModel?> getUser();

  /// Clear user data from local storage
  Future<void> clearUser();

  /// Save email verification status
  Future<void> saveEmailVerificationStatus(String email);

  /// Get email that needs verification
  Future<String?> getEmailVerificationStatus();

  /// Clear email verification status
  Future<void> clearEmailVerificationStatus();

  /// Save user profile data to local storage
  Future<void> saveUserProfile(UserProfileModel userProfile);

  /// Get user profile data from local storage
  Future<UserProfileModel?> getUserProfile();

  /// Clear user profile data from local storage
  Future<void> clearUserProfile();
}

/// Implementation of AuthLocalDatasource using SharedPreferences
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences _sharedPreferences;
  static const String _emailVerificationKey = 'email_verification_status';
  static const String _userProfileKey = 'user_profile';

  AuthLocalDatasourceImpl({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toMap());
    await _sharedPreferences.setString(AppConstants.userKey, userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = _sharedPreferences.getString(AppConstants.userKey);
    if (userJson == null) {
      return null;
    }

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromMap(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _sharedPreferences.remove(AppConstants.userKey);
  }

  @override
  Future<void> saveEmailVerificationStatus(String email) async {
    await _sharedPreferences.setString(_emailVerificationKey, email);
  }

  @override
  Future<String?> getEmailVerificationStatus() async {
    return _sharedPreferences.getString(_emailVerificationKey);
  }

  @override
  Future<void> clearEmailVerificationStatus() async {
    await _sharedPreferences.remove(_emailVerificationKey);
  }

  @override
  Future<void> saveUserProfile(UserProfileModel userProfile) async {
    final userProfileJson = jsonEncode(userProfile.toMap());
    await _sharedPreferences.setString(_userProfileKey, userProfileJson);
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final userProfileJson = _sharedPreferences.getString(_userProfileKey);
    if (userProfileJson == null) {
      return null;
    }

    try {
      final userProfileMap =
          jsonDecode(userProfileJson) as Map<String, dynamic>;
      return UserProfileModel.fromMap(userProfileMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserProfile() async {
    await _sharedPreferences.remove(_userProfileKey);
  }
}
