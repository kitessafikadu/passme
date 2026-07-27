abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);

  /// Registers a new user and returns a token
  Future<String> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String> refreshToken();
}
