import 'dart:convert';
import 'dart:io';
import 'package:askyourself/db/database_helper.dart';
import 'package:askyourself/models/answer_model.dart';
import 'package:askyourself/models/question_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
// Import path_provider for getting the downloads directory, though FilePicker handles path selection.
// For direct file saving without picker, path_provider would be more relevant.
// import 'package:path_provider/path_provider.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  Future<void> exportDatabase() async {
    if (kIsWeb) {
      // Web implementation might differ (e.g., download via anchor tag)
      await _exportDatabaseWeb();
      return;
    }

    // Mobile/Desktop specific permission for external storage
    if (Platform.isAndroid || Platform.isIOS) {
       // For Android, specific storage permissions might be nuanced based on SDK level
      // For simplicity, using Permission.storage, but more specific ones like
      // Permission.manageExternalStorage might be needed for broader access on Android 11+
      // However, for user-selected paths via file_picker, direct broad storage permission
      // might not be strictly necessary as the picker handles access.
      // Let's stick to Permission.storage for now.
      if (!await _requestPermission(Permission.storage)) {
        throw Exception("Storage permission not granted");
      }
    }

    final questions = await _dbHelper.fetchQuestions();
    final answers = await _dbHelper.getAllAnswers();

    final List<Map<String, dynamic>> questionMaps = questions
        .map((q) => {
              'id': q.id, // Keep original ID for reference during export
              'text': q.text,
              'type': q.type,
              'askAgainAfterDays': q.askAgainAfterDays,
              'config': q.config,
            })
        .toList();

    final List<Map<String, dynamic>> answerMaps =
        answers.map((a) => a.toMap()).toList();

    final Map<String, dynamic> data = {
      'questions': questionMaps,
      'answers': answerMaps,
    };

    final String jsonString = jsonEncode(data);

    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'askyourself.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        if (kDebugMode) {
          print('Database exported to $outputFile');
        }
      } else {
        if (kDebugMode) {
          print('No output file selected.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting database: $e');
      }
      throw Exception("Error exporting database: $e");
    }
  }

  Future<void> _exportDatabaseWeb() async {
    // Web export logic
    final questions = await _dbHelper.fetchQuestions();
    final answers = await _dbHelper.getAllAnswers();

    final List<Map<String, dynamic>> questionMaps = questions
        .map((q) => {
              'id': q.id,
              'text': q.text,
              'type': q.type,
              'askAgainAfterDays': q.askAgainAfterDays,
              'config': q.config,
            })
        .toList();

    final List<Map<String, dynamic>> answerMaps = answers.map((a) => a.toMap()).toList();

    final Map<String, dynamic> data = {
      'questions': questionMaps,
      'answers': answerMaps,
    };
    final String jsonString = jsonEncode(data);
    final List<int> bytes = utf8.encode(jsonString);

    // Use html.AnchorElement to trigger download on web
    // This requires 'dart:html' which is not available in non-web environments.
    // Conditional import or a web-specific service implementation is needed.
    // For now, this is a placeholder for web export.
    if (kDebugMode) {
      print("Web export initiated. Data (first 100 chars): ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}");
      // In a real web app, you'd use:
      // final blob = html.Blob([bytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute("download", "askyourself.json")
      //   ..click();
      // html.Url.revokeObjectUrl(url);
    }
  }


  Future<void> importDatabase() async {
    if (kIsWeb) {
      await _importDatabaseWeb();
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
        if (!await _requestPermission(Permission.storage)) {
            throw Exception("Storage permission not granted");
        }
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        final List<dynamic> questionList = data['questions'] as List<dynamic>;
        final List<dynamic> answerList = data['answers'] as List<dynamic>;

        Map<int, int> oldToNewQuestionIdMap = {};

        // Import Questions
        for (var qData in questionList) {
          final questionMap = qData as Map<String, dynamic>;
          final oldQuestionId = questionMap['id'] as int?; // ID from JSON

          // Create a Question object from map. Assuming Question model has fromMap or similar constructor.
          // For this example, we'll manually map, but a Question.fromMap is better.
          Question questionToImport = Question(
            // id: null, // Let DB assign new ID
            text: questionMap['text'] as String,
            type: questionMap['type'] as String,
            askAgainAfterDays: questionMap['askAgainAfterDays'] as int,
            config: questionMap['config'] != null ? Map<String, dynamic>.from(questionMap['config']) : {},
          );

          // Check if question exists (e.g., by text) to avoid duplicates or to update.
          // This requires a method in DatabaseHelper like `fetchQuestionByText`.
          // For simplicity, we'll assume new questions are inserted, and updates are handled if IDs match.
          // However, since JSON IDs might not match DB IDs after previous imports/exports,
          // a more robust check (e.g., by text or a unique content hash) is needed.
          // Let's assume `insertOrUpdateQuestion` handles this logic based on content.

          final newQuestionId = await _dbHelper.insertOrUpdateQuestion(questionToImport);

          if (oldQuestionId != null) {
            oldToNewQuestionIdMap[oldQuestionId] = newQuestionId;
          }
        }

        // Import Answers
        for (var aData in answerList) {
          final answerMap = aData as Map<String, dynamic>;
          final oldQuestionId = answerMap['questionId'] as int?;
          int? newQuestionId = oldQuestionId != null ? oldToNewQuestionIdMap[oldQuestionId] : null;

          if (newQuestionId != null) { // Only import answers for which we found/created a question
            Answer answerToImport = Answer(
              // id: null, // Let DB assign new ID
              questionId: newQuestionId,
              content: answerMap['content'] as String,
              timestamp: DateTime.parse(answerMap['timestamp'] as String),
            );

            // Similar to questions, check for existing answers to avoid duplicates or to update.
            // This might involve checking questionId and timestamp.
            // Let's assume `insertOrUpdateAnswer` handles this.
            await _dbHelper.insertOrUpdateAnswer(answerToImport);
          } else {
            if (kDebugMode) {
              print("Skipping answer for old question ID $oldQuestionId as it was not mapped to a new ID.");
            }
          }
        }
        if (kDebugMode) {
          print('Database imported successfully.');
        }
      } else {
        if (kDebugMode) {
          print('No file selected or file path is null.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing database: $e');
      }
      throw Exception("Error importing database: $e");
    }
  }

  Future<void> _importDatabaseWeb() async {
    // Web import logic
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important for web to get file content
      );

      if (result != null && result.files.single.bytes != null) {
        final List<int> fileBytes = result.files.single.bytes!;
        final String jsonString = utf8.decode(fileBytes);
        final Map<String, dynamic> data = jsonDecode(jsonString);

        final List<dynamic> questionList = data['questions'] as List<dynamic>;
        final List<dynamic> answerList = data['answers'] as List<dynamic>;

        Map<int, int> oldToNewQuestionIdMap = {};

        for (var qData in questionList) {
          final questionMap = qData as Map<String, dynamic>;
          final oldQuestionId = questionMap['id'] as int?;
          Question questionToImport = Question(
            text: questionMap['text'] as String,
            type: questionMap['type'] as String,
            askAgainAfterDays: questionMap['askAgainAfterDays'] as int,
            config: questionMap['config'] != null ? Map<String, dynamic>.from(questionMap['config']) : {},
          );
          final newQuestionId = await _dbHelper.insertOrUpdateQuestion(questionToImport);
          if (oldQuestionId != null) {
            oldToNewQuestionIdMap[oldQuestionId] = newQuestionId;
          }
        }

        for (var aData in answerList) {
          final answerMap = aData as Map<String, dynamic>;
          final oldQuestionId = answerMap['questionId'] as int?;
          int? newQuestionId = oldQuestionId != null ? oldToNewQuestionIdMap[oldQuestionId] : null;

          if (newQuestionId != null) {
            Answer answerToImport = Answer(
              questionId: newQuestionId,
              content: answerMap['content'] as String,
              timestamp: DateTime.parse(answerMap['timestamp'] as String),
            );
            await _dbHelper.insertOrUpdateAnswer(answerToImport);
          }
        }
        if (kDebugMode) {
          print('Database imported successfully (Web).');
        }
      } else {
         if (kDebugMode) {
          print('No file selected or file data is null (Web).');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing database (Web): $e');
      }
      throw Exception("Error importing database (Web): $e");
    }
  }
}
