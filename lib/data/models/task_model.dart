class TaskModel {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? dueTime;
  final bool isCompleted;
  final bool isRepeated;
  final String? repeatType; // 'daily', 'weekly', 'custom'
  final String? repeatDays; // JSON string for selected days
  final DateTime createdAt;
  final DateTime? completedAt;
  final int progress; // 0-100 for subtask completion

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.isRepeated = false,
    this.repeatType,
    this.repeatDays,
    required this.createdAt,
    this.completedAt,
    this.progress = 0,
  });

  // Convert Task to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isRepeated': isRepeated ? 1 : 0,
      'repeatType': repeatType,
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  // Create Task from Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      dueTime: map['dueTime'] != null
          ? DateTime.parse(map['dueTime'] as String)
          : null,
      isCompleted: (map['isCompleted'] as int) == 1,
      isRepeated: (map['isRepeated'] as int) == 1,
      repeatType: map['repeatType'] as String?,
      repeatDays: map['repeatDays'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      progress: map['progress'] as int? ?? 0,
    );
  }

  // Copy with method for easy updates
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    bool? isCompleted,
    bool? isRepeated,
    String? repeatType,
    String? repeatDays,
    DateTime? createdAt,
    DateTime? completedAt,
    int? progress,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isRepeated: isRepeated ?? this.isRepeated,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted}';
  }
}
