import 'package:mobile/features/form/domain/entites/question.dart';

class SubmissionEntity {
  final List<QuestionEntity> qa;
  final DateTime date;
  final String title;
  final String from_country;
  final String to_country;
  //final String user_id;
  final String language;

  const SubmissionEntity({
    required this.qa,
    required this.date,
    required this.title,
    required this.from_country,
    required this.to_country,
    //required this.user_id,
    required this.language
  });

  // Creates a copy with updated value
  SubmissionEntity copyWith({
    List<QuestionEntity>? qa,
    DateTime? date,
    String? title,
    String? from_country,
    String? to_country,
    //String? user_id,
    String? language,
  }) {
    return SubmissionEntity(
        qa: qa ?? this.qa,
        date: date ?? this.date,
        title: title ?? this.title,
        from_country: from_country ?? this.from_country,
        to_country: to_country ?? this.to_country,
        //user_id: user_id ?? this.user_id,
        language: language?? this.language);
  }

  // Converts to Map
  Map<String, dynamic> toMap() {
    return {
      'qa': qa.map((q) => q.toMap()).toList(),
      'date': date.toIso8601String(),
      'title': title,
      'from_country': from_country,
      'to_country': to_country,
      'language':language,
    };
  }

  // Creates from Map
  factory SubmissionEntity.fromMap(Map<String, dynamic> map) {
    return SubmissionEntity(
      qa: (map['qa'] as List).map((q) => QuestionEntity.fromMap(q)).toList(),
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      from_country: map['from_country'] as String,
      to_country: map['to_country'] as String,
      //user_id: map['user_id'] as String,
      language:map['language'] as String,
    );
  }

  // Optional JSON methods for compatibility
  Map<String, dynamic> toJson() => toMap();
  factory SubmissionEntity.fromJson(Map<String, dynamic> json) =>
      SubmissionEntity.fromMap(json);

  @override
  int get hashCode {
    return qa.hashCode ^
        date.hashCode ^
        title.hashCode ^
        from_country.hashCode ^
        to_country.hashCode;
  }
}
