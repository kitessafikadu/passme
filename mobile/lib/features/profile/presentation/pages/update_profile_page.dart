import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/blocs/login_cubit.dart';
import '../bloc/profile_bloc.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String _originalUsername = '';
  bool _pendingUsername = false;
  bool _pendingPassword = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {Color bg = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onSaveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameController.text.trim();
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final usernameChanged =
        newUsername.isNotEmpty && newUsername != _originalUsername;
    final passwordChanged = oldPassword.isNotEmpty ||
        newPassword.isNotEmpty ||
        confirmPassword.isNotEmpty;

    if (!usernameChanged && !passwordChanged) {
      _showSnack('No changes to save', bg: Colors.grey.shade700);
      return;
    }

    if (passwordChanged) {
      if (oldPassword.isEmpty) {
        _showSnack('Please enter your current password');
        return;
      }
      if (newPassword.isEmpty) {
        _showSnack('Please enter a new password');
        return;
      }
      if (newPassword != confirmPassword) {
        _showSnack('New passwords do not match');
        return;
      }
    }

    if (usernameChanged) {
      _pendingUsername = true;
      context.read<ProfileBloc>().add(UpdateUsername(newUsername));
    }
    if (passwordChanged) {
      _pendingPassword = true;
      context.read<ProfileBloc>().add(UpdatePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoginCubit>().state;
    final username = loginState.username ?? 'User';
    final initials = username.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

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
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is UsernameUpdated) {
            _pendingUsername = false;
            context.read<LoginCubit>().updateUsername(_usernameController.text.trim());
            _originalUsername = _usernameController.text.trim();
            if (!_pendingPassword) {
              _showSnack('Changes saved!', bg: Colors.green.shade600);
              Navigator.of(context).pop();
            }
          } else if (state is PasswordUpdated) {
            _pendingPassword = false;
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            if (!_pendingUsername) {
              _showSnack('Changes saved!', bg: Colors.green.shade600);
              Navigator.of(context).pop();
            }
          } else if (state is ProfileError) {
            _pendingUsername = false;
            _pendingPassword = false;
            _showSnack(state.message);
          } else if (state is ProfileLoaded) {
            _originalUsername = state.profile.username;
            if (_usernameController.text.isEmpty) {
              _usernameController.text = state.profile.username;
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── Avatar ────────────────────────────────────────
                Center(
                  child: Column(
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
                      const SizedBox(height: 10),
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Username card ─────────────────────────────────
                _sectionCard(
                  label: 'Username',
                  icon: Icons.badge_outlined,
                  iconBg: const Color(0xFF1A3A6B),
                  child: _buildField(
                    controller: _usernameController,
                    hint: 'Enter new username',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password card ─────────────────────────────────
                _sectionCard(
                  label: 'Change Password',
                  icon: Icons.lock_outline,
                  iconBg: const Color(0xFF2A1A3B),
                  child: Column(
                    children: [
                      _buildField(
                        controller: _oldPasswordController,
                        hint: 'Current password',
                        icon: Icons.lock_outline,
                        obscure: _obscureOld,
                        toggleObscure: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _newPasswordController,
                        hint: 'New password',
                        icon: Icons.lock_reset_outlined,
                        obscure: _obscureNew,
                        toggleObscure: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm new password',
                        icon: Icons.check_circle_outline,
                        obscure: _obscureConfirm,
                        toggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save button ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSaveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor:
                          AppColors.primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionCard({
    required String label,
    required IconData icon,
    required Color iconBg,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white70, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}
