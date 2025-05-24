import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/question_tile.dart';
import 'add_question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadQuestions;

  @override
  void initState() {
    super.initState();
    _loadQuestions = context.read<QuestionProvider>().loadVisibleQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<QuestionProvider>().questions;

    return Scaffold(
      appBar: AppBar(title: const Text("AskYourSelf")),
      drawer: const DrawerMenu(),
      body: FutureBuilder(
        future: _loadQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questions.isEmpty) {
            return const Center(child: Text("No questions for today."));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (ctx, i) => QuestionTile(question: questions[i]),
          );
        },
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
