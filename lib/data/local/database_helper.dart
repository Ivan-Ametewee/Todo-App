import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'todo_app.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        tag TEXT NOT NULL,
        deadline INTEGER NOT NULL,
        notifyBefore INTEGER NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    try {
      final db = await database;
      return await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting task: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      
      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<int> deleteTask(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'todo_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}