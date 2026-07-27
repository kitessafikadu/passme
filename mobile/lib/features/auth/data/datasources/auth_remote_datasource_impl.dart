import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/service/local_storage_service.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  AuthRemoteDataSourceImpl(this._apiClient, this._localStorage);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      '/login',
      {'email': email, 'password': password},
      requiresAuth: false,
    );

    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;

    await _localStorage.saveAuthToken(token);
    final rawId = userData['id'];
    final userId = rawId is Map
        ? (rawId['\$oid'] as String? ?? '')
        : (rawId as String? ?? '');
    await _localStorage.saveUserId(userId);
    await _localStorage.saveUserEmail(userData['email'] as String);

    if (response.containsKey('refresh_token')) {
      await _localStorage.saveRefreshToken(response['refresh_token'] as String);
    }

    return response;
  }

  @override
  Future<String> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/register',
      {'username': username, 'email': email, 'password': password},
      requiresAuth: false,
    );

    if (response.containsKey('token')) {
      final token = response['token'] as String;
      await _localStorage.saveAuthToken(token);
      if (response.containsKey('user')) {
        final userData = response['user'] as Map<String, dynamic>;
        final rawId = userData['id'];
        final userId = rawId is Map
            ? (rawId['\$oid'] as String? ?? '')
            : (rawId as String? ?? '');
        await _localStorage.saveUserId(userId);
        await _localStorage.saveUserEmail(userData['email'] as String);
      }
      return token;
    }

    if (response['message'] == 'User registered successfully') {
      return 'registration_successful';
    }

    throw ApiException(statusCode: 500, message: 'Unexpected response format');
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout', {});
    } finally {
      await _localStorage.clearAllUserData();
    }
  }

  @override
  Future<String> refreshToken() async {
    final refreshToken = _localStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      final newToken = response['token'] as String;
      await _localStorage.saveAuthToken(newToken);

      if (response.containsKey('refresh_token')) {
        await _localStorage
            .saveRefreshToken(response['refresh_token'] as String);
      }

      return newToken;
    } on ApiException catch (e) {
      await _localStorage.clearAllUserData();
      throw Exception('Session expired. Please login again.');
    }
  }
}
