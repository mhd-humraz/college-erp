import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedRole = 'All';

  final List<String> _roles = ['All', 'Student', 'Teacher', 'HOD', 'Principal', 'Admin'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/users');
      setState(() { _users = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      await ApiService.delete('/users/$id');
      _fetchUsers();
      _showSnack('User deleted successfully');
    } catch (e) {
      _showSnack('Failed to delete user', isError: true);
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

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'Student';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add User',
              style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _dialogField(passCtrl, 'Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  dropdownColor: AppColors.background,
                  style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
                  decoration: _dropdownDecoration('Role'),
                  items: _roles.where((r) => r != 'All').map((r) =>
                      DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDlg(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.text.withOpacity(0.5), fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiService.post('/users', {
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'password': passCtrl.text,
                    'role': selectedRole,
                  });
                  _fetchUsers();
                  _showSnack('User added successfully');
                } catch (e) {
                  _showSnack('Failed to add user', isError: true);
                }
              },
              child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> get _filteredUsers {
    if (_selectedRole == 'All') return _users;
    return _users.where((u) =>
        (u['role'] ?? '').toString().toLowerCase() == _selectedRole.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Management',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Role filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _roles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final role = _roles[i];
                  final selected = _selectedRole == role;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(role,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppColors.text.withOpacity(0.6),
                          )),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error.isNotEmpty
                    ? _buildError()
                    : _filteredUsers.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (_, i) => _buildUserCard(_filteredUsers[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              (user['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'Unknown',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                Text(user['email'] ?? '',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(user['role'] ?? '',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDelete(user['_id'] ?? user['id']),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete User', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete this user?',
            style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { Navigator.pop(context); _deleteUser(id); },
            child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
      const SizedBox(height: 12),
      Text('Failed to load users', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _fetchUsers,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
    ]),
  );

  Widget _buildEmpty() => Center(
    child: Text('No users found', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))),
  );

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}