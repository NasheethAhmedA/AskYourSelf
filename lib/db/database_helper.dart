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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dbPath = await getDatabasesPath();
    final path = kIsWeb ? 'ask_your_self.db' : join(dbPath, 'ask_your_self.db');

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
        answer TEXT NOT NULL,
        date TEXT NOT NULL
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

  Future<List<Question>> fetchQuestions() async {
    final db = await database;
    final result = await db.query('questions');
    return result.map((q) {
      final rawConfig = q['config'] as String?;
      final configMap = rawConfig != null
          ? Map<String, dynamic>.from(jsonDecode(rawConfig) as Map)
          : <String, dynamic>{};

      return Question(
        id: q['id'] as int,
        text: q['text'] as String,
        type: q['type'] as String,
        askAgainAfterDays: q['askAgainAfterDays'] as int,
        config: configMap,
      );
    }).toList();
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
      orderBy: 'date DESC',
    );
    return result.map((map) => Answer.fromMap(map)).toList();
  }

  Future<Answer?> fetchAnswerForToday(int questionId, String date) async {
    final db = await database;
    final result = await db.query(
      'answers',
      where: 'questionId = ? AND date = ?',
      whereArgs: [questionId, date],
    );
    if (result.isNotEmpty) {
      return Answer.fromMap(result.first);
    }
    return null;
  }
}
