import 'package:flutter/material.dart';
import '../../data/models/subtask_model.dart';
import '../../core/constants/app_colors.dart';

class SubtaskItem extends StatelessWidget {
  final SubtaskModel subtask;
  final Function(bool?)? onToggleComplete;
  final VoidCallback? onDelete;

  const SubtaskItem({
    Key? key,
    required this.subtask,
    this.onToggleComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.gray700
              : AppColors.gray300,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        leading: Checkbox(
          value: subtask.isCompleted,
          onChanged: onToggleComplete,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          subtask.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
            color: subtask.isCompleted ? AppColors.gray500 : null,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: AppColors.errorLight,
              )
            : null,
      ),
    );
  }
}
