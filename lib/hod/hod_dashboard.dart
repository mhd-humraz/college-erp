  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
   
  import '../hod/academic_monitoring.dart';
  import '../hod/attendance_reports.dart';
  import '../hod/faculty_management.dart';
  import '../hod/student_performance.dart';
  import '../hod/timetable_approval.dart';

  import '../utils/theme.dart';

  class HodDashboard extends StatefulWidget {
    const HodDashboard({super.key});

    @override
    State<HodDashboard> createState() => _HodDashboardState();
  }

  class _HodDashboardState extends State<HodDashboard> {
    File? profileImage;

    Future<void> pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,

        drawer: const DashboardDrawer(),

        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'HOD Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Computer Science Department',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.text,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,

                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : const AssetImage('assets/image/hod.png')
                          as ImageProvider,

                  child: profileImage == null
                      ? null
                      : null,
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeSection(),

              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: const [
                  DashboardCard(
                    title: 'Total Students',
                    value: '480',
                    icon: Icons.people,
                  ),

                  DashboardCard(
                    title: 'Faculty Members',
                    value: '32',
                    icon: Icons.school,
                  ),

                  DashboardCard(
                    title: 'Attendance',
                    value: '87%',
                    icon: Icons.bar_chart,
                  ),

                  DashboardCard(
                    title: 'Pending Requests',
                    value: '14',
                    icon: Icons.pending_actions,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Attendance Overview'),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Department Attendance',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.87,
                        minHeight: 14,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '87% overall attendance this week',
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Faculty Monitoring'),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  children: const [
                    FacultyTile(
                      name: 'Dr. Ahmed',
                      subject: 'Data Structures',
                      status: 'Marks Uploaded',
                      statusColor: Colors.green,
                    ),

                    FacultyTile(
                      name: 'Mrs. Fathima',
                      subject: 'Operating Systems',
                      status: 'Pending Attendance',
                      statusColor: Colors.orange,
                    ),

                    FacultyTile(
                      name: 'Mr. Farhan',
                      subject: 'DBMS',
                      status: 'Assignment Added',
                      statusColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Pending Approvals'),

              const SizedBox(height: 14),

              Column(
                children: const [
                  ApprovalCard(
                    title: 'Student Leave Request',
                    subtitle: 'Muhammed Ali - 2 Days Leave',
                  ),

                  SizedBox(height: 12),

                  ApprovalCard(
                    title: 'Faculty Leave Request',
                    subtitle: 'Mrs. Ameena - Medical Leave',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const SectionTitle(title: 'Recent Announcements'),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  children: const [
                    AnnouncementTile(
                      title: 'Internal Exams Start Monday',
                      time: '10 mins ago',
                    ),

                    Divider(color: Colors.white10),

                    AnnouncementTile(
                      title: 'Project Review Scheduled',
                      time: '1 hour ago',
                    ),

                    Divider(color: Colors.white10),

                    AnnouncementTile(
                      title: 'Attendance Submission Deadline Today',
                      time: '3 hours ago',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }
  }

  class WelcomeSection extends StatelessWidget {
    const WelcomeSection({super.key});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF02838A),
            ],
          ),
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, HOD 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Monitor department performance, faculty activities and student analytics.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            )
          ],
        ),
      );
    }
  }

  class DashboardCard extends StatelessWidget {
    final String title;
    final String value;
    final IconData icon;

    const DashboardCard({
      super.key,
      required this.title,
      required this.value,
      required this.icon,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )
              ],
            )
          ],
        ),
      );
    }
  }

  class SectionTitle extends StatelessWidget {
    final String title;

    const SectionTitle({
      super.key,
      required this.title,
    });

    @override
    Widget build(BuildContext context) {
      return Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  class FacultyTile extends StatelessWidget {
    final String name;
    final String subject;
    final String status;
    final Color statusColor;

    const FacultyTile({
      super.key,
      required this.name,
      required this.subject,
      required this.status,
      required this.statusColor,
    });

    @override
    Widget build(BuildContext context) {
      return ListTile(
        contentPadding: EdgeInsets.zero,

        leading: CircleAvatar(
          backgroundColor:
              AppColors.primary.withValues(alpha: 0.2),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subject,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  class ApprovalCard extends StatelessWidget {
    final String title;
    final String subtitle;

    const ApprovalCard({
      super.key,
      required this.title,
      required this.subtitle,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  class AnnouncementTile extends StatelessWidget {
    final String title;
    final String time;

    const AnnouncementTile({
      super.key,
      required this.title,
      required this.time,
    });

    @override
    Widget build(BuildContext context) {
      return ListTile(
        contentPadding: EdgeInsets.zero,

        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.campaign,
            color: AppColors.primary,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          time,
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
      );
    }
  }

 class DashboardDrawer extends StatelessWidget {
    const DashboardDrawer({super.key});

    @override
    Widget build(BuildContext context) {
      return Drawer(
        backgroundColor: AppColors.card,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    'College ERP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // DASHBOARD
            DrawerTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // FACULTY MANAGEMENT
            DrawerTile(
              icon: Icons.people,
              title: 'Faculty Management',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FacultyManagementPage(),
                  ),
                );
              },
            ),

            // STUDENT PERFORMANCE
            DrawerTile(
              icon: Icons.analytics,
              title: 'Student Performance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentPerformancePage(),
                  ),
                );
              },
            ),

            // ATTENDANCE REPORT
            DrawerTile(
              icon: Icons.bar_chart,
              title: 'Attendance Reports',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceReportsPage(),
                  ),
                );
              },
            ),

            // TIMETABLE APPROVAL
            DrawerTile(
              icon: Icons.schedule,
              title: 'Timetable Approval',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TimetableApprovalPage(),
                  ),
                );
              },
            ),

            // ACADEMIC MONITORING
            DrawerTile(
              icon: Icons.menu_book,
              title: 'Academic Monitoring',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AcademicMonitoringPage(),
                  ),
                );
              },
            ),

            // ANNOUNCEMENTS
            DrawerTile(
              icon: Icons.notifications,
              title: 'Announcements',
              onTap: () {},
            ),

            // SETTINGS
            DrawerTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),

            // LOGOUT
            DrawerTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  class DrawerTile extends StatelessWidget {
    final IconData icon;
    final String title;
    final VoidCallback? onTap;

    const DrawerTile({
      super.key,
      required this.icon,
      required this.title,
      this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      return ListTile(
        leading: Icon(
          icon,
          color: AppColors.text,
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),

        onTap: onTap,
      );
    }
  }

  

