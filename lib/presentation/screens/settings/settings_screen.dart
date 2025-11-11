import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';
import 'package:task_manager/presentation/providers/theme_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader(theme, AppStrings.theme, Icons.palette),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.lightMode),
                    subtitle: const Text('Always use light theme'),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    secondary: const Icon(Icons.light_mode),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.darkMode),
                    subtitle: const Text('Always use dark theme'),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.systemDefault),
                    subtitle: const Text('Follow system theme'),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    secondary: const Icon(Icons.brightness_auto),
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // Statistics Section
          _buildSectionHeader(theme, 'Statistics', Icons.bar_chart),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final stats = taskProvider.getStatistics();
              return Column(
                children: [
                  _buildStatTile(
                    theme,
                    'Total Tasks',
                    stats['total']?.toString() ?? '0',
                    Icons.list,
                    AppColors.info,
                  ),
                  _buildStatTile(
                    theme,
                    'Completed',
                    stats['completed']?.toString() ?? '0',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  _buildStatTile(
                    theme,
                    'Pending',
                    stats['pending']?.toString() ?? '0',
                    Icons.pending,
                    AppColors.warning,
                  ),
                  _buildStatTile(
                    theme,
                    'Today\'s Tasks',
                    stats['today']?.toString() ?? '0',
                    Icons.today,
                    AppColors.primaryLight,
                  ),
                  _buildStatTile(
                    theme,
                    'Repeated Tasks',
                    stats['repeated']?.toString() ?? '0',
                    Icons.repeat,
                    AppColors.info,
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader(
            theme,
            AppStrings.notifications,
            Icons.notifications,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminders for upcoming tasks'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
            ),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(theme, 'About', Icons.info),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('Task Management Team'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
