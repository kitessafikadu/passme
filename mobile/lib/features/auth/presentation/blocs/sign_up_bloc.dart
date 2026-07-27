import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpBloc(this.signUpUseCase) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    final result = await signUpUseCase(
      SignUpParams(
        username: event.username,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(SignUpFailure(_mapFailureToMessage(failure))),
      (user) => emit(SignUpSuccess(user)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection';
    // Use the actual message from the failure (e.g. "Email already exists",
    // "Username already taken") rather than a generic fallback
    if (failure is ServerFailure && failure.message.isNotEmpty) {
      String message = failure.message;
      // Strip Exception/ApiException wrapper noise
      if (message.contains('Exception:')) {
        message = message.split('Exception:').last.trim();
      }
      if (message.contains('(Status')) {
        message = message.substring(0, message.indexOf('(Status')).trim();
      }
      return message;
    }
    return 'An unexpected error occurred';
  }
}
