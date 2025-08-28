import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class ModuleDatabase {
  static final ModuleDatabase instance = ModuleDatabase._init();
  static Database? _database;

  ModuleDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('modules.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // ✅ Save database inside a local "data" folder
      final dbDir = join(Directory.current.path, 'CBT');
      await Directory(dbDir).create(recursive: true); // Create folder if missing
      final path = join(dbDir, fileName);

      print('📁 Using Module DB path: $path');

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } catch (e) {
      print('❌ Error initializing module database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE modules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> insertModule(String module) async {
    try {
      final db = await instance.database;

      // Avoid duplicates
      final existing = await db.query(
        'modules',
        where: 'module = ?',
        whereArgs: [module],
      );

      if (existing.isEmpty) {
        await db.insert('modules', {'module': module});
        print('✅ Module "$module" inserted.');
      } else {
        print('ℹ️ Module "$module" already exists.');
      }
    } catch (e) {
      print('❌ Error inserting module "$module": $e');
    }
  }

  Future<List<String>> getModules() async {
    try {
      final db = await instance.database;
      final result = await db.query('modules');
      final modules = result.map((e) => e['module'].toString()).toList();
      print('📥 Fetched modules from DB: $modules');
      return modules;
    } catch (e) {
      print('❌ Error while fetching modules: $e');
      return [];
    }
  }

  Future<void> deleteModule(String module) async {
    try {
      final db = await instance.database;
      final rowsDeleted = await db.delete(
        'modules',
        where: 'module = ?',
        whereArgs: [module],
      );
      print('🗑️ Module "$module" deleted. Rows affected: $rowsDeleted');
    } catch (e) {
      print('❌ Error deleting module "$module": $e');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
