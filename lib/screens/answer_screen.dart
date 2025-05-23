import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'package:intl/intl.dart'; // add this at the top
import '../db/database_helper.dart';
import '../models/answer_model.dart';

class AnswerScreen extends StatefulWidget {
  final Question question;

  const AnswerScreen({super.key, required this.question});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  String? _selectedMCQ;
  final Set<String> _selectedMSQ = {};
  double _sliderValue = 0;
  int _ratingValue = 0;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.question.type == 'Slider') {
      final min = (widget.question.config['min'] ?? 0).toDouble();
      _sliderValue = min;
    }
  }

  void _submitAnswer() async {
    dynamic response;

    switch (widget.question.type) {
      case 'Text':
        response = _textController.text.trim();
        if (response.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please write your answer.')),
          );
          return;
        }
        break;

      case 'MCQ':
        if (_selectedMCQ == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an option.')),
          );
          return;
        }
        response = _selectedMCQ!;
        break;

      case 'MSQ':
        if (_selectedMSQ.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one option.')),
          );
          return;
        }
        response = _selectedMSQ.toList();
        break;

      case 'Slider':
        response = _sliderValue.toStringAsFixed(0);
        break;

      case 'Rating':
        if (_ratingValue == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a rating.')),
          );
          return;
        }
        response = _ratingValue.toString();
        break;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final answer = Answer(
      questionId: widget.question.id!,
      answer: response.toString(),
      date: today,
    );

    await DatabaseHelper.instance.insertAnswer(answer);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Answer saved!')),
    );

    Navigator.pop(context);
  }

  Widget _buildAnswerWidget() {
    final config = widget.question.config;
    switch (widget.question.type) {
      case 'Text':
        return TextFormField(
          controller: _textController,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Your Answer',
            border: OutlineInputBorder(),
          ),
        );

      case 'MCQ':
        final choices = List<String>.from(config['choices'] ?? []);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select One:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...choices
                .map((choice) => RadioListTile<String>(
                      title: Text(choice),
                      value: choice,
                      groupValue: _selectedMCQ,
                      onChanged: (value) =>
                          setState(() => _selectedMCQ = value),
                      contentPadding: EdgeInsets.zero,
                    ))
                .toList(),
          ],
        );

      case 'MSQ':
        final choices = List<String>.from(config['choices'] ?? []);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Multiple:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...choices
                .map((choice) => CheckboxListTile(
                      title: Text(choice),
                      value: _selectedMSQ.contains(choice),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedMSQ.add(choice);
                          } else {
                            _selectedMSQ.remove(choice);
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ))
                .toList(),
          ],
        );

      case 'Slider':
        final min = (config['min'] ?? 0).toDouble();
        final max = (config['max'] ?? 10).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Adjust the slider:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _sliderValue,
              min: min,
              max: max,
              divisions: (max - min).round(),
              label: _sliderValue.toStringAsFixed(0),
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
            Text('Value: ${_sliderValue.toStringAsFixed(0)}'),
          ],
        );

      case 'Rating':
        final maxStars = config['maxStars'] ?? 5;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Rating:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.start,
              children: List.generate(maxStars, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _ratingValue ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _ratingValue = starIndex),
                );
              }),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Answer Question")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildAnswerWidget(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitAnswer,
                icon: const Icon(Icons.check),
                label: const Text("Submit Answer"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
