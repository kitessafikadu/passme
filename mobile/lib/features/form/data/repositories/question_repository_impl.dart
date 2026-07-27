import '../../../../core/widgets/language_selector.dart';
import '../../domain/entites/Submission_entity.dart';
import '../../domain/entites/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasource/question_remote_datasource.dart';
import '../models/submission_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource remoteDataSource;

  QuestionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<QuestionEntity>> getQuestions(Language language) async {
    late final String languageCode;

    switch (language) {
      case Language.english:
        languageCode = 'en';
        break;
      case Language.amharic:
        languageCode = 'am';
        break;
      case Language.turkish:
        languageCode = 'tur';
        break;
    }

    return await remoteDataSource.getQuestions(languageCode);
  }

  @override
  Future<void> submitAnswers(SubmissionEntity submission) async {
    // Convert SubmissionEntity to SubmissionModel before passing to data source
    final submissionModel = SubmissionModel(
        qa: submission.qa,
        date: submission.date,
        title: submission.title,
        to_country: submission.to_country,
        from_country: submission.from_country,
        //user_id: submission.user_id,
        language: submission.language);
    await remoteDataSource.submitAnswers(submissionModel.toJson());
  }
}
