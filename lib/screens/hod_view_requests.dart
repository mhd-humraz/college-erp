import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class HodViewRequestsScreen extends StatefulWidget {
  const HodViewRequestsScreen({super.key});

  @override
  State<HodViewRequestsScreen> createState() => _HodViewRequestsScreenState();
}

class _HodViewRequestsScreenState extends State<HodViewRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/hod/requests');
      setState(() {
        _requests = res.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await ApiService.put('/hod/requests/$requestId', data: {'status': status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request ${status} successfully'),
          backgroundColor: status == 'approved' ? AppColors.success : AppColors.error,
        ));
        _fetchRequests(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requests.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Student Requests', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
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
                _statItem('Total', '${_requests.length}', Icons.receipt_long, AppColors.info),
                _statItem('Pending', '$pendingCount', Icons.pending, AppColors.warning),
                _statItem('Approved', '${_requests.where((r) => r['status'] == 'approved').length}', Icons.check_circle, AppColors.success),
              ],
            ),
          ),

          // Request List
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _requests.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        SizedBox(height: 16),
                        Text('No requests found', style: TextStyle(color: AppColors.textSecondary)),
                        Text('Requests from Class Teachers will appear here', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchRequests,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _requests.length,
                      itemBuilder: (ctx, index) {
                        final request = _requests[index];
                        final isPending = request['status'] == 'pending';

                        return Card(
                          color: AppColors.card,
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(request['status']).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_getStatusIcon(request['status']), size: 14, color: _getStatusColor(request['status'])),
                                          SizedBox(width: 4),
                                          Text(request['status']?.toUpperCase() ?? 'UNKNOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(request['status']))),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Text(_formatDate(request['createdAt']), style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Student Info
                                Row(
                                  children: [
                                    CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.15), child: Icon(Icons.person, size: 18, color: AppColors.primary)),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(request['studentName'] ?? 'Unknown Student', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                                          Text('Roll No: ${request['rollNumber'] ?? 'N/A'}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Reason
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                  child: Text(request['reason'] ?? 'No reason provided', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ),
                                SizedBox(height: 12),

                                // Action Buttons (Only for Pending)
                                if (isPending)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _updateRequestStatus(request['_id'], 'rejected'),
                                          icon: Icon(Icons.close, size: 16),
                                          label: Text('Reject'),
                                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _updateRequestStatus(request['_id'], 'approved'),
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}