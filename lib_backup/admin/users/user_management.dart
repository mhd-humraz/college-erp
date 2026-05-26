// lib/screens/admin/users/user_management.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/search_filter_bar.dart'; 

class UserManagement extends StatefulWidget {s
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String _selectedRole = 'All';
  String _searchQuery = '';
  
  final List<String> _roles = ['All', 'Student', 'Teacher', 'HOD', 'Principal', 'Librarian', 'Staff'];
  
  final List<Map<String, dynamic>> _users = [
    {
      'id': '101',
      'name': 'John Doe',
      'email': 'john.doe@college.edu',
      'role': 'Student',
      'department': 'BCA',
      'status': 'Active',
      'joinDate': '2023-06-01',
    },
    {
      'id': '102',
      'name': 'Jane Smith',
      'email': 'jane.smith@college.edu',
      'role': 'Teacher',
      'department': 'Computer Science',
      'status': 'Active',
      'joinDate': '2022-08-15',
    },
    {
      'id': '103',
      'name': 'Robert Johnson',
      'email': 'robert.j@college.edu',
      'role': 'HOD',
      'department': 'BCA',
      'status': 'Active',
      'joinDate': '2021-03-10',
    },
    {
      'id': '104',
      'name': 'Sarah Williams',
      'email': 'sarah.w@college.edu',
      'role': 'Student',
      'department': 'BBA',
      'status': 'Inactive',
      'joinDate': '2023-09-01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => _showImportDialog(),
            tooltip: 'Bulk Import',
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          SearchFilterBar(
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            filterOptions: _roles,
            selectedFilter: _selectedRole,
            onFilterChanged: (filter) {
              setState(() {
                _selectedRole = filter;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _users.map((user) => DataRow(cells: [
                  DataCell(Text(user['id'])),
                  DataCell(Text(user['name'])),
                  DataCell(Text(user['email'])),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user['role']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['role'],
                      style: TextStyle(color: _getRoleColor(user['role'])),
                    ),
                  )),
                  DataCell(Text(user['department'])),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['status'] == 'Active' 
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['status'],
                      style: TextStyle(
                        color: user['status'] == 'Active' 
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditUserDialog(user),
                        color: AppColors.info,
                      ),
                      IconButton(
                        icon: const Icon(Icons.lock_reset, size: 20),
                        onPressed: () => _showResetPasswordDialog(user),
                        color: AppColors.warning,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _showDeleteConfirmation(user),
                        color: AppColors.error,
                      ),
                    ],
                  )),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch(role) {
      case 'Student': return AppColors.info;
      case 'Teacher': return AppColors.success;
      case 'HOD': return AppColors.warning;
      case 'Principal': return AppColors.purple;
      default: return AppColors.primary;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['Student', 'Teacher', 'HOD', 'Principal', 'Librarian', 'Staff']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Department'),
                items: ['BCA', 'BBA', 'BCom', 'Physics', 'Chemistry']
                    .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                controller: TextEditingController(text: user['name']),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: TextEditingController(text: user['email']),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: user['role'],
                items: ['Student', 'Teacher', 'HOD', 'Principal', 'Librarian', 'Staff']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: user['status'],
                items: ['Active', 'Inactive']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password for ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New password will be sent to the user\'s email.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset for ${user['name']}')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload Excel/CSV file with user data.'),
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload, size: 32),
                    SizedBox(height: 8),
                    Text('Drag & drop or click to upload'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Users imported successfully!')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}