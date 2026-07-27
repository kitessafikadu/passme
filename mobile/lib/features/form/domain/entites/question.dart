class QuestionEntity {
  final int id;
  final String questionText;
  final String placeholder;
  final String? answer;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    required this.placeholder,
    this.answer,
  });

  QuestionEntity copyWith({
    int? id,
    String? questionText,
    String? placeholder,
    String? answer,
  }) {
    return QuestionEntity(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      placeholder: placeholder ?? this.placeholder,
      answer: answer ?? this.answer,
    );
  }

  // Serialization to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'placeholder': placeholder,
      'answer': answer,
    };
  }

  // Deserialization from Map
  factory QuestionEntity.fromMap(Map<String, dynamic> map) {
    return QuestionEntity(
      id: map['id'] as int,
      questionText: map['questionText'] as String,
      placeholder: map['placeholder'] as String,
      answer: map['answer'] as String?,
    );
  }

  // Optional: If you still need JSON methods, they can delegate to Map methods
  Map<String, dynamic> toJson() => toMap();
  factory QuestionEntity.fromJson(Map<String, dynamic> json) =>
      QuestionEntity.fromMap(json);
}
