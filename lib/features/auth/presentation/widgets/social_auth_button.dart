import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: xxTinySpacing),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutralDarkGrey, width: 1),
            borderRadius: BorderRadius.circular(kRadius),
            color: Colors.white,
          ),
          child: SvgPicture.asset(iconPath),
        ),
      ),
    );
  }
}
