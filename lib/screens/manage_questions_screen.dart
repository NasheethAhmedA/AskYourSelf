import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  late Future<void> _loadAllQuestionsFuture;
  List<Question> _allQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadAllQuestionsFuture = _fetchAllQuestions();
  }

  Future<void> _fetchAllQuestions() async {
    try {
      // Ensure context is available and mounted before using Provider.
      // However, for initState, it's better to pass context if needed or handle it carefully.
      // Here, we are calling it directly via a method that will be assigned to a Future.
      final questions = await Provider.of<QuestionProvider>(context, listen: false).fetchAllQuestionsFromDb();
      if (mounted) {
        setState(() {
          _allQuestions = questions;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $error')),
        );
        setState(() {
          _allQuestions = []; // Ensure it's empty on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Questions'),
      ),
      body: FutureBuilder<void>(
        future: _loadAllQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError && _allQuestions.isEmpty) {
            return Center(child: Text('Error loading questions: ${snapshot.error}. Please try again.'));
          }

          if (_allQuestions.isEmpty) {
            return const Center(child: Text('No questions available to manage.'));
          }

          return ListView.builder(
            itemCount: _allQuestions.length,
            itemBuilder: (context, index) {
              final question = _allQuestions[index];
              return ListTile(
                title: Text(question.text),
                subtitle: Text('Type: ${question.type} - Ask again after: ${question.askAgainAfterDays} days'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit "Ask Again After Days"',
                      onPressed: () => _showEditAskAgainDialog(question),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Question',
                      onPressed: () => _showDeleteConfirmDialog(question),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditAskAgainDialog(Question question) {
    final formKey = GlobalKey<FormState>();
    final daysController = TextEditingController(text: question.askAgainAfterDays.toString());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit "Ask Again After Days" for "${question.text}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Days'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a number of days.';
                }
                final days = int.tryParse(value);
                if (days == null) {
                  return 'Please enter a valid number.';
                }
                if (days <= 0) {
                  return 'Days must be greater than 0.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newDays = int.parse(daysController.text);
                  Navigator.of(dialogContext).pop(); // Close dialog first

                  if (question.id == null) return;

                  try {
                    await Provider.of<QuestionProvider>(context, listen: false)
                        .updateQuestionAskAgainAfterDays(question.id!, newDays);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update successful for "${question.text}".')),
                      );
                      setState(() {
                        _loadAllQuestionsFuture = _fetchAllQuestions();
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating question "${question.text}": $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Question question) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this question? This will also delete all its answers and cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); 
                if (question.id == null) return;

                try {
                  await Provider.of<QuestionProvider>(context, listen: false)
                      .permanentlyDeleteQuestion(question.id!);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Question "${question.text}" deleted successfully.')),
                    );
                    setState(() {
                      _loadAllQuestionsFuture = _fetchAllQuestions();
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting question "${question.text}": $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
