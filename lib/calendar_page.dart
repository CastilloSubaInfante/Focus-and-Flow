import 'package:flutter/material.dart';
import 'data_store.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
    @override
    void initState() {
      super.initState();
      _loadCalendarData();
    }

    Future<void> _loadCalendarData() async {
      // Clear and reload calendar data to ensure fresh data
      DataStore.calendarData.clear();
      await DataStore.loadCalendarData();
      if (mounted) {
        setState(() {});
      }
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    const monthNames = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    final monthName = monthNames[month - 1];
    // Last day of month: create date for the 0th day of next month
    final lastDay = DateTime(year, month + 1, 0).day;
    final days = List<int>.generate(lastDay, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName $year'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: days.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$monthName $year', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.green.shade300 : Colors.green)),
                  const SizedBox(height: 12),
                ],
              );
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final day = days[index - 1];
           final dateStr = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
           final tasks = DataStore.calendarData[dateStr] ?? <Map<String, dynamic>>[];
            final weekday = DateTime(year, month, day).weekday; // 1 = Monday
            const dayNames = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
            final weekdayName = dayNames[weekday - 1];

            return Card(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? Colors.grey.shade700 : const Color.fromRGBO(76, 175, 80, 0.15),
                  child: Text('$day', style: TextStyle(color: isDark ? Colors.white : Colors.green, fontWeight: FontWeight.bold)),
                ),
                title: Text('$weekdayName • $monthName $day', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                children: tasks.isNotEmpty
                    ? tasks.map((task) {
                        final isCompleted = task['status'] == 'Completed' || task['status'] == 'Task Completed';
                        final taskIcon = _getTaskIcon(task['title'] ?? '');
                        return CheckboxListTile(
                          value: isCompleted,
                          title: Text(task['title'] ?? '', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          subtitle: Text(task['time'] ?? '', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                          secondary: Icon(taskIcon, color: Colors.green),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            setState(() {
                              task['status'] = val == true ? 'Task Completed' : 'Pending';
                            });
                            DataStore.saveCalendarData();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(val == true ? 'Marked "${task['title']}" complete' : 'Marked "${task['title']}" pending'),
                              duration: const Duration(seconds: 1),
                            ));
                          },
                        );
                      }).toList()
                    : [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text('No tasks for $monthName $day', style: TextStyle(color: Colors.grey[700])),
                        )
                      ],
              ),
            );
          },
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/calendar');
          } else if (index == 2) {
            _showAddCalendarTaskDialog();
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

  void _showAddCalendarTaskDialog() {
    final titleController = TextEditingController();
    TimeOfDay? selectedTime;
    int selectedDay = DateTime.now().day;
    final now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear = now.year;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
        title: const Text('Add Calendar Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: selectedMonth,
              items: List.generate(12, (i) => i + 1).map((m) {
                const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                return DropdownMenuItem(value: m, child: Text(monthNames[m - 1]));
              }).toList(),
              onChanged: (v) {
                if (v != null) setStateDialog(() { selectedMonth = v; });
              },
              decoration: const InputDecoration(labelText: 'Month'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: selectedDay,
              items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('Day $d'))).toList(),
              onChanged: (v) {
                if (v != null) setStateDialog(() { selectedDay = v; });
              },
              decoration: const InputDecoration(labelText: 'Day'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final timeStr = selectedTime == null ? 'No time' : selectedTime!.format(context);
              if (title.isNotEmpty) {
                setState(() {
                  final dateStr = '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}';
                  if (!DataStore.calendarData.containsKey(dateStr)) {
                    DataStore.calendarData[dateStr] = [];
                  }
                  DataStore.calendarData[dateStr]!.insert(0, {'title': title, 'time': timeStr, 'status': 'Pending', 'date': dateStr});
                  // also add to shared home tasks list for consistency
                  DataStore.tasks.insert(0, {'title': title, 'status': 'Pending', 'color': 0xFFFF9800, 'time': timeStr});
                });
                DataStore.saveCalendarData();
                DataStore.saveTasks();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "$title" to $selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}')));
              }
            },
            child: const Text('Add'),
               ),
        ],
      ),
     ),
   );
  }
}
