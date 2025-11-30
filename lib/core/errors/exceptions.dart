/// Base exception class
class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  ServerException({required super.message});
}

/// Cache exception
class CacheException extends AppException {
  CacheException({required super.message});
}

/// Network exception
class NetworkException extends AppException {
  NetworkException({required super.message});
}

/// Authentication exception
class AuthException extends AppException {
  AuthException({required super.message});
}

/// Validation exception
class ValidationException extends AppException {
  ValidationException({required super.message});
}
