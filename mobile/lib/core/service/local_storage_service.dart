// core/service/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _tokenKey = 'jwt_token';

  final SharedPreferences _sharedPreferences;

  LocalStorageService(this._sharedPreferences);

  // Auth Token Methods
  Future<void> saveAuthToken(String token) async {
    await _sharedPreferences.setString(_authTokenKey, token);
  }

  String? getAuthToken() {
    return _sharedPreferences.getString(_authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _sharedPreferences.remove(_authTokenKey);
  }

  // Refresh Token Methods
  Future<void> saveRefreshToken(String token) async {
    await _sharedPreferences.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _sharedPreferences.getString(_refreshTokenKey);
  }

  Future<void> clearRefreshToken() async {
    await _sharedPreferences.remove(_refreshTokenKey);
  }

  // User ID Methods
  Future<void> saveUserId(String userId) async {
    await _sharedPreferences.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _sharedPreferences.getString(_userIdKey);
  }

  Future<void> clearUserId() async {
    await _sharedPreferences.remove(_userIdKey);
  }

  // User Email Methods
  Future<void> saveUserEmail(String email) async {
    await _sharedPreferences.setString(_userEmailKey, email);
  }

  String? getUserEmail() {
    return _sharedPreferences.getString(_userEmailKey);
  }

  Future<void> clearUserEmail() async {
    await _sharedPreferences.remove(_userEmailKey);
  }

  Future<void> saveUserData(String token, String username, String email) async {
    await saveAuthToken(token);
    await saveUserEmail(email);
    await _sharedPreferences.setString('username', username); // Save username
  }

  // Retrieve username
  String? getUsername() {
    return _sharedPreferences.getString('username');
  }

  Future<void> saveUsername(String username) async {
    await _sharedPreferences.setString('username', username);
  }

  // Clear username
  Future<void> clearUsername() async {
    await _sharedPreferences.remove('username');
  }

  // Remember Me Methods
  Future<void> saveRememberMe(bool rememberMe) async {
    await _sharedPreferences.setBool(_rememberMeKey, rememberMe);
  }

  bool getRememberMe() {
    return _sharedPreferences.getBool(_rememberMeKey) ?? false;
  }

  // Save the token
  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  // Retrieve the token
  String? getToken() {
    return _sharedPreferences.getString(_tokenKey);
  }

  // Clear the token
  Future<void> clearToken() async {
    await _sharedPreferences.remove(_tokenKey);
  }

  // Clear all user data (for logout)
  Future<void> clearAllUserData() async {
    await Future.wait([
      clearAuthToken(),
      clearRefreshToken(),
      clearUserId(),
      clearUserEmail(),
    ]);
  }

  // Helper to check if user is authenticated
  bool isAuthenticated() {
    return getAuthToken() != null;
  }
}
