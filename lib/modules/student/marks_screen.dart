// lib/modules/student/marks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // 🚀 FIXED: Passed both required positional parameters cleanly
      Provider.of<AcademicProvider>(context, listen: false)
          .fetchStudentDashboard(auth.userId ?? '6a1c287549e7eb677ccd9150', auth.token ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final List grades = academic.performanceCache?['grades'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Grading Ledger')),
      body: academic.isLoading
          ? const LoadingWidget()
          : grades.isEmpty
              ? const Center(child: Text('No internal or final grades published yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final item = grades[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: AppTheme.spaceXS),
                      child: ListTile(
                        title: Text(item['subject']['name'] ?? 'Subject Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Evaluation Class: ${item['examType']}'),
                        trailing: Text(
                          '${item['marksObtained']} / ${item['maxMarks']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}