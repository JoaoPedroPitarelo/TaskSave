import 'package:sqflite/sqflite.dart';

class LocalDataBaseService {
  static final LocalDataBaseService _instance = LocalDataBaseService._private();
  static Database? _database;

  LocalDataBaseService._private();

  factory LocalDataBaseService() {
    return _instance;
  }

  static Future<Database> get database async {
    _database ??= await _instance._initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/my_database.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        id INTEGER PRIMARY KEY,
        login TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attachment (
        id INTEGER PRIMARY KEY,
        task_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL,
        local_file_path TEXT,
        is_downloaded BOOLEAN NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> closeConnection() async {
    await _database?.close();
  }
}
