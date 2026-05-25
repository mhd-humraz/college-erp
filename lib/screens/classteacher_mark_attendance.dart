import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ClassTeacherMarkAttendanceScreen extends StatefulWidget {
  const ClassTeacherMarkAttendanceScreen({super.key});
  @override
  State<ClassTeacherMarkAttendanceScreen> createState() => _ClassTeacherMarkAttendanceScreenState();
}

class _ClassTeacherMarkAttendanceScreenState extends State<ClassTeacherMarkAttendanceScreen> {
  List<dynamic> _students = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, String> _attendanceStatus = {};

  @override
  void initState() { super.initState(); _fetchStudents(); }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/class-teacher/students');
      setState(() {
        _students = res.data['data'] ?? [];
        _attendanceStatus = {};
        for (var s in _students) { _attendanceStatus[s['_id']] = 'present'; }
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
  }

  Future<void> _submitAttendance() async {
    if (_students.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final records = _students.map((s) => {'studentId': s['_id'], 'status': _attendanceStatus[s['_id']] ?? 'present'}).toList();
      await ApiService.post('/class-teacher/mark-attendance', data: {'records': records});
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance marked!'), backgroundColor: AppColors.success)); _fetchStudents(); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error)); }
    finally { setState(() => _isSubmitting = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Mark Attendance', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children: [
        Container(width: double.infinity, padding: EdgeInsets.all(AppConstants.defaultPadding), color: AppColors.card, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${_students.length} Students', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)), Text(_formatDate(DateTime.now().toString()), style: TextStyle(color: AppColors.textSecondary))])),
        Expanded(child: _isLoading ? Center(child: CircularProgressIndicator(color: AppColors.primary)) : _students.isEmpty ? Center(child: Text('No students found')) : ListView.builder(padding: EdgeInsets.all(AppConstants.defaultPadding), itemCount: _students.length, itemBuilder: (ctx, index) {
          final s = _students[index];
          final status = _attendanceStatus[s['_id']] ?? 'present';
          
          return Card(color: AppColors.card, margin: EdgeInsets.only(bottom: 8), child: ListTile(dense: true, leading: CircleAvatar(radius: 18, child: Text(s['name']?.substring(0, 1)?.toUpperCase() ?? 'S')), title: Text(s['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)), subtitle: Text('Roll: ${s['rollNumber']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)), trailing: SegmentedButton<String>(segments: [ButtonSegment(value: 'present', label: Text('P'), icon: Icon(Icons.check, size: 16)), ButtonSegment(value: 'absent', label: Text('A'), icon: Icon(Icons.close, size: 16)), ButtonSegment(value: 'late', label: Text('L'), icon: Icon(Icons.access_time, size: 16))], selected: {status}, onSelectionChanged: (st) => setState(() => _attendanceStatus[s['_id']] = st.first))));
        })),
        if (_students.isNotEmpty) Container(padding: EdgeInsets.all(AppConstants.defaultPadding), child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _isSubmitting ? null : _submitAttendance, icon: _isSubmitting ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.save), label: Text(_isSubmitting ? 'Saving...' : 'Submit Attendance'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success))))
      ]),
    );
  }

  String _formatDate(String dateStr) { try { final d = DateTime.parse(dateStr); return '${d.day}/${d.month}/${d.year}'; } catch (_) { return ''; } }
}