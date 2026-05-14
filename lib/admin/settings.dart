import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _maintenanceMode = false;
  bool _isLoading = false;

  final _collegeNameCtrl = TextEditingController(text: AppConstants.appName);
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final data = await ApiService.get('/settings');
      setState(() {
        _collegeNameCtrl.text = data['collegeName'] ?? AppConstants.appName;
        _emailCtrl.text = data['email'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
        _notificationsEnabled = data['notificationsEnabled'] ?? true;
        _maintenanceMode = data['maintenanceMode'] ?? false;
      });
    } catch (_) {
      // Use defaults if API fails
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.put('/settings', {
        'collegeName': _collegeNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'notificationsEnabled': _notificationsEnabled,
        'maintenanceMode': _maintenanceMode,
      });
      _showSnack('Settings saved');
    } catch (e) {
      _showSnack('Failed to save settings', isError: true);
    } finally {
      setState(() => _isLoading = false);
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

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password',
            style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(oldPassCtrl, 'Current Password', obscure: true),
          const SizedBox(height: 12),
          _dialogField(newPassCtrl, 'New Password', obscure: true),
          const SizedBox(height: 12),
          _dialogField(confirmCtrl, 'Confirm New Password', obscure: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (newPassCtrl.text != confirmCtrl.text) {
                _showSnack('Passwords do not match', isError: true);
                return;
              }
              Navigator.pop(context);
              try {
                await ApiService.post('/auth/change-password', {
                  'oldPassword': oldPassCtrl.text,
                  'newPassword': newPassCtrl.text,
                });
                _showSnack('Password changed successfully');
              } catch (e) {
                _showSnack('Failed to change password', isError: true);
              }
            },
            child: const Text('Update', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
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
        title: const Text('Settings',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // College Info
          _sectionTitle('College Information'),
          const SizedBox(height: 12),
          _settingsCard(children: [
            _inputField(_collegeNameCtrl, 'College Name', Icons.school_outlined),
            const SizedBox(height: 12),
            _inputField(_emailCtrl, 'Contact Email', Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _inputField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, type: TextInputType.phone),
          ]),

          const SizedBox(height: 24),

          // System Settings
          _sectionTitle('System'),
          const SizedBox(height: 12),
          _settingsCard(children: [
            _toggleTile(
              'Push Notifications',
              'Enable notifications for all users',
              Icons.notifications_outlined,
              _notificationsEnabled,
              (v) => setState(() => _notificationsEnabled = v),
            ),
            Divider(color: AppColors.background, height: 1),
            _toggleTile(
              'Maintenance Mode',
              'Disable access for non-admin users',
              Icons.build_outlined,
              _maintenanceMode,
              (v) => setState(() => _maintenanceMode = v),
            ),
          ]),

          const SizedBox(height: 24),

          // Security
          _sectionTitle('Security'),
          const SizedBox(height: 12),
          _settingsCard(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
              ),
              title: const Text('Change Password',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
              subtitle: Text('Update your admin password',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
              onTap: _showChangePasswordDialog,
            ),
          ]),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Save Settings',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity, height: 55,
            child: OutlinedButton(
              onPressed: () {
                // TODO: implement logout
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Logout',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent)),
            ),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.8)));

  Widget _settingsCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: type,
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

  Widget _toggleTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, {bool obscure = false}) {
    return TextField(
      controller: ctrl, obscureText: obscure,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}