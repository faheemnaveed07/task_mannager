import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/subtask_item.dart';
import 'package:intl/intl.dart';

class AddEditTaskScreen extends StatefulWidget {
  final int? taskId;

  const AddEditTaskScreen({Key? key, this.taskId}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  bool _isRepeated = false;
  String _repeatType = 'daily';
  List<int> _selectedDays = []; // 0-6 for Sun-Sat
  List<SubtaskModel> _subtasks = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.taskId != null;
    if (_isEditMode) {
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);

    final taskProvider = context.read<TaskProvider>();
    final task = await taskProvider.getTaskById(widget.taskId!);

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDate = task.dueDate;

      if (task.dueTime != null) {
        _selectedTime = TimeOfDay.fromDateTime(task.dueTime!);
      }

      _isRepeated = task.isRepeated;
      _repeatType = task.repeatType ?? 'daily';

      if (task.repeatDays != null) {
        try {
          _selectedDays = List<int>.from(jsonDecode(task.repeatDays!));
        } catch (e) {
          _selectedDays = [];
        }
      }

      // Load subtasks
      // Note: Subtasks are loaded and merged into the local _subtasks list.
      await taskProvider.loadSubtasks(task.id!);
      _subtasks = taskProvider.getSubtasksForTask(task.id!);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? AppStrings.editTask : AppStrings.addTask),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskTitle,
                        hintText: 'Enter task title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.titleRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.taskDescription,
                        hintText: 'Enter task description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.descriptionRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Due Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text(AppStrings.dueDate),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),

                    // Due Time
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text(AppStrings.dueTime),
                      subtitle: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'No time set',
                      ),
                      trailing: _selectedTime != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _selectedTime = null);
                              },
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: _selectTime,
                    ),

                    const Divider(height: 32),

                    // Repeat Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(AppStrings.repeatTask),
                      subtitle: Text(
                        _isRepeated ? 'Task will repeat' : 'One-time task',
                      ),
                      value: _isRepeated,
                      onChanged: (value) {
                        setState(() => _isRepeated = value);
                      },
                      secondary: const Icon(Icons.repeat),
                    ),

                    // Repeat Options
                    if (_isRepeated) ...[
                      const SizedBox(height: 16),
                      _buildRepeatOptions(theme),
                    ],

                    const Divider(height: 32),

                    // Subtasks Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.subtasks,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Add Subtask Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskController,
                            decoration: const InputDecoration(
                              hintText: 'Add a subtask',
                              prefixIcon: Icon(Icons.add_circle_outline),
                            ),
                            onSubmitted: (_) => _addSubtask(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addSubtask,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Subtasks List
                    if (_subtasks.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = _subtasks[index];
                          return SubtaskItem(
                            subtask: subtask,
                            onToggleComplete: (value) {
                              if (value != null) {
                                // Subtask status is updated locally and will be handled by _saveTask
                                setState(() {
                                  _subtasks[index] = subtask.copyWith(
                                    isCompleted: value,
                                  );
                                });
                                // Note: For persistent update, toggleSubtaskCompletion is needed in TaskProvider,
                                // but for simplicity and to match the structure, we keep it here.
                                // If the SubtaskItem handles DB update, this local update isn't needed here.
                              }
                            },
                            onDelete: () {
                              setState(() {
                                _subtasks.removeAt(index);
                              });
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Save Button
                    CustomButton(
                      text: _isEditMode ? AppStrings.save : AppStrings.addTask,
                      onPressed: _saveTask,
                      isLoading: _isLoading,
                      width: double.infinity,
                      icon: _isEditMode ? Icons.save : Icons.add,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRepeatOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.repeatType,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Repeat Type Selection
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text(AppStrings.daily),
              selected: _repeatType == 'daily',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _repeatType = 'daily');
                }
              },
            ),
            ChoiceChip(
              label: const Text(AppStrings.weekly),
              selected: _repeatType == 'weekly',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _repeatType = 'weekly');
                }
              },
            ),
            ChoiceChip(
              label: const Text(AppStrings.custom),
              selected: _repeatType == 'custom',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _repeatType = 'custom');
                }
              },
            ),
          ],
        ),

        // Day Selection for Custom
        if (_repeatType == 'custom') ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.selectDays,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
              final isSelected = _selectedDays.contains(index);

              return FilterChip(
                label: Text(days[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(index);
                    } else {
                      _selectedDays.remove(index);
                    }
                  });
                },
              );
            }),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;

    setState(() {
      // Subtasks added here are temporary (ID is null) until _saveTask is called
      _subtasks.add(
        SubtaskModel(
          taskId: widget.taskId ?? 0, // 0 is temporary/placeholder for new task
          title: _subtaskController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      _subtaskController.clear();
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Variable to hold the final task ID (new or existing)
    int? savedTaskId; 

    try {
      final taskProvider = context.read<TaskProvider>();

      // Combine date and time
      DateTime? dueTime;
      if (_selectedTime != null) {
        dueTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      // Create task model
      final task = TaskModel(
        id: widget.taskId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate,
        dueTime: dueTime,
        isRepeated: _isRepeated,
        repeatType: _isRepeated ? _repeatType : null,
        repeatDays: _isRepeated && _repeatType == 'custom'
            ? jsonEncode(_selectedDays)
            : null,
        createdAt: DateTime.now(),
      );
      
      // 💡 FIXED LOGIC HERE: Get the Task ID regardless of mode
      if (_isEditMode) {
        final success = await taskProvider.updateTask(task);
        if (success) {
          savedTaskId = widget.taskId; // Existing ID
        }
      } else {
        // addTask now returns the new ID (int?)
        savedTaskId = (await taskProvider.addTask(task)) as int?; 
      }

      if (savedTaskId != null) {
        // Save/Update subtasks using the confirmed Task ID
        for (final subtask in _subtasks) {
          if (subtask.id == null) {
            // New subtask, add it with the newly created Task ID
            await taskProvider.addSubtask(subtask.copyWith(taskId: savedTaskId));
          } else {
            // Existing subtask (only applicable in edit mode), update it
            await taskProvider.updateSubtask(subtask);
          }
        }
        
        // Success message
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? AppStrings.taskUpdatedSuccess
                    : AppStrings.taskAddedSuccess,
              ),
            ),
          );
        }
      } else {
        // Failure message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save task'),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }
}