import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class VisionModuleDB {
  static final VisionModuleDB instance = VisionModuleDB._init();
  static Database? _database;

  VisionModuleDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('visionmoduledb.db');
    return _database!;
  }

 Future<Database> _initDB(String filename) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbDir = join(Directory.current.path, 'CBT');
  await Directory(dbDir).create(recursive: true);
  final path = join(dbDir, filename);

  print('📂 Using Vision DB path: $path');

  return await databaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: _createDB,
      onOpen: (db) => print('✅ Vision DB Opened Successfully'),
    ),
  );
}



Future<void> _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE vision_modules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      module TEXT NOT NULL UNIQUE
    )
  ''');

  await db.execute('''
    CREATE TABLE vision_questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      module TEXT,
      question_text TEXT,
      image_path TEXT,
      correct_answer TEXT,
      allreasons TEXT,     -- ✅ new column for dropdown reasons
      reasons TEXT,
      video_path TEXT
    )
  ''');

  print('✅ Tables "vision_modules" and "vision_questions" created.');
}

  Future<void> insertModule(String module) async {
    try {
      final db = await instance.database;
      final existing = await db.query(
        'vision_modules',
        where: 'module = ?',
        whereArgs: [module],
      );

      if (existing.isEmpty) {
        await db.insert('vision_modules', {'module': module});
        print('✅ Vision Module "$module" inserted.');
      } else {
        print('ℹ️ Vision Module "$module" already exists.');
      }
    } catch (e) {
      print('❌ Error inserting vision module "$module": $e');
    }
  }

  Future<List<String>> getModules() async {
    try {
      final db = await instance.database;
      final result = await db.query('vision_modules');
      return result.map((e) => e['module'].toString()).toList();
    } catch (e) {
      print('❌ Error fetching vision modules: $e');
      return [];
    }
  }

  Future<void> deleteModule(String module) async {
    try {
      final db = await instance.database;
      await db.delete(
        'vision_modules',
        where: 'module = ?',
        whereArgs: [module],
      );
      print('🗑️ Module "$module" deleted.');
    } catch (e) {
      print('❌ Error deleting module "$module": $e');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
