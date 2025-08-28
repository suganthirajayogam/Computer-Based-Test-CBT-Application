import 'dart:io';
import 'package:computer_based_test/database/accountcreation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/employee.dart';
 
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
 
  DatabaseHelper._privateConstructor();
 
  static const String tableName = 'emp_db';
  static const String columnId = 'id';
  static const String columnEmployeeId = 'employee_id';
  static const String columnEmployeeName = 'employee_name';
  static const String columnModule = 'module';
  static const String columnDepartment = 'department';
  static const String columnMobileNo = 'mobile_no';
  static const String columnImagePath = 'image_path'; // <- added
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
 
  /// Fixed DB path (no XML)
  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
 
    final dbDir = Directory(join(Directory.current.path, 'CBT'));
    if (!await dbDir.exists()) await dbDir.create(recursive: true);
 
    final dbPath = join(dbDir.path, 'emp_db_login.db');
    print('📂 Using DB path: $dbPath');
 
    return await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName (
              $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
              $columnEmployeeId TEXT,
              $columnEmployeeName TEXT,
              $columnModule TEXT,
              $columnDepartment TEXT,
              $columnMobileNo TEXT,
              $columnImagePath TEXT
            )
          ''');
          print('✅ Table $tableName created with full schema including image_path');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            try {
              await db.execute('ALTER TABLE $tableName ADD COLUMN $columnDepartment TEXT');
            } catch (_) {}
            try {
              await db.execute('ALTER TABLE $tableName ADD COLUMN $columnMobileNo TEXT');
            } catch (_) {}
            try {
              await db.execute('ALTER TABLE $tableName ADD COLUMN $columnImagePath TEXT'); // <- added
            } catch (_) {}
          }
        },
      ),
    );
  }
 
  Future<Employee?> getEmployeeByEmployeeId(String empId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: '$columnEmployeeId = ?',
      whereArgs: [empId],
    );
 
    if (result.isNotEmpty) {
      return Employee.fromMap(result.first);
    }
    return null;
  }
 
  Future<int> updateModule(String empId, String newModule) async {
    final db = await database;
    return await db.update(
      tableName,
      {columnModule: newModule},
      where: '$columnEmployeeId = ?',
      whereArgs: [empId],
    );
  }
 
  void login(String enteredEmpId) async {
    final emp = await AccountCreationDB.instance.fetchEmployeeForLogin(enteredEmpId);
    if (emp != null) {
      String empName = emp['employee_name'] ?? '';
      print('✅ Welcome $empName');
      // Navigate to next screen
    } else {
      print('❌ Employee ID not found');
      // Show error dialog
    }
  }
 
  // Add insert, update, delete, and other methods as needed
}
 
 