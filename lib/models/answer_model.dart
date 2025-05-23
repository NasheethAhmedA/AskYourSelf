class Answer {
  final int? id;
  final int questionId;
  final String answer;
  final String date; // Store as ISO date string (e.g., '2025-05-21')

  Answer({
    this.id,
    required this.questionId,
    required this.answer,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'answer': answer,
      'date': date,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      questionId: map['questionId'],
      answer: map['answer'],
      date: map['date'],
    );
  }
}
