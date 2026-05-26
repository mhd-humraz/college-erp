import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../viewuser.dart';

// ✅ ADD THESE IMPORTS FOR DRAWER NAVIGATION
import '../profile_screen.dart';
import '../settings_screen.dart';
import '../notification_center.dart';
import '../analytics_screen.dart';
import '../assignment_screen.dart';
import '../pdf_reports_screen.dart';
import '../audit_logs_screen.dart';
import '../login_screen.dart';  // ✅ For logout navigation

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _departments = [];
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final deptsRes = await ApiService.get('/admin/departments');
      final usersRes = await ApiService.get('/admin/users');
      
      setState(() {
        _departments = deptsRes.data['data'] ?? [];
        _users = usersRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadStaffCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

        final response = await ApiService.postWithFile(
          '/admin/upload-staff-csv',
          result.files.single.path!,
        );

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.data['message']),
            backgroundColor: AppColors.success,
          ));
          _fetchData(); // Refresh data
        } else {
          throw Exception(response.data['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _showCreateDepartmentDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Create Department', style: TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Department Name',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Code (e.g., BCA)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final res = await ApiService.post('/admin/departments', data: {
                  'name': nameCtrl.text,
                  'code': codeCtrl.text,
                  'description': descCtrl.text,
                });
                Navigator.pop(dialogContext);
                _fetchData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res.data['message']),
                    backgroundColor: AppColors.success,
                  ));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  // Helper method for stat cards
  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ✅ NEW: DRAWER WIDGET ====================
  Widget _buildDrawer() {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with User Info
          DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(user?['name'] ?? 'Administrator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(user?['email'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('SUPER ADMIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Menu Items
          _drawerItem(Icons.dashboard_outlined, 'Dashboard', () {
            Navigator.pop(context); // Close drawer
          }),
          
          Divider(height: 1, color: Colors.white10),

          _drawerItem(Icons.people_alt_outlined, 'Manage Users (${_users.length})', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewUsersScreen()));
          }),

          _drawerItem(Icons.business_outlined, 'Departments (${_departments.length})', () {
            Navigator.pop(context);
          }),

          _drawerItem(Icons.upload_file_outlined, 'Upload Staff CSV', () {
            Navigator.pop(context);
            _pickAndUploadStaffCSV();
          }),

          Divider(height: 1, color: Colors.white10),

          _drawerItem(Icons.analytics_outlined, 'Analytics Dashboard', () {
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

          _drawerItem(Icons.picture_as_pdf_outlined, 'PDF Reports', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReportsScreen()));
          }),

          _drawerItem(Icons.history_outlined, 'Audit Logs', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => AuditLogsScreen()));
          }),

          Divider(height: 1, color: Colors.white10),

          _drawerItem(Icons.person_outline, 'My Profile', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          }),

          _drawerItem(Icons.settings_outlined, 'Settings', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
          }),

          Divider(height: 1, color: Colors.white10),

          // ✅ Logout Item (Red Color)
          _drawerItem(Icons.logout, 'Logout', _handleLogout, isLogout: true),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? AppColors.error : AppColors.textSecondary),
      title: Text(title, style: TextStyle(
        color: isLogout ? AppColors.error : AppColors.text,
        fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
      )),
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
              
              // ✅ Navigate to Login Screen & remove all routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        title: Text('Admin Dashboard', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        
        // ✅ ADD MENU ICON FOR DRAWER (Top Left)
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
            onPressed: _handleLogout,  // ✅ Now shows dialog & navigates
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
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              'Welcome, ${user?['name']?.split(' ').first ?? 'Admin'}!',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Full System Control', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildStatCard('Departments', '${_departments.length}'),
                            const SizedBox(width: 15),
                            _buildStatCard('Total Users', '${_users.length}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Quick Actions Grid
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    children: [
                      _actionCard(Icons.upload_file, 'Upload Staff CSV', AppColors.info, _pickAndUploadStaffCSV),
                      _actionCard(Icons.add_business, 'Create Department', AppColors.success, _showCreateDepartmentDialog),
                      _actionCard(Icons.people, 'View Users (${_users.length})', AppColors.warning, () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const ViewUsersScreen()),
                        );
                      }),
                      _actionCard(Icons.settings, 'Settings', AppColors.error, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Departments List
                  Text('Departments (${_departments.length})', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  ..._departments.map((dept) => _departmentCard(dept)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _actionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _departmentCard(dynamic dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.business, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept['name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text),
                ),
                Text(
                  'Code: ${dept['code']} | HOD: ${dept['hodId']?['name'] ?? 'Not Assigned'}',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}