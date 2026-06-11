// lib/modules/admin/department_management.dart
import 'package:flutter/material.dart';

class DepartmentManagementScreen extends StatelessWidget {
  const DepartmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Branches Setup'), backgroundColor: Colors.redAccent),
      body: const Center(child: Text('Establish Academic Departments & HOD Allocation Pointers.')),
    );
  }
}