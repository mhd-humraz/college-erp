// lib/modules/admin/reports_screen.dart
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Audit & Ledger Reporting'), backgroundColor: Colors.redAccent),
      body: const Center(child: Text('Export PDF Performance Reports and Fee Analytics Logs.')),
    );
  }
}