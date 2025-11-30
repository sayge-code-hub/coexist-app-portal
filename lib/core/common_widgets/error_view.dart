import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Error view widget for displaying errors
class ErrorView extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(topBottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: xLargestSpacing, color: AppColors.error),
            const SizedBox(height: xxTinySpacing),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && buttonText != null) ...[
              const SizedBox(height: smallestSpacing),
              AppButton(
                text: buttonText!,
                onPressed: onRetry!,
                isFullWidth: false,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error view
class NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message:
          'No internet connection. Please check your network settings and try again.',
      buttonText: 'Retry',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

/// Empty state view
class EmptyStateView extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateView({
    super.key,
    required this.message,
    this.buttonText,
    this.onAction,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(topBottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: xLargestSpacing,
              color: AppColors.neutralDarkerGrey,
            ),
            const SizedBox(height: xxTinySpacing),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onAction != null && buttonText != null) ...[
              const SizedBox(height: smallestSpacing),
              AppButton(
                text: buttonText!,
                onPressed: onAction!,
                isFullWidth: false,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
