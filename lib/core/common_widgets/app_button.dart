import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, text }

enum ButtonSize { small, medium, large }

/// Reusable button component
class AppButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconLeading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = _buildElevatedButton(context);
        break;
      case ButtonType.secondary:
        button = _buildOutlinedButton(context);
        break;
      case ButtonType.text:
        button = _buildTextButton(context);
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: AppColors.primaryGreen,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          // Changed to primary green as per user preference
          foregroundColor: Colors.transparent,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
        ),
        child: _buildButtonContent(null),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDarkGreen,
        side: const BorderSide(color: AppColors.primaryGreen),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
      ),
      child: _buildButtonContent(AppColors.primaryGreen),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: _getPadding(),
      ),
      child: _buildButtonContent(AppColors.primaryGreen),
    );
  }

  Widget _buildButtonContent(Color? textColor) {
    if (isLoading) {
      return const SizedBox(
        width: smallestSpacing,
        height: smallestSpacing,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon == null) {
      return Text(text, style: _getTextStyle(textColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconLeading
          ? [
              Icon(
                icon,
                size: _getIconSize(),
                color: textColor ?? Colors.white,
              ),
              const SizedBox(width: xxxTinierSpacing),
              Flexible(
                child: Text(
                  text,
                  style: _getTextStyle(textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          : [
              Flexible(
                child: Text(
                  text,
                  style: _getTextStyle(textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: xxxTinierSpacing),
              Icon(
                icon,
                size: _getIconSize(),
                color: textColor ?? Colors.white,
              ),
            ],
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: xxTinySpacing,
          vertical: xxxTinierSpacing,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: smallestSpacing,
          vertical: tinierSpacing,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: xxxSmallSpacing,
          vertical: xxTinySpacing,
        );
    }
  }

  TextStyle _getTextStyle(Color? textColor) {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonMedium.copyWith(
          color: textColor ?? AppColors.neutralWhite,
        );
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium.copyWith(
          color: textColor ?? AppColors.neutralWhite,
        );
      case ButtonSize.large:
        return AppTextStyles.buttonLarge.copyWith(
          color: textColor ?? AppColors.neutralWhite,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return xxTinySpacing;
      case ButtonSize.medium:
        return xxxSmallestSpacing;
      case ButtonSize.large:
        return smallestSpacing;
    }
  }
}
