import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/answer_model.dart';
import '../db/database_helper.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  void setQuestions(List<Question> list) {
    _questions = list;
    notifyListeners();
  }

  Future<void> addQuestion(Question question) async {
    final id = await DatabaseHelper.instance.insertQuestion(question);
    final saved = Question(
      id: id,
      text: question.text,
      type: question.type,
      askAgainAfterDays: question.askAgainAfterDays,
      config: question.config,
    );
    _questions.add(saved);
    notifyListeners();
  }

  // get a question by ID from database helper
  Future<Question?> getQuestionById(int id) async {
    final question = await DatabaseHelper.instance.fetchQuestionById(id);
    if (question != null) {
      return question;
    }
    return null;
  }

  // This method seems to be unused. Deletion is handled by permanentlyDeleteQuestion.
  // Future<void> removeQuestion(Question question) async {
  //   if (question.id != null) {
  //     await DatabaseHelper.instance.deleteQuestion(question.id!);
  //   }
  //   _questions.removeWhere((q) => q.id == question.id);
  //   notifyListeners();
  // }

  Future<void> loadVisibleQuestions() async {
    final list = await DatabaseHelper.instance.getVisibleQuestions();
    setQuestions(list);
  }

  Future<void> reloadAllQuestions() async {
    final all = await DatabaseHelper.instance.fetchQuestions();
    setQuestions(all);
  }

  Future<void> submitAnswer(Answer answer) async {
    await DatabaseHelper.instance.insertAnswer(answer);
    await loadVisibleQuestions();
  }

  Future<List<Question>> fetchAllQuestionsFromDb() async {
    return await DatabaseHelper.instance.fetchQuestions();
  }

  Future<void> permanentlyDeleteQuestion(int questionId) async {
    await DatabaseHelper.instance.deleteQuestion(questionId);
    // Refresh the main _questions list (consumed by HomeScreen).
    // notifyListeners() is called by setQuestions within loadVisibleQuestions.
    await loadVisibleQuestions(); 
  }

  Future<void> updateQuestionAskAgainAfterDays(int questionId, int newDays) async {
    await DatabaseHelper.instance.updateQuestionAskAgainAfterDays(questionId, newDays);
    // Refresh the main _questions list (consumed by HomeScreen).
    // notifyListeners() is called by setQuestions within loadVisibleQuestions.
    await loadVisibleQuestions();
  }
}
