import 'package:flutter/material.dart';
import 'data_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    // Clear memory first
    DataStore.tasks.clear();
    DataStore.calendarData.clear();
    
    // Then load fresh from storage
    await DataStore.loadCalendarData();
    await DataStore.loadTasks();
    
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    TimeOfDay? selectedTime;
    String selectedStatus = 'Pending';
    int selectedColor = 0xFF2196F3;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStatus,
                  items: ['Pending', 'In progress', 'Task Completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Color:'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildColorOption(0xFF2196F3, selectedColor, (color) {
                        setStateDialog(() {
                          selectedColor = color;
                        });
                      }),
                      _buildColorOption(0xFFFF9800, selectedColor, (color) {
                        setStateDialog(() {
                          selectedColor = color;
                        });
                      }),
                      _buildColorOption(0xFF4CAF50, selectedColor, (color) {
                        setStateDialog(() {
                          selectedColor = color;
                        });
                      }),
                      _buildColorOption(0xFF9C27B0, selectedColor, (color) {
                        setStateDialog(() {
                          selectedColor = color;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final timeStr = selectedTime == null ? 'No time' : selectedTime!.format(context);
                DataStore.addTask(
                  title: titleController.text,
                  status: selectedStatus,
                  color: selectedColor,
                  time: timeStr,
                );
                // Also add to calendar data with the full date (YYYY-MM-DD format)
                final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                if (!DataStore.calendarData.containsKey(dateStr)) {
                  DataStore.calendarData[dateStr] = [];
                }
                DataStore.calendarData[dateStr]!.insert(0, {
                  'title': titleController.text,
                  'time': timeStr,
                  'status': selectedStatus,
                  'date': dateStr,
                });
                DataStore.saveCalendarData();
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task added for ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a task title'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildColorOption(int color, int selectedColor, Function(int) onSelect) {
    return GestureDetector(
      onTap: () {
        onSelect(color);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header card: greeting, progress and avatar
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withAlpha((0.2 * 255).round()),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text('Good Day! ', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
                                Text('🌟', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DataStore.currentUserUsername?.isNotEmpty ?? false 
                                ? DataStore.currentUserUsername! 
                                : (DataStore.currentUserEmail?.split('@')[0] ?? 'User'),
                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildProgressSection(),
                  const SizedBox(height: 10),
                  _buildProgressBar(),
                ],
              ),
            ),

            // Dates row - outside header (5-day real-time window starting today)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Builder(builder: (context) {
                final now = DateTime.now();
                // show a 5-day window starting from today
                final dates = List<DateTime>.generate(5, (i) => DateTime(now.year, now.month, now.day + i));
                final shortDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(dates.length, (i) {
                    final d = dates[i];
                    final dayNum = d.day;
                    final dayName = shortDays[d.weekday % 7];
                    final isToday = dayNum == now.day;
                    // Use date string for lookup
                    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    final todosForDay = DataStore.calendarData[dateStr] ?? [];
                    final todosCount = todosForDay.length;
                    
                    return Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? LinearGradient(
                                    colors: [Colors.green.shade300, Colors.green.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isToday ? null : (isDark ? Colors.grey.shade800 : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isToday ? Colors.green.withAlpha((0.3 * 255).round()) : Colors.black12,
                                blurRadius: isToday ? 6 : 2,
                                offset: Offset(0, isToday ? 3.0 : 1.0),
                              ),
                            ],
                            border: isToday ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.white : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              if (todosCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.white : Colors.orange.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$todosCount',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? Colors.green.shade600 : Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayName,
                          style: TextStyle(
                            color: isToday ? Colors.green : (isDark ? Colors.grey.shade400 : Colors.grey),
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                            fontSize: isToday ? 13 : 12,
                          ),
                        ),
                      ],
                    );
                  }),
                );
              }),
            ),

            // Date selector for viewing tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withAlpha((0.1 * 255).round()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tasks for: ${_formatDate(_selectedDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                    ],
                  ),
                ),
              ),
            ),

            // Task list - show tasks for selected date
            Expanded(
              child: Builder(
                builder: (context) {
                  // Get tasks for the selected date using YYYY-MM-DD format
                  final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                  final tasksForDate = DataStore.calendarData[dateStr] ?? [];
                  
                  if (tasksForDate.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for this date',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a new task',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: tasksForDate.length,
                    itemBuilder: (context, index) {
                      final item = tasksForDate[index];
                      final title = item['title'] ?? '';
                      final status = item['status'] ?? '';
                      final time = item['time'] ?? '';
                      final color = Colors.blue; // Default color for calendar tasks
                      final isCompleted = status == 'Task Completed' || status == 'Completed';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isCompleted
                                ? null
                                : () {
                                    tasksForDate[index]['status'] = 'Task Completed';
                                    setState(() {});
                                    DataStore.saveCalendarData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text('$title completed!')),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task?'),
                                  content: Text('Delete "$title"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        tasksForDate.removeAt(index);
                                        DataStore.saveCalendarData();
                                        Navigator.pop(context);
                                        setState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Task deleted'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: _taskTile(title, status, color, time),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 32), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/calendar');
          } else if (index == 2) {
            _showAddTaskDialog();
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/notifications');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  // Get icon based on task description
  IconData _getTaskIcon(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('jog') || lowerTitle.contains('run') || lowerTitle.contains('walk')) {
      return Icons.directions_run;
    } else if (lowerTitle.contains('study') || lowerTitle.contains('read') || lowerTitle.contains('learn')) {
      return Icons.school;
    } else if (lowerTitle.contains('eat') || lowerTitle.contains('breakfast') || lowerTitle.contains('lunch') || lowerTitle.contains('dinner')) {
      return Icons.restaurant;
    } else if (lowerTitle.contains('meditate') || lowerTitle.contains('yoga') || lowerTitle.contains('stretch')) {
      return Icons.self_improvement;
    } else if (lowerTitle.contains('drink') || lowerTitle.contains('water')) {
      return Icons.local_drink;
    } else if (lowerTitle.contains('meeting') || lowerTitle.contains('standup') || lowerTitle.contains('call')) {
      return Icons.groups;
    } else if (lowerTitle.contains('work') || lowerTitle.contains('project') || lowerTitle.contains('task')) {
      return Icons.work;
    } else if (lowerTitle.contains('exercise') || lowerTitle.contains('gym') || lowerTitle.contains('fitness')) {
      return Icons.fitness_center;
    } else if (lowerTitle.contains('sleep') || lowerTitle.contains('rest')) {
      return Icons.bedtime;
    } else {
      return Icons.check_circle_outline;
    }
  }

  Widget _taskTile(String title, String status, Color color, [String time = '']) {
    final isCompleted = status == 'Task Completed';
    final isPending = status == 'Pending';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskIcon = _getTaskIcon(title);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withAlpha((0.15 * 255).round()),
              child: Icon(taskIcon, size: 32, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  if (time.isNotEmpty)
                    Text(time, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : (isPending ? Icons.schedule : Icons.hourglass_top),
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                      ),
                      if (isPending) ...[
                        const SizedBox(width: 4),
                        Text('→', style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.touch_app, size: 18, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final tasksForDate = DataStore.calendarData[dateStr] ?? [];
    int completedCount = tasksForDate.where((task) => task['status'] == 'Task Completed' || task['status'] == 'Completed').length;
    int totalCount = tasksForDate.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (totalCount == 0) {
      return Text(
        'No tasks for today',
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
      );
    }
    
    return Text(
      'Complete $completedCount/$totalCount tasks!',
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
    );
  }

  Widget _buildProgressBar() {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final tasksForDate = DataStore.calendarData[dateStr] ?? [];
    int completedCount = tasksForDate.where((task) => task['status'] == 'Task Completed' || task['status'] == 'Completed').length;
    int totalCount = tasksForDate.length;
    double progressValue = totalCount > 0 ? completedCount / totalCount : 0;

    // Return empty container if no tasks
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 10,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressValue == 1.0 ? Colors.amber.shade300 : Colors.blueAccent,
            ),
            backgroundColor: Colors.white24,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedCount of $totalCount completed',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            if (progressValue == 1.0)
              const Text('🎉 All tasks done!', style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold))
            else
              Text(
                '${(progressValue * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ],
    );
  }
}

