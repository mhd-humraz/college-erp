import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherUploadMarksScreen extends StatefulWidget {
  const TeacherUploadMarksScreen({super.key});

  @override
  State<TeacherUploadMarksScreen> createState() => _TeacherUploadMarksScreenState();
}

class _TeacherUploadMarksScreenState extends State<TeacherUploadMarksScreen> {
  List<dynamic> _classes = [];
  List<dynamic> _students = [];
  String? _selectedClassId;
  String? _selectedSubject;
  String? _examType;
  int _maxMarks = 100;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, TextEditingController> _marksControllers = {};

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
        _marksControllers = {};
        for (var s in _students) {
          _marksControllers[s['_id']] = TextEditingController();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitMarks() async {
    if (_selectedClassId == null || _examType == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      final marksData = _students.map((s) => {
        'studentId': s['_id'],
        'score': int.tryParse(_marksControllers[s['_id']]?.text ?? '0') ?? 0,
        'maxScore': _maxMarks,
      }).toList();

      await ApiService.post('/teacher/upload-marks', data: {
        'classId': _selectedClassId,
        'subject': _selectedSubject,
        'examType': _examType,
        'maxMarks': _maxMarks,
        'marks': marksData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Marks uploaded successfully!'),
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
        title: Text('Upload Marks', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.card,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    prefixIcon: Icon(Icons.class_),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  items: _classes.map((c) => DropdownMenuItem(
                    value: c['_id']?.toString(),
                    child: Text(c['name'] ?? ''),
                  )).toList(),
                  onChanged: (v) {
                    setState(() => _selectedClassId = v);
                    if (v != null) _fetchStudents(v);
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    prefixIcon: Icon(Icons.book),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (v) => setState(() => _selectedSubject = v),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _examType,
                  decoration: InputDecoration(
                    labelText: 'Exam Type',
                    prefixIcon: Icon(Icons.assignment),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  items: ['Internal 1', 'Internal 2', 'Semester Exam', 'Quiz'].map((t) => 
                    DropdownMenuItem(value: t, child: Text(t))
                  ).toList(),
                  onChanged: (v) => setState(() => _examType = v),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max Marks',
                          prefixIcon: Icon(Icons.grade),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        onChanged: (v) => setState(() => _maxMarks = int.tryParse(v) ?? 100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _students.isEmpty 
                ? Center(child: Text('No students found', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: _students.length,
                    itemBuilder: (ctx, index) {
                      final s = _students[index];
                      return Card(
                        color: AppColors.card,
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                                    Text('Roll: ${s['rollNumber'] ?? ''}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _marksControllers[s['_id']],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '/$_maxMarks',
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_students.isNotEmpty)
            Container(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitMarks,
                  icon: _isSubmitting 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.upload),
                  label: Text(_isSubmitting ? 'Uploading...' : 'Upload Marks'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ),
            )
        ],
      ),
    );
  }
}