import 'package:askyourself/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/database_helper.dart';
import '../models/answer_model.dart';

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

    setState(() {
      _answersByDate = answersMap;
      _selectedAnswers.value = _getAnswersForDay(_selectedDay!);
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
                    return ListTile(
                      title: Text(answer.questionId.toString()),
                      subtitle: Text(
                        'Answered: ${answer.content} on ${answer.timestamp.toLocal()}',
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
