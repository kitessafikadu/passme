import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null) {
      setState(() {
        emailController.text = rememberedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', email);
    } else {
      await prefs.remove('remembered_email');
    }
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8), // Add spacing between the image and text
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png', // Replace with your image path
                height: 100, // Adjust the height as needed
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: BlocListener<LoginCubit, LoginState>(
                  listener: (context, state) async {
                    if (state.token != null) {
                      // Always save the token
                      await _saveAuthToken(state.token!);
                      // Only save email if remember me is checked
                      await _saveRememberedEmail(emailController.text);
                      Navigator.pushReplacementNamed(context, '/flights');
                    } else if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error!)),
                      );
                    }
                  },
                  child: BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign In',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "Don't have an account ",
                                style:
                                    TextStyle(color: AppColors.hintTextColor),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text(
                                  "Register Here",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            style: const TextStyle(color: AppColors.textColor),
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.email, color: AppColors.iconColor),
                              hintText: 'Email',
                              hintStyle:
                                  TextStyle(color: AppColors.hintTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.iconColor, width: 1.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primaryColor, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.5),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.textColor),
                            decoration: InputDecoration(
                              prefixIcon:
                                  Icon(Icons.lock, color: AppColors.iconColor),
                              hintText: 'Password',
                              hintStyle:
                                  TextStyle(color: AppColors.hintTextColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.iconColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.iconColor, width: 1.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primaryColor, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.5),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) {
                                      setState(() {
                                        _rememberMe = val ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primaryColor,
                                  ),
                                  const Text("Remember Me",
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text("Forget Password?",
                                    style: TextStyle(color: Colors.white70)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<LoginCubit>().login(
                                      emailController.text,
                                      passwordController.text,
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppColors.borderColor)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  "Or sign in with",
                                  style:
                                      TextStyle(color: AppColors.hintTextColor),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: AppColors.borderColor)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.facebook,
                                    color: Colors.blue, size: 36),
                                onPressed: () {
                                  // Handle Facebook sign in
                                  // context.read<SignUpBloc>().add(SignInWithFacebook());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.apple,
                                    color: AppColors.textColor, size: 36),
                                onPressed: () {
                                  // Handle Apple sign in
                                  // context.read<SignUpBloc>().add(SignInWithApple());
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                    'assets/images/google_icon.png',
                                    width: 25),
                                onPressed: () {
                                  // Handle Google sign in
                                  // context.read<SignUpBloc>().add(SignInWithGoogle());
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
