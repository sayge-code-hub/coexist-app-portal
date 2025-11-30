import 'package:dio/dio.dart';

class AccountService {
  static const String _baseUrl = 'https://hvgxicauyuchtqcdmdgp.functions.supabase.co';
  static const String _deleteAccountEndpoint = '/delete_account';
  static const String _authToken = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2Z3hpY2F1eXVjaHRxY2RtZGdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNTI0NDgsImV4cCI6MjA2MTgyODQ0OH0.5C6hBjilmgfFdXk5RLZi6cfQBzkdFNahEffXmda3vVA';

  static Future<bool> deleteAccount(String userId) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$_baseUrl$_deleteAccountEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': _authToken,
          },
        ),
        data: {'user_id': userId},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
