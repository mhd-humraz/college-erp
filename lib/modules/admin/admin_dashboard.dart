import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'user_management.dart';
import 'department_management.dart';
import 'course_management.dart';
import 'batch_management.dart';
import 'subject_management.dart';
import 'timetable_management.dart';
// import 'announcement_management.dart';
import 'settings_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../analytics/campus_charts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isUploadingStaff = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final auth = context.read<AuthProvider>();

        context
            .read<AdminProvider>()
            .fetchGlobalMetrics(
              auth.token ?? '',
            );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  Future<void> _handleStaffCsvIngestion() async {
    final pickedCsv =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'csv',
      ],
    );

    if (pickedCsv == null) {
      return;
    }

    setState(() {
      _isUploadingStaff = true;
    });

    final auth = context.read<AuthProvider>();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'http://localhost:5000/api/admin/upload-staff',
        ),
      );

      request.headers['Authorization'] =
          'Bearer ${auth.token ?? ''}';

      final file = pickedCsv.files.first;

      final bytes = file.bytes;

      if (bytes == null) {
        throw Exception(
          'Unable to read selected CSV file',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'staffFile',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();

      if (!mounted) {
        return;
      }

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Staff records imported successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Staff import failed: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      debugPrint(
        'STAFF CSV ERROR: $error',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to import staff CSV',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingStaff = false;
        });
      }
    }
  }

  void _openComingSoon(
    String module,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$module screen will open here',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider =
        context.watch<AdminProvider>();

    final metrics =
        adminProvider.metricsCache ??
            {
              'totalStudents': 154,
              'totalFaculty': 18,
              'totalDepartments': 4,
              'globalAttendance': 82.40,
            };

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Admin Portal',
        ),
        backgroundColor:
            Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
            ),
            onPressed: () {
              context
                  .read<AuthProvider>()
                  .terminateSession();

              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor:
              Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.dashboard_outlined,
              ),
              text: 'Management',
            ),
            Tab(
              icon: Icon(
                Icons.analytics_outlined,
              ),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: adminProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.redAccent,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildManagementView(
                  metrics,
                ),
                _buildAnalyticsView(
                  metrics,
                ),
              ],
            ),
    );
  }

  Widget _buildManagementView(
    Map<String, dynamic> metrics,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Institution Overview',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Manage academic and administrative operations',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            _buildStatCard(
              title: 'Students',
              value:
                  '${metrics['totalStudents']}',
              icon: Icons.school_outlined,
              color: Colors.blue,
            ),

            const SizedBox(width: 10),

            _buildStatCard(
              title: 'Faculty',
              value:
                  '${metrics['totalFaculty']}',
              icon: Icons.badge_outlined,
              color: Colors.teal,
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _buildStatCard(
              title: 'Departments',
              value:
                  '${metrics['totalDepartments']}',
              icon:
                  Icons.account_tree_outlined,
              color: Colors.deepPurple,
            ),

            const SizedBox(width: 10),

            _buildStatCard(
              title: 'Attendance',
              value:
                  '${metrics['globalAttendance']}%',
              icon: Icons
                  .assignment_turned_in_outlined,
              color: Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: 25),

        Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(
              alpha: 0.08,
            ),
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: Colors.redAccent.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.all(15),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    Colors.redAccent.withValues(
                  alpha: 0.13,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: _isUploadingStaff
                  ? const Padding(
                      padding:
                          EdgeInsets.all(13),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    )
                  : const Icon(
                      Icons.upload_file_outlined,
                      color: Colors.redAccent,
                    ),
            ),
            title: const Text(
              'Import Staff Records',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'Upload a CSV file to create staff accounts',
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: _isUploadingStaff
                ? null
                : _handleStaffCsvIngestion,
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Management Modules',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        _buildModuleCard(
          icon: Icons.manage_accounts_outlined,
          title: 'User Management',
          subtitle:
              'Manage student, faculty and staff accounts',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const UserManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.account_tree_outlined,
          title: 'Departments',
          subtitle:
              'Manage departments and department heads',
          color: Colors.deepPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const DepartmentManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.school_outlined,
          title: 'Courses',
          subtitle:
              'Manage courses and academic programmes',
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const CourseManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon:
              Icons.calendar_month_outlined,
          title: 'Batches & Semesters',
          subtitle:
              'Manage batches and semester progression',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const BatchManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.menu_book_outlined,
          title: 'Subjects',
          subtitle:
              'Manage subjects and credit information',
          color: Colors.indigo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const SubjectManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.schedule_outlined,
          title: 'Timetable',
          subtitle:
              'Manage institutional class schedules',
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const TimetableManagementScreen(),
              ),
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.campaign_outlined,
          title: 'Announcements',
          subtitle:
              'Publish institution-wide announcements',
          color: Colors.red,
          onTap: () {
            _openComingSoon(
              'Announcements',
            );
          },
        ),

        _buildModuleCard(
          icon: Icons.settings_outlined,
          title: 'System Settings',
          subtitle:
              'Configure institution and ERP settings',
          color: Colors.blueGrey,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const SettingsScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAnalyticsView(
    Map<String, dynamic> metrics,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Institution Analytics',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Monitor overall institutional performance',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Fee Collection',
                    style: TextStyle(
                      color:
                          Colors.blueGrey.shade200,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.account_balance_outlined,
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                '₹14,85,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Total collected fees',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Divider(
                color: Colors.white24,
                height: 30,
              ),

              Row(
                children: [
                  Text(
                    'Institution Attendance',
                    style: TextStyle(
                      color:
                          Colors.blueGrey.shade200,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${metrics['globalAttendance']}%',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        const SizedBox(
          width: double.infinity,
          child: CampusAnalyticsChart(),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}