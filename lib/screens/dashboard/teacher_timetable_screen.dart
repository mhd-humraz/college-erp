import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  Map<String, dynamic> _timetable = {};
  bool _isLoading = true;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() { 
    super.initState(); 
    _fetchTimetable(); 
  }

  Future<void> _fetchTimetable() async {
    try {
      final res = await ApiService.get('/teacher/my-timetable');
      setState(() { 
        _timetable = res.data['data'] is Map ? res.data['data'] : {}; 
        _isLoading = false; 
      });
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Timetable', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _fetchTimetable,
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
                        Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        SizedBox(height: 12),
                        if (entries.isEmpty)
                          Text('No classes', style: TextStyle(color: AppColors.textSecondary))
                        else
                          ...entries.map((entry) => ListTile(
                            dense: true,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${entry['period'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  Text('${entry['startTime'] ?? ''}-${entry['endTime'] ?? ''}', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            title: Text(entry['subjectId']?['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                            subtitle: Text(entry['classId']?['name'] ?? '', style: TextStyle(color: AppColors.textSecondary)),
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