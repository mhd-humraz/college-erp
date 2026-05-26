import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

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
import '../login_screen.dart';  // For logout

// ✅ Import HOD-specific screens
import '../hod_assign_teacher.dart';
import '../hod_manage_timetable.dart';
import '../hod_view_requests.dart';
import '../hod_students_list.dart';
import '../hod_manage_subjects.dart';

class HODDashboard extends StatefulWidget {
  const HODDashboard({super.key});

  @override
  State<HODDashboard> createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
  List<dynamic> _students = [];
  List<dynamic> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final studentsRes = await ApiService.get('/hod/students');
      final requestsRes = await ApiService.get('/hod/requests');
      
      setState(() {
        _students = studentsRes.data['data'] ?? [];
        _requests = requestsRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadStudentsCSV() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Center(child: CircularProgressIndicator(color: AppColors.primary)));

    try {
      final res = await ApiService.postWithFile('/hod/upload-students-csv', result.files.single.path!);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']), backgroundColor: AppColors.success));
      _fetchData();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  // ==================== ✅ NEW: DRAWER WIDGET ====================
  Widget _buildDrawer() {
    final user = context.watch<AuthProvider>().user;
    final pendingRequests = _requests.where((r) => r['status'] == 'pending').length;

    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header - HOD Info
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE66D), Color(0xFFFFE66D).withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.school, size: 35, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  user?['name'] ?? 'HOD',
                  style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  user?['email'] ?? '',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HEAD OF DEPT',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 10, fontWeight: FontWeight.w600),
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

          // Department Management Section
        _drawerItem(Icons.people_alt, 'Students (${_students.length})', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HodStudentsListScreen()));
        }),

        _drawerItem(Icons.book_outlined, 'Manage Subjects', () {  // ✅ NEW!
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HodManageSubjectsScreen()));
        }),

        _drawerItem(Icons.person_add_outlined, 'Assign Teachers', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HodAssignTeacherScreen()));
        }),

        _drawerItem(Icons.calendar_month_outlined, 'Manage Timetable', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HodManageTimetableScreen()));
        }),

        _drawerItem(Icons.upload_file_outlined, 'Upload Students CSV', () {
          Navigator.pop(context);
          _uploadStudentsCSV();
        }),

        _drawerItem(Icons.pending_actions_outlined, 'Requests ($pendingRequests)', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HodViewRequestsScreen()));
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
    final pendingRequests = _requests.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      
      // ✅ ADD DRAWER HERE
      drawer: _buildDrawer(),
      
      appBar: AppBar(
        title: Text('${user?['departmentName'] ?? 'Department'} - HOD Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        
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
            onRefresh: _fetchData,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFE66D).withOpacity(0.2), AppColors.card]),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Color(0xFFFFE66D).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.school, color: Color(0xFFFFE66D), size: 28),
                        const SizedBox(width: 10),
                        Text('HOD Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text))
                      ]),
                      const SizedBox(height: 12),
                      Text('Manage your department efficiently', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 15),
                      Row(children: [
                        _miniStat('Students', '${_students.length}', AppColors.success),
                        const SizedBox(width: 15),
                        _miniStat('Pending Requests', '$pendingRequests', AppColors.warning)
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Actions - ✅ NOW ALL WORKING!
                Text('Actions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // ✅ Upload Students CSV -> Opens File Picker
                    _actionChip(Icons.upload_rounded, 'Upload Students CSV', AppColors.success, _uploadStudentsCSV),
                    
                    // ✅ Assign Teacher -> Opens Screen
                    _actionChip(Icons.person_add, 'Assign Teacher', AppColors.info, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HodAssignTeacherScreen()));
                    }),
                    
                    // ✅ Manage Timetable -> Opens Screen
                    _actionChip(Icons.calendar_month, 'Manage Timetable', AppColors.primary, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HodManageTimetableScreen()));
                    }),
                    
                    // ✅ View Requests -> Opens Screen
                    _actionChip(Icons.pending_actions, 'View Requests ($pendingRequests)', AppColors.warning, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HodViewRequestsScreen()));
                    }),
                  ],
                ),
                const SizedBox(height: 22),

                // Recent Students - ✅ Tappable now
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Students', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HodStudentsListScreen()));
                      },
                      child: Text('View All', style: TextStyle(color: AppColors.primary))
                    )
                  ]
                ),
                const SizedBox(height: 12),
                ..._students.take(5).map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.15), child: Icon(Icons.person, color: AppColors.primary)),
                  title: Text(s['name'] ?? '', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                  subtitle: Text('Roll: ${s['rollNumber']} | ${s['className'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                )).toList(),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 13))
        ]),
      ),
    );
  }
}