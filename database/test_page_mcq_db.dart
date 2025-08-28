import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';

class MCQDatabaseHelper {
  static final MCQDatabaseHelper instance = MCQDatabaseHelper._init();
  static Database? _database;

  MCQDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mcq_questions.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mcq_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        questionImagePath TEXT,
        optionA TEXT,
        optionAImagePath TEXT,
        optionB TEXT,
        optionBImagePath TEXT,
        optionC TEXT,
        optionCImagePath TEXT,
        optionD TEXT,
        optionDImagePath TEXT,
        correctAnswer TEXT,
        subject TEXT
      )
    ''');
  }

  Future<List<MCQQuestion>> getQuestionsBySubject(String subject) async {
    final db = await instance.database;
    final result = await db.query(
      'mcq_questions',
      where: 'subject = ?',
      whereArgs: [subject],
    );

    return result.map((map) => MCQQuestion.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
