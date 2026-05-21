import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Attendance'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Attendance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('Overall Attendance', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 12),
                  Text('85%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('136 Present | 24 Absent', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subject-wise Attendance
            Text('Subject-wise Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            
            _buildSubjectAttendance('Data Structures', 92, 46, 4),
            const SizedBox(height: 12),
            _buildSubjectAttendance('Database Management', 88, 44, 6),
            const SizedBox(height: 12),
            _buildSubjectAttendance('Operating Systems', 82, 41, 9),
            const SizedBox(height: 12),
            _buildSubjectAttendance('Computer Networks', 90, 45, 5),
            const SizedBox(height: 12),
            _buildSubjectAttendance('Software Engineering', 78, 39, 11),
            
            const SizedBox(height: 24),
            
            // Monthly Statistics
            Text('Monthly Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMonthRow('January', 95),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildMonthRow('February', 88),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildMonthRow('March', 92),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildMonthRow('April', 85),
                  Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                  _buildMonthRow('May', 85),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAttendance(String subject, int percentage, int present, int absent) {
    Color statusColor = percentage >= 75 ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(subject, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text))),
              Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Present: $present days', style: TextStyle(fontSize: 12, color: AppColors.success)),
              Text('Absent: $absent days', style: TextStyle(fontSize: 12, color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(String month, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: TextStyle(color: AppColors.text)),
          Text('$percentage%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}