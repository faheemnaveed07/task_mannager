import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/models/subtask_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../core/utils/notification_helper.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final NotificationHelper _notificationHelper = NotificationHelper.instance;

  List<TaskModel> _allTasks = [];
  List<TaskModel> _todayTasks = [];
  List<TaskModel> _completedTasks = [];
  List<TaskModel> _repeatedTasks = [];
  Map<int, List<SubtaskModel>> _subtasksMap = {};

  bool _isLoading = false;
  String? _error;

  // Getters
  List<TaskModel> get allTasks => _allTasks;
  List<TaskModel> get todayTasks => _todayTasks;
  List<TaskModel> get completedTasks => _completedTasks;
  List<TaskModel> get repeatedTasks => _repeatedTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get subtasks for a specific task
  List<SubtaskModel> getSubtasksForTask(int taskId) {
    return _subtasksMap[taskId] ?? [];
  }

  // Initialize and load all data
  Future<void> initialize() async {
    await loadAllTasks();
    await loadTodayTasks();
    await loadCompletedTasks();
    await loadRepeatedTasks();
  }

  // Load all tasks
  Future<void> loadAllTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allTasks = await _repository.getAllTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load today's tasks
  Future<void> loadTodayTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todayTasks = await _repository.getTodayTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load completed tasks
  Future<void> loadCompletedTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _completedTasks = await _repository.getCompletedTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load repeated tasks
  Future<void> loadRepeatedTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _repeatedTasks = await _repository.getRepeatedTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new task
  // 💡 FIXED: Now returns the new Task ID (int?) instead of bool.
  Future<int?> addTask(TaskModel task) async {
    try {
      _error = null;

      final taskId = await _repository.addTask(task);

      // Schedule notification if time is set
      if (task.dueTime != null) {
        // taskId is the newly generated ID from the database
        final taskWithId = task.copyWith(id: taskId);
        await _notificationHelper.scheduleTaskNotification(taskWithId);
      }

      await initialize();
      return taskId; // ✅ Return the new Task ID
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null; // ❌ Return null on failure
    }
  }

  // Update task
  Future<bool> updateTask(TaskModel task) async {
    try {
      _error = null;

      await _repository.updateTask(task);

      // Update notification
      if (task.dueTime != null && task.id != null) {
        await _notificationHelper.cancelNotification(task.id!);
        await _notificationHelper.scheduleTaskNotification(task);
      }

      await initialize();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(int id) async {
    try {
      _error = null;

      await _repository.deleteTask(id);
      await _notificationHelper.cancelNotification(id);

      await initialize();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(int id, bool isCompleted) async {
    try {
      _error = null;

      await _repository.toggleTaskCompletion(id, isCompleted);

      // Cancel notification if completed
      if (isCompleted) {
        await _notificationHelper.cancelNotification(id);
      }

      await initialize();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(int id) async {
    try {
      return await _repository.getTaskById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ==================== SUBTASK OPERATIONS ====================

  // Load subtasks for a task
  Future<void> loadSubtasks(int taskId) async {
    try {
      final subtasks = await _repository.getSubtasksByTaskId(taskId);
      _subtasksMap[taskId] = subtasks;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add subtask
  Future<bool> addSubtask(SubtaskModel subtask) async {
    try {
      _error = null;

      await _repository.addSubtask(subtask);
      await loadSubtasks(subtask.taskId);
      await initialize(); // Reload to update progress

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update subtask
  Future<bool> updateSubtask(SubtaskModel subtask) async {
    try {
      _error = null;

      await _repository.updateSubtask(subtask);
      await loadSubtasks(subtask.taskId);
      await initialize();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete subtask
  Future<bool> deleteSubtask(int id, int taskId) async {
    try {
      _error = null;

      await _repository.deleteSubtask(id, taskId);
      await loadSubtasks(taskId);
      await initialize();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle subtask completion
  Future<bool> toggleSubtaskCompletion(
    int id,
    int taskId,
    bool isCompleted,
  ) async {
    try {
      _error = null;

      await _repository.toggleSubtaskCompletion(id, taskId, isCompleted);
      await loadSubtasks(taskId);
      await initialize();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'total': _allTasks.length,
      'completed': _completedTasks.length,
      'pending': _allTasks.where((t) => !t.isCompleted).length,
      'today': _todayTasks.length,
      'repeated': _repeatedTasks.length,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
