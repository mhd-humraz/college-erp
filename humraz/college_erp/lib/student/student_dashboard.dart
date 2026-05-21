import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/dashboard_card.dart';
import 'package:college_erp/widgets/custom_appbar.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Muhammed Humraz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Computer Science • Semester 5',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  title: 'Attendance',
                  value: '85%',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  subtitle: 'Present today',
                ),
                DashboardCard(
                  title: 'CGPA',
                  value: '8.5',
                  icon: Icons.grade_outlined,
                  color: AppColors.warning,
                  subtitle: 'Current semester',
                ),
                DashboardCard(
                  title: 'Assignments',
                  value: '12/15',
                  icon: Icons.assignment_outlined,
                  color: AppColors.info,
                  subtitle: 'Completed',
                ),
                DashboardCard(
                  title: 'Fee Status',
                  value: 'Paid',
                  icon: Icons.payment_outlined,
                  color: AppColors.success,
                  subtitle: 'No dues',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Schedule
            _buildSectionHeader('Today\'s Schedule', Icons.today_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  _buildScheduleItem('9:00 AM', 'Data Structures', 'Dr. Smith', 'Room 101'),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildScheduleItem('11:00 AM', 'Database Systems', 'Prof. Johnson', 'Lab 205'),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildScheduleItem('2:00 PM', 'Operating Systems', 'Dr. Williams', 'Room 103'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Notifications
            _buildSectionHeader('Notifications', Icons.notifications_outlined),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  _buildNotificationItem('Assignment Due', 'Submit DBMS assignment by Friday', Icons.assignment_late, AppColors.warning),
                  const SizedBox(height: 12),
                  _buildNotificationItem('Exam Schedule', 'Mid-term exams start next week', Icons.event_note, AppColors.info),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(String time, String subject, String teacher, String room) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 70,
            child: Text(time, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                Text('$teacher • $room', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 14)),
              Text(message, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}