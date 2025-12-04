import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataStore {
  // Current logged-in user email
  static String? currentUserEmail;

  // Current logged-in user username
  static String? currentUserUsername;

  // Registered users (email -> {password, name, verified})
  static Map<String, Map<String, dynamic>> registeredUsers = {};

  // Default tasks
  static const List<Map<String, dynamic>> defaultTasks = [
    {'title': 'Study 1 hour for Mobile Development', 'status': 'Pending', 'color': 0xFF2196F3, 'time': '9:00 AM'},
    {'title': 'Eat healthy breakfast', 'status': 'Pending', 'color': 0xFFFF9800, 'time': '7:30 AM'},
    {'title': 'Meditate for 10 minutes', 'status': 'Task Completed', 'color': 0xFF2196F3, 'time': '6:30 AM'},
    {'title': 'Drink 8 cups of water', 'status': 'In progress', 'color': 0xFF4CAF50, 'time': 'All day'},
    {'title': 'Team standup meeting', 'status': 'Pending', 'color': 0xFF9C27B0, 'time': '10:00 AM'},
    {'title': 'Evening walk', 'status': 'Pending', 'color': 0xFF4CAF50, 'time': '6:00 PM'},
  ];

  // Default calendar data
  static const Map<int, List<Map<String, dynamic>>> defaultCalendarData = {
    13: [
      {'title': 'Morning Jog', 'time': '6:00 AM', 'status': 'Pending'},
      {'title': 'Study 1 hour for Mobile Development', 'time': '9:00 AM', 'status': 'In progress'},
    ],
    14: [
      {'title': 'Eat healthy breakfast', 'time': '7:30 AM', 'status': 'Pending'},
      {'title': 'Team standup meeting', 'time': '10:00 AM', 'status': 'Pending'},
    ],
    15: [
      {'title': 'Meditate for 10 minutes', 'time': '6:30 AM', 'status': 'Completed'},
      {'title': 'Work Meeting', 'time': '2:00 PM', 'status': 'Pending'},
    ],
    16: [
      {'title': 'Drink 8 cups of water', 'time': 'All day', 'status': 'In progress'},
      {'title': 'Evening walk', 'time': '6:00 PM', 'status': 'Pending'},
    ],
    17: [
      {'title': 'Yoga Class', 'time': '5:00 PM', 'status': 'Pending'},
    ],
  };

  // Shared task list for Home page
  static List<Map<String, dynamic>> tasks = [];

  // Shared calendar data: date string (YYYY-MM-DD) -> list of tasks
  static Map<String, List<Map<String, dynamic>>> calendarData = {};

  // Generate user-specific key for calendar data
  static String _getCalendarDataKey() {
    if (currentUserEmail == null) {
      return 'calendar_data_global';
    }
    return 'calendar_data_${currentUserEmail!.replaceAll('@', '_').replaceAll('.', '_')}';
  }

  // Save calendar data to persistent storage with user-specific key
  static Future<void> saveCalendarData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(calendarData);
      final key = _getCalendarDataKey();
      await prefs.setString(key, jsonData);
    } catch (e) {
      print('Error saving calendar data: $e');
    }
  }

  // Migrate old calendar data format (day -> date string) if needed
  static Future<void> _migrateOldCalendarData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCalendarDataKey();
      final jsonData = prefs.getString(key);
      
      if (jsonData != null && jsonData.isNotEmpty) {
        final decoded = jsonDecode(jsonData);
        
        // Check if keys are integers (old format) by trying to parse first key
        bool isOldFormat = false;
        if (decoded is Map && decoded.isNotEmpty) {
          final firstKey = decoded.keys.first;
          try {
            int.parse(firstKey);
            isOldFormat = true;
          } catch (e) {
            isOldFormat = false;
          }
        }
        
        // If old format, convert to new format
        if (isOldFormat) {
          print('Migrating old calendar data format to new date-based format');
          final now = DateTime.now();
          final newData = <String, dynamic>{};
          
          (decoded as Map).forEach((dayKey, value) {
            try {
              final dayInt = int.parse(dayKey);
              final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayInt.toString().padLeft(2, '0')}';
              newData[dateStr] = value;
            } catch (e) {
              // If it's already a date string, keep it as is
              newData[dayKey] = value;
            }
          });
          
          // Save the migrated data
          final migratedJson = jsonEncode(newData);
          await prefs.setString(key, migratedJson);
          print('Calendar data migration completed');
        }
      }
    } catch (e) {
      print('Error during calendar data migration: $e');
    }
  }

  // Load calendar data from persistent storage with user-specific key
  static Future<void> loadCalendarData() async {
    try {
      // First, migrate any old format data
      await _migrateOldCalendarData();
      
      final prefs = await SharedPreferences.getInstance();
      final key = _getCalendarDataKey();
      final jsonData = prefs.getString(key);
      if (jsonData != null && jsonData.isNotEmpty) {
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        calendarData.clear();
        decoded.forEach((key, value) {
          calendarData[key] = List<Map<String, dynamic>>.from(
            (value as List).map((item) => Map<String, dynamic>.from(item as Map))
          );
        });
      } else {
        // If no data in SharedPreferences, reinitialize with defaults (convert to date strings)
        calendarData.clear();
        final now = DateTime.now();
        defaultCalendarData.forEach((dayInt, taskList) {
          // Create a date string using today's month/year with the day from defaults
          final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayInt.toString().padLeft(2, '0')}';
          calendarData[dateStr] = List<Map<String, dynamic>>.from(
            taskList.map((item) => Map<String, dynamic>.from(item))
          );
        });
      }
    } catch (e) {
      print('Error loading calendar data: $e');
      // On error, reinitialize with defaults
      calendarData.clear();
      final now = DateTime.now();
      defaultCalendarData.forEach((dayInt, taskList) {
        final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayInt.toString().padLeft(2, '0')}';
        calendarData[dateStr] = List<Map<String, dynamic>>.from(
          taskList.map((item) => Map<String, dynamic>.from(item))
        );
      });
    }
  }

  // Save registered users to persistent storage
  static Future<void> saveRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(registeredUsers);
      await prefs.setString('registered_users', jsonData);
    } catch (e) {
      print('Error saving registered users: $e');
    }
  }

  // Load registered users from persistent storage
  static Future<void> loadRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('registered_users');
      if (jsonData != null) {
        final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
        registeredUsers.clear();
        decoded.forEach((key, value) {
          registeredUsers[key] = Map<String, dynamic>.from(value as Map);
        });
      }
    } catch (e) {
      print('Error loading registered users: $e');
    }
  }

  // Load current user email from persistent storage
  static Future<void> loadCurrentUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserEmail = prefs.getString('current_user_email');
    } catch (e) {
      print('Error loading current user email: $e');
    }
  }

  // Save current user email to persistent storage
  static Future<void> saveCurrentUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUserEmail != null) {
        await prefs.setString('current_user_email', currentUserEmail!);
      } else {
        await prefs.remove('current_user_email');
      }
    } catch (e) {
      print('Error saving current user email: $e');
    }
  }

  // Generate user-specific key for tasks
  static String _getTasksKey() {
    if (currentUserEmail == null) {
      return 'tasks_global';
    }
    return 'tasks_${currentUserEmail!.replaceAll('@', '_').replaceAll('.', '_')}';
  }

  // Save tasks to persistent storage with user-specific key
  static Future<void> saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(tasks);
      final key = _getTasksKey();
      await prefs.setString(key, jsonData);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  // Load tasks from persistent storage with user-specific key
  static Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTasksKey();
      final jsonData = prefs.getString(key);
      if (jsonData != null && jsonData.isNotEmpty) {
        final decoded = jsonDecode(jsonData) as List;
        tasks.clear();
        tasks.addAll(
          decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList()
        );
      } else {
        // If no data in SharedPreferences, reinitialize with defaults
        tasks.clear();
        tasks.addAll(
          defaultTasks.map((item) => Map<String, dynamic>.from(item)).toList()
        );
      }
    } catch (e) {
      print('Error loading tasks: $e');
      // On error, reinitialize with defaults
      tasks.clear();
      tasks.addAll(
        defaultTasks.map((item) => Map<String, dynamic>.from(item)).toList()
      );
    }
  }

  // Add a new task (inserted at the top for newest-first ordering)
  static void addTask({
    required String title,
    required String status,
    required int color,
    required String time,
  }) {
    tasks.insert(0, {
      'title': title,
      'status': status,
      'color': color,
      'time': time,
    });
    saveTasks();
  }

  // Remove a task by index
  static void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
      saveTasks();
    }
  }

  // Update a task by index
  static void updateTask(int index, {
    String? title,
    String? status,
    int? color,
    String? time,
  }) {
    if (index >= 0 && index < tasks.length) {
      if (title != null) tasks[index]['title'] = title;
      if (status != null) tasks[index]['status'] = status;
      if (color != null) tasks[index]['color'] = color;
      if (time != null) tasks[index]['time'] = time;
      saveTasks();
    }
  }

  // Save current user username to persistent storage
  static Future<void> saveCurrentUserUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUserUsername != null) {
        await prefs.setString('current_user_username', currentUserUsername!);
      } else {
        await prefs.remove('current_user_username');
      }
    } catch (e) {
      print('Error saving current user username: $e');
    }
  }

  // Load current user username from persistent storage
  static Future<void> loadCurrentUserUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserUsername = prefs.getString('current_user_username');
      // If username is not set, try to extract from email
      if (currentUserUsername == null && currentUserEmail != null) {
        currentUserUsername = currentUserEmail!.split('@')[0];
      }
    } catch (e) {
      print('Error loading current user username: $e');
    }
  }
}
