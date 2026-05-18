import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../admin/user_management.dart';
import '../admin/department_management.dart';
import '../admin/course_management.dart';
import '../admin/timetable_management.dart';
import '../admin/notification_management.dart';
import '../admin/reports_analytics.dart';
import '../admin/settings.dart';
import '../admin/fee_management.dart';
import '../admin/attendance_monitoring.dart';
import '../admin/exam_management.dart';
import '../admin/staff_management.dart';
import '../admin/library_management.dart';
import '../admin/event_management.dart';
import '../admin/roles_permissions.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _quickStats = [
    {'label': 'Students', 'value': '2,450', 'icon': Icons.school_rounded, 'color': Color(0xFF00ADB5)},
    {'label': 'Staff', 'value': '120', 'icon': Icons.people_rounded, 'color': Color(0xFF4CAF50)},
    {'label': 'Leave Pending', 'value': '18', 'icon': Icons.pending_actions_rounded, 'color': Color(0xFFFF9800)},
    {'label': 'Fee Pending', 'value': '₹3.2L', 'icon': Icons.payments_rounded, 'color': Color(0xFFE91E63)},
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'User Management', 'icon': Icons.manage_accounts_rounded, 'subtitle': 'Manage all users', 'page': const UserManagement()},
    {'title': 'Departments', 'icon': Icons.account_tree_rounded, 'subtitle': 'Manage departments', 'page': const DepartmentManagement()},
    {'title': 'Courses', 'icon': Icons.book_rounded, 'subtitle': 'Subjects & credits', 'page': const CourseManagement()},
    {'title': 'Timetable', 'icon': Icons.calendar_month_rounded, 'subtitle': 'Schedule management', 'page': const TimetableManagementPage()},
    {'title': 'Fee Management', 'icon': Icons.payments_rounded, 'subtitle': 'Fees & payments', 'page': const FeeManagementPage()},
    {'title': 'Attendance', 'icon': Icons.fact_check_rounded, 'subtitle': 'Monitor attendance', 'page': const AttendanceMonitoringPage()},
    {'title': 'Examinations', 'icon': Icons.assignment_rounded, 'subtitle': 'Exams & results', 'page': const ExamManagementPage()},
    {'title': 'Staff', 'icon': Icons.badge_rounded, 'subtitle': 'Staff profiles', 'page': const StaffManagementPage()},
    {'title': 'Library', 'icon': Icons.local_library_rounded, 'subtitle': 'Books & resources', 'page': const LibraryManagementPage()},
    {'title': 'Events', 'icon': Icons.event_rounded, 'subtitle': 'Events & activities', 'page': const EventManagementPage()},
    {'title': 'Notifications', 'icon': Icons.notifications_rounded, 'subtitle': 'Send announcements', 'page': const NotificationManagementPage()},
    {'title': 'Reports', 'icon': Icons.bar_chart_rounded, 'subtitle': 'Analytics & reports', 'page': const ReportsAnalyticsPage()},
    {'title': 'Roles & Permissions', 'icon': Icons.security_rounded, 'subtitle': 'Access control', 'page': const RolesPermissionsPage()},
    {'title': 'Settings', 'icon': Icons.settings_rounded, 'subtitle': 'System settings', 'page': const SettingsPage()},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Admin Dashboard', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        leading: Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.text), onPressed: () => Scaffold.of(ctx).openDrawer())),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text((widget.user['name'] ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildSystemAlert(),
            const SizedBox(height: 24),
            Text('Quick Access', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.8))),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final anim = Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _controller, curve: Interval(0.05 + index * 0.05, 0.5 + index * 0.04, curve: Curves.easeOutBack)),
                );
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: anim,
                      child: _MenuCard(title: item['title'], icon: item['icon'], subtitle: item['subtitle'],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['page']))),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back 👋', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text.withOpacity(0.5))),
          Text(widget.user['name'] ?? 'Admin', style: const TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
          Text(AppConstants.appName, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary.withOpacity(0.8))),
        ]),
      ]),
    );
  }

  Widget _buildQuickStats() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quickStats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
      ),
      itemBuilder: (_, i) {
        final s = _quickStats[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: (s['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(s['icon'], color: s['color'], size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(s['value'], style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: s['color'])),
              Text(s['label'], style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.45))),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildSystemAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('System Alert', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
          Text('18 leave requests pending approval', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.6))),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orange, size: 14),
      ]),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.card),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text((widget.user['name'] ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(height: 10),
            Text(widget.user['name'] ?? 'Admin', style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600)),
            Text('Administrator', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary.withOpacity(0.8), fontSize: 12)),
          ]),
        ),
        ..._menuItems.map((item) => ListTile(
          leading: Icon(item['icon'], color: AppColors.primary, size: 22),
          title: Text(item['title'], style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14)),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => item['page'])); },
        )),
        const Divider(color: AppColors.card),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
          title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontSize: 14)),
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ]),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.icon, required this.subtitle, required this.onTap});
  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
            child: Icon(widget.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(widget.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(widget.subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.text.withOpacity(0.4))),
        ]),
      ),
    );
  }
}