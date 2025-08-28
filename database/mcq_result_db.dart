import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:computer_based_test/models/exam_result.dart';
 
// The database class remains largely the same.
// The key is to simply not use the update function.
class ExamResultDatabase {
  static final ExamResultDatabase instance = ExamResultDatabase._init();

  static Database? _database;

  ExamResultDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exam_results.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // Make sure data folder exists inside the project root
    final dataDir = Directory(join(Directory.current.path, 'CBT'));
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    // Database path inside 'CBT' folder
    final path = join(dataDir.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table for individual question results
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empId TEXT,
        empName TEXT,
        subject TEXT,
        module TEXT,
        questionId INTEGER,
        questionText TEXT,
        correctAnswer TEXT,
        attempted TEXT,
        imagePath TEXT,
        totalQuestions INTEGER
      )
    ''');

    // Table for summary results
    await db.execute('''
      CREATE TABLE result_summary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empId TEXT,
        empName TEXT,
        subject TEXT,
        module TEXT,
        totalQuestions INTEGER,
        attempted INTEGER,
        correct INTEGER,
        score INTEGER,
        percentage REAL,
        status TEXT,
        date TEXT
      )
    ''');
  }

  // Insert detailed question result
  Future<void> insertResult(ExamResult result) async {
    final db = await instance.database;
    await db.insert('results', result.toMap());
  }

  // Insert summary result (this is the correct method to use)
  Future<void> insertSummary(ExamResultSummary summary) async {
    if (summary.empId == null || summary.empId!.isEmpty) {
      throw Exception("empId is required for inserting summary result");
    }

    final db = await instance.database;
    await db.insert(
      'result_summary',
      summary.toMap(),
    );
  }

  // Get all results
  Future<List<Map<String, dynamic>>> getAllResults() async {
    final db = await instance.database;
    return await db.query('results');
  }

  // Get all summaries (this will now return all past test results)
  Future<List<Map<String, dynamic>>> getAllSummaries() async {
    final db = await instance.database;
    return await db.query('result_summary');
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  // *** IMPORTANT: Remove this function as it causes the overwrite issue ***
  // Future<int> updateEmpByEmployeeId(String empId, Map<String, Object?> updateData) async {
  //   final db = await instance.database;
  //   return await db.update(
  //     'result_summary',
  //     updateData,
  //     where: 'empId = ?',
  //     whereArgs: [empId],
  //   );
  // }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await instance.database;
    final result = await db.query('result_summary');
    return result;
  }
}