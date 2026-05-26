import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

// ✅ Import all screens for drawer navigation
import '../profile_screen.dart';
import '../settings_screen.dart';
import '../notification_center.dart';
import '../analytics_screen.dart';
import '../assignment_screen.dart';
import '../pdf_reports_screen.dart';
import '../login_screen.dart';

// ✅ Import Class Teacher-specific screens
import '../classteacher_view_students.dart';
import '../classteacher_mark_attendance.dart';
import 'classteacher_request_student.dart';
import '../classteacher_leave_management.dart';

class ClassTeacherDashboard extends StatefulWidget {
  const ClassTeacherDashboard({super.key});

  @override
  State<ClassTeacherDashboard> createState() => _ClassTeacherDashboardState();
}

class _ClassTeacherDashboardState extends State<ClassTeacherDashboard> {
  List<dynamic> _students = [];
  List<dynamic> _leaveRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final studentsRes = await ApiService.get('/class-teacher/students');
      final leavesRes = await ApiService.get('/class-teacher/leave-requests');
      
      setState(() {
        _students = studentsRes.data['data'] ?? [];
        _leaveRequests = leavesRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer() {
    final user = context.watch<AuthProvider>().user;
    final pendingLeaves = _leaveRequests.where((l) => l['status'] == 'pending').length;

    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header - Class Teacher Info
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFA29BFE), Color(0xFFA29BFE).withOpacity(0.7)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.class_, size: 35, color: Colors.white)),
                SizedBox(height: 10),
                Text(user?['name'] ?? 'Class Teacher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(user?['email'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 6),
                Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(12)), child: Text('CLASS TEACHER', style: TextStyle(color: Color(0xFF333333), fontSize: 10, fontWeight: FontWeight.w600))),
              ],
            ),
          ),

          _drawerItem(Icons.dashboard_outlined, 'Dashboard', () => Navigator.pop(context)),
          Divider(height: 1, color: Colors.white10),

          // Class Management Section
          _drawerItem(Icons.people_alt, 'My Students (${_students.length})', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherViewStudentsScreen())); }),
          _drawerItem(Icons.check_circle_outline, 'Mark Attendance', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherMarkAttendanceScreen())); }),
          _drawerItem(Icons.person_add_outlined, 'Request Student', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherRequestStudentScreen())); }),
          _drawerItem(Icons.beach_access_outlined, 'Leave Management ($pendingLeaves)', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherLeaveManagementScreen())); }),

          Divider(height: 1, color: Colors.white10),

          // General Section
          _drawerItem(Icons.analytics_outlined, 'Analytics', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen())); }),
          _drawerItem(Icons.notifications_outlined, 'Notifications', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationCenter())); }),
          _drawerItem(Icons.assignment_outlined, 'Assignments', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentScreen())); }),
          _drawerItem(Icons.picture_as_pdf, 'PDF Reports', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReportsScreen())); }),

          Divider(height: 1, color: Colors.white10),

          // Account Section
          _drawerItem(Icons.person_outline, 'Profile', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())); }),
         _drawerItem(Icons.settings, 'Settings', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())); }),

          Divider(height: 1, color: Colors.white10),
          _drawerItem(Icons.logout, 'Logout', _handleLogout, isLogout: true),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.textSecondary), title: Text(title, style: TextStyle(color: isLogout ? AppColors.error : AppColors.text, fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal)), onTap: onTap);
  }

  // ==================== LOGOUT HANDLER ====================
  void _handleLogout() {
    Navigator.pop(context);
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: AppColors.card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), title: Row(children: [Icon(Icons.logout, color: AppColors.error), SizedBox(width: 10), Text('Logout?', style: TextStyle(color: AppColors.text))]), content: Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textSecondary)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))), ElevatedButton(onPressed: () { Navigator.pop(ctx); context.read<AuthProvider>().logout(); Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: Text('Logout', style: TextStyle(color: Colors.white)))]));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pendingLeaves = _leaveRequests.where((l) => l['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text('Class Teacher Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        leading: Builder(builder: (ctx) => IconButton(icon: Icon(Icons.menu, color: AppColors.text), onPressed: () => Scaffold.of(ctx).openDrawer())),
        actions: [IconButton(icon: Icon(Icons.logout, color: AppColors.text), onPressed: _handleLogout)],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _fetchData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header Card
                Container(width: double.infinity, padding: EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFA29BFE).withOpacity(0.2), AppColors.card]), borderRadius: BorderRadius.circular(AppConstants.borderRadius), border: Border.all(color: Color(0xFFA29BFE).withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: Color(0xFFA29BFE).withOpacity(0.25), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.class_, color: Color(0xFFA29BFE), size: 26)), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome, ${user?['name']?.split(' ').first ?? 'Class Teacher'}!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)), Text('Class: ${user?['className'] ?? 'N/A'} | Students: ${_students.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))]))]),
                  SizedBox(height: 15),
                  Row(children: [_miniStat('Students', '${_students.length}', AppColors.primary), SizedBox(width: 12), _miniStat('Pending Leaves', '$pendingLeaves', AppColors.warning)])
                ])),
                SizedBox(height: 22),

                // Quick Actions
                Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge), SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _actionChip(Icons.people, 'View Students (${_students.length})', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherViewStudentsScreen()))),
                  _actionChip(Icons.check_circle, 'Mark Attendance', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherMarkAttendanceScreen()))),
                  _actionChip(Icons.person_add, 'Request Student', Color(0xFFA29BFE), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherRequestStudentScreen()))),
                  _actionChip(Icons.beach_access, 'Leave Requests ($pendingLeaves)', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherLeaveManagementScreen()))),
                ]),
                SizedBox(height: 22),

                // Recent Students Preview
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('My Class Students', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClassTeacherViewStudentsScreen())), child: Text('View All', style: TextStyle(color: AppColors.primary)))]),
                SizedBox(height: 12),
                ..._students.take(5).map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(s['name']?.substring(0, 1)?.toUpperCase() ?? 'S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))), title: Text(s['name'] ?? '', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)), subtitle: Text('Roll: ${s['rollNumber']} | Att: ${s['attendancePercent'] ?? 'N/A'}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary))).toList(),
              ]),
            ),
          ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Expanded(child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))])));
  
  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 18), SizedBox(width: 6), Text(label, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 12))])));
}