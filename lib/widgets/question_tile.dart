import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionTile extends StatelessWidget {
  final Question question;

  const QuestionTile({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(question.text),
      onTap: () {
        // TODO: navigate to answer screen
      },
    );
  }
}
