# Task Management Application

A comprehensive task management application built with Flutter and SQLite for efficient daily task organization and tracking.

## 📱 Features

### Core Functionality
- ✅ **Task Management**: Add, edit, delete, and mark tasks as completed
- 📅 **Today's Tasks**: View tasks due today
- ✔️ **Completed Tasks**: Track completed tasks with completion dates
- 🔄 **Repeated Tasks**: Set tasks to repeat daily, weekly, or on custom days
- 📊 **Progress Tracking**: Add subtasks with visual progress indicators
- 🔔 **Notifications**: Local notifications for task reminders
- 📤 **Export Options**: Export tasks to PDF, CSV, and share via email

### Advanced Features
- 🎨 **Theme Customization**: Light, dark, and system default themes
- 📈 **Statistics Dashboard**: Track total, completed, and pending tasks
- 🎯 **Subtask Management**: Break down tasks into smaller actionable items
- 🔍 **Task Categories**: Organize tasks by today, completed, repeated, and all
- 💾 **Persistent Storage**: SQLite database for reliable data storage
- 🎯 **Clean Architecture**: Well-structured codebase with separation of concerns

## 🏗️ Project Structure

```
task_management_app/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/                              # Core utilities and constants
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Color definitions
│   │   │   ├── app_strings.dart          # String constants
│   │   │   └── app_theme.dart            # Theme configuration
│   │   ├── utils/
│   │   │   ├── date_formatter.dart       # Date formatting utilities
│   │   │   ├── notification_helper.dart  # Notification management
│   │   │   └── export_helper.dart        # Export functionality
│   │   └── routes/
│   │       └── app_routes.dart           # Navigation routes
│   │
│   ├── data/                              # Data layer
│   │   ├── models/
│   │   │   ├── task_model.dart           # Task data model
│   │   │   └── subtask_model.dart        # Subtask data model
│   │   ├── database/
│   │   │   ├── database_helper.dart      # SQLite operations
│   │   │   └── tables.dart               # Database schema
│   │   └── repositories/
│   │       └── task_repository.dart      # Data access layer
│   │
│   ├── presentation/                      # UI layer
│   │   ├── screens/
│   │   │   ├── home/                     # Home screen
│   │   │   ├── today_tasks/              # Today's tasks screen
│   │   │   ├── completed_tasks/          # Completed tasks screen
│   │   │   ├── repeated_tasks/           # Repeated tasks screen
│   │   │   ├── add_edit_task/            # Add/Edit task screen
│   │   │   └── settings/                 # Settings screen
│   │   ├── widgets/
│   │   │   ├── task_card.dart            # Task card widget
│   │   │   ├── subtask_item.dart         # Subtask item widget
│   │   │   ├── progress_indicator_widget.dart
│   │   │   └── custom_button.dart        # Custom button widget
│   │   └── providers/
│   │       ├── task_provider.dart        # Task state management
│   │       └── theme_provider.dart       # Theme state management
│   │
│   └── services/                          # Service layer (if needed)
│
├── assets/                                # Asset files
│   ├── sounds/                           # Notification sounds
│   └── images/                           # App images
│
├── pubspec.yaml                          # Dependencies
├── analysis_options.yaml                 # Lint rules
└── README.md                             # This file
```

## 🛠️ Tech Stack

- **Framework**: Flutter (SDK >=3.0.0)
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Notifications**: flutter_local_notifications
- **Export**: pdf, csv packages
- **UI Components**: Material Design 3

## 📦 Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.1
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  
  # UI Components
  intl: ^0.18.1
  flutter_slidable: ^3.0.1
  
  # Export Functionality
  pdf: ^3.10.7
  csv: ^5.1.1
  share_plus: ^7.2.1
  open_file: ^3.3.2
  
  # Others
  shared_preferences: ^2.2.2
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd task_management_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Screens Overview

### 1. Home Screen
- Bottom navigation with 4 tabs: Today, Completed, Repeated, All
- Floating action button to add new tasks
- Pull-to-refresh functionality
- Export menu (PDF/CSV)
- Settings access

### 2. Add/Edit Task Screen
- Task title and description fields
- Due date and time pickers
- Repeat options (daily, weekly, custom days)
- Subtask management
- Progress tracking
- Form validation

### 3. Task Categories
- **Today Tasks**: Tasks due today
- **Completed Tasks**: All completed tasks
- **Repeated Tasks**: Tasks with repeat settings
- **All Tasks**: Complete task list

### 4. Settings Screen
- Theme selection (Light/Dark/System)
- Task statistics
- Notification preferences
- App information

## 🗄️ Database Schema

### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  dueDate TEXT NOT NULL,
  dueTime TEXT,
  isCompleted INTEGER DEFAULT 0,
  isRepeated INTEGER DEFAULT 0,
  repeatType TEXT,
  repeatDays TEXT,
  createdAt TEXT NOT NULL,
  completedAt TEXT,
  progress INTEGER DEFAULT 0
)
```

### Subtasks Table
```sql
CREATE TABLE subtasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  taskId INTEGER NOT NULL,
  title TEXT NOT NULL,
  isCompleted INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
)
```

## 🎨 Design Patterns

- **Clean Architecture**: Separation of concerns with distinct layers
- **Repository Pattern**: Abstract data access logic
- **Provider Pattern**: State management
- **Singleton Pattern**: Database and notification helpers

## ✨ Key Features Implementation

### 1. Notifications
```dart
// Schedule notification for a task
await NotificationHelper.instance.scheduleTaskNotification(task);
```

### 2. Export to PDF/CSV
```dart
// Export tasks to PDF
String filePath = await ExportHelper.exportToPDF(tasks);

// Export tasks to CSV
String filePath = await ExportHelper.exportToCSV(tasks);
```

### 3. Progress Tracking
- Automatic calculation based on subtask completion
- Visual progress bar with percentage
- Color-coded progress indicators

### 4. Repeat Tasks
- Daily: Task repeats every day
- Weekly: Task repeats every week
- Custom: Select specific days of the week

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📝 Code Quality

The project follows Flutter best practices:
- Proper null safety
- Widget composition
- Const constructors where possible
- Clean code principles
- Comprehensive error handling

## 🐛 Known Issues

None at the moment. Please report any issues you encounter.

## 🔮 Future Enhancements

- [ ] Task priority levels
- [ ] Task categories/tags
- [ ] Search functionality
- [ ] Task sorting options
- [ ] Cloud sync
- [ ] Task sharing
- [ ] Dark mode improvements
- [ ] Widget for home screen

## 📄 License

This project is created for educational purposes as part of Mobile Application Development course.

## 👨‍💻 Author

**Muhammad Abdullah**
- Email: githubprojectmine@gmail.com
- Course: Mobile Application Development
- Institution: [Your Institution Name]

## 📞 Support

For any queries or support, please contact the instructor or raise an issue in the repository.

---

**Note**: This project was created as a mid-term assignment for the Mobile Application Development course (Fall 2024).

## 🙏 Acknowledgments

- Flutter team for excellent documentation
- Course instructor for guidance
- Open source community for packages used