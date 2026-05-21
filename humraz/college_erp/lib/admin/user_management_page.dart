import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';
import 'package:dio/dio.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _error;
  final _searchController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      Future.delayed(Duration(milliseconds: 500), () {
        if (_searchController.text.isNotEmpty) {
          _fetchUsers();
        }
      });
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/admin/users');

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _users = response.data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadCSV() async {
    try {
      setState(() => _isUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xls', 'xlsx'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes ?? [];
      
      final apiService = ApiService();
      
      var formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(List<int>.from(bytes), filename: file.name),
      });

      final response = await apiService.dio.post(
        '/api/admin/users/upload-csv',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success']) {
        setState(() => _isUploading = false);
        _fetchUsers();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text('Success!', style: TextStyle(color: AppColors.text)),
            content: Text('CSV uploaded successfully!', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRoleDialog(String userId, String currentRole) {
    String? selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AppColors.card,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Change Role', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                SizedBox(height: 8),
                Text('Current: $currentRole', style: TextStyle(color: AppColors.textSecondary)),
                SizedBox(height: 16),
                
                ...['admin', 'teacher', 'hod'].map((role) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      selectedRole = role;
                      setDialogState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedRole == role ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selectedRole == role ? AppColors.primary : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(selectedRole == role ? Icons.radio_button_checked : Icons.radio_button_unchecked, 
                             color: selectedRole == role ? AppColors.primary : AppColors.textSecondary),
                          SizedBox(width: 12),
                          Text(role.toUpperCase(), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                )),
                
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, selectedRole),
                      child: Text('OK', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((newRole) {
      if (newRole != null && newRole != currentRole) {
        _updateUserRole(userId, newRole);
      }
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      final apiService = ApiService();
      final response = await apiService.put('/api/admin/users/$userId/role', data: {'role': newRole});
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Role updated to $newRole'), backgroundColor: Colors.green));
        _fetchUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'User Management'),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.card,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file, color: Colors.white),
                        label: Text(_isUploading ? 'Uploading...' : 'Upload CSV', style: TextStyle(color: Colors.white)),
                        onPressed: _isUploading ? null : _pickAndUploadCSV,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text('Refresh', style: TextStyle(color: Colors.white)),
                        onPressed: _fetchUsers,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: AppColors.primary));
    
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error, size: 64, color: Colors.red),
      SizedBox(height: 16),
      Text('Error', style: TextStyle(fontSize: 18, color: Colors.red)),
      SizedBox(height: 8),
      Text(_error ?? '', textAlign: TextAlign.center),
      SizedBox(height: 24),
      ElevatedButton(onPressed: _fetchUsers, child: Text('Retry'))
    ]));
    
    if (_users.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people, size: 64, color: AppColors.textSecondary),
      SizedBox(height: 16),
      Text('No users yet', style: TextStyle(fontSize: 18, color: AppColors.text)),
      SizedBox(height: 24),
      ElevatedButton(
        onPressed: _isUploading ? null : _pickAndUploadCSV,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Text('Upload CSV', style: TextStyle(color: Colors.white))),
      )
    ]));
    
    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: AppColors.card,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.primary, child: Text(user['firstName']?.toString()[0] ?? 'U')),
              title: Text('${user['firstName']} ${user['lastName']}'),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user['email'] ?? ''),
                Row(children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: user['role'] == 'hod' ? Colors.purple : AppColors.info, borderRadius: BorderRadius.circular(4)), child: Text(user['role']?.toUpperCase() ?? '', style: TextStyle(fontSize: 10, color: Colors.white))),
                  SizedBox(width: 8),
                  if (user['profile']?['employeeId'] != null) Text('ID: ${user['profile']['employeeId']}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ]),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'role': _showRoleDialog(user['_id'], user['role']); break;
                    case 'delete': _confirmDelete(user['_id'], user['email']); break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'role', child: ListTile(dense: true, leading: Icon(Icons.admin_panel_settings, color: Colors.purple), title: Text('Change Role'))),
                  PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete'))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(String userId, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete User?', style: TextStyle(color: AppColors.text)),
        content: Text('Delete $email?\nThis cannot be undone!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final apiService = ApiService();
                await apiService.delete('/api/admin/users/$userId');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Deleted'), backgroundColor: Colors.green));
                _fetchUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}