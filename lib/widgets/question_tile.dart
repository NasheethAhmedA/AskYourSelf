import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../screens/answer_screen.dart';

class QuestionTile extends StatelessWidget {
  final Question question;

  const QuestionTile({super.key, required this.question});

  IconData _iconForType(String type) {
    switch (type) {
      case 'Text':
        return Icons.text_format;
      case 'MCQ':
        return Icons.radio_button_checked;
      case 'MSQ':
        return Icons.check_box;
      case 'Slider':
        return Icons.switch_left_rounded;
      case 'Rating':
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Text(
            question.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Type: ${question.type}',
            style: const TextStyle(color: Colors.grey),
          ),
          leading: Icon(_iconForType(question.type), color: Colors.deepPurple),
          trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnswerScreen(question: question),
              ),
            );
          },
        ),
      ),
    );
  }
}
