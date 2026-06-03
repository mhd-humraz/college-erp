import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
 
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HODDashboard extends StatefulWidget {
  const HODDashboard({super.key});

  @override
  State<HODDashboard> createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
  List<dynamic> _students = [];
  List<dynamic> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final studentsRes = await ApiService.get('/hod/students');
      final requestsRes = await ApiService.get('/hod/requests');
      
      setState(() {
        _students = studentsRes.data['data'] ?? [];
        _requests = requestsRes.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadStudentsCSV() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Center(child: CircularProgressIndicator(color: AppColors.primary)));

    try {
      final res = await ApiService.postWithFile('/hod/upload-students-csv', result.files.single.path!);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']), backgroundColor: AppColors.success));
      _fetchData();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final pendingRequests = _requests.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${user?['departmentName'] ?? 'Department'} - HOD Panel', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)), actions: [IconButton(icon: Icon(Icons.logout, color: AppColors.text), onPressed: () => context.read<AuthProvider>().logout())]),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppColors.primary)) : RefreshIndicator(onRefresh: _fetchData, color: AppColors.primary, child: ListView(padding: const EdgeInsets.all(AppConstants.defaultPadding), children: [
        // Header
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFE66D).withOpacity(0.2), AppColors.card]), borderRadius: BorderRadius.circular(AppConstants.borderRadius), border: Border.all(color: Color(0xFFFFE66D).withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.school, color: Color(0xFFFFE66D), size: 28), const SizedBox(width: 10), Text('HOD Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text))]), const SizedBox(height: 12), Text('Manage your department efficiently', style: TextStyle(color: AppColors.textSecondary)), const SizedBox(height: 15), Row(children: [_miniStat('Students', '${_students.length}', AppColors.success), const SizedBox(width: 15), _miniStat('Pending Requests', '$pendingRequests', AppColors.warning)])])),
        const SizedBox(height: 22),

        // Actions
        Text('Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _actionChip(Icons.upload_rounded, 'Upload Students CSV', AppColors.success, _uploadStudentsCSV),
          _actionChip(Icons.person_add, 'Assign Teacher', AppColors.info, (){}),
          _actionChip(Icons.calendar_month, 'Manage Timetable', AppColors.primary, (){}),
          _actionChip(Icons.pending_actions, 'View Requests ($pendingRequests)', AppColors.warning, (){}),
        ]),
        const SizedBox(height: 22),

        // Recent Students
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recent Students', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: (){}, child: Text('View All', style: TextStyle(color: AppColors.primary)))]),
        const SizedBox(height: 12),
        ..._students.take(5).map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.15), child: Icon(Icons.person, color: AppColors.primary)), title: Text(s['name'] ?? '', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)), subtitle: Text('Roll: ${s['rollNumber']} | ${s['className'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)), trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary))).toList(),
      ])),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))])));
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(label, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 13))])));
  }
}