import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/presentation/blocs/sign_up_bloc.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';

import '../../../../core/theme/app_colors.dart';
// Import your existing BLoC

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords don't match")),
        );
        return;
      }

      // Dispatch the sign up event to your BLoC
      context.read<SignUpBloc>().add(
            SignUpSubmitted(
              username: username,
              email: email,
              password: password,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful!"),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to login page after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 24,
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Already have an account ",
                  style: TextStyle(color: AppColors.hintTextColor),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to login screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                  child: const Text(
                    "login Here",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _InputField(
              icon: Icons.person,
              hint: "Username",
              controller: usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _InputField(
              icon: Icons.email,
              hint: "Email",
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _InputField(
              icon: Icons.lock,
              hint: "Password",
              isObscure: true,
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _InputField(
              icon: Icons.lock,
              hint: "Confirm Password",
              isObscure: true,
              controller: confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<SignUpBloc, SignUpState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is SignUpLoading
                        ? null
                        : () => _onRegister(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state is SignUpLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Or sign in with",
                    style: TextStyle(color: AppColors.hintTextColor),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.borderColor)),
              ],
            ),
            const SizedBox(height: 16),
            const _SocialIconsRow(),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isObscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _InputField({
    required this.icon,
    required this.hint,
    required this.controller,
    this.isObscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppColors.textColor),
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.iconColor),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.hintTextColor),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.iconColor, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}

class _SocialIconsRow extends StatelessWidget {
  const _SocialIconsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook, color: Colors.blue, size: 36),
          onPressed: () {
            // Handle Facebook sign in
            // context.read<SignUpBloc>().add(SignInWithFacebook());
          },
        ),
        IconButton(
          icon: const Icon(Icons.apple, color: AppColors.textColor, size: 36),
          onPressed: () {
            // Handle Apple sign in
            // context.read<SignUpBloc>().add(SignInWithApple());
          },
        ),
        IconButton(
          icon: Image.asset('assets/images/google_icon.png', width: 25),
          onPressed: () {
            // Handle Google sign in
            // context.read<SignUpBloc>().add(SignInWithGoogle());
          },
        ),
      ],
    );
  }
}
