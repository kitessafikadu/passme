import '../../domain/entities/flight.dart';

class FlightModel extends Flight {
  FlightModel({
    required String id,
    required String title,
    required String fromCountry,
    required String toCountry,
    required DateTime date,
    required String userId,
    required String language,
    required List<Map<String, String>> qa,
  }) : super(
          id: id,
          title: title,
          fromCountry: fromCountry,
          toCountry: toCountry,
          date: date,
          userId: userId,
          language: language,
          qa: qa,
        );

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fromCountry: json['from_country'] as String? ?? '',
      toCountry: json['to_country'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      userId: json['user_id'] as String? ?? '',
      language: json['language'] as String? ?? 'amharic',
      qa: (json['qa'] as List<dynamic>?)
              ?.map((item) => {
                    'question': item['question'] as String? ?? '',
                    'answer': item['answer'] as String? ?? '',
                  })
              .toList() ??
          [],
    );
  }

  factory FlightModel.fromFlight(Flight flight) {
    return FlightModel(
      id: flight.id,
      title: flight.title,
      fromCountry: flight.fromCountry,
      toCountry: flight.toCountry,
      date: flight.date,
      userId: flight.userId,
      language: flight.language,
      qa: flight.qa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'from_country': fromCountry,
      'to_country': toCountry,
      'date': date.toIso8601String(),
      'user_id': userId,
      'language': language,
      'qa': qa
          .map((item) => {
                'question': item['question'],
                'answer': item['answer'],
              })
          .toList(),
    };
  }
}
