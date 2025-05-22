import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../screens/answer_screen.dart';

class QuestionTile extends StatelessWidget {
  final Question question;

  const QuestionTile({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: const Icon(Icons.question_answer_outlined),
          title: Text(
            question.text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
