import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

// ✅ IMPORT ALL SCREENS FOR DRAWER NAVIGATION
import '../profile_screen.dart';
import '../settings_screen.dart';
import '../notification_center.dart';
import '../analytics_screen.dart';
import '../assignment_screen.dart';
import '../pdf_reports_screen.dart';
import '../login_screen.dart';  // For logout

// ✅ IMPORT TEACHER-SPECIFIC SCREENS
import 'teacher_mark_attendance.dart';
import 'teacher_upload_marks.dart';
import 'teacher_timetable_screen.dart';
import 'teacher_share_materials.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<dynamic> _myClasses = [];
  Map<String, dynamic> _timetable = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final classesRes = await ApiService.get('/teacher/my-classes');
      final timeRes = await ApiService.get('/teacher/my-timetable');
      
      setState(() {
        _myClasses = classesRes.data['data'] ?? [];
        _timetable = timeRes.data['data'] is Map ? timeRes.data['data'] : {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==================== ✅ NEW: DRAWER WIDGET ====================
  Widget _buildDrawer() {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header - Teacher Info
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.info, AppColors.info.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 35, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  user?['name'] ?? 'Teacher',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  user?['email'] ?? '',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TEACHER',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Section
          _drawerItem(Icons.dashboard_outlined, 'Dashboard', () {
            Navigator.pop(context);
          }),
          
          Divider(height: 1, color: Colors.white10),

          // Teaching Section
          _drawerItem(Icons.class_outlined, 'My Classes (${_myClasses.length})', () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Viewing ${_myClasses.length} assigned classes'),
              backgroundColor: AppColors.info,
            ));
          }),

          _drawerItem(Icons.check_circle_outline, 'Mark Attendance', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherMarkAttendanceScreen()));
          }),

          _drawerItem(Icons.grade_outlined, 'Upload Marks', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherUploadMarksScreen()));
          }),

          _drawerItem(Icons.calendar_today, 'My Timetable', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherTimetableScreen()));
          }),

          _drawerItem(Icons.upload_file, 'Share Materials', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherShareMaterialsScreen()));
          }),

          Divider(height: 1, color: Colors.white10),

          // General Section
          _drawerItem(Icons.analytics_outlined, 'Analytics', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen()));
          }),

          _drawerItem(Icons.notifications_outlined, 'Notifications', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationCenter()));
          }),

          _drawerItem(Icons.assignment_outlined, 'Assignments', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentScreen()));
          }),

          _drawerItem(Icons.picture_as_pdf, 'PDF Reports', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReportsScreen()));
          }),

          Divider(height: 1, color: Colors.white10),

          // Account Section
          _drawerItem(Icons.person_outline, 'My Profile', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          }),

          _drawerItem(Icons.settings, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
          }),

          Divider(height: 1, color: Colors.white10),

          // ✅ Logout (Red Color)
          _drawerItem(Icons.logout, 'Logout', _handleLogout, isLogout: true),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? AppColors.error : AppColors.text,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  // ==================== ✅ NEW: LOGOUT HANDLER ====================
  void _handleLogout() {
    Navigator.pop(context); // Close drawer first
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [
          Icon(Icons.logout, color: AppColors.error),
          SizedBox(width: 10),
          Text('Logout?', style: TextStyle(color: AppColors.text)),
        ]),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.read<AuthProvider>().logout();
              
              // ✅ Navigate to Login Screen & remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      
      // ✅ ADD DRAWER HERE
      drawer: _buildDrawer(),
      
      appBar: AppBar(
        title: Text('Teacher Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        
        // ✅ ADD MENU ICON (Top Left)
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.text),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        
        actions: [
          // ✅ FIXED LOGOUT BUTTON
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.text),
            tooltip: 'Logout',
            onPressed: _handleLogout,  // ✅ Now shows confirmation & navigates
          ),
        ],
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
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.info.withOpacity(0.2), AppColors.card],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, color: AppColors.info, size: 26),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${user?['name']?.split(' ').first ?? 'Teacher'}!',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    Text('${user?['departmentName'] ?? ''} Department', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _miniStat('Classes', '${_myClasses.length}', AppColors.primary),
                              const SizedBox(width: 12),
                              _miniStat('Today', '4', AppColors.success),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Quick Actions - ✅ NOW ALL WORKING!
                    Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // ✅ Mark Attendance -> Opens Screen
                        _actionChip(Icons.check_circle_outline, 'Mark Attendance', AppColors.success, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherMarkAttendanceScreen()));
                        }),
                        
                        // ✅ Upload Marks -> Opens Screen
                        _actionChip(Icons.grade_outlined, 'Upload Marks', AppColors.warning, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherUploadMarksScreen()));
                        }),
                        
                        // ✅ Share Materials -> Opens Screen
                        _actionChip(Icons.upload_file, 'Share Materials', AppColors.info, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherShareMaterialsScreen()));
                        }),
                        
                        // ✅ View Timetable -> Opens Screen
                        _actionChip(Icons.calendar_today, 'View Timetable', AppColors.primary, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherTimetableScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Today's Schedule
                    Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (_timetable.isNotEmpty)
                      ...(_timetable['Monday'] ?? []).take(5).map((entry) => _scheduleCard(entry)).toList()
                    else
                      Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No classes scheduled', style: TextStyle(color: AppColors.textSecondary)))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))
        ]),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _scheduleCard(dynamic entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(entry['startTime'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
              Text(entry['endTime'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry['subjectId']?['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 14)),
              Text('${entry['classId']?['name'] ?? ''} • Period ${entry['period']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}