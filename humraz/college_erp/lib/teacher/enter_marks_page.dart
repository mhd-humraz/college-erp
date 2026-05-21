import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/widgets/custom_button.dart';
import 'package:college_erp/services/api_service.dart';

class EnterMarksPage extends StatefulWidget {
  const EnterMarksPage({super.key});

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _students = [];
  String? _selectedClassId;
  String _examType = 'internal1';
  final _maxMarksController = TextEditingController(text: '50');
  
  Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/teacher/classes');
      
      if (response.statusCode == 200 && response.data['success']) {
        setState(() => _classes = response.data['data']);
        _isLoading = false;
      }
    } catch (e) {
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
          _marksControllers = {};
          for (var s in _students) {
            _marksControllers[s['_id']] = TextEditingController();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitMarks() async {
    if (_selectedClassId == null || _students.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final apiService = ApiService();
      final selectedClass = _classes.firstWhere((c) => c['_id'] == _selectedClassId);
      final maxMarks = double.tryParse(_maxMarksController.text) ?? 50;

      final marks = [];
      for (var s in _students) {
        final controller = _marksControllers[s['_id']];
        marks.add({
          'studentId': s['_id'],
          'marksObtained': double.tryParse(controller?.text ?? '0') ?? 0,
        });
      }

      final response = await apiService.post('/api/teacher/marks', data: {
        'examType': _examType,
        'courseId': selectedClass['course']['_id'],
        'semester': selectedClass['course']['semester'].toString(),
        'maxMarks': maxMarks.toString(),
        'marks': marks,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Marks saved successfully!'), backgroundColor: AppColors.success),
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
      appBar: CustomAppBar(title: 'Enter Marks'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Type Selection
            Text('📝 Exam Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _examType,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: 'internal1', child: Text('Internal Exam 1')),
                    DropdownMenuItem<String>(value: 'internal2', child: Text('Internal Exam 2')),
                    DropdownMenuItem<String>(value: 'semester', child: Text('Semester Exam')),
                    DropdownMenuItem<String>(value: 'practical', child: Text('Practical Exam')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => _examType = val); },
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Max Marks
            TextField(
              controller: _maxMarksController,
              decoration: InputDecoration(
                labelText: 'Maximum Marks',
                hintText: 'e.g., 50, 100',
                prefixIcon: Icon(Icons.star_border, color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.card,
              ),
              style: TextStyle(color: AppColors.text),
              keyboardType: TextInputType.number,
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
                  hint: Text('Choose class...'),
                  items: _classes.map<DropdownMenuItem<String>>((cls) {
                    return DropdownMenuItem<String>(
                      value: cls['_id'],
                      child: Text('${cls['subject']?['name']} - ${cls['course']?['name']}', style: TextStyle(color: AppColors.text)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedClassId = val);
                      _loadStudents(val);
                    }
                  },
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Students Marks Entry
            if (!_isLoading && _students.isNotEmpty) ...[
              Text('📊 Enter Marks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
              SizedBox(height: 12),
              
              Card(
                color: AppColors.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.1)),
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final controller = _marksControllers[student['_id']];
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (student['user']?['firstName'] ?? '') + ' ' + (student['user']?['lastName'] ?? ''),
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                                ),
                                Text(
                                  'Roll: ' + (student['rollNumber'] ?? 'N/A'),
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '0-' + (_maxMarksController.text),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.background,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 24),

              CustomButton(
                text: _isSaving ? 'Saving...' : '💾 Save Marks',
                icon: _isSaving ? Icons.hourglass_empty : Icons.save,
                onPressed: _isSaving ? null : _submitMarks,
                fullWidth: true,
              ),
            ],

            if (_isLoading && _selectedClassId != null)
              Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),
          ],
        ),
      ),
    );
  }
}