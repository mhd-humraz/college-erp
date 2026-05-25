import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List<dynamic> _users = [];
  List<dynamic> _departments = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRoleFilter;

  final List<String> _roles = ['admin', 'hod', 'teacher', 'class_teacher', 'student'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final usersRes = await ApiService.get('/admin/users');
      final deptsRes = await ApiService.get('/admin/departments');
      
      setState(() {
        _users = usersRes.data['data'] ?? [];
        _departments = deptsRes.data['data'] ?? [];
        _filteredUsers = List.from(_users);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _filterUsers() {
    var filtered = List.from(_users);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = (user['name'] ?? '').toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) || 
               email.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply role filter
    if (_selectedRoleFilter != null && _selectedRoleFilter!.isNotEmpty) {
      filtered = filtered.where((user) => 
        user['role'] == _selectedRoleFilter
      ).toList();
    }

    setState(() => _filteredUsers = filtered);
  }

  void _showEditUserDialog(dynamic user) {
    // Safe extraction
    final userName = user['name']?.toString() ?? 'Unknown';
    final userEmail = user['email']?.toString() ?? '';
    final currentRole = user['role']?.toString() ?? 'teacher';
    
    final nameCtrl = TextEditingController(text: userName);
    final emailCtrl = TextEditingController(text: userEmail);
    String selectedRole = currentRole;
    
    // Handle departmentId safely
    dynamic rawDeptId = user['departmentId'];
    String selectedDept = '';
    
    if (rawDeptId is String) {
      selectedDept = rawDeptId;
    } else if (rawDeptId is Map && rawDeptId['_id'] != null) {
      selectedDept = rawDeptId['_id'];
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text('Edit User', style: TextStyle(color: AppColors.text))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                            Text(userEmail, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Role Selection
                Text('Assign Role', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 14)),
                SizedBox(height: 8),
                ..._roles.map((role) => RadioListTile<String>(
                  title: Text(role.toUpperCase(), style: TextStyle(color: AppColors.text)),
                  value: role,
                  groupValue: selectedRole,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setDialogState(() => selectedRole = val!);
                  },
                )),
                
                SizedBox(height: 16),

                // Department Selection (for HOD/Teachers)
                if (selectedRole == 'hod' || selectedRole == 'teacher' || selectedRole == 'class_teacher') ...[
                  Text('Assign Department', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 14)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDept.isEmpty ? null : selectedDept,
                    decoration: InputDecoration(
                      labelText: 'Select Department',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: AppColors.card,
                    items: [
                      DropdownMenuItem(value: '', child: Text('No Department', style: TextStyle(color: AppColors.textSecondary))),
                      ..._departments.map((dept) => DropdownMenuItem(
                        value: dept['_id']?.toString(),
                        child: Text(dept['name']?.toString() ?? 'Unnamed', style: TextStyle(color: AppColors.text)),
                      )),
                    ],
                    onChanged: (val) {
                      setDialogState(() => selectedDept = val ?? '');
                    },
                  ),
                  
                  // HOD Info
                  if (selectedRole == 'hod') ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This user will become HOD of the selected department',
                              style: TextStyle(fontSize: 11, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  Navigator.pop(dialogContext);
                  
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );

                  // API call to update user
                  final response = await ApiService.put('/admin/users/${user['_id']}', data: {
                    'role': selectedRole,
                    'departmentId': selectedDept.isNotEmpty ? selectedDept : null,
                  });

                  Navigator.pop(context); // Close loading

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text('$userName updated to ${selectedRole.toUpperCase()}'),
                      ]),
                      backgroundColor: AppColors.success,
                    ));
                    _fetchData(); // Refresh list
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              },
              icon: Icon(Icons.save, size: 18),
              label: Text('Save Changes'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'hod': return AppColors.warning;
      case 'teacher': return AppColors.info;
      case 'class_teacher': return Color(0xFFA29BFE);
      case 'student': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'admin': return Icons.admin_panel_settings;
      case 'hod': return Icons.school;
      case 'teacher': return Icons.person;
      case 'class_teacher': return Icons.class_;
      case 'student': return Icons.school_outlined;
      default: return Icons.person_outline;
    }
  }

  String _getDepartmentName(dynamic deptId) {
    if (deptId == null) return 'Not Assigned';
    
    // If it's already a string (ID)
    if (deptId is String) {
      if (deptId.isEmpty) return 'Not Assigned';
      final dept = _departments.firstWhere((d) => d['_id'] == deptId, orElse: () => {});
      return dept['name'] ?? 'Unknown Dept';
    }
    
    // If it's a Map/Object (with _id field)
    if (deptId is Map) {
      return deptId['name'] ?? deptId['departmentName'] ?? 'Unknown Dept';
    }
    
    return 'Not Assigned';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Users', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.text),
            onPressed: _fetchData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterUsers();
                  },
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterUsers();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', null),
                      ..._roles.map((role) => _filterChip(role.toUpperCase(), role)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Total', '${_users.length}', Icons.people, AppColors.info),
                _miniStat('HODs', '${_users.where((u) => u['role'] == 'hod').length}', Icons.school, AppColors.warning),
                _miniStat('Teachers', '${_users.where((u) => u['role'] == 'teacher' || u['role'] == 'class_teacher').length}', Icons.person, AppColors.success),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white10),

          // Users List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredUsers.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10),
                          itemBuilder: (context, index) => _userCard(_filteredUsers[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final isSelected = _selectedRoleFilter == value;
    
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary)),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (val) {
          setState(() {
            _selectedRoleFilter = isSelected ? null : value;
            _filterUsers();
          });
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 14)),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _userCard(dynamic user) {
    // Safely extract values
    final userName = user['name']?.toString() ?? 'Unknown User';
    final userEmail = user['email']?.toString() ?? 'No email';
    final role = user['role']?.toString() ?? 'unknown';
    final roleColor = _getRoleColor(role);
    
    // Handle departmentId which might be string OR object
    dynamic deptData = user['departmentId'];
    String deptName;
    if (deptData is Map) {
      deptName = deptData['name'] ?? 'Not Assigned';
    } else if (deptData is String) {
      deptName = _getDepartmentName(deptData);
    } else {
      deptName = 'Not Assigned';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: roleColor.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [roleColor.withOpacity(0.3), roleColor.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getRoleIcon(role), color: roleColor, size: 26),
            ),
            SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 15),
                  ),
                  SizedBox(height: 3),
                  Text(
                    userEmail,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      // Role Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: roleColor),
                        ),
                      ),
                      SizedBox(width: 8),
                      
                      // Department Badge
                      if (deptName != 'Not Assigned')
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business, size: 10, color: AppColors.info),
                              SizedBox(width: 3),
                              Text(
                                deptName,
                                style: TextStyle(fontSize: 10, color: AppColors.info),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit Button
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
              tooltip: 'Edit User',
              onPressed: () => _showEditUserDialog(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline, size: 45, color: AppColors.textSecondary.withOpacity(0.35)),
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedRoleFilter != null ? 'No Matching Users' : 'No Users Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedRoleFilter != null
                  ? 'Try adjusting your search or filters'
                  : 'Upload staff CSV to add users',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (_searchQuery.isNotEmpty || _selectedRoleFilter != null) ...[
              SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedRoleFilter = null;
                    _filterUsers();
                  });
                },
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}