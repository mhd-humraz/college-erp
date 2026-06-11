// lib/modules/student/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // 🚀 FIXED: Passed both required positional argument mappings (ID + Active Token context)
      Provider.of<AcademicProvider>(context, listen: false)
          .fetchStudentDashboard(auth.userId ?? '6a1c287549e7eb677ccd9150', auth.token ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final att = academic.performanceCache?['attendance'] ?? {
      'totalSlots': 0,
      'presentSlots': 0,
      'percentage': "0.0"
    };

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance History')),
      body: academic.isLoading
          ? const LoadingWidget()
          : Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: Column(
                children: [
                  Card(
                    color: AppTheme.primaryIndigo.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceXL),
                      child: Column(
                        children: [
                          Text(
                            '${att['percentage']}%',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo),
                          ),
                          const SizedBox(height: AppTheme.spaceSM),
                          const Text('Aggregated Attendance Metric', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLG),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppTheme.primaryIndigo),
                    title: const Text('Total Conducted Sessions'),
                    trailing: Text('${att['totalSlots']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: AppTheme.accentTeal),
                    title: const Text('Total Present Sessions'),
                    trailing: Text('${att['presentSlots']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}