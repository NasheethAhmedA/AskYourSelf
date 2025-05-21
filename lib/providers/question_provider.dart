import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  void setQuestions(List<Question> list) {
    _questions = list;
    notifyListeners();
  }

  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  void removeQuestion(Question question) {
    _questions.remove(question);
    notifyListeners();
  }
}
