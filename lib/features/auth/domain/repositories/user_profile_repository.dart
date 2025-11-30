import '../models/user_profile_model.dart';

/// Interface for user profile operations
abstract class UserProfileRepository {
  /// Save user profile to Supabase
  Future<UserProfileModel?> saveUserProfile(UserProfileModel userProfile);
  
  /// Get user profile from Supabase by user ID
  Future<UserProfileModel?> getUserProfileById(String userId);
  
  /// Get user profile from Supabase by email
  Future<UserProfileModel?> getUserProfileByEmail(String email);

  /// Get user profile from Supabase by mobile number
  Future<UserProfileModel?> getUserProfileByMobile(String mobileNumber);
  
  /// Update user profile in Supabase
  Future<UserProfileModel?> updateUserProfile(UserProfileModel userProfile);
}
