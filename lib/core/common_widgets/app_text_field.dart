import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Reusable text field component
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;
  final bool enabled;
  final EdgeInsets? contentPadding;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (label != null && label!.isNotEmpty)
            ? Text(
                '$label',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              )
            : SizedBox.shrink(),
        SizedBox(height: (label == null || label!.isEmpty) ? 0 : 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onTap: onTap,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            prefixText: prefixText,
            suffixIcon: suffix,
            contentPadding:
                contentPadding ?? const EdgeInsets.all(xxTinySpacing),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
              borderSide: const BorderSide(color: AppColors.neutralDarkGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
              borderSide: const BorderSide(color: AppColors.neutralDarkGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: xxxTiniestSpacing,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: enabled ? AppColors.neutralGrey : Colors.grey.shade200,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutralDarkerGrey,
            ),
          ),
        ),
      ],
    );
  }
}
