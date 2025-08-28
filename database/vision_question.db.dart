import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:sqflite/sqflite.dart';

import '../models/vis_ques_model.dart';
 
class VisionQuestionDB {

  static final VisionQuestionDB instance = VisionQuestionDB._init();

  static Database? _database;
 
  VisionQuestionDB._init();
 
  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB();

    return _database!;

  }
 
  Future<Database> _initDB() async {

    try {

      final directory = Directory.current;

      final dbPath = p.join(directory.path, 'CBT', 'visionmoduledb.db');

      print('📂 Using Vision DB path: $dbPath');
 
      final db = await openDatabase(

        dbPath,

        version: 1,

        onCreate: _createDB,

        onOpen: (db) => print('✅ Vision DB Opened Successfully'),

      );
 
      print('✅ visionmoduledb.db initialized');

      return db;

    } catch (e) {

      print('❌ Failed to initialize Vision DB: $e');

      rethrow;

    }

  }
 
  Future _createDB(Database db, int version) async {

    try {

      await db.execute('''

        CREATE TABLE vision_questions (

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          module TEXT,

          question_text TEXT,

          image_path TEXT,

          correct_answer TEXT,

          allreasons TEXT,

          reasons TEXT,

          video_path TEXT

        )

      ''');

      print('✅ vision_questions table created');
 
      await db.execute('''

        CREATE TABLE IF NOT EXISTS vision_reasons (

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          reason_text TEXT UNIQUE

        )

      ''');

      print('✅ vision_reasons table created');
 
    } catch (e) {

      print('❌ Error creating tables: $e');

    }

  }
 
  Future<void> insertvisionQuestion(VisionQuestionModel question) async {

    final db = await instance.database;
 
    final id = await db.insert('vision_questions', question.toMap());
 
    print('\n✅ Question Inserted Successfully!');

    print('🆔 ID: $id');

    print('📦 Module: ${question.module}');

    print('❓ Question: ${question.questionText}');

    print('📷 Image: ${question.imagePath}');

    print('🎞️ Video: ${question.videoPath}');

    print('✅ Correct Answer: ${question.correctAnswer}');

    print('📋 All Reasons: ${question.allReasons.join(", ")}');

    print('📍 Selected Reasons: ${question.reasons.isNotEmpty ? question.reasons.join(", ") : "None"}\n');

  }
 
  Future<int> updateVisionQuestion(int id, Map<String, dynamic> updatedData) async {

    try {

      final db = await instance.database;

      return await db.update(

        'vision_questions',

        updatedData,

        where: 'id = ?',

        whereArgs: [id],

      );

    } catch (e) {

      print('❌ Error updating vision question: $e');

      return 0;

    }

  }
 
  Future<int> deleteVisionQuestion(int id) async {

    try {

      final db = await instance.database;

      return await db.delete(

        'vision_questions',

        where: 'id = ?',

        whereArgs: [id],

      );

    } catch (e) {

      print('❌ Error deleting vision question: $e');

      return 0;

    }

  }
 
  Future<void> deleteQuestionById(int id) async {

    final db = await instance.database;

    await db.delete('vision_questions', where: 'id = ?', whereArgs: [id]);

  }
 
  Future<void> debugPrintAllQuestions() async {

    final db = await instance.database;

    final result = await db.query('vision_questions');

    print("🗂️ All questions in DB:");

    for (final row in result) {

      print(row);

    }

  }
 
  Future close() async {

    final db = await instance.database;

    await db.close();

    print('🛑 visionmoduledb.db closed');

  }
 
  Future<void> printSchema() async {

    final db = await instance.database;

    final result = await db.rawQuery('PRAGMA table_info(vision_questions)');

    print('📊 Table schema for vision_questions:');

    for (var row in result) {

      print(row);

    }

  }
 
  Future<List<VisionQuestionModel>> getQuestionsByModule(String module) async {

    final db = await instance.database;

    final result = await db.query(

      'vision_questions',

      where: 'module = ?',

      whereArgs: [module],

    );
 
    for (final row in result) {

      print('📥 Raw DB row: $row');

    }
 
    final questions = result.map((e) => VisionQuestionModel.fromMap(e)).toList();
 
    for (final q in questions) {

      print('📦 Question: ${q.questionText}, AllReasons: ${q.allReasons}, Selected: ${q.reasons}');

    }
 
    return questions;

  }
 
  // ✅ GLOBAL REASON TABLE FUNCTIONS
 
  Future<void> insertReason(String reason) async {

    final db = await instance.database;

    try {

      await db.insert(

        'vision_reasons',

        {'reason_text': reason},

        conflictAlgorithm: ConflictAlgorithm.ignore,

      );

      print('➕ Reason added: $reason');

    } catch (e) {

      print('❌ Error inserting reason: $e');

    }

  }
 
  Future<List<String>> getAllReasons() async {

    final db = await instance.database;

    final result = await db.query('vision_reasons', orderBy: 'reason_text ASC');

    return result.map((row) => row['reason_text'] as String).toList();

  }
 
  Future<void> deleteReason(String reason) async {

    final db = await instance.database;

    await db.delete('vision_reasons', where: 'reason_text = ?', whereArgs: [reason]);

    print('🗑️ Reason deleted: $reason');

  }

}

 
