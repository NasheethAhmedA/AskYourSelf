class Answer {
  final int? id;
  final int questionId;
  final String content;
  final DateTime timestamp;

  Answer({
    this.id,
    required this.questionId,
    required this.content,
    required this.timestamp,
  });

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      questionId: map['questionId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
