import '../../../../di/injection_container.dart' as di;
import '../../../../core/network/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/models/auth_credentials.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_text_field.dart';
import '../../../../core/utils/app_router.dart';
import 'package:go_router/go_router.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({
    super.key,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
  });

  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _login() {
    _performLogin();
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final isConnected = await di.sl<NetworkInfo>().isConnected;
    if (!isConnected) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No Internet Connection')));
      }
      return;
    }

    final credentials = AuthCredentials(
      email: widget.emailController.text.trim(),
      password: widget.passwordController.text,
    );
    context.read<AuthBloc>().add(LoginEvent(credentials: credentials));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.01,
          vertical: size.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login to\ncontinue your impact!',
              style: AppTextStyles.h1.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
              ),
            ),
            SizedBox(height: size.height * 0.025),
            AppTextField(
              hint: 'Enter your email',
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              enabled: !widget.isLoading,
            ),
            SizedBox(height: size.height * 0.018),
            AppTextField(
              hint: 'Enter your password',
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              enabled: !widget.isLoading,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.neutralDarkerGrey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () => context.go(AppRoutes.forgotPassword),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.neutralTextGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            AppButton(
              text: 'Login',
              onPressed: widget.isLoading ? () {} : _login,
              isLoading: widget.isLoading,
              type: ButtonType.primary,
              size: ButtonSize.large,
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}
