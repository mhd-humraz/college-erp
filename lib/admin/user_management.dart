import 'package:flutter/material.dart';
import '../utils/theme.dart';  // ✅ correct

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});
  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedRole = 'All';

  final List<String> _roles = ['All', 'Student', 'Teacher', 'HOD', 'Principal', 'Librarian', 'Staff'];

  final List<Map<String, dynamic>> _users = [
    {'name': 'Anjali Sharma', 'role': 'Student', 'dept': 'BCA', 'email': 'anjali@college.edu', 'status': 'Active', 'avatar': 'AS'},
    {'name': 'Dr. Priya Nair', 'role': 'Teacher', 'dept': 'Physics', 'email': 'priya@college.edu', 'status': 'Active', 'avatar': 'PN'},
    {'name': 'Rahul Mehta', 'role': 'Student', 'dept': 'BBA', 'email': 'rahul@college.edu', 'status': 'Active', 'avatar': 'RM'},
    {'name': 'Prof. Suresh Kumar', 'role': 'HOD', 'dept': 'BCA', 'email': 'suresh@college.edu', 'status': 'Active', 'avatar': 'SK'},
    {'name': 'Meena Joseph', 'role': 'Librarian', 'dept': 'Library', 'email': 'meena@college.edu', 'status': 'Active', 'avatar': 'MJ'},
    {'name': 'Arjun Pillai', 'role': 'Student', 'dept': 'BCom', 'email': 'arjun@college.edu', 'status': 'Inactive', 'avatar': 'AP'},
    {'name': 'Dr. Kavitha Rao', 'role': 'Principal', 'dept': 'Administration', 'email': 'kavitha@college.edu', 'status': 'Active', 'avatar': 'KR'},
    {'name': 'Vijay Thomas', 'role': 'Staff', 'dept': 'Office', 'email': 'vijay@college.edu', 'status': 'Active', 'avatar': 'VT'},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((u) {
      final matchRole = _selectedRole == 'All' || u['role'] == _selectedRole;
      final matchSearch = _searchQuery.isEmpty ||
          u['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchRole && matchSearch;
    }).toList();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Student': return const Color(0xFF00ADB5);
      case 'Teacher': return const Color(0xFF4CAF50);
      case 'HOD': return const Color(0xFF9C27B0);
      case 'Principal': return const Color(0xFFFF5722);
      case 'Librarian': return const Color(0xFFFF9800);
      default: return const Color(0xFF2196F3);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('User Management', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file_rounded, color: AppColors.primary), onPressed: () => _showImportDialog()),
          IconButton(icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Users'), Tab(text: 'Roles & Permissions')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddUserSheet(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildRolesTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _roles.length,
                  itemBuilder: (_, i) {
                    final r = _roles[i];
                    final selected = _selectedRole == r;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRole = r),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(r, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_filteredUsers.length} users found', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
                label: const Text('Export', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUsers.length,
            itemBuilder: (_, i) => _buildUserTile(_filteredUsers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final roleColor = _roleColor(user['role']);
    final isActive = user['status'] == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: roleColor.withOpacity(0.2),
            child: Text(user['avatar'], style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(user['email'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: roleColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(user['role'], style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text(user['dept'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(user['status'], style: TextStyle(color: isActive ? const Color(0xFF4CAF50) : Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              PopupMenuButton<String>(
                color: AppColors.card,
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
                onSelected: (val) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.text))),
                  const PopupMenuItem(value: 'reset', child: Text('Reset Password', style: TextStyle(color: AppColors.text))),
                  PopupMenuItem(value: 'toggle', child: Text(isActive ? 'Deactivate' : 'Activate', style: const TextStyle(color: AppColors.text))),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab() {
    final roles = [
      {'role': 'Student', 'perms': ['View attendance', 'View marks', 'View timetable', 'Library access'], 'color': Color(0xFF00ADB5)},
      {'role': 'Teacher', 'perms': ['Mark attendance', 'Enter marks', 'View timetable', 'Send notifications'], 'color': Color(0xFF4CAF50)},
      {'role': 'HOD', 'perms': ['All Teacher perms', 'Manage department', 'Approve leaves', 'View dept reports'], 'color': Color(0xFF9C27B0)},
      {'role': 'Principal', 'perms': ['All HOD perms', 'Full reports', 'Manage staff', 'Approve policies'], 'color': Color(0xFFFF5722)},
      {'role': 'Librarian', 'perms': ['Manage books', 'Issue/Return', 'Manage fines', 'View stock'], 'color': Color(0xFFFF9800)},
      {'role': 'Admin', 'perms': ['Full system access', 'Manage all users', 'System settings', 'Backup/Restore'], 'color': Color(0xFFE91E63)},
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: roles.map((r) {
        final color = r['color'] as Color;
        final perms = r['perms'] as List<String>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(r['role'] as String, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(color: AppColors.primary))),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: perms.map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(p, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddUserSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _AddUserSheet(),
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Bulk Import Users', style: TextStyle(color: AppColors.text)),
        content: const Text('Upload an Excel file (.xlsx) with columns: Name, Email, Role, Department', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('Choose File', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AddUserSheet extends StatefulWidget {
  const _AddUserSheet();
  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  String _selectedRole = 'Student';
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New User', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _buildField('Full Name', _nameCtrl, Icons.person_rounded),
          const SizedBox(height: 12),
          _buildField('Email', _emailCtrl, Icons.email_rounded),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              labelText: 'Role',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: ['Student', 'Teacher', 'HOD', 'Principal', 'Librarian', 'Staff']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(context),
              child: const Text('Create User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}