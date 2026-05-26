import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HodAssignTeacherScreen extends StatefulWidget {
  const HodAssignTeacherScreen({super.key});

  @override
  State<HodAssignTeacherScreen> createState() => _HodAssignTeacherScreenState();
}

class _HodAssignTeacherScreenState extends State<HodAssignTeacherScreen> {
  List<dynamic> _teachers = [];
  List<dynamic> _classes = [];
  List<dynamic> _subjects = [];
  bool _isLoading = true;
  bool _isAssigning = false;

  String? _selectedTeacherId;
  String? _selectedClassId;
  String? _selectedSubjectId;
  bool _isClassTeacher = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final teachersRes = await ApiService.get('/hod/teachers');
      final classesRes = await ApiService.get('/hod/classes');
      final subjectsRes = await ApiService.get('/hod/subjects');

      setState(() {
        _teachers = teachersRes.data['data'] ?? [];
        _classes = classesRes.data['data'] ?? [];
        _subjects = subjectsRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignTeacher() async {
    if (_selectedTeacherId == null || _selectedClassId == null) return;

    setState(() => _isAssigning = true);
    try {
      await ApiService.post('/hod/assign-teacher', data: {
        'teacherId': _selectedTeacherId,
        'classId': _selectedClassId,
        'subjectIds': [_selectedSubjectId],
        'isClassTeacher': _isClassTeacher,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Teacher assigned successfully!'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Assign Teacher', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign teachers to classes and subjects', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                SizedBox(height: 20),

                // Select Teacher
                Card(
                  color: AppColors.card,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Teacher', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedTeacherId,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: _teachers.map((t) => DropdownMenuItem(
                            value: t['_id']?.toString(),
                            child: Text(t['name'] ?? '', style: TextStyle(color: AppColors.text)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedTeacherId = v),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Select Class
                Card(
                  color: AppColors.card,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Class', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedClassId,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.class_),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: _classes.map((c) => DropdownMenuItem(
                            value: c['_id']?.toString(),
                            child: Text(c['name'] ?? '', style: TextStyle(color: AppColors.text)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedClassId = v),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Select Subject
                Card(
                  color: AppColors.card,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Subject', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSubjectId,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.book),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          items: _subjects.map((s) => DropdownMenuItem(
                            value: s['_id']?.toString(),
                            child: Text(s['name'] ?? '', style: TextStyle(color: AppColors.text)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedSubjectId = v),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Class Teacher Toggle
                Card(
                  color: AppColors.card,
                  child: SwitchListTile(
                    title: Text('Assign as Class Teacher', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500)),
                    subtitle: Text('This teacher will manage the entire class', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    activeColor: AppColors.warning,
                    value: _isClassTeacher,
                    onChanged: (v) => setState(() => _isClassTeacher = v),
                  ),
                ),
                SizedBox(height: 24),

                // Assign Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isAssigning ? null : _assignTeacher,
                    icon: _isAssigning 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(Icons.person_add),
                    label: Text(_isAssigning ? 'Assigning...' : 'Assign Teacher'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}