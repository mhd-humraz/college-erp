import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HodStudentsListScreen extends StatefulWidget {
  const HodStudentsListScreen({super.key});

  @override
  State<HodStudentsListScreen> createState() => _HodStudentsListScreenState();
}

class _HodStudentsListScreenState extends State<HodStudentsListScreen> {
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
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
      final res = await ApiService.get('/hod/students');
      setState(() {
        _students = res.data['data'] ?? [];
        _filteredStudents = List.from(_students);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents() {
    if (_searchQuery.isEmpty) {
      setState(() => _filteredStudents = List.from(_students));
    } else {
      setState(() {
        _filteredStudents = _students.where((s) {
          final name = (s['name'] ?? '').toLowerCase();
          final roll = (s['rollNumber'] ?? '').toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) || roll.contains(_searchQuery.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Department Students', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.card,
            child: TextField(
              onChanged: (val) {
                _searchQuery = val;
                _filterStudents();
              },
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search by name or roll number...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 18), onPressed: () { setState(() => _searchQuery = ''); _filterStudents(); })
                  : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Stats
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Total: ${_students.length}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                Text('Showing: ${_filteredStudents.length}', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filteredStudents.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        SizedBox(height: 16),
                        Text(_searchQuery.isNotEmpty ? 'No matching students' : 'No students in department', style: TextStyle(color: AppColors.textSecondary)),
                        if (_searchQuery.isNotEmpty)
                          TextButton(onPressed: () { setState(() => _searchQuery = ''); _filterStudents(); }, child: Text('Clear search'))
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchStudents,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (ctx, index) {
                        final student = _filteredStudents[index];
                        return Card(
                          color: AppColors.card,
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              child: Text(student['name']?.substring(0, 1)?.toUpperCase() ?? 'S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                            title: Text(student['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Roll: ${student['rollNumber'] ?? 'N/A'}', style: TextStyle(color: AppColors.textSecondary)),
                                Text(student['className'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
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