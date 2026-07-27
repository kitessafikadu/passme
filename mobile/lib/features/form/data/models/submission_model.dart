import 'package:mobile/features/form/domain/entites/Submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel(
      {required super.qa,
      required super.date,
      required super.title,
      required super.from_country,
      required super.to_country,
      //required super.user_id,
      required super.language});

  factory SubmissionModel.fromEntity(SubmissionEntity entity) {
    return SubmissionModel(
      qa: entity.qa,
      date: entity.date,
      title: entity.title,
      from_country: entity.from_country,
      to_country: entity.to_country,
      //user_id: entity.user_id,
      language: entity.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qa': qa
          .map((q) => {
                'question': q.questionText,
                'answer': q.answer,
              })
          .toList(),
      'date': date.toIso8601String(),
      'title': title,
      'from_country': from_country,
      'to_country': to_country,
      //'user_id': user_id,
      'language': language,
    };
  }
}
