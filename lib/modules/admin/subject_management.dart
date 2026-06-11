// lib/modules/admin/subject_management.dart
import 'package:flutter/material.dart';

class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syllabus Curriculum Mapping'), backgroundColor: Colors.redAccent),
      body: const Center(child: Text('Create Curriculum Subjects and Map Faculty Instruction Assignments.')),
    );
  }
}