import 'package:mobile/core/errors/failures.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart'; // Import this to work with Either

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return repository.login(email, password); // Return the result directly
  }
}
