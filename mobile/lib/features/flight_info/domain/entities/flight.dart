class Flight {
  final String id;
  final String title;
  final String fromCountry;
  final String toCountry;
  final DateTime date;
  final String userId;
  final String language;
  final List<Map<String, String>> qa;

  const Flight({
    required this.id,
    required this.title,
    required this.fromCountry,
    required this.toCountry,
    required this.date,
    required this.userId,
    required this.language,
    required this.qa,
  });

  @override
  String toString() {
    return 'Flight{id: $id, title: $title, from: $fromCountry, to: $toCountry, '
        'date: $date, userId: $userId, language: $language, qa: ${qa.length} items}';
  }
}
