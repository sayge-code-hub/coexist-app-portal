import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of UserProfileRepository using Supabase
class UserProfileRepositoryImpl implements UserProfileRepository {
  final SupabaseClient _supabaseClient;
  final AuthLocalDatasource _localDatasource;
  static const String _tableName = 'users';

  UserProfileRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AuthLocalDatasource localDatasource,
  }) : _supabaseClient = supabaseClient,
       _localDatasource = localDatasource;

  @override
  Future<UserProfileModel?> saveUserProfile(
    UserProfileModel userProfile,
  ) async {
    print('🔍 SAVE USER PROFILE: Saving user profile for ${userProfile.email}');
    try {
      // Check if user already exists
      final existingUser = await getUserProfileByEmail(userProfile.email);
      if (existingUser != null) {
        print('⚠️ SAVE USER PROFILE: User already exists, updating instead');
        return updateUserProfile(userProfile);
      }
      userProfile = userProfile.copyWith(role: "Admin");
      // Insert new user profile
      final response = await _supabaseClient
          .from(_tableName)
          .insert(userProfile.toSupabaseInsert())
          .select()
          .single();

      print('✅ SAVE USER PROFILE: User profile saved successfully');
      final savedProfile = UserProfileModel.fromSupabase(response);

      // Save to local cache
      await _localDatasource.saveUserProfile(savedProfile);

      return savedProfile;
    } catch (e) {
      print('❌ SAVE USER PROFILE ERROR: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> getUserProfileById(String userId) async {
    print('🔍 GET USER PROFILE BY ID: Fetching user profile for ID: $userId');
    try {
      // First check if we have a cached profile
      final cachedProfile = await _localDatasource.getUserProfile();
      if (cachedProfile != null && cachedProfile.id == userId) {
        print('📋 GET USER PROFILE BY ID: Found cached profile');
        return cachedProfile;
      }

      // Fetch from Supabase
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      print('✅ GET USER PROFILE BY ID: User profile fetched successfully');
      final userProfile = UserProfileModel.fromSupabase(response);

      // Save to local cache
      await _localDatasource.saveUserProfile(userProfile);

      return userProfile;
    } catch (e) {
      print('❌ GET USER PROFILE BY ID ERROR: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> getUserProfileByEmail(String email) async {
    print(
      '🔍 GET USER PROFILE BY EMAIL: Fetching user profile for email: $email',
    );
    try {
      // First check if we have a cached profile
      final cachedProfile = await _localDatasource.getUserProfile();
      if (cachedProfile != null && cachedProfile.email == email) {
        print('📋 GET USER PROFILE BY EMAIL: Found cached profile');
        return cachedProfile;
      }

      // Fetch from Supabase
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        print('⚠️ GET USER PROFILE BY EMAIL: No user found with email: $email');
        return null;
      }

      print('✅ GET USER PROFILE BY EMAIL: User profile fetched successfully');
      final userProfile = UserProfileModel.fromSupabase(response);

      // Save to local cache
      await _localDatasource.saveUserProfile(userProfile);

      return userProfile;
    } catch (e) {
      print('❌ GET USER PROFILE BY EMAIL ERROR: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> getUserProfileByMobile(String mobileNumber) async {
    print(
      '🔍 GET USER PROFILE BY MOBILE: Fetching user profile for mobile: $mobileNumber',
    );
    try {
      // First check if we have a cached profile
      final cachedProfile = await _localDatasource.getUserProfile();
      if (cachedProfile != null && cachedProfile.mobileNumber == mobileNumber) {
        print('📋 GET USER PROFILE BY MOBILE: Found cached profile');
        return cachedProfile;
      }

      // Fetch from Supabase
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('mobile_number', mobileNumber)
          .maybeSingle();

      if (response == null) {
        print(
          '⚠️ GET USER PROFILE BY MOBILE: No user found with mobile: $mobileNumber',
        );
        return null;
      }

      print('✅ GET USER PROFILE BY MOBILE: User profile fetched successfully');
      final userProfile = UserProfileModel.fromSupabase(response);

      // Save to local cache
      await _localDatasource.saveUserProfile(userProfile);

      return userProfile;
    } catch (e) {
      print('❌ GET USER PROFILE BY MOBILE ERROR: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> updateUserProfile(
    UserProfileModel userProfile,
  ) async {
    print(
      '🔍 UPDATE USER PROFILE: Updating user profile for ${userProfile.email}',
    );
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .update(userProfile.toSupabaseInsert())
          .eq('id', userProfile.id)
          .select()
          .single();

      print('✅ UPDATE USER PROFILE: User profile updated successfully');
      final updatedProfile = UserProfileModel.fromSupabase(response);

      // Update local cache
      await _localDatasource.saveUserProfile(updatedProfile);

      return updatedProfile;
    } catch (e) {
      print('❌ UPDATE USER PROFILE ERROR: ${e.toString()}');
      return null;
    }
  }
}
