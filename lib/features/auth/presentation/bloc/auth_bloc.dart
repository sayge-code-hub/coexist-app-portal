import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../di/injection_container.dart' as di;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for handling authentication logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final prefs = di.sl<SharedPreferences>();

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<MarkFirstCalculationCompleteEvent>(_onMarkFirstCalculationComplete);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  /// Handle checking current authentication status
  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AUTH BLOC: Checking authentication status');
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        print('✅ AUTH BLOC: User is authenticated - ${user.email}');

        // Get user profile from local cache
        final userProfile = await _authRepository.getUserProfileFromCache();
        
        emit(
          Authenticated(
            user: user,
            userProfile: userProfile,
          ),
        );
      } else {
        print('❌ AUTH BLOC: User is not authenticated');
        emit(const Unauthenticated());
      }
    } catch (e) {
      print('❌ AUTH BLOC ERROR: ${e.toString()}');
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle user registration
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    print('🔄 AUTH BLOC: Processing registration');
    emit(const AuthLoading());
    try {
      final result = await _authRepository.register(event.credentials);

      if (result.requiresEmailVerification) {
        print('📧 AUTH BLOC: Email verification required');
        emit(EmailVerificationRequired(email: event.credentials.email));
      } else if (result.user != null) {
        print('✅ AUTH BLOC: Registration successful');

        emit(
          Authenticated(
            user: result.user!,
            userProfile: result.userProfile,
            isNewUser: result.isNewUser,
          ),
        );
      } else {
        print('❌ AUTH BLOC: Registration failed - ${result.errorMessage}');
        emit(AuthError(message: result.errorMessage ?? 'Registration failed'));
      }
    } catch (e) {
      print('❌ AUTH BLOC ERROR: ${e.toString()}');
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle user login
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    print('🔄 AUTH BLOC: Processing login');
    emit(const AuthLoading());
    try {
      final result = await _authRepository.login(event.credentials);

      if (result.requiresEmailVerification) {
        print('📧 AUTH BLOC: Email verification required');
        emit(EmailVerificationRequired(email: event.credentials.email));
      } else if (result.user != null) {
        print('✅ AUTH BLOC: Login successful');
        emit(
          Authenticated(
            user: result.user!,
            userProfile: result.userProfile,
            isNewUser: result.isNewUser,
          ),
        );
      } else {
        print('❌ AUTH BLOC: Login failed - ${result.errorMessage}');
        emit(AuthError(message: result.errorMessage ?? 'Login failed'));
      }
    } catch (e) {
      print('❌ AUTH BLOC ERROR: ${e.toString()}');
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle user logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    print('🔄 AUTH BLOC: Processing logout');
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      await prefs.clear();
      print('✅ AUTH BLOC: Logout successful');
      emit(const Unauthenticated());
    } catch (e) {
      print('❌ AUTH BLOC ERROR: ${e.toString()}');
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle marking the user as having completed their first calculation
  Future<void> _onMarkFirstCalculationComplete(
    MarkFirstCalculationCompleteEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(currentState.copyWith(hasCompletedCalculation: true));
    }
  }

  /// Handle updating user profile
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final updatedProfile = await _authRepository.updateProfile(
        userId: currentState.user.id,
        name: event.name,
        mobileNumber: event.mobileNumber,
      );

      if (updatedProfile != null) {
        emit(
          currentState.copyWith(userProfile: updatedProfile, isLoading: false),
        );
      } else {
        emit(currentState.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isLoading: false,
          error: 'Failed to update profile. Please try again.',
        ),
      );
      print('✅ AUTH BLOC: User is no longer marked as new');
    }
  }
}
