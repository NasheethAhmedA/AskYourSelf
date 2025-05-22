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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'askAgainAfterDays': askAgainAfterDays,
      'config': config,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      type: map['type'],
      askAgainAfterDays: map['askAgainAfterDays'],
      config: Map<String, dynamic>.from(map['config'] ?? {}),
    );
  }
}
