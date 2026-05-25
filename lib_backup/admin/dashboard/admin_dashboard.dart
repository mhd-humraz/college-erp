// lib/screens/admin/dashboard/admin_dashboard.dart
// OLD (incorrect depth)
import '../users/user_management.dart';
import '../departments/department_management.dart';
// etc.

// NEW (correct for new structure)
import '../users/user_management.dart';
import '../departments/department_management.dart';
import '../courses/course_management.dart';
import '../timetable/timetable_management.dart';
import '../notifications/notification_management.dart';
import '../reports/reports_analytics.dart';
import '../settings/settings.dart';
import '../fees/fee_management.dart';
import '../attendance/attendance_monitoring.dart';
import '../exams/exam_management.dart';
import '../staff/staff_management.dart';
import '../roles/roles_permissions.dart';

// Also update theme and widgets import
import '../../../utils/theme.dart';
import '../../../widgets/stats_card.dart';

 

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Dashboard', 'screen': null},
    {'icon': Icons.people, 'title': 'User Management', 'screen': const UserManagement()},
    {'icon': Icons.business, 'title': 'Department Management', 'screen': const DepartmentManagement()},
    {'icon': Icons.book, 'title': 'Course Management', 'screen': const CourseManagement()},
    {'icon': Icons.schedule, 'title': 'Timetable Management', 'screen': const TimetableManagement()},
    {'icon': Icons.notifications, 'title': 'Notification Management', 'screen': const NotificationManagement()},
    {'icon': Icons.analytics, 'title': 'Reports & Analytics', 'screen': const ReportsAnalytics()},
    {'icon': Icons.settings, 'title': 'Settings', 'screen': const Settings()},
    {'icon': Icons.attach_money, 'title': 'Fee Management', 'screen': const FeeManagement()},
    {'icon': Icons.calendar_today, 'title': 'Attendance Monitoring', 'screen': const AttendanceMonitoring()},
    {'icon': Icons.assignment, 'title': 'Examination Management', 'screen': const ExamManagement()},
    {'icon': Icons.people_outline, 'title': 'Staff Management', 'screen': const StaffManagement()},
    {'icon': Icons.security, 'title': 'Roles & Permissions', 'screen': const RolesPermissions()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 900) _buildSidebar(),
          Expanded(
            child: _selectedIndex == 0
                ? _buildDashboardContent()
                : _menuItems[_selectedIndex]['screen'],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white24, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'College ERP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.text,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white24, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: AppColors.text),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@college.edu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  onPressed: () {
                    // Handle logout
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: const Column(
              children: [
                Icon(Icons.school, size: 60, color: AppColors.text),
                SizedBox(height: 10),
                Text(
                  'College ERP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  leading: Icon(item['icon']),
                  title: Text(item['title']),
                  selected: _selectedIndex == index,
                  selectedTileColor: AppColors.primary.withOpacity(0.2),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 6 : 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              StatsCard(
                title: 'Total Students',
                value: '2,450',
                icon: Icons.people,
                color: AppColors.primary,
                subtitle: '+12%',
              ),
              StatsCard(
                title: 'Total Staff',
                value: '120',
                icon: Icons.person,
                color: AppColors.success,
                subtitle: '+5%',
              ),
              StatsCard(
                title: 'Departments',
                value: '8',
                icon: Icons.business,
                color: AppColors.warning,
              ),
              StatsCard(
                title: 'Attendance Today',
                value: '87%',
                icon: Icons.calendar_today,
                color: AppColors.info,
                subtitle: '+3%',
              ),
              StatsCard(
                title: 'Fee Collection',
                value: '₹3.2L',
                icon: Icons.attach_money,
                color: AppColors.success,
                subtitle: '70% collected',
              ),
              StatsCard(
                title: 'Pending Leaves',
                value: '18',
                icon: Icons.beach_access,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'New student registration',
                          '5 minutes ago',
                          Icons.person_add,
                        ),
                        _buildActivityItem(
                          'Department meeting scheduled',
                          '1 hour ago',
                          Icons.meeting_room,
                        ),
                        _buildActivityItem(
                          'Fee payment received',
                          '3 hours ago',
                          Icons.payment,
                        ),
                        _buildActivityItem(
                          'Exam results published',
                          '1 day ago',
                          Icons.assignment_turned_in,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildEventItem(
                          'Mid-Term Exams',
                          'Dec 15, 2024',
                          Icons.assignment,
                        ),
                        _buildEventItem(
                          'Parent-Teacher Meeting',
                          'Dec 20, 2024',
                          Icons.people,
                        ),
                        _buildEventItem(
                          'Winter Break',
                          'Dec 25, 2024',
                          Icons.beach_access,
                        ),
                        _buildEventItem(
                          'Sports Day',
                          'Jan 5, 2025',
                          Icons.sports,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAlertItem(
                    'Database backup pending',
                    'Last backup was 7 days ago',
                    Icons.warning,
                    AppColors.warning,
                  ),
                  _buildAlertItem(
                    'Server maintenance scheduled',
                    'Tomorrow at 2 AM',
                    Icons.info,
                    AppColors.info,
                  ),
                  _buildAlertItem(
                    'Low attendance in multiple classes',
                    '5 classes below 75%',
                    Icons.error,
                    AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}