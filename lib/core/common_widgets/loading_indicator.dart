import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color = AppColors.primaryGreen,
    this.strokeWidth = 4,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// Full screen loading indicator with optional message
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  
  const FullScreenLoading({
    super.key,
    this.message,
    this.backgroundColor = Colors.white70,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: xxTinySpacing),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
