import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'social_auth_button.dart';

class SocialAuthFunction extends StatelessWidget {
  const SocialAuthFunction({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: AppColors.neutralDarkGrey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Or Sign Up with',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralTextGrey,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.neutralDarkGrey)),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialButton(
              iconPath: 'assets/icons/google.svg',
              onPressed: () {
                // Handle Google sign-in logic
              },
            ),
            const SizedBox(width: 16),
            SocialButton(
              iconPath: 'assets/icons/facebook.svg',
              onPressed: () {
                // Handle Facebook sign-in logic
              },
            ),
            const SizedBox(width: 16),
            SocialButton(
              iconPath: 'assets/icons/apple.svg',
              onPressed: () {
                // Handle Apple sign-in logic
              },
            ),
          ],
        ),
      ],
    );
  }
}
