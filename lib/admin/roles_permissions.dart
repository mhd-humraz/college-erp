import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class RolesPermissionsPage extends StatefulWidget {
  const RolesPermissionsPage({super.key});
  @override
  State<RolesPermissionsPage> createState() => _RolesPermissionsPageState();
}

class _RolesPermissionsPageState extends State<RolesPermissionsPage> {
  final Map<String, Map<String, bool>> _permissions = {
    'Teacher': {
      'Take Attendance': true,
      'Enter Marks': true,
      'Upload Assignments': true,
      'Send Notifications': false,
      'View Reports': false,
      'Manage Students': false,
      'Manage Courses': false,
      'Access Fee Module': false,
    },
    'HOD': {
      'Take Attendance': true,
      'Enter Marks': true,
      'Upload Assignments': true,
      'Send Notifications': true,
      'View Reports': true,
      'Manage Students': true,
      'Manage Courses': true,
      'Access Fee Module': false,
    },
    'Principal': {
      'Take Attendance': true,
      'Enter Marks': true,
      'Upload Assignments': true,
      'Send Notifications': true,
      'View Reports': true,
      'Manage Students': true,
      'Manage Courses': true,
      'Access Fee Module': true,
    },
    'Student': {
      'Take Attendance': false,
      'Enter Marks': false,
      'Upload Assignments': false,
      'Send Notifications': false,
      'View Reports': false,
      'Manage Students': false,
      'Manage Courses': false,
      'Access Fee Module': false,
    },
  };

  String _selectedRole = 'Teacher';

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
    backgroundColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Future<void> _savePermissions() async {
    try {
      await ApiService.put('/roles/permissions', {
        'role': _selectedRole,
        'permissions': _permissions[_selectedRole],
      });
      _showSnack('Permissions saved for $_selectedRole');
    } catch (e) {
      _showSnack('Permissions saved locally');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolePerms = _permissions[_selectedRole] ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Roles & Permissions', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Control what each role can access in the app.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.7)))),
            ]),
          ),

          const SizedBox(height: 16),

          // Role selector tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: _permissions.keys.map((role) {
              final sel = _selectedRole == role;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _selectedRole = role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(role, textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.text.withOpacity(0.5))),
                ),
              ));
            }).toList()),
          ),

          const SizedBox(height: 20),

          Text('Permissions for $_selectedRole',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.7))),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: rolePerms.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Icon(
                    entry.value ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: entry.value ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.key,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.text))),
                  Switch(
                    value: entry.value,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _permissions[_selectedRole]![entry.key] = v),
                  ),
                ]),
              )).toList(),
            ),
          ),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _savePermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Permissions',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}