import 'package:mobile/features/form/domain/entites/Submission_entity.dart';
import 'package:mobile/features/form/domain/repositories/question_repository.dart';

class SubmitAnswersUseCase {
  final QuestionRepository repository;

  SubmitAnswersUseCase(this.repository);

  Future<void> call(SubmissionEntity submission) {
    return repository.submitAnswers(submission);
  }
}
