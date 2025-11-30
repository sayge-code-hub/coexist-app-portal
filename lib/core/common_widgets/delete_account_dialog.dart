import 'package:coexist_app_portal/core/utils/navigation_utils.dart';
import 'package:coexist_app_portal/features/auth/data/services/account_service.dart';
import 'package:flutter/material.dart';

Future<void> showDeleteAccountDialog(
  BuildContext context,
  String userId,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete your account?'),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone and all your data will be permanently removed.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);

              try {
                // Show loading indicator
                showDialog(
                  context: dialogContext,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Deleting account...'),
                        ],
                      ),
                    );
                  },
                );

                final success = await AccountService.deleteAccount(userId);

                // Close loading dialog
                if (navigator.mounted) {
                  navigator.pop();
                }

                if (success) {
                  await NavigationUtils.clearAllAndNavigateToLogin(
                    dialogContext,
                  );
                } else {
                  if (dialogContext.mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to delete account. Please try again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    navigator.pop();
                  }
                }
              } catch (e) {
                // Close loading dialog if still open
                if (navigator.mounted) {
                  navigator.pop();
                }

                if (dialogContext.mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  navigator.pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      );
    },
  );
}
