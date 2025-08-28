import 'dart:io';
import 'package:computer_based_test/models/admin_log.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
 
class AdminDatabase {
  static final AdminDatabase instance = AdminDatabase._init();
  static Database? _database;
 
  AdminDatabase._init();
 
  Future<Database> get database async {
    if (_database != null) return _database!;
 
    //  Init FFI just for this class
    sqfliteFfiInit();
 
    final dbFactory = databaseFactoryFfi; //  Only local, not global
 
    final dbPath = join(Directory.current.path, 'CBT', 'admin_login.db');
 
    _database = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
 
    return _database!;
  }
 
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admins (
        username TEXT PRIMARY KEY,
        password TEXT NOT NULL
      )
    ''');
  }
 
  Future<void> insertAdmin(Admin admin) async {
    final db = await database;
    await db.insert(
      'admins',
      admin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
 
  Future<Admin?> getAdminByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'admins',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return Admin.fromMap(result.first);
    }
    return null;
  }
 
  Future<bool> hasAnyAdmin() async {
    final db = await database;
    final result = await db.query('admins');
    return result.isNotEmpty;
  }
}
 