import 'package:mobile/core/widgets/language_selector.dart';
import 'package:mobile/features/form/domain/entites/Submission_entity.dart';
import 'package:mobile/features/form/domain/entites/question.dart';

abstract class QuestionRepository {
  Future<List<QuestionEntity>> getQuestions(Language language);
  Future<void> submitAnswers(SubmissionEntity submission);
}
