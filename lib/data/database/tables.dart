class Tables {
  // Tasks Table
  static const String tasks = '''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      dueDate TEXT NOT NULL,
      dueTime TEXT,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      isRepeated INTEGER NOT NULL DEFAULT 0,
      repeatType TEXT,
      repeatDays TEXT,
      createdAt TEXT NOT NULL,
      completedAt TEXT,
      progress INTEGER NOT NULL DEFAULT 0
    )
  ''';

  // Subtasks Table
  static const String subtasks = '''
    CREATE TABLE subtasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      taskId INTEGER NOT NULL,
      title TEXT NOT NULL,
      isCompleted INTEGER NOT NULL DEFAULT 0,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
    )
  ''';

  // Get all create table statements
  static List<String> getAllTables() {
    return [tasks, subtasks];
  }
}
