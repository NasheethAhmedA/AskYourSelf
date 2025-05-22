import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/question_tile.dart';
import 'add_question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<QuestionProvider>().questions;

    return Scaffold(
      appBar: AppBar(title: const Text("AskYourSelf")),
      drawer: const DrawerMenu(),
      body: questions.isEmpty
          ? const Center(child: Text("No questions yet."))
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (ctx, i) => QuestionTile(question: questions[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
