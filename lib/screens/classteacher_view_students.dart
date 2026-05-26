import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'classteacher_request_student.dart'; // ✅ IMPORT ADDED!

class ClassTeacherViewStudentsScreen extends StatefulWidget {
  const ClassTeacherViewStudentsScreen({super.key});

  @override
  State<ClassTeacherViewStudentsScreen> createState() => _ClassTeacherViewStudentsScreenState();
}

class _ClassTeacherViewStudentsScreenState extends State<ClassTeacherViewStudentsScreen> {
  List<dynamic> _students = [];
  List<dynamic> _originalStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() { 
    super.initState(); 
    _fetchStudents(); 
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/class-teacher/students');
      setState(() { 
        _students = res.data['data'] ?? []; 
        _originalStudents = List.from(_students);
        _isLoading = false; 
      });
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  void _filterStudents() {
    if (_searchQuery.isEmpty) { 
      setState(() => _students = List.from(_originalStudents));
    } else { 
      setState(() {
        _students = _originalStudents.where((s) => 
          (s['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) || 
          (s['rollNumber'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Class Students', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ClassTeacherRequestStudentScreen()) // ✅ NOW THIS WILL WORK!
          );
        },
        backgroundColor: Color(0xFFA29BFE),
        icon: Icon(Icons.person_add),
        label: Text('Request Student'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.card,
            child: TextField(
              onChanged: (v) { 
                _searchQuery = v; 
                _filterStudents(); 
              },
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
              ),
            ),
          ),

          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _students.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        SizedBox(height: 16),
                        Text('No students in your class', style: TextStyle(color: AppColors.textSecondary)),
                        SizedBox(height: 8),
                        Text('Tap + to request adding students', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchStudents,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _students.length,
                      itemBuilder: (ctx, index) {
                        final s = _students[index];
                        
                        return Card(
                          color: AppColors.card,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.primary.withOpacity(0.15),
                                      child: Text(s['name']?.substring(0, 1)?.toUpperCase() ?? 'S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                                          Text('Roll: ${s['rollNumber']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ],
                                ),
                                
                                SizedBox(height: 8),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _infoChip('Attendance', '${s['attendancePercent'] ?? 0}%', s['attendancePercent'] != null && s['attendancePercent'] >= 75 ? AppColors.success : AppColors.error),
                                    _infoChip('Marks Avg', '${s['averageMarks'] ?? 'N/A'}', AppColors.info),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}