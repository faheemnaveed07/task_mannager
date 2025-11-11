import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int progress;
  final double size;
  final double strokeWidth;

  const ProgressIndicatorWidget({
    Key? key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.gray700 : AppColors.gray200,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
            ),
          ),
          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$progress%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress),
                ),
              ),
              Text(
                'Complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress == 100) {
      return AppColors.success;
    } else if (progress >= 50) {
      return AppColors.info;
    } else if (progress >= 25) {
      return AppColors.warning;
    } else {
      return AppColors.errorLight;
    }
  }
}
