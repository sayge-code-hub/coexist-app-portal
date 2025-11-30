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

class RegisterPageForm extends StatefulWidget {
  const RegisterPageForm({
    super.key,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.firstNameController,
    required this.lastNameController,
    required this.mobileNumberController,
  });

  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController mobileNumberController;
  @override
  State<RegisterPageForm> createState() => _RegisterPageFormState();
}

class _RegisterPageFormState extends State<RegisterPageForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  void _register() {
    setState(() {
      _showTermsError = !_acceptedTerms;
    });
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      final credentials = AuthCredentials(
        email: widget.emailController.text,
        password: widget.passwordController.text,
        name:
            '${widget.firstNameController.text} ${widget.lastNameController.text}',
        mobileNumber: widget.mobileNumberController.text.isNotEmpty
            ? widget.mobileNumberController.text
            : null,
      );

      context.read<AuthBloc>().add(RegisterEvent(credentials: credentials));
    }
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
              'Start Your Journey to a greener tomorrow.',
              style: AppTextStyles.h1.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
              ),
            ),
            SizedBox(height: size.height * 0.025),
            AppTextField(
              hint: 'First name',
              controller: widget.firstNameController,
              validator: Validators.validateName,
              enabled: !widget.isLoading,
            ),
            SizedBox(height: size.height * 0.018),
            AppTextField(
              hint: 'Last Name',
              controller: widget.lastNameController,
              validator: Validators.validateName,
              enabled: !widget.isLoading,
            ),
            SizedBox(height: size.height * 0.018),
            AppTextField(
              hint: 'Email',
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              enabled: !widget.isLoading,
            ),
            SizedBox(height: size.height * 0.018),
            AppTextField(
              hint: 'Phone Number',
              controller: widget.mobileNumberController,
              keyboardType: TextInputType.phone,
              enabled: !widget.isLoading,
              validator: Validators.validatePhone,
            ),
            SizedBox(height: size.height * 0.018),
            AppTextField(
              hint: 'Create Password',
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
            SizedBox(height: size.height * 0.02),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: widget.isLoading
                      ? null
                      : (bool? value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                            _showTermsError = false;
                          });
                        },
                  activeColor: AppColors.primaryGreen,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.isLoading
                        ? null
                        : () {
                            setState(() {
                              _acceptedTerms = !_acceptedTerms;
                              _showTermsError = false;
                            });
                          },
                    child: Text(
                      'I agree to the Terms and Conditions and Privacy Policy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _showTermsError
                            ? AppColors.error
                            : AppColors.neutralTextGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showTermsError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'You must accept the terms and conditions to continue',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            SizedBox(height: size.height * 0.02),
            AppButton(
              text: 'Register',
              onPressed: widget.isLoading ? () {} : _register,
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
