import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// API client for handling network requests
class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio) {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectionTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'apikey': AppConstants.apiKey,
    };
    
    // Add interceptors for logging, error handling, etc.
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  /// Add auth token to headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// Remove auth token from headers
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  /// GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }
  
  /// POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }
  
  /// PUT request
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }
  
  /// DELETE request
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }
  
  /// Handle Dio errors
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: 'Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          throw AuthException(message: 'Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw AuthException(message: 'Access forbidden.');
        } else if (statusCode == 404) {
          throw ServerException(message: 'Resource not found.');
        } else if (statusCode == 422) {
          final message = responseData?['message'] ?? 'Validation error.';
          throw ValidationException(message: message);
        } else {
          final message = responseData?['message'] ?? 'Server error.';
          throw ServerException(message: message);
        }
      
      case DioExceptionType.cancel:
        throw NetworkException(message: 'Request cancelled.');
      
      case DioExceptionType.unknown:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          throw NetworkException(message: 'No internet connection.');
        }
        throw ServerException(message: 'An unexpected error occurred.');
        
      default:
        throw ServerException(message: 'An unexpected error occurred.');
    }
  }
}
