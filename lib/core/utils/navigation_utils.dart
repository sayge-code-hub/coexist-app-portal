import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';

class NavigationUtils {
  static Future<void> clearAllAndNavigateToLogin(BuildContext context) async {
    // Clear all shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen and remove all previous routes
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}
