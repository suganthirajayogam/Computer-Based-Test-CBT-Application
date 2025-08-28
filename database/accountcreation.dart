import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
 
class AccountCreationDB {
  static final AccountCreationDB instance = AccountCreationDB._init();
  static Database? _database;
 
  AccountCreationDB._init();
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('emp_db_login.db');
    return _database!;
  }
 
  Future<Database> _initDB(String fileName) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
 
    // DB directory in "data" folder
    final dbDir = Directory(join(Directory.current.path, 'CBT'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
      print('✅ Created DB directory at: ${dbDir.path}');
    }
 
    final dbPath = join(dbDir.path, fileName);
    print('📂 Using DB path: $dbPath');
 
    final db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
 
    return db;
  }
 
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE emp_db (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL UNIQUE,
        employee_name TEXT NOT NULL,
        department TEXT,
        module TEXT,
        mobile_no TEXT,
        image_path TEXT
      );
    ''');
    print('✅ Table emp_db created successfully');
  }
 
  Future<int> insertEmp(Map<String, dynamic> data, dynamic imagesDir) async {
    try {
      final db = await instance.database;
      final empId = data['employee_id'].toString().trim();
 
      // Check duplicate
      final existing = await db.query(
        'emp_db',
        where: 'employee_id = ?',
        whereArgs: [empId],
      );
      if (existing.isNotEmpty) {
        print('⚠️ Skipped: employee_id $empId already exists.');
        return 0;
      }
 
      // Save image in "data/Emp_Images"
      String fullImagePath = data['image_path']?.toString().trim() ?? '';
      String relativeImagePath = '';
     if (fullImagePath.isNotEmpty && await File(fullImagePath).exists()) {
  final fileName = basename(fullImagePath);
  final newPath = join(imagesDir.path, fileName);
  await File(fullImagePath).copy(newPath);
  relativeImagePath = 'CBT/Emp_Images/$fileName';
}
 
 
      final cleanedData = {
        'employee_id': empId,
        'employee_name': data['employee_name'].toString().trim(),
        'department': data['department']?.toString().trim() ?? '',
        'module': data['module']?.toString().trim() ?? '',
        'mobile_no': data['mobile_no']?.toString().trim() ?? '',
        'image_path': relativeImagePath,
      };
 
      final id = await db.insert('emp_db', cleanedData);
      print('✅ Inserted employee: $cleanedData');
      return id;
    } catch (e) {
      print('❌ Insert error: $e');
      return -1;
    }
  }
 
  Future<int> updateEmp(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('emp_db', data, where: 'id = ?', whereArgs: [id]);
  }
 
  Future<int> deleteEmp(String empId) async {
    try {
      final db = await instance.database;
      print('Trying to delete empId: $empId');
      return await db.delete(
        'emp_db',
        where: 'employee_id = ?',
        whereArgs: [empId.trim()],
      );
    } catch (e) {
      print('❌ Delete error: $e');
      return 0;
    }
  }
 
  Future<int> updateEmpByEmployeeId(String empId, Map<String, dynamic> data) async {
    final db = await instance.database;
 
    if (data.containsKey('image_path')) {
      String fullImagePath = data['image_path']?.toString().trim() ?? '';
      if (fullImagePath.isNotEmpty) {
        final imagesDir = Directory(join(Directory.current.path, 'CBT', 'Emp_Images'));
        if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
        final fileName = basename(fullImagePath);
        final newPath = join(imagesDir.path, fileName);
        await File(fullImagePath).copy(newPath);
        data['image_path'] = 'CBT/Emp_Images/$fileName';
      }
    }
 
    return await db.update(
      'emp_db',
      data,
      where: 'employee_id = ?',
      whereArgs: [empId.trim()],
    );
  }
 
  Future<Map<String, dynamic>?> getEmployeeById(String empId) async {
    final db = await database;
    final result = await db.query(
      'emp_db',
      where: 'employee_id = ?',
      whereArgs: [empId.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }
 
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await instance.database;
    return await db.query('emp_db');
  }
 
  Future<File?> getEmployeeImage(String imagePathFromDb) async {
    try {
      if (imagePathFromDb.isEmpty) return null;
      final file = File(imagePathFromDb);
      return await file.exists() ? file : null;
    } catch (e) {
      debugPrint("Error loading image: $e");
      return null;
    }
  }
 
  Future<Map<String, dynamic>?> fetchEmployeeForLogin(String empId) async {
    try {
      final db = await database;
      final result = await db.query(
        'emp_db',
        where: 'employee_id = ?',
        whereArgs: [empId.trim()],
      );
 
      if (result.isNotEmpty) {
        print('✅ Employee found: ${result.first}');
        return result.first;
      } else {
        print('⚠️ Employee ID not found: $empId');
        return null;
      }
    } catch (e) {
      print('❌ Fetch error: $e');
      return null;
    }
  }
}
 