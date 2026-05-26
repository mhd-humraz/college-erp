import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HodManageSubjectsScreen extends StatefulWidget {
  const HodManageSubjectsScreen({super.key});

  @override
  State<HodManageSubjectsScreen> createState() => _HodManageSubjectsScreenState();
}

class _HodManageSubjectsScreenState extends State<HodManageSubjectsScreen> {
  List<dynamic> _subjects = [];
  List<dynamic> _teachers = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _errorMessage; // ✅ NEW: Track errors
  
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController(text: '4');
  final _semesterCtrl = TextEditingController(text: '3');
  final _typeCtrl = TextEditingController(text: 'Theory');
  String? _selectedTeacherId;

  @override
  void initState() { 
    super.initState(); 
    _fetchData(); 
  }

  @override
  void dispose() {
    // ✅ NEW: Clean up controllers
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _creditsCtrl.dispose();
    _semesterCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  // ✅ FIXED: Better error handling + timeout protection
  Future<void> _fetchData() async {
    setState(() { 
      _isLoading = true; 
      _errorMessage = null; // Clear previous errors
    });
    
    try {
      print('📡 Fetching subjects and teachers...');
      
      // ✅ Use Future.wait for parallel requests (faster!)
      final results = await Future.wait([
        ApiService.get('/hod/subjects').timeout(
          Duration(seconds: 10),
          onTimeout: () => throw Exception('Subjects request timed out'),
        ),
        ApiService.get('/hod/teachers').timeout(
          Duration(seconds: 10),
          onTimeout: () => throw Exception('Teachers request timed out'),
        ),
      ]);

      final subjectsRes = results[0];
      final teachersRes = results[1];

      print('✅ Subjects response: ${subjectsRes.statusCode}');
      print('✅ Teachers response: ${teachersRes.statusCode}');
      
      if (mounted) {
        setState(() {
          _subjects = subjectsRes.data['data'] ?? subjectsRes.data ?? [];
          _teachers = teachersRes.data['data'] ?? teachersRes.data ?? [];
          _isLoading = false;
          _errorMessage = null;
        });

        print('📊 Loaded ${_subjects.length} subjects and ${_teachers.length} teachers');
      }
    } catch (e) {
      print('❌ Error fetching data: $e');
      
      if (mounted) {
        setState(() { 
          _isLoading = false; 
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        // ✅ Show error snackbar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('⚠️ Failed to load data: $_errorMessage'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _fetchData,
              ),
            ));
          }
        });
      }
    }
  }

  Future<void> _createSubject() async {
    if (_nameCtrl.text.isEmpty || _codeCtrl.text.isEmpty) {
      _showErrorSnackBar('Please fill in Subject Name and Code');
      return;
    }
    
    if (_selectedTeacherId == null) {
      _showErrorSnackBar('Please select a teacher');
      return;
    }
    
    setState(() => _isCreating = true);
    
    try {
      print('📡 Creating subject: ${_nameCtrl.text}');
      
      final response = await ApiService.post('/hod/create-subject', data: {
        'name': _nameCtrl.text.trim(),
        'code': _codeCtrl.text.toUpperCase().trim(),
        'description': 'Subject created by HOD',
        'credits': int.tryParse(_creditsCtrl.text) ?? 4,
        'semester': int.tryParse(_semesterCtrl.text) ?? 3,
        'type': _typeCtrl.text,
        'teacherId': _selectedTeacherId,
      }).timeout(
        Duration(seconds: 15),
        onTimeout: () => throw Exception('Create subject timed out'),
      );

      print('✅ Subject created: ${response.statusCode}');

      if (mounted) {
        Navigator.pop(context); // Close dialog FIRST
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Subject "${_nameCtrl.text}" created successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ));
        
        _clearForm();
        _fetchData(); // Refresh list
      }
    } catch (e) {
      print('❌ Error creating subject: $e');
      
      if (mounted) {
        _showErrorSnackBar('Failed to create subject: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally { 
      if (mounted) {
        setState(() => _isCreating = false); 
      }
    }
  }

  // ✅ NEW: Helper method for error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      duration: Duration(seconds: 3),
    ));
  }

  void _clearForm() {
    _nameCtrl.clear();
    _codeCtrl.clear();
    _creditsCtrl.text = '4';
    _semesterCtrl.text = '3';
    _typeCtrl.text = 'Theory';
    _selectedTeacherId = null;
  }

  Future<void> _assignTeacher(String subjectId, String teacherId) async {
    try {
      await ApiService.put('/hod/subjects/$subjectId/assign-teacher', data: {
        'teacherId': teacherId
      }).timeout(Duration(seconds: 10));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Teacher assigned successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ));
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to assign teacher: $e');
      }
    }
  }

  Future<void> _deleteSubject(String subjectId) async {
    try {
      await ApiService.delete('/hod/subjects/$subjectId').timeout(Duration(seconds: 10));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🗑️ Subject deleted!'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ));
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to delete subject: $e');
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'theory': return Colors.blue;
      case 'lab': return Colors.green;
      case 'elective': return Colors.orange;
      default: return Colors.purple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'theory': return Icons.book;
      case 'lab': return Icons.science;
      case 'elective': return Icons.computer;
      default: return Icons.subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWithTeachers = _subjects.where((s) => s['teacherId'] != null && s['teacherId'] != '').length;
    final totalWithoutTeachers = _subjects.where((s) => s['teacherId'] == null || s['teacherId'] == '').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Subjects', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: AppColors.text), onPressed: _fetchData),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: AppColors.card,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Total Subjects', '${_subjects.length}', Icons.book, AppColors.primary),
                _statItem('With Teacher', '$totalWithTeachers', Icons.verified_user, AppColors.success),
                _statItem('No Teacher', '$totalWithoutTeachers', Icons.person_outline, AppColors.error),
              ],
            ),
          ),

          // ✅ NEW: Show error message if any
          if (_errorMessage != null && !_isLoading)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: TextStyle(color: AppColors.error, fontSize: 12))),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: AppColors.error),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: AppColors.primary,
                  child: _subjects.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.book_online, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                            SizedBox(height: 16),
                            Text('No subjects found', style: TextStyle(color: AppColors.textSecondary)),
                            SizedBox(height: 8),
                            Text('Tap + to add your first subject', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
                            if (_errorMessage != null) ...[
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchData,
                                icon: Icon(Icons.refresh),
                                label: Text('Retry'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _subjects.length,
                        itemBuilder: (ctx, index) {
                          final subj = _subjects[index];
                          final hasTeacher = subj['teacherId'] != null && subj['teacherId'] != '';
                          
                          return Card(
                            color: AppColors.card,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(subj['type'] ?? 'Theory').withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_getTypeIcon(subj['type'] ?? 'Theory'), color: _getTypeColor(subj['type'] ?? 'Theory'), size: 22),
                              ),
                              title: Text(subj['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Code: ${subj['code'] ?? ''}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.info.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('${subj['credits'] ?? 4} Credits', style: TextStyle(fontSize: 10, color: AppColors.info)),
                                        ),
                                        SizedBox(width: 6),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Sem ${subj['semester'] ?? 3}', style: TextStyle(fontSize: 10, color: AppColors.warning)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditDialog(subj);
                                      break;
                                    case 'delete':
                                      _confirmDelete(subj['_id']);
                                      break;
                                    case 'assign':
                                      _showAssignTeacherDialog(subj);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'edit', child: Text('Edit Subject')),
                                  PopupMenuItem(value: 'assign', child: Text('Assign Teacher')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete Subject', style: TextStyle(color: AppColors.error))),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      hasTeacher 
                                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                                            CircleAvatar(radius: 14, backgroundColor: AppColors.success.withOpacity(0.15), child: Icon(Icons.check_circle, size: 14, color: AppColors.success)),
                                            SizedBox(width: 6),
                                            Flexible(child: Text('${subj['teacherId']?['name'] ?? 'Assigned'}', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500))),
                                          ])
                                        : Row(mainAxisSize: MainAxisSize.min, children: [
                                            CircleAvatar(radius: 14, backgroundColor: AppColors.error.withOpacity(0.15), child: Icon(Icons.error_outline, size: 14, color: AppColors.error)),
                                            SizedBox(width: 6),
                                            Flexible(child: Text('No Teacher Assigned!', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600))),
                                          ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
          ),
        ],
      ),

      // FAB - Add New Subject
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add),
        label: Text('Add Subject'),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  // ✅ FIXED: Improved dialog with better UX
  void _showCreateDialog() {
    _clearForm();
    
    // Pre-select first teacher if available
    if (_teachers.isNotEmpty) {
      _selectedTeacherId = _teachers[0]['_id']?.toString();
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.add_circle, color: AppColors.primary), 
          SizedBox(width: 10), 
          Text('Create New Subject', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))
        ]),
        content: Container(
          width: double.maxFinite, // ✅ Fix unbounded width
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7), // ✅ Limit height
          child: ListView( // ✅ Use ListView instead of SingleChildScrollView + Column
            shrinkWrap: true,
            children: [
              TextField(
                controller: _nameCtrl, 
                decoration: InputDecoration(
                  labelText: 'Subject Name *', 
                  prefixIcon: Icon(Icons.title),
                  filled: true, 
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _codeCtrl, 
                decoration: InputDecoration(
                  labelText: 'Subject Code *', 
                  prefixIcon: Icon(Icons.code),
                  filled: true, 
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ), 
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _creditsCtrl, 
                      keyboardType: TextInputType.number, 
                      decoration: InputDecoration(
                        labelText: 'Credits', 
                        prefixIcon: Icon(Icons.grade),
                        filled: true, 
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _semesterCtrl, 
                      keyboardType: TextInputType.number, 
                      decoration: InputDecoration(
                        labelText: 'Semester', 
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true, 
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeCtrl.text,
                decoration: InputDecoration(
                  labelText: 'Type', 
                  prefixIcon: Icon(Icons.category),
                  filled: true, 
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Theory', 'Lab', 'Elective'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) { if (v != null) _typeCtrl.text = v; },
              ),
              SizedBox(height: 16),
              
              // Teacher Selection
              Text('Assign Teacher *', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 14)),
              SizedBox(height: 8),
              
              _teachers.isEmpty
                ? Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('No teachers available. Please add teachers first.', style: TextStyle(color: AppColors.warning, fontSize: 12))),
                      ],
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: _selectedTeacherId,
                    decoration: InputDecoration(
                      hintText: 'Select a teacher',
                      prefixIcon: Icon(Icons.person),
                      helperText: 'Each subject MUST have at least 1 teacher!',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    isExpanded: true, // ✅ Fix dropdown width
                    items: _teachers.map((t) => DropdownMenuItem(
                      value: t['_id']?.toString(),
                      child: Text(t['name'] ?? '', overflow: TextOverflow.ellipsis), // ✅ Simpler dropdown item
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedTeacherId = val),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton.icon(
            onPressed: (_isCreating || _teachers.isEmpty) ? null : _createSubject,
            icon: _isCreating 
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(Icons.check),
            label: Text(_isCreating ? 'Creating...' : 'Create Subject'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(dynamic subj) {
    _nameCtrl.text = subj['name'] ?? '';
    _codeCtrl.text = subj['code'] ?? '';
    _creditsCtrl.text = subj['credits']?.toString() ?? '4';
    _semesterCtrl.text = subj['semester']?.toString() ?? '3';
    _typeCtrl.text = subj['type'] ?? 'Theory';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.edit, color: AppColors.primary), SizedBox(width: 10), Text('Edit Subject', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Subject Name *', prefixIcon: Icon(Icons.title), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: 12),
              TextField(controller: _codeCtrl, decoration: InputDecoration(labelText: 'Code *', prefixIcon: Icon(Icons.code), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), textCapitalization: TextCapitalization.characters),
              SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _creditsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Credits', prefixIcon: Icon(Icons.grade), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
                SizedBox(width: 12),
                Expanded(child: TextField(controller: _semesterCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Semester', prefixIcon: Icon(Icons.calendar_today), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              ]),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _typeCtrl.text, decoration: InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: ['Theory', 'Lab', 'Elective'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) { if (v != null) _typeCtrl.text = v; }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.put('/hod/subjects/${subj['_id']}', data: {
                  'name': _nameCtrl.text,
                  'code': _codeCtrl.text.toUpperCase(),
                  'credits': int.tryParse(_creditsCtrl.text) ?? 4,
                  'semester': int.tryParse(_semesterCtrl.text) ?? 3,
                  'type': _typeCtrl.text,
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Subject updated!'), backgroundColor: AppColors.success));
                  _fetchData();
                }
              } catch (e) {
                if (mounted) _showErrorSnackBar('Update failed: $e');
              }
            },
            icon: Icon(Icons.save),
            label: Text('Update'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String subjectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Icon(Icons.delete_forever, color: AppColors.error), SizedBox(width: 10), Text('Delete Subject?', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))]),
        content: Text('Are you sure? This cannot be undone!', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); _deleteSubject(subjectId); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showAssignTeacherDialog(dynamic subj) {
    String? selectedTeacherId = subj['teacherId']?['_id']?.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [Icon(Icons.person_add, color: AppColors.info), SizedBox(width: 10), Text('Assign Teacher', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select teacher for:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
            SizedBox(height: 8),
            Text('${subj['name']} (${subj['code']})', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeacherId,
              decoration: InputDecoration(prefixIcon: Icon(Icons.person), hintText: 'Choose teacher...', filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: _teachers.map((t) => DropdownMenuItem(value: t['_id']?.toString(), child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.info.withOpacity(0.15), child: Text(t['name']?.substring(0, 1)?.toUpperCase() ?? 'T')),
                SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.text)),
                  Text(t['email'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
              ]))).toList(),
              onChanged: (val) => selectedTeacherId = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              if (selectedTeacherId != null) _assignTeacher(subj['_id'], selectedTeacherId!);
            },
            icon: Icon(Icons.person_add),
            label: Text('Assign'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
          ),
        ],
      ),
    );
  }
}