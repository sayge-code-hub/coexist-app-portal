import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/auth_credentials.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository using Supabase
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final AuthLocalDatasource _localDatasource;
  final UserProfileRepository _userProfileRepository;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AuthLocalDatasource localDatasource,
    required UserProfileRepository userProfileRepository,
  }) : _supabaseClient = supabaseClient,
       _localDatasource = localDatasource,
       _userProfileRepository = userProfileRepository;

  @override
  Future<AuthResult> register(AuthCredentials credentials) async {
    print(
      '🔍 REGISTER: Attempting to register user with email: ${credentials.email}',
    );
    try {
      // If mobile number is provided, ensure it is unique in users table
      final mobile = credentials.mobileNumber?.trim();
      if (mobile != null && mobile.isNotEmpty) {
        final existingByMobile = await _userProfileRepository
            .getUserProfileByMobile(mobile);
        if (existingByMobile != null) {
          print('❌ REGISTER: Mobile number already exists: $mobile');
          return AuthResult(
            errorMessage:
                'This mobile number is already registered. Please use a different number.',
          );
        }
      }

      final response = await _supabaseClient.auth.signUp(
        email: credentials.email,
        password: credentials.password,
        data: credentials.name != null ? {'name': credentials.name} : null,
      );

      print(
        '✅ REGISTER RESPONSE: User: ${response.user != null}, Session: ${response.session != null}',
      );

      // Check if email verification is required
      if (response.session == null && response.user != null) {
        print('📧 REGISTER: Email verification required');
        return AuthResult(requiresEmailVerification: true);
      }

      // If we have a session, the user is authenticated
      if (response.session != null && response.user != null) {
        print('🔓 REGISTER: User authenticated successfully');
        final userModel = UserModel.fromSupabase(response.user!.toJson());
        await _localDatasource.saveUser(userModel);

        // Create and save user profile
        final userProfile = UserProfileModel(
          id: userModel.id,
          name: credentials.name ?? '',
          email: userModel.email,
          joinedAt: DateTime.now(),
          mobileNumber: credentials.mobileNumber,
        );

        final savedProfile = await _userProfileRepository.saveUserProfile(
          userProfile,
        );
        print(
          '📝 REGISTER: User profile saved: ${savedProfile != null ? 'success' : 'failed'}',
        );

        return AuthResult(
          user: userModel,
          userProfile: savedProfile,
          isNewUser: true,
        );
      }

      print('❌ REGISTER: Registration failed with unknown reason');
      return AuthResult(errorMessage: 'Registration failed. Please try again.');
    } on AuthException catch (e) {
      print('❌ REGISTER ERROR: ${e.message}');
      // Format the error message to be more user-friendly
      String errorMessage = e.message;
      if (errorMessage.contains('already registered')) {
        errorMessage =
            'This email is already registered. Please use a different email or try logging in.';
      } else if (errorMessage.contains('password')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      }
      return AuthResult(errorMessage: errorMessage);
    } catch (e) {
      print('❌ REGISTER ERROR: ${e.toString()}');
      return AuthResult(
        errorMessage:
            'An error occurred during registration. Please try again.',
      );
    }
  }

  @override
  Future<AuthResult> login(AuthCredentials credentials) async {
    print(
      '🔍 LOGIN: Attempting to login user with email: ${credentials.email}',
    );
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      print(
        '✅ LOGIN RESPONSE: User: ${response.user != null}, Session: ${response.session != null}',
      );

      if (response.session != null && response.user != null) {
        print('🔓 LOGIN: User authenticated successfully');
        final userModel = UserModel.fromSupabase(response.user!.toJson());
        await _localDatasource.saveUser(userModel);

        // Fetch user profile
        final userProfile = await _userProfileRepository.getUserProfileById(
          userModel.id,
        );

        // Portal restriction: only allow users whose role is not 'user'
        final role = (userProfile?.role ?? 'user').toLowerCase();
        if (role == 'user') {
          // Deny portal access for plain users. Clean up local cache and sign out.
          try {
            await _supabaseClient.auth.signOut();
          } catch (_) {}
          await _localDatasource.clearUser();
          await _localDatasource.clearUserProfile();
          print('🚫 LOGIN: Access denied for user with role="$role"');
          return AuthResult(
            errorMessage: 'Access denied: portal access is restricted.',
          );
        }

        if (userProfile != null) {
          print('📝 LOGIN: User profile fetched successfully');
        } else {
          print('⚠️ LOGIN: User profile not found, creating a new one');
          // Create a new profile if not found
          final newProfile = UserProfileModel(
            id: userModel.id,
            name: userModel.name ?? '',
            email: userModel.email,
            joinedAt: DateTime.now(),
            mobileNumber: null, // No mobile number available during login
          );
          await _userProfileRepository.saveUserProfile(newProfile);
        }

        return AuthResult(user: userModel, userProfile: userProfile);
      }

      print('❌ LOGIN: Login failed with unknown reason');
      return AuthResult(errorMessage: 'Invalid login credentials');
    } on AuthException catch (e) {
      print('❌ LOGIN ERROR: ${e.message}');
      // Format the error message to be more user-friendly
      String errorMessage = e.message;
      if (errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (errorMessage.contains('Email not confirmed')) {
        errorMessage = 'Please verify your email before logging in.';
      }
      return AuthResult(errorMessage: errorMessage);
    } catch (e) {
      print('❌ LOGIN ERROR: ${e.toString()}');
      return AuthResult(errorMessage: 'An error occurred. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    print('🔍 LOGOUT: Attempting to logout user');
    try {
      await _supabaseClient.auth.signOut();
      await _localDatasource.clearUser();
      await _localDatasource.clearUserProfile();
      print('✅ LOGOUT: User logged out successfully');
    } catch (e) {
      print('❌ LOGOUT ERROR: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    print('🔍 GET CURRENT USER: Checking for current user');
    try {
      // First check if we have a cached user
      final cachedUser = await _localDatasource.getUser();

      // If we have a cached user, verify with Supabase that the session is still valid
      if (cachedUser != null) {
        print('📋 GET CURRENT USER: Found cached user: ${cachedUser.email}');
        print('GET CURRENT USER: Found cached user: ${cachedUser.id}');
        final currentUser = _supabaseClient.auth.currentUser;
        if (currentUser != null) {
          print('✅ GET CURRENT USER: Session is valid');
          return cachedUser;
        } else {
          // If the session is no longer valid, clear the cached user
          print(
            '⚠️ GET CURRENT USER: Session is invalid, clearing cached user',
          );
          await _localDatasource.clearUser();
          return null;
        }
      }

      // If no cached user, check if we have a current session
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser != null) {
        print(
          '🔄 GET CURRENT USER: Found Supabase session, creating cached user',
        );
        final userModel = UserModel.fromSupabase(currentUser.toJson());
        await _localDatasource.saveUser(userModel);
        return userModel;
      }

      print('❌ GET CURRENT USER: No user found');
      return null;
    } catch (e) {
      print('❌ GET CURRENT USER ERROR: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<bool> resendVerificationEmail(String email) async {
    print(
      '🔍 RESEND VERIFICATION: Attempting to resend verification email to: $email',
    );
    try {
      await _supabaseClient.auth.resend(type: OtpType.signup, email: email);
      print('✅ RESEND VERIFICATION: Verification email resent successfully');
      return true;
    } catch (e) {
      print('❌ RESEND VERIFICATION ERROR: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<void> saveEmailVerificationStatus(String email) async {
    print('📝 SAVING EMAIL VERIFICATION STATUS: $email');
    await _localDatasource.saveEmailVerificationStatus(email);
  }

  @override
  Future<String?> getEmailVerificationStatus() async {
    final email = await _localDatasource.getEmailVerificationStatus();
    print('🔍 GETTING EMAIL VERIFICATION STATUS: $email');
    return email;
  }

  @override
  Future<void> clearEmailVerificationStatus() async {
    print('🗑️ CLEARING EMAIL VERIFICATION STATUS');
    await _localDatasource.clearEmailVerificationStatus();
  }

  @override
  Future<bool> checkEmailVerified(String email) async {
    print('🔍 CHECKING IF EMAIL IS VERIFIED: $email');
    try {
      // Try to sign in with password to check if it's verified
      // This is a simplified check - in a real app, you might want to use a more robust method
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: 'dummy_password', // This will fail, but that's expected
      );

      // If we get here without an exception, the email is verified
      print('✅ EMAIL VERIFICATION CHECK: Verified');
      return true;
    } on AuthException catch (e) {
      // If the error is about invalid credentials, the email exists but password is wrong
      // This means the email is verified
      if (e.message.contains('Invalid login credentials')) {
        print('✅ EMAIL VERIFICATION CHECK: Verified (invalid password)');
        return true;
      }

      // If the error is about email not confirmed, the email is not verified
      if (e.message.contains('Email not confirmed')) {
        print('❌ EMAIL VERIFICATION CHECK: Not verified');
        return false;
      }

      print('❌ EMAIL VERIFICATION CHECK ERROR: ${e.message}');
      return false;
    } catch (e) {
      print('❌ EMAIL VERIFICATION CHECK ERROR: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<UserProfileModel?> getUserProfileFromCache() async {
    return await _localDatasource.getUserProfile();
  }

  @override
  Future<UserProfileModel?> updateProfile({
    required String userId,
    required String name,
    String? mobileNumber,
  }) async {
    try {
      // Get the current user profile
      final currentProfile = await _userProfileRepository.getUserProfileById(
        userId,
      );

      if (currentProfile == null) {
        // If no profile exists, create a new one
        final newProfile = UserProfileModel(
          id: userId,
          name: name,
          email: _supabaseClient.auth.currentUser?.email ?? '',
          joinedAt: DateTime.now(),
          mobileNumber: mobileNumber,
        );
        return await _userProfileRepository.saveUserProfile(newProfile);
      } else {
        // Update existing profile
        final updatedProfile = currentProfile.copyWith(
          name: name,
          mobileNumber: mobileNumber,
        );
        return await _userProfileRepository.updateUserProfile(updatedProfile);
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }
}
