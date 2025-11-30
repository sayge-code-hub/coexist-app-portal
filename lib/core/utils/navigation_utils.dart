import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationUtils {
  static Future<void> clearAllAndNavigateToLogin(BuildContext context) async {
    // Clear all shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen and remove all previous routes
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
