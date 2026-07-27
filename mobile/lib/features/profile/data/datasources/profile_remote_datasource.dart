// lib/data/datasources/profile_remote_data_source_impl.dart

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/service/local_storage_service.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateUsername(String newUsername);
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;
  final LocalStorageService _localStorageService;

  ProfileRemoteDataSourceImpl(this._apiClient, this._localStorageService);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(
        '/profile',
        requiresAuth: true,
      );

      print('Profile API Response: $response'); // Add this line

      return ProfileModel.fromJson(response);
    } on ApiException catch (e) {
      print('API Exception: ${e.message}'); // Add this line
      throw Exception('Failed to load profile: ${e.message}');
    } catch (e) {
      print('General Exception: $e'); // Add this line
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    try {
      final response = await _apiClient.put(
        '/profile/username',
        {
          'new_username': newUsername,
        },
        requiresAuth: true,
      );

      if (response.containsKey('username')) {
        // Optionally update locally stored username if you have that feature
        await _localStorageService.saveUsername(response['username']);
      }
    } on ApiException catch (e) {
      throw Exception('Failed to update username: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update username: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.put(
        '/profile/password',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
        requiresAuth: true,
      );
    } on ApiException catch (e) {
      throw Exception('Failed to update password: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}
