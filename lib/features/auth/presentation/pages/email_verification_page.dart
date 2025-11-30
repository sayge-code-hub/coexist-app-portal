import 'package:coexist_app_portal/core/utils/app_router.dart';

import '../../../../core/network/network_info.dart';
import 'package:flutter/material.dart';
// flutter_bloc not required in this file
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/common_widgets/app_button.dart';

/// Email verification page shown after registration when verification is required
class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final isConnected = await sl<NetworkInfo>().isConnected;
      if (!isConnected) {
        setState(() {
          _isResending = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No Internet Connection')));
        return;
      }
      final authRepository = sl<AuthRepository>();
      final success = await authRepository.resendVerificationEmail(
        widget.email,
      );

      if (!mounted) return;

      setState(() {
        _isResending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Verification email resent successfully'
                : 'Failed to resend verification email. Please try again.',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isResending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: Unable to resend verification email',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(
                  Icons.mark_email_read,
                  size: 100,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification link to:',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  widget.email,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightGreen.withAlpha(
                      76,
                    ), // 0.3 * 255 = 76
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionItem(
                        '1. Check your email inbox',
                        Icons.inbox,
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionItem(
                        '2. Click the verification link in the email',
                        Icons.link,
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionItem(
                        '3. Return here to login after verification',
                        Icons.login,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Note about spam folder
                Text(
                  'If you don\'t see the email, please check your spam folder.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralDarkerGrey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Back to login button
                AppButton(
                  text: 'Back to Login',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.login),
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                ),
                const SizedBox(height: 16),

                // Resend email button
                AppButton(
                  text: 'Resend Verification Email',
                  onPressed: _isResending
                      ? () {}
                      : () => _resendVerificationEmail(),
                  isLoading: _isResending,
                  type: ButtonType.secondary,
                  size: ButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
