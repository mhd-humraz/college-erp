import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'UPLOAD'];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(
          '/audit?page=1&limit=50&action=${_selectedFilter == 'all' ? '' : _selectedFilter}');
      setState(() {
        _logs = response.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'CREATE':
        return AppColors.success;
      case 'UPDATE':
        return AppColors.info;
      case 'DELETE':
        return AppColors.error;
      case 'LOGIN':
        return AppColors.primary;
      case 'UPLOAD':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'CREATE':
        return Icons.add_circle_outline;
      case 'UPDATE':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline;
      case 'LOGIN':
        return Icons.login;
      case 'UPLOAD':
        return Icons.upload_file;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Audit Logs',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return FilterChip(
                  selected: isSelected,
                  label: Text(filter,
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textSecondary)),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.card,
                  side: BorderSide.none,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (val) {
                    setState(() => _selectedFilter = filter);
                    _fetchLogs();
                  },
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.white10),

          // Logs List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _logs.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchLogs,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: _logs.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Color(0x0DFFFFFF)),
                          itemBuilder: (context, index) => _logCard(_logs[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _logCard(dynamic log) {
    final action = log['action'] ?? 'UNKNOWN';
    final color = _getActionColor(action);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(_getActionIcon(action), color: color, size: 22),
          ),
          SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(log['userName'] ?? 'Unknown User',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                              fontSize: 14))),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(action,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ]),
                SizedBox(height: 6),
                Text(log['description'] ?? '',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(_formatTime(log['createdAt']),
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(log['module'] ?? '',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 10)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                  color: AppColors.card, shape: BoxShape.circle),
              child: Icon(Icons.history_toggle_off,
                  size: 42, color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            SizedBox(height: 20),
            Text('No Activity Found',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 8),
            Text('Activity will appear here as users interact\nwith the system',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }
}