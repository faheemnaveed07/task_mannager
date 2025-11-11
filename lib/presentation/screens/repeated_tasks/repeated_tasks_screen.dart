import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/task_card.dart';

class RepeatedTasksScreen extends StatelessWidget {
  const RepeatedTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.repeatedTasks)),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskProvider.repeatedTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 80, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noRepeatedTasks,
                    style: TextStyle(fontSize: 18, color: AppColors.gray600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onToggleComplete: (value) async {
                  if (value != null && task.id != null) {
                    await taskProvider.toggleTaskCompletion(task.id!, value);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
