import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'user.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            name TEXT
          )
        ''');

        // ایجاد جدول وظایف
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            dueDate TEXT,
            priority TEXT,
            isCompleted INTEGER
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              dueDate TEXT,
              priority TEXT,
              isCompleted INTEGER
            )
          ''');
        }
      },
    );
  }

  Future<int> registerUser(
      String username, String password, String name) async {
    final dbClient = await db;
    return await dbClient.insert('users', {
      'username': username,
      'password': password,
      'name': name,
    });
  }

  Future<Map?> getUser(String username, String password) async {
    final dbClient = await db;
    List<Map> result = await dbClient.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> checkUsernameExists(String username) async {
    final dbClient = await db;
    List<Map> result = await dbClient.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final dbClient = await db;
    return await dbClient.query('tasks');
  }

  Future<int> addTask(String title, String description, DateTime dueDate,
      String priority) async {
    final dbClient = await db;
    return await dbClient.insert('tasks', {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': 0,
    });
  }

  Future<int> updateTaskCompletion(int id, bool isCompleted) async {
    final dbClient = await db;
    return await dbClient.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
