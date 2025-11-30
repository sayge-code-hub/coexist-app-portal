/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'CO2 Exist';
  static const String appVersion = '1.0.0';

  // API endpoints (placeholder for future Supabase integration)
  static const String baseUrl = 'https://hvgxicauyuchtqcdmdgp.supabase.co';
  static const String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2Z3hpY2F1eXVjaHRxY2RtZGdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNTI0NDgsImV4cCI6MjA2MTgyODQ0OH0.5C6hBjilmgfFdXk5RLZi6cfQBzkdFNahEffXmda3vVA';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
