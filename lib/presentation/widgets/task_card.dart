import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/task_model.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_colors.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(bool?)? onToggleComplete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: BorderRadius.circular(12),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: AppColors.errorLight,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Checkbox
                  Row(
                    children: [
                      if (onToggleComplete != null)
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: onToggleComplete,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? AppColors.gray500 : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (task.isRepeated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.repeat,
                                size: 14,
                                color: AppColors.info,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Repeat',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Progress Bar (if has subtasks)
                  if (task.progress > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                              Text(
                                '${task.progress}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.progress / 100,
                              backgroundColor: isDark
                                  ? AppColors.gray700
                                  : AppColors.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                task.progress == 100
                                    ? AppColors.success
                                    : AppColors.primaryLight,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Due Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _getDateColor(task.dueDate, task.isCompleted),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.getRelativeDateString(task.dueDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getDateColor(task.dueDate, task.isCompleted),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (task.dueTime != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatTime(task.dueTime!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDateColor(DateTime dueDate, bool isCompleted) {
    if (isCompleted) {
      return AppColors.success;
    }

    if (DateFormatter.isPast(dueDate)) {
      return AppColors.errorLight;
    } else if (DateFormatter.isToday(dueDate)) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }
}
