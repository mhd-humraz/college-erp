import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'faculty_management.dart';
import 'department_students.dart';
import 'student_performance.dart';
import 'timetable_approval.dart';
import 'department_analytics.dart';
import 'department_announcements.dart';
import 'leave_approval.dart';

import '../../providers/auth_provider.dart';

class HodDashboard extends StatelessWidget {
  const HodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'HOD Portal',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
            ),
            onPressed: () {
              _showLogoutDialog(
                context,
                auth,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDepartmentHeader(),

            const SizedBox(height: 24),

            const Text(
              'Department Workspace',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage and monitor department activities',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _buildMenuCard(
                  context: context,
                  icon: Icons.people_alt_outlined,
                  title: 'Faculty',
                  subtitle: 'Manage department faculty',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FacultyManagementScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.school_outlined,
                  title: 'Students',
                  subtitle: 'View department students',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DepartmentStudentsScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.insights_outlined,
                  title: 'Performance',
                  subtitle: 'Student academic insights',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const StudentPerformanceScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.calendar_month_outlined,
                  title: 'Timetable',
                  subtitle: 'Review timetable requests',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const TimetableApprovalScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.event_note_outlined,
                  title: 'Leave',
                  subtitle: 'Review faculty leave',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LeaveApprovalScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  subtitle: 'Department performance overview',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DepartmentAnalyticsScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  subtitle: 'Notify students and faculty',
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DepartmentAnnouncementsScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.assignment_ind_outlined,
                  title: 'Faculty Assignment',
                  subtitle: 'Assign subjects and workload',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FacultyAssignmentScreen(),
                      ),
                    );
                  },
                ),
                
                _buildMenuCard(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Reports',
                  subtitle: 'Generate department reports',
                  color: Colors.redAccent,
                  onTap: () {
                    _showComingSoon(
                      context,
                      'Department Reports',
                    );
                  },
                ),

                _buildMenuCard(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Notices',
                  subtitle: 'Publish department notices',
                  color: Colors.deepOrange,
                  onTap: () {
                    _showComingSoon(
                      context,
                      'Department Notices',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Department Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildOverviewCard(
              icon: Icons.people_alt_outlined,
              title: 'Faculty Members',
              value: '12',
              description: 'Active department faculty',
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildOverviewCard(
              icon: Icons.school_outlined,
              title: 'Students',
              value: '186',
              description: 'Students across all semesters',
              color: Colors.teal,
            ),

            const SizedBox(height: 12),

            _buildOverviewCard(
              icon: Icons.warning_amber_rounded,
              title: 'Attendance Risk',
              value: '8',
              description:
                  'Students below attendance requirement',
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildOverviewCard(
              icon: Icons.pending_actions_outlined,
              title: 'Pending Approvals',
              value: '3',
              description:
                  'Department requests awaiting review',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple,
            Colors.deepPurple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(
              alpha: 0.20,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department Dashboard',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Computer Applications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Head of Department',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 18),

          Row(
            children: [
              Icon(
                Icons.apartment_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 7),
              Text(
                'Department Code: BCA',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature frontend is next',
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text(
            'Do you want to end your HOD session?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (logout != true || !context.mounted) {
      return;
    }

    auth.terminateSession();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }
}