import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/blocs/login_cubit.dart';
import 'package:mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/presentation/pages/update_profile_page.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_option.dart';
import 'package:mobile/injection_container.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 34,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
      body: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final username = state.username ?? 'User';
          final email = state.email ?? '';
          final initials = username.isNotEmpty
              ? username.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
              : 'U';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner header ─────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFF3972FF),
                            child: Text(
                              initials,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openEditPage(context),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.backgroundColor, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _openEditPage(context),
                        icon: const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.white70),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Settings section ──────────────────────────
                      _sectionLabel('Settings'),
                      const SizedBox(height: 8),
                      _OptionCard(children: [
                        ProfileOption(
                          title: 'Language Preference',
                          onTap: () {},
                          leadingIcon: _optionIcon(
                              Icons.language_outlined,
                              bgColor: const Color(0xFF1A3A6B)),
                          trailingIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('English',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white38, fontSize: 13)),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white38, size: 18),
                            ],
                          ),
                        ),
                        _divider(),
                        ProfileOption(
                          title: 'Clear History',
                          onTap: () {},
                          leadingIcon: _optionIcon(
                              Icons.history_rounded,
                              bgColor: const Color(0xFF3B2A1A)),
                          trailingIcon: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2A3C).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color:
                                        const Color(0xFFFF2A3C).withOpacity(0.35)),
                              ),
                              child: Text('Clear',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF2A3C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                          ),
                        ),
                        _divider(),
                        ProfileOption(
                          title: 'About PassMe',
                          onTap: () {},
                          leadingIcon: _optionIcon(
                              Icons.info_outline_rounded,
                              bgColor: const Color(0xFF1A2E1A)),
                          trailingIcon: const Icon(Icons.chevron_right,
                              color: Colors.white38, size: 18),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // ── Account section ───────────────────────────
                      _sectionLabel('Account'),
                      const SizedBox(height: 8),
                      _OptionCard(children: [
                        ProfileOption(
                          title: 'Log Out',
                          titleStyle: GoogleFonts.poppins(
                            color: const Color(0xFFF63C3C),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF2A2A3E),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: Text('Log Out',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                content: Text(
                                    'Are you sure you want to log out?',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 14)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text('Cancel',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white54)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text('Log Out',
                                        style: GoogleFonts.poppins(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                            if (shouldLogout == true) {
                              context.read<LoginCubit>().logout();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login', (route) => false);
                            }
                          },
                          leadingIcon: _optionIcon(
                            Icons.logout_outlined,
                            color: const Color(0xFFF63C3C),
                            bgColor: const Color(0xFF3B1A1A),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
          child: const UpdateProfilePage(),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      );

  Widget _optionIcon(IconData icon,
      {Color color = Colors.white,
      Color bgColor = const Color(0xFF2A2A3E)}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }

  Widget _divider() => const Divider(
        color: Colors.white10,
        height: 1,
        indent: 66,
        endIndent: 0,
      );
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}
