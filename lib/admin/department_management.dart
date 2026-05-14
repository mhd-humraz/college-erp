import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class DepartmentManagementPage extends StatefulWidget {
  const DepartmentManagementPage({super.key});

  @override
  State<DepartmentManagementPage> createState() => _DepartmentManagementPageState();
}

class _DepartmentManagementPageState extends State<DepartmentManagementPage> {
  List<dynamic> _departments = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/departments');
      setState(() { _departments = data; _isLoading = false; });
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

  void _showDeptDialog({dynamic dept}) {
    final nameCtrl = TextEditingController(text: dept?['name'] ?? '');
    final hodCtrl = TextEditingController(text: dept?['hod'] ?? '');
    final isEdit = dept != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Department' : 'Add Department',
            style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(nameCtrl, 'Department Name', Icons.account_tree_outlined),
          const SizedBox(height: 12),
          _dialogField(hodCtrl, 'HOD Name', Icons.person_outline),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(context);
              final body = {'name': nameCtrl.text.trim(), 'hod': hodCtrl.text.trim()};
              try {
                if (isEdit) {
                  await ApiService.put('/departments/${dept['_id'] ?? dept['id']}', body);
                  _showSnack('Department updated');
                } else {
                  await ApiService.post('/departments', body);
                  _showSnack('Department added');
                }
                _fetchDepartments();
              } catch (e) {
                _showSnack('Operation failed', isError: true);
              }
            },
            child: Text(isEdit ? 'Update' : 'Add',
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
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
        title: const Text('Department Management',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchDepartments),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showDeptDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : _departments.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _departments.length,
                      itemBuilder: (_, i) => _buildDeptCard(_departments[i]),
                    ),
    );
  }

  Widget _buildDeptCard(dynamic dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dept['name'] ?? '',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 3),
          Text('HOD: ${dept['hod'] ?? 'Not assigned'}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
        ])),
        IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            onPressed: () => _showDeptDialog(dept: dept)),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          onPressed: () async {
            try {
              await ApiService.delete('/departments/${dept['_id'] ?? dept['id']}');
              _fetchDepartments();
              _showSnack('Department deleted');
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
    Text('Failed to load departments', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: _fetchDepartments,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
  ]));

  Widget _buildEmpty() => Center(
    child: Text('No departments found', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))),
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