import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/widgets/custom_button.dart';
import 'package:college_erp/services/api_service.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _students = [];
  String? _selectedClassId;
  Map<String, String> _attendanceStatus = {};
  
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/teacher/classes');
      
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _classes = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents(String classId) async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final selectedClass = _classes.firstWhere((c) => c['_id'] == classId);
      
      final response = await apiService.get('/api/teacher/students', queryParameters: {
        'courseId': selectedClass['course']?['_id'],
        'semester': selectedClass['course']?['semester'].toString(),
      });

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _students = response.data['data'];
          _attendanceStatus = {};
          for (var s in _students) {
            _attendanceStatus[s['_id']] = 'present';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null || _students.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final apiService = ApiService();
      final selectedClass = _classes.firstWhere((c) => c['_id'] == _selectedClassId);

      final records = [];
      for (var s in _students) {
        records.add({
          'studentId': s['_id'],
          'status': _attendanceStatus[s['_id']] ?? 'absent',
        });
      }

      final response = await apiService.post('/api/teacher/attendance', data: {
        'date': _dateController.text,
        'courseId': selectedClass['course']['_id'],
        'semester': selectedClass['course']['semester'].toString(),
        'records': records,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Attendance saved!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Mark Attendance'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
            Text('📅 Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.card,
              ),
              style: TextStyle(color: AppColors.text),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  _dateController.text = date.toString().split(' ')[0];
                }
              },
            ),
            
            SizedBox(height: 20),
            
            // Class Selection
            Text('📚 Select Class', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClassId,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  hint: Text('Choose a class...', style: TextStyle(color: AppColors.textSecondary)),
                  items: _classes.map<DropdownMenuItem<String>>((cls) {
                    return DropdownMenuItem<String>(
                      value: cls['_id'],
                      child: Text(
                        '${cls['subject']?['name'] ?? ''} - ${cls['course']?['name'] ?? ''} (${cls['studentCount'] ?? 0} students)',
                        style: TextStyle(color: AppColors.text),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                    _loadStudents(value!);
                  },
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Students List
            if (!_isLoading && _students.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('👥 Students (' + _students.length.toString() + ')', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() {
                          for (var key in _attendanceStatus.keys) {
                            _attendanceStatus[key] = 'present';
                          }
                        }),
                        icon: Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                        label: Text('All Present', style: TextStyle(fontSize: 12, color: AppColors.success)),
                      ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                ...List.generate(_students.length, (index) {
                  final student = _students[index];
                  final studentId = student['_id'];
                  final status = _attendanceStatus[studentId] ?? 'present';
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: status == 'present' ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                        child: Text(
                          (student['user']?['firstName']?.toString()[0] ?? '?').toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: status == 'present' ? AppColors.success : AppColors.error),
                        ),
                      ),
                      title: Text(
                        (student['user']?['firstName'] ?? '') + ' ' + (student['user']?['lastName'] ?? ''),
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                      ),
                      subtitle: Text(
                        'Roll No: ' + (student['rollNumber'] ?? 'N/A'),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() {
                            _attendanceStatus[studentId] = status == 'present' ? 'absent' : 'present';
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 36,
                          decoration: BoxDecoration(
                            color: status == 'present' ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: status == 'present' ? AppColors.success : AppColors.error,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(status == 'present' ? Icons.check_circle : Icons.cancel, size: 18, color: status == 'present' ? AppColors.success : AppColors.error),
                              SizedBox(width: 4),
                              Text(status == 'present' ? 'Present' : 'Absent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: status == 'present' ? AppColors.success : AppColors.error)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 24),

                CustomButton(
                  text: _isSaving ? 'Saving...' : '✓ Submit Attendance',
                  icon: _isSaving ? Icons.hourglass_empty : Icons.check_circle,
                  onPressed: _isSaving ? null : _submitAttendance,
                  fullWidth: true,
                ),
              ],

              if (_isLoading && _selectedClassId != null)
                Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),

              if (!_isLoading && _selectedClassId != null && _students.isEmpty)
                Center(child: Padding(padding: EdgeInsets.all(40), child: Column(children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No students found', style: TextStyle(color: AppColors.textSecondary)),
                ]))),
          ],
        ),
      ),
    );
  }
}