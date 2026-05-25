import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherMarkAttendanceScreen extends StatefulWidget {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  State<TeacherMarkAttendanceScreen> createState() => _TeacherMarkAttendanceScreenState();
}

class _TeacherMarkAttendanceScreenState extends State<TeacherMarkAttendanceScreen> {
  List<dynamic> _classes = [];
  List<dynamic> _students = [];
  String? _selectedClassId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final res = await ApiService.get('/teacher/my-classes');
      setState(() {
        _classes = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudents(String classId) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/teacher/students/$classId');
      setState(() {
        _students = res.data['data'] ?? [];
        _attendanceStatus = {};
        for (var s in _students) {
          _attendanceStatus[s['_id']] = 'present';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null || _students.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      final attendanceRecords = _students.map((s) => {
        'studentId': s['_id'],
        'status': _attendanceStatus[s['_id']] ?? 'present',
        'date': DateTime.now().toIso8601String(),
      }).toList();

      await ApiService.post('/teacher/mark-attendance', data: {
        'classId': _selectedClassId,
        'records': attendanceRecords,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Attendance marked successfully!'),
          backgroundColor: AppColors.success,
        ));
        setState(() {
          _students = [];
          _selectedClassId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mark Attendance', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Class Selector
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.card,
            child: DropdownButtonFormField<String>(
              value: _selectedClassId,
              decoration: InputDecoration(
                labelText: 'Select Class',
                prefixIcon: Icon(Icons.class_),
                filled: true,
                fillColor: AppColors.background,
              ),
              items: _classes.map((c) => DropdownMenuItem(
                value: c['_id']?.toString(),
                child: Text(c['name'] ?? '', style: TextStyle(color: AppColors.text)),
              )).toList(),
              onChanged: (val) {
                setState(() => _selectedClassId = val);
                if (val != null) _fetchStudents(val);
              },
            ),
          ),

          // Student List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _students.isEmpty 
                ? Center(child: Text('No students found', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final status = _attendanceStatus[student['_id']] ?? 'present';
                      
                      return Card(
                        color: AppColors.card,
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(student['name']?.substring(0, 1)?.toUpperCase() ?? 'S'),
                          ),
                          title: Text(student['name'] ?? '', style: TextStyle(color: AppColors.text)),
                          subtitle: Text('Roll: ${student['rollNumber'] ?? ''}', style: TextStyle(color: AppColors.textSecondary)),
                          trailing: SegmentedButton<String>(
                            segments: [
                              ButtonSegment(value: 'present', label: Text('P'), icon: Icon(Icons.check, size: 16)),
                              ButtonSegment(value: 'absent', label: Text('A'), icon: Icon(Icons.close, size: 16)),
                              ButtonSegment(value: 'late', label: Text('L'), icon: Icon(Icons.access_time, size: 16)),
                            ],
                            selected: {status},
                            onSelectionChanged: (s) => setState(() => _attendanceStatus[student['_id']] = s.first),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Submit Button
          if (_students.isNotEmpty)
            Container(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitAttendance,
                  icon: _isSubmitting 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.save),
                  label: Text(_isSubmitting ? 'Saving...' : 'Submit Attendance'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ),
            )
        ],
      ),
    );
  }
}