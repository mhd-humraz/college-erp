import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HodManageTimetableScreen extends StatefulWidget {
  const HodManageTimetableScreen({super.key});

  @override
  State<HodManageTimetableScreen> createState() => _HodManageTimetableScreenState();
}

class _HodManageTimetableScreenState extends State<HodManageTimetableScreen> {
  Map<String, dynamic> _timetable = {};
  List<dynamic> _classes = [];
  List<dynamic> _teachers = [];
  List<dynamic> _subjects = [];
  bool _isLoading = true;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<int> _periods = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final timeRes = await ApiService.get('/hod/timetable');
      final classRes = await ApiService.get('/hod/classes');
      final teacherRes = await ApiService.get('/hod/teachers');
      final subjectRes = await ApiService.get('/hod/subjects');

      setState(() {
        _timetable = timeRes.data['data'] is Map ? timeRes.data['data'] : {};
        _classes = classRes.data['data'] ?? [];
        _teachers = teacherRes.data['data'] ?? [];
        _subjects = subjectRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddEntryDialog() {
    String? selectedDay;
    int? selectedPeriod;
    String? selectedClass;
    String? selectedTeacher;
    String? selectedSubject;
    String startTime = '09:00';
    String endTime = '09:50';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Add Timetable Entry', style: TextStyle(color: AppColors.text)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: InputDecoration(labelText: 'Day', filled: true, fillColor: AppColors.background),
                items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => selectedDay = v,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedPeriod,
                decoration: InputDecoration(labelText: 'Period', filled: true, fillColor: AppColors.background),
                items: _periods.map((p) => DropdownMenuItem(value: p, child: Text('Period $p'))).toList(),
                onChanged: (v) => selectedPeriod = v,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: InputDecoration(labelText: 'Class', filled: true, fillColor: AppColors.background),
                items: _classes.map((c) => DropdownMenuItem(value: c['_id']?.toString(), child: Text(c['name'] ?? ''))).toList(),
                onChanged: (v) => selectedClass = v,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTeacher,
                decoration: InputDecoration(labelText: 'Teacher', filled: true, fillColor: AppColors.background),
                items: _teachers.map((t) => DropdownMenuItem(value: t['_id']?.toString(), child: Text(t['name'] ?? ''))).toList(),
                onChanged: (v) => selectedTeacher = v,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: InputDecoration(labelText: 'Subject', filled: true, fillColor: AppColors.background),
                items: _subjects.map((s) => DropdownMenuItem(value: s['_id']?.toString(), child: Text(s['name'] ?? ''))).toList(),
                onChanged: (v) => selectedSubject = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedDay != null && selectedPeriod != null && selectedClass != null && selectedTeacher != null && selectedSubject != null) {
                Navigator.pop(ctx);
                try {
                  await ApiService.post('/hod/create-timetable', data: {
                    'day': selectedDay,
                    'period': selectedPeriod,
                    'classId': selectedClass,
                    'teacherId': selectedTeacher,
                    'subjectId': selectedSubject,
                    'startTime': startTime,
                    'endTime': endTime,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timetable entry added!'), backgroundColor: AppColors.success));
                    _fetchData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                  }
                }
              }
            },
            child: Text('Add Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Timetable', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.text),
            tooltip: 'Add Entry',
            onPressed: _showAddEntryDialog,
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _fetchData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: _days.length,
              itemBuilder: (ctx, index) {
                final day = _days[index];
                final entries = _timetable[day] ?? [];

                return Card(
                  color: AppColors.card,
                  margin: EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.warning)),
                            Text('${entries.length} classes', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (entries.isEmpty)
                          Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No classes scheduled', style: TextStyle(color: AppColors.textSecondary))))
                        else
                          ...entries.map((entry) => ListTile(
                            dense: true,
                            leading: Text('P${entry['period'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                            title: Text(entry['subjectId']?['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                            subtitle: Text('${entry['classId']?['name'] ?? ''} • ${entry['teacherId']?['name'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            trailing: Text('${entry['startTime'] ?? ''}-${entry['endTime'] ?? ''}', style: TextStyle(color: AppColors.info, fontSize: 11)),
                          )).toList()
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }
}