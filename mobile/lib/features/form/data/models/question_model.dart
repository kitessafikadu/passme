import '../../domain/entites/question.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.questionText,
    required super.placeholder,
    super.answer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      questionText: json['questionText'],
      placeholder: json['placeholder'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'placeholder': placeholder,
      'answer': answer,
    };
  }
}
