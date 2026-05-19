import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 
import '../hod/academic_monitoring.dart';
import '../hod/attendance_reports.dart';
import '../hod/faculty_management.dart';
import '../hod/student_performance.dart';
import '../hod/timetable_approval.dart';

import '../utils/theme.dart';

// 👇 ADD THIS IMPORT (NEW!)
import '../services/api_service.dart';

class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodDashboardState();
}

// ==========================================
// 🔥 UPDATED: Now fetches from backend!
// ==========================================
class _HodDashboardState extends State<HodDashboard> {
  File? profileImage;

  // 👇 NEW: API state variables
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // Load data when screen opens
  }

  /// Load dashboard data from backend
  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.fetchHODDashboard();
      
      if (mounted) {
        setState(() {
          dashboardData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  /// Pull-to-refresh handler
  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
      
      // 👇 NEW: Upload to backend
      final imageUrl = await ApiService.uploadProfileImage(File(pickedFile.path));
      if (imageUrl != null) {
        print('✅ Profile image uploaded!');
      }
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

      // 👇 UPDATED: Loading / Error / Success states
      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
              ? _buildErrorState()
              : _buildSuccessState(),
    );
  }

  /// Loading spinner
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  /// Error screen with retry button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, color: Colors.red[200]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main success view with REAL DATA from backend
  Widget _buildSuccessState() {
    final stats = dashboardData?['stats'] ?? {};
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(),

            const SizedBox(height: 24),

            // 👇 UPDATED: Stats with REAL DATA
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  title: 'Total Students',
                  value: '${stats['totalStudents'] ?? '--'}',  // ← REAL DATA
                  icon: Icons.people,
                ),

                DashboardCard(
                  title: 'Faculty Members',
                  value: '${stats['totalFaculty'] ?? '--'}',   // ← REAL DATA
                  icon: Icons.school,
                ),

                DashboardCard(
                  title: 'Attendance',
                  value: '${stats['attendance'] ?? '--}%',     // ← REAL DATA
                  icon: Icons.bar_chart,
                ),

                DashboardCard(
                  title: 'Pending Requests',
                  value: '${stats['pendingRequests'] ?? '--'}', // ← REAL DATA
                  icon: Icons.pending_actions,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 👇 UPDATED: Attendance with REAL DATA
            _buildAttendanceSection(),

            const SizedBox(height: 30),

            // 👇 UPDATED: Faculty with REAL DATA
            _buildFacultySection(),

            const SizedBox(height: 30),

            // 👇 UPDATED: Approvals with REAL DATA + WORKING BUTTONS
            _buildApprovalsSection(),

            const SizedBox(height: 30),

            // Announcements (placeholder - can connect later)
            const SectionTitle(title: 'Recent Announcements'),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: const Center(
                child: Text(
                  'Announcements coming soon...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Attendance Overview Section with REAL DATA
  Widget _buildAttendanceSection() {
    final attendance = dashboardData?['attendanceOverview'] ?? {};

    return Column(
      children: [
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
                child: LinearProgressIndicator(
                  value: (attendance['percentage'] ?? 0) / 100,  // ← REAL DATA
                  minHeight: 14,
                  backgroundColor: Colors.white12,
                  valueColor:
                      AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                attendance['message'] ?? 'No data available',  // ← REAL DATA
                style: const TextStyle(color: Colors.white70),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Faculty Monitoring Section with REAL DATA
  Widget _buildFacultySection() {
    final facultyList = dashboardData?['facultyMonitoring'] ?? [];

    return Column(
      children: [
        const SectionTitle(title: 'Faculty Monitoring'),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: facultyList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No faculty data available',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              : Column(
                  children: facultyList.map<Widget>((faculty) {
                    return FacultyTile(
                      name: faculty['name'] ?? 'Unknown',
                      subject: faculty['subject'] ?? 'N/A',
                      status: faculty['status'] ?? 'Active',
                      statusColor: _parseColor(faculty['statusColor']),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  /// Pending Approvals Section with REAL DATA + WORKING BUTTONS
  Widget _buildApprovalsSection() {
    final approvals = dashboardData?['pendingApprovals'] ?? [];

    return Column(
      children: [
        const SectionTitle(title: 'Pending Approvals'),

        const SizedBox(height: 14),

        approvals.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Center(
                  child: Text(
                    'No pending approvals',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            : Column(
                children: approvals.map<Widget>((approval) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ApprovalCard(
                      title: approval['title'] ?? 'Leave Request',
                      subtitle: approval['subtitle'] ?? '',
                      onApprove: () => _handleApproval(approval['id'], 'approve'),
                      onReject: () => _handleApproval(approval['id'], 'reject'),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  /// Handle approve/reject button press
  Future<void> _handleApproval(String? requestId, String action) async {
    if (requestId == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          '$action Request?',
          style: const TextStyle(color: AppColors.text),
        ),
        content: Text(
          'Are you sure you want to $action this leave request?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action.toUpperCase(),
              style: TextStyle(
                color: action == 'approve' ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Call API
      final success = await ApiService.processApproval(
        requestId: requestId,
        action: action,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${action}d successfully!'),
            backgroundColor: action == 'approve' ? Colors.green : Colors.red,
          ),
        );
        // Refresh data
        _loadDashboardData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Parse hex color string to Color object
  Color _parseColor(dynamic colorString) {
    if (colorString == null) return Colors.green;

    final hexColor = colorString.toString().replaceAll('#', '');
    try {
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.green; // Default fallback
    }
  }
}

// ==========================================
// ✅ KEEP ALL THESE WIDGETS EXACTLY AS-IS
// (except ApprovalCard which got 2 new params)
// ==========================================

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
      ),
    );
  }
}

// ==========================================
// 🔧 UPDATED: Added onApprove and onReject callbacks
// ==========================================
class ApprovalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onApprove;   // ← NEW PARAMETER
  final VoidCallback? onReject;    // ← NEW PARAMETER

  const ApprovalCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onApprove,                // ← ADD THIS
    this.onReject,                 // ← ADD THIS
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
                  onPressed: onApprove,       // ← USE CALLBACK NOW
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
                  onPressed: onReject,        // ← USE CALLBACK NOW
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