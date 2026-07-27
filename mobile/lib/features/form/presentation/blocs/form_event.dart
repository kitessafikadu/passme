// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

class LoadQuestions extends FormEvent {
  final Language language;

  const LoadQuestions(this.language);

  @override
  List<Object> get props => [language];
}

class SubmitAnswers extends FormEvent {
  final SubmissionEntity submission;

  const SubmitAnswers(
    this.submission,
  );

  @override
  List<Object> get props => [submission];

  SubmitAnswers copyWith({
    SubmissionEntity? submission,
  }) {
    return SubmitAnswers(
      submission ?? this.submission,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'submission': submission.toMap(),
    };
  }

  factory SubmitAnswers.fromMap(Map<String, dynamic> map) {
    return SubmitAnswers(
      SubmissionEntity.fromMap(map['submission'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubmitAnswers.fromJson(String source) =>
      SubmitAnswers.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SubmitAnswers(submission: $submission)';

  @override
  bool operator ==(covariant SubmitAnswers other) {
    if (identical(this, other)) return true;

    return other.submission == submission;
  }

  @override
  int get hashCode => submission.hashCode;
}

class UpdateAnswer extends FormEvent {
  final String questionId;
  final String answer;

  const UpdateAnswer(this.questionId, this.answer);

  @override
  List<Object> get props => [questionId, answer];
}
