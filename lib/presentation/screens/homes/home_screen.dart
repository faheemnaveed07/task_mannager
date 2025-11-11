import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/export_helper.dart';

import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isExporting = false;

  final List<String> _titles = [
    AppStrings.todayTasks,
    AppStrings.completedTasks,
    AppStrings.repeatedTasks,
    AppStrings.allTasks,
  ];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // Export Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_upload),
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: AppColors.errorLight),
                    SizedBox(width: 8),
                    Text(AppStrings.exportToPDF),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(AppStrings.exportToCSV),
                  ],
                ),
              ),
            ],
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: _isExporting
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _refreshTasks, child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addTask);
          _refreshTasks();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          NavigationDestination(icon: Icon(Icons.repeat), label: 'Repeated'),
          NavigationDestination(icon: Icon(Icons.list), label: 'All'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = _getTasksForIndex(taskProvider);

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 80, color: AppColors.gray400),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(),
                  style: TextStyle(fontSize: 18, color: AppColors.gray600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.editTask,
                  arguments: task.id,
                );
                _refreshTasks();
              },
              onToggleComplete: (value) async {
                if (value != null && task.id != null) {
                  await taskProvider.toggleTaskCompletion(task.id!, value);
                  _showSnackBar(
                    value
                        ? AppStrings.taskCompletedSuccess
                        : 'Task marked as incomplete',
                  );
                }
              },
              onEdit: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.editTask,
                  arguments: task.id,
                );
                _refreshTasks();
              },
              onDelete: () => _showDeleteDialog(task.id!),
            );
          },
        );
      },
    );
  }

  List<dynamic> _getTasksForIndex(TaskProvider provider) {
    switch (_selectedIndex) {
      case 0:
        return provider.todayTasks;
      case 1:
        return provider.completedTasks;
      case 2:
        return provider.repeatedTasks;
      case 3:
      default:
        return provider.allTasks;
    }
  }

  String _getEmptyMessage() {
    switch (_selectedIndex) {
      case 0:
        return AppStrings.noTasksToday;
      case 1:
        return AppStrings.noCompletedTasks;
      case 2:
        return AppStrings.noRepeatedTasks;
      case 3:
      default:
        return AppStrings.noTasksFound;
    }
  }

  Future<void> _handleExport(String type) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();
      final tasks = taskProvider.allTasks;

      if (tasks.isEmpty) {
        _showSnackBar('No tasks to export');
        return;
      }

      String filePath;
      if (type == 'pdf') {
        filePath = await ExportHelper.exportToPDF(tasks);
        _showSnackBar(AppStrings.pdfGenerated);
      } else {
        filePath = await ExportHelper.exportToCSV(tasks);
        _showSnackBar(AppStrings.csvGenerated);
      }

      // Show dialog to open or share
      _showExportDialog(filePath);
    } catch (e) {
      _showSnackBar('${AppStrings.exportFailed}: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showExportDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.exportSuccess),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ExportHelper.openFile(filePath);
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ExportHelper.shareFile(
                filePath,
                'tasks_${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<TaskProvider>().deleteTask(
                taskId,
              );
              if (success) {
                _showSnackBar(AppStrings.taskDeletedSuccess);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
