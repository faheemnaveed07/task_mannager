import 'package:flutter/material.dart';
import 'package:task_manager/presentation/screens/homes/home_screen.dart';

import '../../presentation/screens/today_tasks/today_tasks_screen.dart';
import '../../presentation/screens/completed_tasks/completed_tasks_screen.dart';
import '../../presentation/screens/repeated_tasks/repeated_tasks_screen.dart';
import '../../presentation/screens/add_edit_task/add_edit_task_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String todayTasks = '/today-tasks';
  static const String completedTasks = '/completed-tasks';
  static const String repeatedTasks = '/repeated-tasks';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      todayTasks: (context) => const TodayTasksScreen(),
      completedTasks: (context) => const CompletedTasksScreen(),
      repeatedTasks: (context) => const RepeatedTasksScreen(),
      addTask: (context) => const AddEditTaskScreen(),
      // editTask route ko onGenerateRoute mein handle karna behtar hai
      settings: (context) => const SettingsScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // FIX: Switch statement replaced with if-else if to avoid compile-time constant error
    final name = settings.name;

    if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == todayTasks) {
      return MaterialPageRoute(builder: (_) => const TodayTasksScreen());
    } else if (name == completedTasks) {
      return MaterialPageRoute(builder: (_) => const CompletedTasksScreen());
    } else if (name == repeatedTasks) {
      return MaterialPageRoute(builder: (_) => const RepeatedTasksScreen());
    } else if (name == addTask) {
      return MaterialPageRoute(builder: (_) => const AddEditTaskScreen());
    } else if (name == editTask) {
      final taskId = settings.arguments as int?;
      return MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(taskId: taskId),
      );
    } else if (name == settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else {
      // Default (404) route
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text('No route defined for $name'))),
      );
    }
  }
}
