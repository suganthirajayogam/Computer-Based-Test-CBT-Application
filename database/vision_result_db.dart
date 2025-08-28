import 'package:computer_based_test/models/Vision_result_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // 👈 Import the package
 
class VisionExamResultDB {
  static final VisionExamResultDB instance = VisionExamResultDB._init();
  static Database? _database;
 
  VisionExamResultDB._init();
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vision_exam_result.db');
    return _database!;
  }
 
  Future<Database> _initDB(String filePath) async {
    try {
      // Get the current working directory of the application
      // This is the directory where your project is running
      final currentDirectory = Directory.current;
 
      // Create a 'CBT' directory inside the project folder
      final dataDirectory = Directory(join(currentDirectory.path, 'CBT'));
 
      // Create the 'CBT' directory if it doesn't exist
      if (!await dataDirectory.exists()) {
        await dataDirectory.create(recursive: true);
        print("📂 'CBT' directory created at: ${dataDirectory.path}");
      }
 
      final path = join(dataDirectory.path, filePath);
 
      print("📂 Opening database at: $path");
 
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
 
      return db;
    } catch (e) {
      print("❌ Error initializing DB: $e");
      rethrow;
    }
  }
 
  // The rest of the class remains unchanged...
  Future<void> _createDB(Database db, int version) async {
    try {
      print("🛠 Creating vision_exam_result table...");
      await db.execute('''
        CREATE TABLE vision_exam_result (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empId TEXT,
          empName TEXT,
          module TEXT,
          questionId INTEGER,
          questionText TEXT,
          correctAnswer TEXT,
          selectedAnswer TEXT,
          selectedReasons TEXT
        )
      ''');
 
      print("🛠 Creating vision_exam_result_summary table...");
      await db.execute('''
        CREATE TABLE vision_exam_result_summary (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          empId TEXT,
          empName TEXT,
          module TEXT,
          score INTEGER,
          percentage REAL,
          status TEXT,
          date TEXT
        )
      ''');
 
      print("✅ Tables created successfully.");
    } catch (e) {
      print("❌ Error creating tables: $e");
    }
  }
 
  Future<void> insertResult(VisionExamResultModel result) async {
    try {
      final db = await instance.database;
      await db.insert(
        'vision_exam_result',
        result.toMap(),
        // conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("❌ Error inserting result: $e");
    }
  }
 
  Future<void> insertResultSummary(VisionExamResultSummaryModel summary) async {
    try {
      final db = await instance.database;
 
      // Convert the summary object to a map for printing
      final Map<String, dynamic> dataToInsert = summary.toMap();
 
      // Print the data to the console
      print("📋 Inserting into vision_exam_result_summary:");
      print(dataToInsert);
 
      await db.insert(
        'vision_exam_result_summary',
        dataToInsert,
        // conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("✅ Successfully inserted data.");
    } catch (e) {
      print("❌ Error inserting summary: $e");
    }
  }
 
  Future<List<VisionExamResultModel>> fetchResults(
      String empId, String module) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'vision_exam_result',
        where: 'empId = ? AND module = ?',
        whereArgs: [empId, module],
      );
      return maps.map((e) => VisionExamResultModel.fromMap(e)).toList();
    } catch (e) {
      print("❌ Error fetching results: $e");
      return [];
    }
  }
 
  Future<List<VisionExamResultModel>> fetchAllResults() async {
    try {
      final db = await instance.database;
      final result = await db.query('vision_exam_result');
      return result.map((e) => VisionExamResultModel.fromMap(e)).toList();
    } catch (e) {
      print("❌ Error fetching all results: $e");
      return [];
    }
  }
 
  Future<List<VisionExamResultSummaryModel>> getAllSummaryResults() async {
    try {
      final db = await instance.database;
      final result = await db.query('vision_exam_result_summary');
      return result
          .map((e) => VisionExamResultSummaryModel.fromMap(e))
          .toList();
    } catch (e) {
      print('❌ Error fetching summary results: $e');
      return [];
    }
  }
 
  Future<void> deleteResults(String empId, String module) async {
    try {
      final db = await instance.database;
      await db.delete(
        'vision_exam_result',
        where: 'empId = ? AND module = ?',
        whereArgs: [empId, module],
      );
      await db.delete(
        'vision_exam_result_summary',
        where: 'empId = ? AND module = ?',
        whereArgs: [empId, module],
      );
    } catch (e) {
      print("❌ Error deleting results: $e");
    }
  }
 
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
 
 