import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart'; 

class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/reports/summary');
      setState(() { _stats = Map<String, dynamic>.from(data); _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reports & Analytics',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchStats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Summary cards
                    _sectionTitle('Overview'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _statCard('Total Students', '${_stats['totalStudents'] ?? 0}', Icons.school_rounded, AppColors.primary),
                        _statCard('Total Teachers', '${_stats['totalTeachers'] ?? 0}', Icons.cast_for_education_rounded, const Color(0xFF4CAF50)),
                        _statCard('Departments', '${_stats['totalDepartments'] ?? 0}', Icons.account_tree_rounded, const Color(0xFFFF9800)),
                        _statCard('Courses', '${_stats['totalCourses'] ?? 0}', Icons.book_rounded, const Color(0xFF9C27B0)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Attendance Summary'),
                    const SizedBox(height: 12),
                    _buildAttendanceCard(),

                    const SizedBox(height: 24),
                    _sectionTitle('Recent Activity'),
                    const SizedBox(height: 12),
                    _buildActivityList(),
                  ]),
                ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.8)));

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 26),
        const Spacer(),
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.45))),
      ]),
    );
  }

  Widget _buildAttendanceCard() {
    final attendance = _stats['attendance'] as Map? ?? {};
    final percent = (attendance['percentage'] ?? 0).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Average Attendance', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          Text('${percent.toStringAsFixed(1)}%',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _attendanceStat('Present', '${attendance['present'] ?? 0}', Colors.green),
          _attendanceStat('Absent', '${attendance['absent'] ?? 0}', Colors.redAccent),
          _attendanceStat('Leave', '${attendance['leave'] ?? 0}', Colors.orange),
        ]),
      ]),
    );
  }

  Widget _attendanceStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.45))),
    ]);
  }

  Widget _buildActivityList() {
    final activities = (_stats['recentActivity'] as List?) ?? [
      {'action': 'New student registered', 'time': 'Just now'},
      {'action': 'Timetable updated', 'time': '2 hrs ago'},
      {'action': 'Notification sent', 'time': '5 hrs ago'},
    ];
    return Column(
      children: activities.map<Widget>((a) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(a['action'] ?? '',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text))),
          Text(a['time'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.4))),
        ]),
      )).toList(),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
    const SizedBox(height: 12),
    Text('Failed to load reports', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: _fetchStats,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
  ]));
}