// lib/modules/student/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My ERP Credentials')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 45, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 45, color: Colors.white)),
            const SizedBox(height: 16),
            Text(auth.userEmail ?? 'student@edusphere.edu', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text(auth.userRole ?? 'Student')),
          ],
        ),
      ),
    );
  }
}