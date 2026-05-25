import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard/admin_dashboard.dart';
import 'dashboard/hod_dashboard.dart';
import 'dashboard/teacher_dashboard.dart';
import 'dashboard/class_teacher_dashboard.dart';
import 'dashboard/student_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role;

    // Route based on role
    switch (role) {
      case 'admin':
        return const AdminDashboard();
      case 'hod':
        return const HODDashboard();
      case 'class_teacher':
        return const ClassTeacherDashboard();
      case 'teacher':
        return const TeacherDashboard();
      case 'student':
        return const StudentDashboard();
      default:
        return _buildErrorScreen();
    }
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 20),
            Text('Unknown Role', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text('Contact administrator', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}