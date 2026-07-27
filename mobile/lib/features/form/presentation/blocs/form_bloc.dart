import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/language_selector.dart';
import 'package:mobile/features/form/domain/entites/Submission_entity.dart';
import 'package:mobile/features/form/domain/entites/question.dart';
import 'package:mobile/features/form/domain/repositories/question_repository.dart';
import 'dart:convert';

import '../../data/models/question_model.dart';
part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormsSates> {
  final QuestionRepository questionRepository;
  List<QuestionEntity> questions = [];
  Language? currentLanguage;

  FormBloc({required this.questionRepository}) : super(FormInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<SubmitAnswers>(_onSubmitAnswers);
    on<UpdateAnswer>(_onUpdateAnswer);
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<FormsSates> emit,
  ) async {
    // Don't reload if we already have questions for this language
    if (currentLanguage == event.language && questions.isNotEmpty) {
      return;
    }

    emit(QuestionsLoading());
    try {
      questions = await questionRepository.getQuestions(event.language);
      currentLanguage = event.language;
      emit(QuestionsLoaded(questions));
    } catch (e) {
      emit(QuestionsError('Failed to load questions'));
      // Revert to previous state if we had one
      if (questions.isNotEmpty) {
        emit(QuestionsLoaded(questions));
      }
    }
  }

  Future<void> _onSubmitAnswers(
    SubmitAnswers event,
    Emitter<FormsSates> emit,
  ) async {
    // Validate before submission
    if (event.submission.qa.any((q) => q.answer?.isEmpty ?? true)) {
      emit(SubmissionFailure('All questions must be answered'));
      return;
    }

    emit(SubmissionInProgress());
    try {
      await questionRepository.submitAnswers(event.submission);
      emit(SubmissionSuccess());
    } catch (e) {
      emit(SubmissionFailure(
        'Submission failed: ${e.toString()}',
      ));
      // Revert to loaded state after failure
      if (questions.isNotEmpty) {
        emit(QuestionsLoaded(questions));
      }
    }
  }

  void _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<FormsSates> emit,
  ) {
    if (state is! QuestionsLoaded) return;

    final currentState = state as QuestionsLoaded;

    try {
      final updatedQuestions = currentState.questions.map((question) {
        return question.id.toString() == event.questionId
            ? QuestionModel(
                // Ensure you're creating the correct type
                id: question.id,
                questionText: question.questionText,
                placeholder: question.placeholder,
                answer: event.answer,
              )
            : question;
      }).toList();

      emit(QuestionsLoaded(updatedQuestions));
    } catch (e) {
      debugPrint('Update error: $e');
      emit(QuestionsLoaded(currentState.questions));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    // Add global error handling here
    super.onError(error, stackTrace);
  }
}
