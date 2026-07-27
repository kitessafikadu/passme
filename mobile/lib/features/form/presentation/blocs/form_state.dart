part of 'form_bloc.dart';

abstract class FormsSates extends Equatable {
  const FormsSates();

  @override
  List<Object> get props => [];
}

class FormInitial extends FormsSates {}

class QuestionsLoading extends FormsSates {}

class QuestionsLoaded extends FormsSates {
  final List<QuestionEntity> questions;

  const QuestionsLoaded(this.questions);

  @override
  List<Object> get props => [questions];
}

class QuestionsError extends FormsSates {
  final String message;

  const QuestionsError(this.message);

  @override
  List<Object> get props => [message];
}

class SubmissionInProgress extends FormsSates {}

class SubmissionSuccess extends FormsSates {}

class SubmissionFailure extends FormsSates {
  final String error;

  const SubmissionFailure(this.error);

  @override
  List<Object> get props => [error];
}

class QuestionUpdateError extends FormsSates {
  final String message;
  final String error;

  const QuestionUpdateError({
    required this.message,
    required this.error,
  });

  @override
  List<Object> get props => [message, error];
}
