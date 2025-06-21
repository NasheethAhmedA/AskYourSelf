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

  // Convert a Question object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'askAgainAfterDays': askAgainAfterDays,
      'config': config, // Assuming config is already a Map<String, dynamic>
    };
  }

  // Extract a Question object from a Map object
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?, // ID can be null if it's a new question from JSON without one
      text: map['text'] as String,
      type: map['type'] as String,
      askAgainAfterDays: map['askAgainAfterDays'] as int,
      config: map['config'] != null
          ? Map<String, dynamic>.from(map['config'] as Map)
          : {},
    );
  }
}
