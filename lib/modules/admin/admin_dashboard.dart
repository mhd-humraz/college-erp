// lib/modules/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../analytics/campus_charts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploadingStaff = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionToken = Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<AdminProvider>(context, listen: false).fetchGlobalMetrics(sessionToken);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleStaffCsvIngestion() async {
    // 🚀 FIXED: Uses safe cross-compatibility method mapping parameters for version 11.x
    FilePickerResult? pickedCsv = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (pickedCsv == null) return;
    setState(() => _isUploadingStaff = true);
    final sessionToken = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    try {
      var multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/admin/upload-staff'),
      );
      multipartRequest.headers['Authorization'] = 'Bearer $sessionToken';

      var rawBytes = pickedCsv.files.first.bytes;
      if (rawBytes != null) {
        multipartRequest.files.add(http.MultipartFile.fromBytes(
          'staffFile',
          rawBytes,
          filename: pickedCsv.files.first.name,
        ));
      }

      var networkStreamResponse = await multipartRequest.send();
      if (networkStreamResponse.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Staff records imported, user accounts provisioned.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("CSV payload execution fault: $e");
    } finally {
      if (mounted) setState(() => _isUploadingStaff = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminDataState = Provider.of<AdminProvider>(context);
    final metrics = adminDataState.metricsCache ?? {
      'totalStudents': 154,
      'totalFaculty': 18,
      'totalDepartments': 4,
      'globalAttendance': 82.40
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Central Command'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.apps_rounded), text: 'Management Modules'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Institutional Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).terminateSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: adminDataState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildManagementGrid(metrics),
                _buildInstitutionalAnalyticsView(metrics),
              ],
            ),
    );
  }

  Widget _buildManagementGrid(Map<String, dynamic> metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMiniStat('Students Active', '${metrics['totalStudents']}', Colors.blue),
              const SizedBox(width: 12),
              _buildMiniStat('Faculty Staff', '${metrics['totalFaculty']}', Colors.teal),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: _isUploadingStaff 
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : const Icon(Icons.upload_file_rounded, color: Colors.redAccent, size: 28),
              title: const Text('Provision System Staff Directory', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Upload raw .csv structure row vectors to seed user slots.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: _isUploadingStaff ? null : _handleStaffCsvIngestion,
            ),
          ),
          const SizedBox(height: 24),
          const Text('System Architecture Gates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildModuleRow(Icons.people_outline_rounded, 'User Access Management Control', 'Alter authorization roles, locks, and account metrics.'),
          _buildModuleRow(Icons.account_tree_outlined, 'Academic Department Framework', 'Initialize corporate branches and assign tracking HODs.'),
          _buildModuleRow(Icons.calendar_view_week_rounded, 'Master Schedulers Engine', 'Generate dynamic lecture timelines and auto-resolve room conflicts.'),
        ],
      ),
    );
  }

  Widget _buildInstitutionalAnalyticsView(Map<String, dynamic> metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blueGrey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Institutional Revenue Flow', style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 14)),
                      const Icon(Icons.account_balance, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹14,85,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('Collected Dues', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Global Attendance Index Rate', style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 13)),
                      Text('${metrics['globalAttendance']}%', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Macro Performance Metrics Evaluation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const SizedBox(
            width: double.infinity,
            child: CampusAnalyticsChart(), 
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, String val, Color baseThemeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: baseThemeColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: baseThemeColor, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleRow(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}