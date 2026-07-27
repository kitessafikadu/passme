import 'package:mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository(this._remoteDataSource);

  Future<ProfileModel> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return profile;
    } catch (e) {
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      await _remoteDataSource.updateUsername(newUsername);
    } catch (e) {
      throw Exception('Failed to update username: ${e.toString()}');
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDataSource.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}
