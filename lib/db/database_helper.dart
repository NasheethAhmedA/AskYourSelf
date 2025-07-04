import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:convert';
import '../models/question_model.dart';
import '../models/answer_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    late String path;
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
      path = 'ask_your_self.db';
    } else {
      path = join(await getDatabasesPath(), 'ask_your_self.db');
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        type TEXT NOT NULL,
        askAgainAfterDays INTEGER NOT NULL,
        config TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionId INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // QUESTIONS

  Future<int> insertQuestion(Question q) async {
    final db = await database;
    return await db.insert('questions', {
      'text': q.text,
      'type': q.type,
      'askAgainAfterDays': q.askAgainAfterDays,
      'config': jsonEncode(q.config),
    });
  }

  // Helper method to convert a map to a Question object
  Question _mapToQuestion(Map<String, dynamic> map) {
    final rawConfig = map['config'] as String?;
    final configMap = rawConfig != null && rawConfig.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(rawConfig) as Map)
        : <String, dynamic>{};

    return Question(
      id: map['id'] as int,
      text: map['text'] as String,
      type: map['type'] as String,
      askAgainAfterDays: map['askAgainAfterDays'] as int,
      config: configMap,
    );
  }

  Future<List<Question>> fetchQuestions() async {
    final db = await database;
    final result = await db.query('questions');
    return result.map((q) => _mapToQuestion(q)).toList();
  }

  Future<Question?> fetchQuestionById(int id) async {
    final db = await database;
    final result = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return _mapToQuestion(result.first);
    }
    return null;
  }

  Future<List<Question>> getVisibleQuestions() async {
    final db = await database;
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);

    final qRows = await db.query('questions');
    final questions = <Question>[];

    for (final qMap in qRows) {
      final question = _mapToQuestion(qMap);

      final answerRes = await db.query(
        'answers',
        where: 'questionId = ?',
        whereArgs: [question.id],
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      if (answerRes.isEmpty) {
        questions.add(question); // never answered before
      } else {
        final lastAnswerDateTime =
            DateTime.parse(answerRes.first['timestamp'] as String);
        final nextAvailableDateTime =
            lastAnswerDateTime.add(Duration(days: question.askAgainAfterDays));

        final nextAvailableDateOnly = DateTime(nextAvailableDateTime.year,
            nextAvailableDateTime.month, nextAvailableDateTime.day);

        if (!nowDate.isBefore(nextAvailableDateOnly)) {
          questions.add(question); // eligible again
        }
      }
    }

    return questions;
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    int result = 0;
    await db.transaction((txn) async {
      // Delete associated answers first
      await txn.delete(
        'answers',
        where: 'questionId = ?',
        whereArgs: [id],
      );
      // Then delete the question
      result = await txn.delete(
        'questions',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    return result; // This will be the result of deleting the question row
  }

  Future<int> updateQuestionAskAgainAfterDays(
      int id, int newAskAgainAfterDays) async {
    final db = await database;
    return await db.update(
      'questions', // Table name
      {'askAgainAfterDays': newAskAgainAfterDays}, // Values to update
      where: 'id = ?', // Where clause
      whereArgs: [id], // Arguments for where clause
    );
  }

  // ANSWERS

  Future<int> insertAnswer(Answer answer) async {
    final db = await database;
    return await db.insert('answers', answer.toMap());
  }

  Future<List<Answer>> fetchAnswersForQuestion(int questionId) async {
    final db = await database;
    final result = await db.query(
      'answers',
      where: 'questionId = ?',
      whereArgs: [questionId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => Answer.fromMap(map)).toList();
  }

  Future<Answer?> fetchAnswerForToday(int questionId, String date) async {
    final db = await database;
    // TODO: Using `LIKE` for date matching on a timestamp string can be problematic
    // if timestamps are not stored in a consistent UTC format or if local time
    // complexities (like DST) are involved. Consider storing dates as epoch/ISO 8601 UTC
    // and using date functions if the DB supports them, or fetching relevant range and filtering in Dart.
    final result = await db.query(
      'answers',
      where: 'questionId = ? AND timestamp LIKE ?',
      whereArgs: [questionId, '$date%'], // Match date part of the timestamp
    );
    if (result.isNotEmpty) {
      return Answer.fromMap(result.first);
    }
    return null;
  }

  Future<List<Answer>> getAllAnswers() async {
    final db = await database;
    final maps = await db.query('answers');
    return maps.map((map) => Answer.fromMap(map)).toList();
  }
}
