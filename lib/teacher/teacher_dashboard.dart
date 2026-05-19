import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../teacher/attendance_entry.dart';
import '../teacher/announcements.dart';
import '../teacher/assignment_upload.dart';
import '../teacher/leave_management.dart';
import '../teacher/marks_entry.dart';
import '../teacher/student_list.dart';
import '../teacher/study_materials.dart';
import '../teacher/timetable.dart';

class TeacherDashboard extends StatefulWidget {
  final Map<String, dynamic> user; 

  const TeacherDashboard({super.key, required this.user});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Timetable', 'icon': Icons.calendar_month_rounded},
    {'title': 'Attendance', 'icon': Icons.check_circle_rounded},
    {'title': 'Assignments', 'icon': Icons.assignment_rounded},
    {'title': 'Leave Management', 'icon': Icons.description_rounded},
    {'title': 'Mark Entry', 'icon': Icons.grade_rounded},
    {'title': 'Study Materials', 'icon': Icons.menu_book_rounded},
    {'title': 'Student List', 'icon': Icons.people_rounded},
    {'title': 'Announcements', 'icon': Icons.announcement_rounded},
  ];

  String get _todayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        title: const Text('Teacher Dashboard', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text((widget.user['name'] ?? 'T')[0].toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildTaskCard(),
            const SizedBox(height: 24),
            Text('Quick Access', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.8))),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.05),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Interval(0.1 + index * 0.07, 0.5 + index * 0.07, curve: Curves.easeOutBack)));
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: anim,
                      child: _DashboardCard(
                        title: item['title'], icon: item['icon'],
                        onTap: () {
                          Widget page;
                          switch (item['title']) {
                            case 'Timetable': page = const TimetablePage(); break;
                            case 'Attendance': page = const AttendanceEntry(); break;
                            case 'Assignments': page = const AssignmentUploadPage(); break;
                            case 'Leave Management': page = const LeaveManagementPage(); break;
                            case 'Mark Entry': page = const MarkEntryPage(); break;
                            case 'Study Materials': page = const StudyMaterialPage(); break;
                            case 'Student List': page = const StudentListPage(); break;
                            case 'Announcements': page = const AnnouncementsPage(); break;
                            default: page = const Scaffold(body: Center(child: Text('Page Not Found')));
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.borderRadius), border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_todayName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 10),
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.cast_for_education_rounded, color: AppColors.primary, size: 24)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome back 👋', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text.withOpacity(0.5))), Text(widget.user['name'] ?? 'Teacher', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text))]),
          ]),
          const SizedBox(height: 12),
          Text('This dashboard helps you manage attendance, assignments, timetable, leave letters, marks, study materials, and announcements easily.', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text.withOpacity(0.5), height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    final tasks = ['Upload today\'s assignment', 'Complete attendance entry', 'Update internal marks', 'Check leave requests'];
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Tasks", style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 14),
        ...tasks.map((task) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20), const SizedBox(width: 10), Expanded(child: Text(task, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.text.withOpacity(0.8))))]))),
      ]),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.card),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text((widget.user['name'] ?? 'T')[0].toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(height: 12),
              Text(widget.user['name'] ?? 'Teacher', style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
              Text(widget.user['teacherId'] ?? '', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.45), fontSize: 12)),
            ]),
          ),
          ..._menuItems.map((item) => ListTile(leading: Icon(item['icon'], color: AppColors.primary), title: Text(item['title'], style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 15)), onTap: () => Navigator.pop(context))),
          const Divider(color: AppColors.card),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontSize: 15)),
            onTap: _handleLogout, // Actually logs out now!
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String title; final IconData icon; final VoidCallback onTap;
  const _DashboardCard({required this.title, required this.icon, required this.onTap});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0), padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(widget.icon, color: AppColors.primary, size: 24)),
          const SizedBox(height: 14),
          Text(widget.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        ]),
      ),
    );
  }
}