// lib/modules/student/notification_screen.dart
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notifications Board')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.warning, color: Colors.white)),
              title: Text('Attendance Clearance Warning', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Your attendance rate for DSA is trending near 74%. Contact HOD.'),
            ),
          ),
        ],
      ),
    );
  }
}