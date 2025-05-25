class Question {
  int? id;
  final String text;
  final String type;
  final int askAgainAfterDays;
  final Map<String, dynamic> config; // dynamic field depending on type

  Question({
    this.id,
    required this.text,
    required this.type,
    required this.askAgainAfterDays,
    this.config = const {},
  });
}
