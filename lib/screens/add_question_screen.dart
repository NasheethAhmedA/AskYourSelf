import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _daysController = TextEditingController(text: '1');

  String _selectedType = 'Text';
  final List<String> _answerTypes = ['MCQ', 'MSQ', 'Text', 'Slider', 'Rating'];

  List<TextEditingController> _choiceControllers = [TextEditingController()];
  final _sliderMinController = TextEditingController(text: '0');
  final _sliderMaxController = TextEditingController(text: '10');
  final _ratingMaxController = TextEditingController(text: '5');

  void _addChoiceField() {
    setState(() => _choiceControllers.add(TextEditingController()));
  }

  void _removeChoiceField(int index) {
    setState(() => _choiceControllers.removeAt(index));
  }

  Map<String, dynamic> _buildConfig() {
    switch (_selectedType) {
      case 'MCQ':
      case 'MSQ':
        return {
          'choices': _choiceControllers
              .map((c) => c.text.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        };
      case 'Slider':
        return {
          'min': int.tryParse(_sliderMinController.text) ?? 0,
          'max': int.tryParse(_sliderMaxController.text) ?? 10,
        };
      case 'Rating':
        return {
          'maxStars': int.tryParse(_ratingMaxController.text) ?? 5,
        };
      default:
        return {};
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        text: _questionController.text.trim(),
        type: _selectedType,
        askAgainAfterDays: int.parse(_daysController.text),
        config: _buildConfig(),
      );

      Provider.of<QuestionProvider>(context, listen: false)
          .addQuestion(newQuestion);
      Navigator.pop(context);
    }
  }

  Widget _buildDynamicFields() {
    switch (_selectedType) {
      case 'MCQ':
      case 'MSQ':
        return _buildChoiceFields();
      case 'Slider':
        return _buildSliderFields();
      case 'Rating':
        return _buildRatingField();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChoiceFields() {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choices",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._choiceControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Choice ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_choiceControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => _removeChoiceField(index),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addChoiceField,
              icon: const Icon(Icons.add),
              label: const Text("Add Choice"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderFields() {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Slider Configuration",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _sliderMinController,
              decoration: const InputDecoration(
                  labelText: 'Minimum Value', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _sliderMaxController,
              decoration: const InputDecoration(
                  labelText: 'Maximum Value', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingField() {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rating Configuration",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _ratingMaxController,
              decoration: const InputDecoration(
                  labelText: 'Max Stars', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Question")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Basic Info",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a question'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Answer Type',
                  border: OutlineInputBorder(),
                ),
                items: _answerTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _choiceControllers = [TextEditingController()];
                      _sliderMinController.text = '0';
                      _sliderMaxController.text = '10';
                      _ratingMaxController.text = '5';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                  labelText: 'Ask again after (days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              _buildDynamicFields(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text("Save Question"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
