class Question {
  int? id;
  final String text;
  final String type;
  final int askAgainAfterDays;

  Question({
    this.id,
    required this.text,
    required this.type,
    required this.askAgainAfterDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'askAgainAfterDays': askAgainAfterDays,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'],
      type: map['type'],
      askAgainAfterDays: map['askAgainAfterDays'],
    );
  }
}
