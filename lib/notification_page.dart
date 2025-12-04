import 'package:flutter/material.dart';
import 'data_store.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<Map<String, dynamic>> notifications;
  late Set<int> readIndices;

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
  void initState() {
    super.initState();
    // Generate notifications from calendar data
    notifications = [];
    DataStore.calendarData.forEach((day, tasks) {
      for (final task in tasks) {
        final title = task['title'] ?? 'Task';
        final time = task['time'] ?? 'No time set';
        final status = task['status'] ?? 'Pending';
        
        // Determine icon and color based on status
        IconData icon;
        int color;
        String displayStatus;
        
        if (status == 'Task Completed') {
          icon = Icons.check_circle;
          color = 0xFF2196F3;
          displayStatus = 'Completed';
        } else if (status == 'Pending') {
          icon = Icons.schedule;
          color = 0xFFFF9800;
          displayStatus = 'Pending';
        } else {
          icon = Icons.notifications_active;
          color = 0xFF4CAF50;
          displayStatus = 'Upcoming';
        }
        
        // Override icon based on task description
        icon = _getTaskIcon(title);
        
        notifications.add({
          'title': title,
          'time': time,
          'date': 'Dec $day, 2025',
          'day': day,
          'status': displayStatus,
          'icon': icon,
          'color': color,
        });
      }
    });
    readIndices = {};
  }

  void _showDetailsPopup(int index) {
    final notif = notifications[index];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(notif['color'] as int).withAlpha((0.15 * 255).round()),
                    child: Icon(notif['icon'] as IconData, size: 40, color: Color(notif['color'] as int)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(notif['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(notif['time'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(notif['icon'] as IconData, size: 16, color: Color(notif['color'] as int)),
                        const SizedBox(width: 8),
                        Text(notif['status'] as String, style: TextStyle(fontSize: 14, color: Color(notif['color'] as int), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('This notification reminds you about "${notif['title']}" scheduled for ${notif['date']} at ${notif['time']}. Current status: ${notif['status']}.', 
                style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          readIndices.add(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${notif['title']} marked as read'), duration: const Duration(seconds: 1)),
                        );
                      },
                      child: const Text('Mark as Read'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            final isRead = readIndices.contains(index);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isRead ? (isDark ? Colors.grey.shade700 : Colors.grey.shade100) : (isDark ? Colors.grey.shade800 : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(notif['color'] as int).withAlpha((0.15 * 255).round()),
                        child: Icon(notif['icon'] as IconData, color: Color(notif['color'] as int)),
                      ),
                      if (!isRead)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    notif['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isRead ? (isDark ? Colors.grey.shade400 : Colors.grey) : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif['time'] as String, style: TextStyle(fontSize: 12, color: isRead ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400) : (isDark ? Colors.grey.shade400 : Colors.grey))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(notif['status'] as String, style: TextStyle(fontSize: 12, color: Color(notif['color'] as int), fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          if (isRead)
                            Text('• Read', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  onTap: () => _showDetailsPopup(index),
                ),
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/calendar');
          } else if (index == 2) {
            // Add task action for notifications page
            Navigator.pushReplacementNamed(context, '/home').then((_) {
              // After navigating to home, show add task dialog
              Future.delayed(Duration.zero, () {
                // This will be handled by home page's add button
              });
            });
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
}
