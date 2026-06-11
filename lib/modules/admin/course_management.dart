// lib/modules/admin/course_management.dart
import 'package:flutter/material.dart';

class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provisions & Degree Schemes'), backgroundColor: Colors.redAccent),
      body: const Center(child: Text('Add Courses and Define Total Semesters Parameter Configurations.')),
    );
  }
}