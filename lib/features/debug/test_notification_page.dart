import 'package:flutter/material.dart';

import '../../core/notification_service.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';

class TestNotificationPage extends StatelessWidget {
  const TestNotificationPage({super.key});

  Future<void> _scheduleTestMeeting(BuildContext context) async {
    final now = DateTime.now();
    final candidate = DateTime(now.year, now.month, now.day, 9, 30);
    final scheduledDay = candidate.isAfter(now) ? candidate : candidate.add(Duration(days: 1));

    final task = DzTask(
      id: 'test-0930-${scheduledDay.millisecondsSinceEpoch}',
      title: 'Test Meeting',
      startTime: const TimeOfDay(hour: 9, minute: 30),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      priority: TaskPriority.high,
      date: DateTime(scheduledDay.year, scheduledDay.month, scheduledDay.day),
    );

    try {
      await AppData.of(context).tasks.addTask(task);
      final dayLabel = '${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scheduled test meeting for $dayLabel 09:30')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule test meeting: $e')),
      );
    }
  }

  Future<void> _sendImmediate(BuildContext context) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF);
      await NotificationService.instance.showImmediateNotification(
        id: id,
        title: 'Immediate Test',
        body: 'This is an immediate test notification',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Immediate notification sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send immediate notification: $e')),
      );
    }
  }

  Future<void> _showPending(BuildContext context) async {
    try {
      final pending = await NotificationService.instance.pendingRequests();
      if (pending.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pending notifications')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Pending (${pending.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: pending
                  .map((p) => ListTile(
                        title: Text('${p.id}: ${p.title ?? '<no title>'}'),
                        subtitle: Text(p.body ?? ''),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to query pending notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Schedule 09:30 Test Meeting'),
              onPressed: () => _scheduleTestMeeting(context),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule +1 Minute Test Meeting'),
              onPressed: () async {
                final now = DateTime.now().add(const Duration(minutes: 1));
                final task = DzTask(
                  id: 'test-in-1min-${now.millisecondsSinceEpoch}',
                  title: '1-minute Test Meeting',
                  startTime: TimeOfDay(hour: now.hour, minute: now.minute),
                  endTime: TimeOfDay(hour: now.hour, minute: (now.minute + 30) % 60),
                  priority: TaskPriority.high,
                  date: DateTime(now.year, now.month, now.day),
                );
                try {
                  await AppData.of(context).tasks.addTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scheduled 1-minute test meeting')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to schedule test meeting: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on),
              label: const Text('Send Immediate Notification'),
              onPressed: () => _sendImmediate(context),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Show Pending Notifications'),
              onPressed: () => _showPending(context),
            ),
          ],
        ),
      ),
    );
  }
}
