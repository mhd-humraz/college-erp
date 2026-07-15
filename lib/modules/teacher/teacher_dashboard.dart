import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'attendance_entry.dart';
import 'leave_management.dart';
import 'marks_entry.dart';
import 'student_list.dart';
import 'study_materials.dart';
import 'assignment_upload.dart';
import 'online_meeting.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Faculty Portal',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.teal,
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
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            const Text(
              'Faculty Workspace',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your academic activities',
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
                  icon: Icons
                      .assignment_turned_in_outlined,
                  title: 'Attendance',
                  subtitle: 'Mark daily attendance',
                  color: Colors.teal,
                  screen:
                      const AttendanceEntryScreen(),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.grade_outlined,
                  title: 'Marks',
                  subtitle: 'Enter student marks',
                  color: Colors.orange,
                  screen: MarksEntryScreen(
                    subjectId: '',
                    students: const [],
                  ),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.assignment_outlined,
                  title: 'Assignments',
                  subtitle: 'Create student assignments',
                  color: Colors.deepOrange,
                  screen: const AssignmentUploadScreen(),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.video_camera_front_outlined,
                  title: 'Online Class',
                  subtitle: 'Schedule online meetings',
                  color: Colors.indigo,
                  screen: const OnlineMeetingScreen(),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.people_outline_rounded,
                  title: 'Students',
                  subtitle: 'View student profiles',
                  color: Colors.blue,
                  screen:
                      const StudentListScreen(),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  title: 'Materials',
                  subtitle: 'Share study resources',
                  color: Colors.green,
                  screen:
                      const StudyMaterialsScreen(),
                ),
                _buildMenuCard(
                  context: context,
                  icon: Icons.event_note_outlined,
                  title: 'Leave',
                  subtitle: 'Manage leave requests',
                  color: Colors.purple,
                  screen:
                      const LeaveManagementScreen(),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _buildOverviewCard(
              icon: Icons.people_alt_outlined,
              title: 'Students',
              value: '1',
              description:
                  'Students in your department',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildOverviewCard(
              icon: Icons.schedule_outlined,
              title: 'Pending Leave',
              value: '1',
              description:
                  'Leave request awaiting review',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildOverviewCard(
              icon: Icons.library_books_outlined,
              title: 'Materials',
              value: '2',
              description:
                  'Learning resources shared',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Colors.teal.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(
              alpha: 0.20,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Rajina',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Assistant Professor • Computer Applications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 7),
              Text(
                'EMP001',
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
    required Widget screen,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
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
            'Do you want to end your faculty session?',
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