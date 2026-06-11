// lib/modules/teacher/student_list.dart
import 'package:flutter/material.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Class Directory'), backgroundColor: Colors.teal),
      body: ListView(
        children: const [
          ListTile(leading: CircleAvatar(child: Text('AM')), title: Text('Alex Mercer'), subtitle: Text('BCA Tracker Roll: CS2026094')),
        ],
      ),
    );
  }
}