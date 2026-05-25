import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ClassTeacherLeaveManagementScreen extends StatefulWidget {
  const ClassTeacherLeaveManagementScreen({super.key});

  @override
  State<ClassTeacherLeaveManagementScreen> createState() => _ClassTeacherLeaveManagementScreenState();
}

class _ClassTeacherLeaveManagementScreenState extends State<ClassTeacherLeaveManagementScreen> {
  List<dynamic> _leaves = [];
  bool _isLoading = true;

  @override
  void initState() { 
    super.initState(); 
    _fetchLeaves(); 
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/class-teacher/leave-requests');
      setState(() { 
        _leaves = res.data['data'] ?? []; 
        _isLoading = false; 
      });
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  Future<void> _updateLeaveStatus(String leaveId, String status) async {
    try {
      await ApiService.put('/class-teacher/leave-requests/$leaveId', data: {'status': status});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Leave $status'),
          backgroundColor: status == 'approved' ? AppColors.success : AppColors.error
        ));
        _fetchLeaves();
      }
    } catch (e) { 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _leaves.where((l) => l['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leave Management', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.card,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Total', '${_leaves.length}', Icons.receipt, AppColors.info),
                _statItem('Pending', '$pendingCount', Icons.pending, AppColors.warning),
                _statItem('Approved', '${_leaves.where((l) => l['status'] == 'approved').length}', Icons.check_circle, AppColors.success),
              ],
            ),
          ),

          // Leave List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _leaves.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.beach_access, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        SizedBox(height: 16),
                        Text('No leave requests', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchLeaves,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _leaves.length,
                      itemBuilder: (ctx, index) {
                        final leave = _leaves[index];
                        final isPending = leave['status'] == 'pending';

                        return Card(
                          color: AppColors.card,
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status & Date Row
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(leave['status']).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_getStatusIcon(leave['status']), size: 14, color: _getStatusColor(leave['status'])),
                                          SizedBox(width: 4),
                                          Text(
                                            leave['status']?.toUpperCase() ?? 'UNKNOWN',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(leave['status']))
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Text(_formatDate(leave['createdAt']), style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Student Info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.primary.withOpacity(0.15),
                                      child: Icon(Icons.person, size: 18, color: AppColors.primary),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leave['studentId']?['name'] ?? leave['studentName'] ?? 'Unknown',
                                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)
                                          ),
                                          Text(
                                            'Roll: ${leave['studentId']?['rollNumber'] ?? ''}',
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Reason Box
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    leave['reason'] ?? 'No reason provided',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)
                                  ),
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Dates
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: AppColors.info),
                                    SizedBox(width: 4),
                                    Text('${leave['fromDate'] ?? ''} to ${leave['toDate'] ?? ''}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Action Buttons (Only for Pending)
                                if (isPending)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _updateLeaveStatus(leave['_id'], 'rejected'),
                                          icon: Icon(Icons.close, size: 16),
                                          label: Text('Reject'),
                                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _updateLeaveStatus(leave['_id'], 'approved'),
                                          icon: Icon(Icons.check, size: 16),
                                          label: Text('Approve'),
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'pending': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'pending': return Icons.pending;
      default: return Icons.help_outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}';
    } catch (_) {
      return dateStr;
    }
  }
}