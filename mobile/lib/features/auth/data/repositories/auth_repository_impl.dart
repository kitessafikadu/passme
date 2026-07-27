import 'dart:convert'; // Import the jsonDecode function

import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userMap = await remoteDataSource.login(email, password);
      final user = UserModel.fromJson(userMap);
      // Pass the Map to fromJson
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      final token = await remoteDataSource.signUp(
        username: username,
        email: email,
        password: password,
      );

      final user = User(
        id: '', // You may want to get ID from response if available
        token: token,
        username: username,
        email: email,
      );

      return Right(user);
    } catch (e) {
      if (e.toString().contains('Email already exists')) {
        return Left(ServerFailure('Email already exists'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
