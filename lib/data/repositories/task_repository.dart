import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Task Operations
  Future<int> addTask(TaskModel task) async {
    return await _dbHelper.insertTask(task);
  }

  Future<List<TaskModel>> getAllTasks() async {
    return await _dbHelper.getAllTasks();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    return await _dbHelper.getTodayTasks();
  }

  Future<List<TaskModel>> getCompletedTasks() async {
    return await _dbHelper.getCompletedTasks();
  }

  Future<List<TaskModel>> getRepeatedTasks() async {
    return await _dbHelper.getRepeatedTasks();
  }

  Future<TaskModel?> getTaskById(int id) async {
    return await _dbHelper.getTaskById(id);
  }

  Future<int> updateTask(TaskModel task) async {
    return await _dbHelper.updateTask(task);
  }

  Future<int> deleteTask(int id) async {
    return await _dbHelper.deleteTask(id);
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    return await _dbHelper.markTaskCompleted(id, isCompleted);
  }

  // Subtask Operations
  Future<int> addSubtask(SubtaskModel subtask) async {
    final result = await _dbHelper.insertSubtask(subtask);
    await _dbHelper.updateTaskProgress(subtask.taskId);
    return result;
  }

  Future<List<SubtaskModel>> getSubtasksByTaskId(int taskId) async {
    return await _dbHelper.getSubtasksByTaskId(taskId);
  }

  Future<int> updateSubtask(SubtaskModel subtask) async {
    final result = await _dbHelper.updateSubtask(subtask);
    await _dbHelper.updateTaskProgress(subtask.taskId);
    return result;
  }

  Future<int> deleteSubtask(int id, int taskId) async {
    final result = await _dbHelper.deleteSubtask(id);
    await _dbHelper.updateTaskProgress(taskId);
    return result;
  }

  Future<int> toggleSubtaskCompletion(
    int id,
    int taskId,
    bool isCompleted,
  ) async {
    final result = await _dbHelper.toggleSubtaskCompletion(id, isCompleted);
    await _dbHelper.updateTaskProgress(taskId);
    return result;
  }
}
