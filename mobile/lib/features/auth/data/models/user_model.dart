import '../../domain/entities/user.dart';

class UserModel extends User {
  final String token;

  UserModel({
    required String id,
    required String username,
    required String email,
    required this.token,
  }) : super(id: id, token: token, username: username, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? {};
    return UserModel(
      id: userJson['id'] ?? '',
      username: userJson['username'] ?? '',
      email: userJson['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
    };
  }
}
