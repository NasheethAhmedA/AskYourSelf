import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart'; // Corrected import path
import 'package:table_calendar/table_calendar.dart';
import '../db/database_helper.dart';
import '../models/answer_model.dart';
import '../models/question_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Answer>> _selectedAnswers;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Answer>> _answersByDate = {};
  Map<int, Question> _questionDetails = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedAnswers = ValueNotifier([]);
    _loadAnswers();
  }

  @override
  void dispose() {
    _selectedAnswers.dispose();
    super.dispose();
  }

  Future<void> _loadAnswers() async {
    // Fetch answers
    final answers = await DatabaseHelper.instance.getAllAnswers();
    final Map<DateTime, List<Answer>> answersMap = {};
    for (var answer in answers) {
      final date = DateTime.utc(
        answer.timestamp.year,
        answer.timestamp.month,
        answer.timestamp.day,
      );
      if (answersMap[date] == null) {
        answersMap[date] = [answer];
      } else {
        answersMap[date]!.add(answer);
      }
    }

    // Fetch questions
    final questionsList = await Provider.of<QuestionProvider>(context, listen: false).fetchAllQuestionsFromDb();
    final Map<int, Question> qDetails = {};
    for (var q in questionsList) {
      if (q.id != null) {
        qDetails[q.id!] = q;
      }
    }

    setState(() {
      _answersByDate = answersMap;
      _questionDetails = qDetails; // Store question details
      if (_selectedDay != null) {
        _selectedAnswers.value = _getAnswersForDay(_selectedDay!);
      }
    });
  }

  List<Answer> _getAnswersForDay(DateTime day) {
    return _answersByDate[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<Answer>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getAnswersForDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedAnswers.value = _getAnswersForDay(selectedDay);
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Answer>>(
              valueListenable: _selectedAnswers,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text('No answers for this day.'),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final answer = value[index];
                    final question = _questionDetails[answer.questionId];
                    final questionText = question?.text ?? 'Question ID: ${answer.questionId} (Not found)';
                    final String formattedTime = DateFormat.jm().format(answer.timestamp.toLocal());

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Answer: ${answer.content}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Time: $formattedTime',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
