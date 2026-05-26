import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherMyClassesScreen extends StatefulWidget {
  const TeacherMyClassesScreen({super.key});
  @override
  State<TeacherMyClassesScreen> createState() => _TeacherMyClassesScreenState();
}

class _TeacherMyClassesScreenState extends State<TeacherMyClassesScreen> {
  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _fetchClasses(); }

  Future<void> _fetchClasses() async {
    try {
      final res = await ApiService.get('/teacher/my-classes');
      setState(() { _classes = res.data['data'] ?? []; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('My Classes', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)), centerTitle: true),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppColors.primary)) : RefreshIndicator(onRefresh: _fetchClasses, color: AppColors.primary, child: _classes.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.class_, size: 80, color: AppColors.textSecondary.withOpacity(0.3)), SizedBox(height: 16), Text('No classes assigned', style: TextStyle(color: AppColors.textSecondary)), Text('Contact HOD to get class assignments', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)))])) : ListView.builder(padding: EdgeInsets.all(AppConstants.defaultPadding), itemCount: _classes.length, itemBuilder: (ctx, index) {
        final c = _classes[index];
        return Card(color: AppColors.card, margin: EdgeInsets.only(bottom: 15), child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.class_, color: AppColors.primary, size: 28)), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c['name'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)), Text('Semester: ${c['semester'] ?? ''} | Section: ${c['section'] ?? ''}', style: TextStyle(color: AppColors.textSecondary))]))]),
          SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_statItem(Icons.people, '${c['studentCount'] ?? 0} Students', AppColors.success), _statItem(Icons.book, '${c['subjectCount'] ?? 0} Subjects', AppColors.info)]),
          SizedBox(height: 15),
          Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('View Students'), avatar: Icon(Icons.people, size: 16), backgroundColor: AppColors.primary.withOpacity(0.1)), Chip(label: Text('Take Attendance'), avatar: Icon(Icons.check_circle, size: 16), backgroundColor: AppColors.success.withOpacity(0.1)), Chip(label: Text('Upload Marks'), avatar: Icon(Icons.grade, size: 16), backgroundColor: AppColors.warning.withOpacity(0.1))])
        ])));
      })),
    );
  }

  Widget _statItem(IconData icon, String label, Color color) => Column(children: [Icon(icon, color: color, size: 24), SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500))]);
}