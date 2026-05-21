import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  bool _isLoading = true;
  List<dynamic> _classes = [];
  List<dynamic> _students = [];
  String? _selectedClassId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/teacher/classes');
      if (response.statusCode == 200) {
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
        'search': _searchController.text,
      });

      if (response.statusCode == 200) {
        setState(() {
          _students = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'My Students'),
      body: Column(
        children: [
          // Filters
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.1))),
            ),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or roll number...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  style: TextStyle(color: AppColors.text),
                  onSubmitted: (_) {
                    if (_selectedClassId != null) _loadStudents(_selectedClassId!);
                  },
                ),
                
                SizedBox(height: 12),
                
                // Class Filter
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClassId,
                      isExpanded: true,
                      dropdownColor: AppColors.card,
                      hint: Text('All Classes'),
                      items: _classes.map<DropdownMenuItem<String>>((cls) {
                        return DropdownMenuItem<String>(
                          value: cls['_id'],
                          child: Text('${cls['subject']?['name']} - ${cls['course']?['name']} (${cls['studentCount'] ?? 0})'),
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
              ],
            ),
          ),

          // Students List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text('No students found', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (_selectedClassId != null) {
                            await _loadStudents(_selectedClassId!);
                          }
                        },
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              color: AppColors.card,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      child: Text(
                                        ((student['user']?['firstName']?.toString()[0] ?? '?').toUpperCase()) +
                                        ((student['user']?['lastName']?.toString()[0] ?? '').toUpperCase()),
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (student['user']?['firstName'] ?? '') + ' ' + (student['user']?['lastName'] ?? ''),
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
                                          ),
                                          SizedBox(height: 4),
                                          Text('Roll No: ' + (student['rollNumber'] ?? 'N/A'), style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                                              SizedBox(width: 4),
                                              Expanded(child: Text(student['user']?.email ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                                              SizedBox(width: 12),
                                              Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                                              SizedBox(width: 4),
                                              Text(student['user']?.phone ?? 'N/A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
}