// lib/modules/teacher/assignment_upload.dart
import 'package:flutter/material.dart';

class AssignmentUploadScreen extends StatelessWidget {
  const AssignmentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deploy Assignment'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Assignment Task Title', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Technical Prompts & Instructions', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('Broadcast Task to Active Class'),
            )
          ],
        ),
      ),
    );
  }
}