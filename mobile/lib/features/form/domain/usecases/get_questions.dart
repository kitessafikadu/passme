import 'package:mobile/core/widgets/language_selector.dart';
import 'package:mobile/features/form/domain/entites/question.dart';
import 'package:mobile/features/form/domain/repositories/question_repository.dart';

class GetQuestionsUseCase {
  final QuestionRepository repository;

  GetQuestionsUseCase(this.repository);

  Future<List<QuestionEntity>> call(Language language) {
    return repository.getQuestions(language);
  }
}
