import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/presentation/blocs/login_cubit.dart';
import '../bloc/profile_bloc.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is UsernameUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Username updated!')),
            );

            // Update LoginCubit username too!
            context
                .read<LoginCubit>()
                .updateUsername(_usernameController.text.trim());

            context.read<ProfileBloc>().add(LoadProfile());
          } else if (state is PasswordUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated!')),
            );
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            context.read<ProfileBloc>().add(LoadProfile());
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileLoaded) {
            _usernameController.text = state.profile.username;
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text("Update Username", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'New Username'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final newUsername = _usernameController.text.trim();
                          if (newUsername.isNotEmpty) {
                            context
                                .read<ProfileBloc>()
                                .add(UpdateUsername(newUsername));
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Username"),
                ),
                const SizedBox(height: 24),
                const Text("Update Password", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_newPasswordController.text.trim() !=
                              _confirmPasswordController.text.trim()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match')),
                            );
                            return;
                          }
                          context.read<ProfileBloc>().add(UpdatePassword(
                                oldPassword: _oldPasswordController.text.trim(),
                                newPassword: _newPasswordController.text.trim(),
                                confirmPassword:
                                    _confirmPasswordController.text.trim(),
                              ));
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Change Password"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
