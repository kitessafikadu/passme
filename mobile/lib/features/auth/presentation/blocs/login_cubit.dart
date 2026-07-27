import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/service/local_storage_service.dart';
import 'package:mobile/features/auth/domain/usecases/login_user.dart';
import 'package:dartz/dartz.dart'; // For Either
import 'package:mobile/core/errors/failures.dart'; // Your Failure class
import 'package:mobile/core/service/local_storage_service.dart'; // You must import your LocalStorageService

class LoginState {
  final bool isLoading;
  final String? error;
  final String? token;
  final String? username;
  final String? email;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.token,
    this.username,
    this.email,
  });

  // Factory constructor to create initial state
  factory LoginState.initial() {
    return const LoginState(
      isLoading: false,
      error: null,
      token: null,
      username: null,
      email: null,
    );
  }

  LoginState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    String? username,
    String? email,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      token: token ?? this.token,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  final LoginUser loginUser;
  final LocalStorageService localStorageService; // <-- Add this!

  LoginCubit({
    required this.loginUser,
    required this.localStorageService,
  }) : super(LoginState.initial());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await loginUser(email, password);

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false, error: failure.toString()));
        },
        (user) async {
          final token = user.token;
          final username = user.username;

          // Save user data locally
          await localStorageService.saveUserData(token, username, email);

          emit(state.copyWith(
            isLoading: false,
            token: token,
            username: username,
            email: email,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await localStorageService.clearAllUserData();
    emit(LoginState.initial());
  }

  void updateUsername(String newUsername) {
    emit(state.copyWith(username: newUsername));
  }
}
