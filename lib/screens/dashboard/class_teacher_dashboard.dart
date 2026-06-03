import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ClassTeacherDashboard extends StatefulWidget {
  const ClassTeacherDashboard({super.key});

  @override
  State<ClassTeacherDashboard> createState() => _ClassTeacherDashboardState();
}

class _ClassTeacherDashboardState extends State<ClassTeacherDashboard> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final res = await ApiService.get('/student/class-students');
      setState(() {
        _students = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showRequestStudentDialog() {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Request Add Student', style: TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: TextStyle(color: AppColors.text), decoration: InputDecoration(labelText: 'Student Name *')),
            const SizedBox(height: 10),
            TextField(controller: rollCtrl, style: TextStyle(color: AppColors.text), decoration: InputDecoration(labelText: 'Roll Number')),
            const SizedBox(height: 10),
            TextField(controller: reasonCtrl, style: TextStyle(color: AppColors.text), maxLines: 2, decoration: InputDecoration(labelText: 'Reason')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.post('/student/request-student', data: {
                  'studentName': nameCtrl.text,
                  'rollNumber': rollCtrl.text,
                  'reason': reasonCtrl.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to HOD!'), backgroundColor: AppColors.success));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: AppColors.error));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Send Request'),
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
      appBar: AppBar(
        title: Text('Class Teacher Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.logout, color: AppColors.text), onPressed: () => context.read<AuthProvider>().logout()),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadStudents,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFA29BFE).withOpacity(0.2), AppColors.card]),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(color: Color(0xFFA29BFE).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(width: 48, height: 48, decoration: BoxDecoration(color: Color(0xFFA29BFE).withOpacity(0.25), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.class_, color: Color(0xFFA29BFE), size: 26)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Class Teacher Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                              Text('Class: ${user?['className'] ?? 'N/A'} | Students: ${_students.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ])),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Actions
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      _actionChip(Icons.people, "View Students (${_students.length})", AppColors.primary, (){}),
                      _actionChip(Icons.person_add, 'Request Student', Color(0xFFA29BFE), _showRequestStudentDialog),
                      _actionChip(Icons.fact_check, 'Attendance Report', AppColors.success, (){}),
                      _actionChip(Icons.beach_access, 'Leave Requests', AppColors.warning, (){}),
                    ]),
                    const SizedBox(height: 22),

                    // Students List
                    Text('My Class Students', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ..._students.map((s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.15), child: Icon(Icons.person, color: AppColors.primary)),
                      title: Text(s['name'] ?? '', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                      subtitle: Text('Roll: ${s['rollNumber']} | ${s['email'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onSelected: (value) {},
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'view', child: Text('View Profile')),
                          PopupMenuItem(value: 'attendance', child: Text('Attendance')),
                          PopupMenuItem(value: 'contact', child: Text('Contact Parent')),
                        ],
                      ),
                    )).toList(),
                    
                    if (_students.isEmpty)
                      Padding(padding: EdgeInsets.all(40), child: Center(child: Column(children: [
                        Icon(Icons.group_off, size: 60, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('No students found in your class', style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(onPressed: _showRequestStudentDialog, child: Text('Request to add students →', style: TextStyle(color: AppColors.primary))),
                      ]))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 12)),
        ]),
      ),
    );
  }
}