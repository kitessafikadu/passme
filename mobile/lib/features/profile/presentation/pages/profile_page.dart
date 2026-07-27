import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/blocs/login_cubit.dart';
import 'package:mobile/features/profile/presentation/widgets/personal_details.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_option.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: SizedBox(
          height: 36,
          child: Image.asset("assets/images/logo.png"),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                final username = state.username ?? "johndoe";
                final email = state.email ?? "john@example.com";

                return PersonalDetails(
                  imageUrl: 'assets/images/profile_picture(puppy).jpg',
                  name: username,
                  email: email,
                );
              },
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white),
            const SizedBox(height: 20),
            ProfileOption(
              title: "Language Preference",
              onTap: () {},
              leadingIcon: const Icon(
                Icons.language_outlined,
                size: 30,
                color: Colors.white,
              ),
              trailingIcon: Text(
                "English",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB7B7B7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ProfileOption(
              title: "Clear History",
              onTap: () {},
              leadingIcon: const Icon(
                Icons.history_rounded,
                size: 30,
                color: Colors.white,
              ),
              trailingIcon: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                ),
                child: Text(
                  "Clear All",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ProfileOption(
              title: "About",
              onTap: () {},
              leadingIcon: const Icon(
                Icons.info_outline_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ProfileOption(
              title: "Log Out",
              titleStyle: GoogleFonts.poppins(
                color: const Color(0xFFF63C3C),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              onTap: () async {
                // Show a confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2E2E2E),
                    title: Text(
                      'Confirm Logout',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    content: Text(
                      'Are you sure you want to log out?',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  // Clear session
                  context.read<LoginCubit>().logout();

                  // Navigate to login page and clear previous stack
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              leadingIcon: const Icon(
                Icons.logout_outlined,
                size: 30,
                color: Color(0xFFF63C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
