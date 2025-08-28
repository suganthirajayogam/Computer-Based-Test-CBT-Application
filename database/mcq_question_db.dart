import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
 
class MCQQuestionDatabase {
  static final MCQQuestionDatabase instance = MCQQuestionDatabase._init();
  static Database? _database;
 
  MCQQuestionDatabase._init();
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
 
  Future<Database> _initDB() async {
    final dbPath = join(Directory.current.path, 'CBT', 'questions.db');
    final directory = Directory(join(Directory.current.path, 'CBT'));
 
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
 
    return await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }
 
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mcq_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT,
        questionText TEXT,
        questionImagePath TEXT,
        optionA TEXT,
        optionAImagePath TEXT,
        optionB TEXT,
        optionBImagePath TEXT,
        optionC TEXT,
        optionCImagePath TEXT,
        optionD TEXT,
        optionDImagePath TEXT,
        correctAnswer TEXT
      )
    ''');
  }
 
  // Insert
  Future<int> insertQuestion(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('mcq_questions', data);
  }
 
  // Get by subject
  Future<List<MCQQuestion>> getQuestionsBySubject(String subject) async {
    final db = await instance.database;
    final result = await db.query(
      'mcq_questions',
      where: 'subject = ?',
      whereArgs: [subject],
    );
    return result.map((q) => MCQQuestion.fromMap(q)).toList();
  }
 
  // Update
  Future<int> updateQuestion(int id, Map<String, dynamic> updatedData) async {
    final db = await instance.database;
    return await db.update(
      'mcq_questions',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
 
  // Delete
  Future<int> deleteQuestion(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mcq_questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
 
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
 
 