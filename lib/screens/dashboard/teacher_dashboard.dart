import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<dynamic> _myClasses = [];
  Map<String, dynamic> _timetable = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final classesRes = await ApiService.get('/teacher/my-classes');
      final timeRes = await ApiService.get('/teacher/my-timetable');
      
      setState(() {
        _myClasses = classesRes.data['data'] ?? [];
        _timetable = timeRes.data['data'] is Map ? timeRes.data['data'] : {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Teacher Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.text),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.info.withOpacity(0.2), AppColors.card],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, color: AppColors.info, size: 26),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${user?['name']?.split(' ').first ?? 'Teacher'}!',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    Text('${user?['departmentName'] ?? ''} Department', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _miniStat('Classes', '${_myClasses.length}', AppColors.primary),
                              const SizedBox(width: 12),
                              _miniStat('Today', '4', AppColors.success),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Quick Actions
                    Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _actionChip(Icons.check_circle_outline, 'Mark Attendance', AppColors.success, (){}),
                        _actionChip(Icons.grade_outlined, 'Upload Marks', AppColors.warning, (){}),
                        _actionChip(Icons.upload_file, 'Share Materials', AppColors.info, (){}),
                        _actionChip(Icons.calendar_today, 'View Timetable', AppColors.primary, (){}),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Today's Classes
                    Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (_timetable.isNotEmpty)
                      ...(_timetable['Monday'] ?? []).take(5).map((entry) => _scheduleCard(entry)).toList()
                    else
                      Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No classes scheduled', style: TextStyle(color: AppColors.textSecondary)))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))
        ]),
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

  Widget _scheduleCard(dynamic entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(entry['startTime'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
              Text(entry['endTime'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry['subjectId']?['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 14)),
              Text('${entry['classId']?['name'] ?? ''} • Period ${entry['period']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}