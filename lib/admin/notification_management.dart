import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() => _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String _error = '';

  final List<String> _targetRoles = ['All', 'Student', 'Teacher', 'HOD', 'Principal'];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/notifications');
      setState(() { _notifications = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: isError ? Colors.redAccent : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSendDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String selectedTarget = 'All';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Send Notification',
              style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField(titleCtrl, 'Title', Icons.title_rounded),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.message_outlined, color: AppColors.primary, size: 18),
                ),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedTarget,
              dropdownColor: AppColors.background,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Target Audience',
                labelStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5), fontSize: 13),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              items: _targetRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setDlg(() => selectedTarget = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiService.post('/notifications', {
                    'title': titleCtrl.text.trim(),
                    'message': msgCtrl.text.trim(),
                    'target': selectedTarget,
                  });
                  _showSnack('Notification sent!');
                  _fetchNotifications();
                } catch (e) {
                  _showSnack('Failed to send', isError: true);
                }
              },
              child: const Text('Send', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchNotifications),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _showSendDialog,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: const Text('Send', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : _notifications.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (_, i) => _buildNotifCard(_notifications[i]),
                    ),
    );
  }

  Widget _buildNotifCard(dynamic notif) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.notifications_rounded, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notif['title'] ?? '',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(notif['message'] ?? '',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.5)), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('To: ${notif['target'] ?? 'All'}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          onPressed: () async {
            try {
              await ApiService.delete('/notifications/${notif['_id'] ?? notif['id']}');
              _fetchNotifications();
              _showSnack('Notification deleted');
            } catch (e) {
              _showSnack('Failed to delete', isError: true);
            }
          },
        ),
      ]),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
    const SizedBox(height: 12),
    Text('Failed to load', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: _fetchNotifications,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
  ]));

  Widget _buildEmpty() => Center(
    child: Text('No notifications yet', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))),
  );

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}