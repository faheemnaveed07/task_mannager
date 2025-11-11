import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Enable foreign keys
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    final tables = Tables.getAllTables();
    for (var table in tables) {
      await db.execute(table);
    }
  }

  // ==================== TASK OPERATIONS ====================

  // Insert Task
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  // Get All Tasks
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'dueDate ASC');
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Get Today's Tasks
  Future<List<TaskModel>> getTodayTasks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final result = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ? AND isCompleted = 0',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dueDate ASC',
    );

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Get Completed Tasks
  Future<List<TaskModel>> getCompletedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = 1',
      orderBy: 'completedAt DESC',
    );
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Get Repeated Tasks
  Future<List<TaskModel>> getRepeatedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'isRepeated = 1',
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Get Task by ID
  Future<TaskModel?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TaskModel.fromMap(result.first);
    }
    return null;
  }

  // Update Task
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete Task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark Task as Completed
  Future<int> markTaskCompleted(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SUBTASK OPERATIONS ====================

  // Insert Subtask
  Future<int> insertSubtask(SubtaskModel subtask) async {
    final db = await database;
    return await db.insert('subtasks', subtask.toMap());
  }

  // Get Subtasks by Task ID
  Future<List<SubtaskModel>> getSubtasksByTaskId(int taskId) async {
    final db = await database;
    final result = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt ASC',
    );
    return result.map((map) => SubtaskModel.fromMap(map)).toList();
  }

  // Update Subtask
  Future<int> updateSubtask(SubtaskModel subtask) async {
    final db = await database;
    return await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  // Delete Subtask
  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete(
      'subtasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle Subtask Completion
  Future<int> toggleSubtaskCompletion(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'subtasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update Task Progress based on Subtasks
  Future<void> updateTaskProgress(int taskId) async {
    final subtasks = await getSubtasksByTaskId(taskId);
    if (subtasks.isEmpty) {
      await database.then((db) => db.update(
        'tasks',
        {'progress': 0},
        where: 'id = ?',
        whereArgs: [taskId],
      ));
      return;
    }

    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final progress = ((completedCount / subtasks.length) * 100).round();

    await database.then((db) => db.update(
      'tasks',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [taskId],
    ));
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}