import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/widgets/signup_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0, // Remove shadow from AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add the logo image above the form
              Image.asset(
                'assets/images/logo.png',
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(
                  height: 24), // Add spacing between the image and the form
              const SignUpForm(),
            ],
          ),
        ),
      ),
    );
  }
}
