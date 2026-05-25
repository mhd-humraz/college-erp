import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';        // ✅ Correct
import '../../services/api_service.dart';            // ✅ Correct
import '../../theme/app_theme.dart';                 // ✅ Correct

// ✅ FIXED - These were wrong, now correct:
import '../profile_screen.dart';                     // ✅ FIXED
import '../settings_screen.dart';                    // ✅ FIXED  
import '../notification_center.dart';                // ✅ FIXED

import '../analytics_screen.dart';
import '../assignment_screen.dart';
import '../pdf_reports_screen.dart';
import '../audit_logs_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? _dashboardData;
  dynamic _timetable = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dashRes = await ApiService.get('/student/dashboard');
      final timeRes = await ApiService.get('/student/timetable');
      
      setState(() {
        _dashboardData = dashRes.data['data'];
        _timetable = timeRes.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final attendancePct = (_dashboardData?['attendancePercentage'] ?? 0.0).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.card,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(user?['name'] ?? 'Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(user?['email'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            _drawerItem(Icons.calendar_today, 'My Timetable', (){}),
            _drawerItem(Icons.check_circle, 'Attendance ($attendancePct%)', (){}),
            _drawerItem(Icons.grade, 'My Marks', (){}),
            _drawerItem(Icons.notifications, 'Notifications', (){}),
            _drawerItem(Icons.beach_access, 'Apply Leave', (){}),
            Divider(color: Colors.white10),
            _drawerItem(Icons.person, 'Profile', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            }),
            _drawerItem(Icons.analytics, 'Analytics Dashboard', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen()));
            }),
            _drawerItem(Icons.assignment, 'Assignments', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentScreen()));
            }),
            _drawerItem(Icons.picture_as_pdf, 'PDF Reports', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReportsScreen()));
            }),
            _drawerItem(Icons.history, 'Audit Logs', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AuditLogsScreen()));
            }),
            _drawerItem(Icons.settings, 'Settings', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            }),
            _drawerItem(Icons.notifications, 'Notifications', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationCenter()));
            }),
            _drawerItem(Icons.logout, 'Logout', () => context.read<AuthProvider>().logout()),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('👋 Hi, ${user?['name']?.split(' ').first ?? 'Student'}!', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.text),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(child: _statCard('Attendance', '$attendancePct%', Icons.check_circle, AppColors.success)),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard('Classes Today', '5', Icons.today, AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _statCard('Notifications', '${_dashboardData?['unreadNotifications'] ?? 0}', Icons.notifications_active, AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Today's Schedule
                    Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Column(
                        children: [
                          _scheduleRow('10:00 AM', 'Data Structures', 'Shiyas Sir', AppColors.info),
                          Divider(height: 24, color: Colors.white10),
                          _scheduleRow('11:00 AM', 'Mathematics', 'Rahul Sir', AppColors.success),
                          Divider(height: 24, color: Colors.white10),
                          _scheduleRow('02:00 PM', 'Database Lab', "Anjali Ma'am", AppColors.warning),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Recent Marks Preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Marks', style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: (){},
                          child: Text('View All', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(_dashboardData?['recentMarks'] ?? []).take(3).map((m) => _markCard(m)).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _scheduleRow(String time, String subject, String teacher, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(time, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(teacher, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _markCard(dynamic mark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mark['subjectId']?['name'] ?? '', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                  Text(mark['examType'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${mark['score']}/${mark['maxScore']}',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: AppColors.text)),
      onTap: onTap,
    );
  }
}