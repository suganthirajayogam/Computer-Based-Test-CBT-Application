import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:computer_based_test/models/mcq_emp_login.dart';

class MCQEmployeeDatabase {
  static final MCQEmployeeDatabase instance = MCQEmployeeDatabase._init();
  static Database? _database;

  MCQEmployeeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mcq_employee.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // ✅ Use custom folder under project root
    final directory = Directory.current.path;
    final dbFolder = Directory(join(directory, 'CBT'));

    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }

    final path = join(dbFolder.path, fileName);
    print(' MCQ DB Path: $path');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mcq_employees (
        empId TEXT PRIMARY KEY,
        name TEXT,
        department TEXT,
        dob TEXT,
        subject TEXT,
        email TEXT,
        phone TEXT
      )
    ''');
  }

  Future<void> insertEmployee(MCQEmployee emp) async {
    final db = await instance.database;
    await db.insert(
      'mcq_employees',
      emp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MCQEmployee>> getAllEmployees() async {
    final db = await instance.database;
    final result = await db.query('mcq_employees');
    return result.map((json) => MCQEmployee(
      empId: json['empId'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      dob: json['dob'] as String,
      subject: json['subject'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    )).toList();
  }
}
