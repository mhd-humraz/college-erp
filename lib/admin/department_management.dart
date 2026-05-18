import 'package:flutter/material.dart';
import '../utils/theme.dart';  // ✅ correct

class DepartmentManagement extends StatefulWidget {
  const DepartmentManagement({super.key});
  @override
  State<DepartmentManagement> createState() => _DepartmentManagementState();
}

class _DepartmentManagementState extends State<DepartmentManagement> {
  final List<Map<String, dynamic>> _departments = [
    {'name': 'Bachelor of Computer Applications', 'code': 'BCA', 'hod': 'Prof. Suresh Kumar', 'students': 320, 'staff': 12, 'color': Color(0xFF00ADB5)},
    {'name': 'Bachelor of Business Administration', 'code': 'BBA', 'hod': 'Dr. Rekha Menon', 'students': 280, 'staff': 10, 'color': Color(0xFF9C27B0)},
    {'name': 'Bachelor of Commerce', 'code': 'BCom', 'hod': 'Prof. Anil Varghese', 'students': 350, 'staff': 11, 'color': Color(0xFF4CAF50)},
    {'name': 'Department of Physics', 'code': 'PHY', 'hod': 'Dr. Priya Nair', 'students': 180, 'staff': 8, 'color': Color(0xFFFF9800)},
    {'name': 'Department of Chemistry', 'code': 'CHEM', 'hod': 'Dr. Sanjay Pillai', 'students': 160, 'staff': 7, 'color': Color(0xFFE91E63)},
    {'name': 'Department of Mathematics', 'code': 'MATH', 'hod': 'Prof. Leena Roy', 'students': 200, 'staff': 9, 'color': Color(0xFF2196F3)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Department Management', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Dept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddDeptSheet(),
      ),
      body: Column(
        children: [
          _buildSummaryRow(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _departments.length,
              itemBuilder: (_, i) => _buildDeptCard(_departments[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    int totalStudents = _departments.fold(0, (s, d) => s + (d['students'] as int));
    int totalStaff = _departments.fold(0, (s, d) => s + (d['staff'] as int));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _summaryChip('${_departments.length}', 'Departments', Icons.account_balance_rounded, const Color(0xFF00ADB5)),
          const SizedBox(width: 10),
          _summaryChip('$totalStudents', 'Students', Icons.school_rounded, const Color(0xFF4CAF50)),
          const SizedBox(width: 10),
          _summaryChip('$totalStaff', 'Staff', Icons.people_rounded, const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  Widget _summaryChip(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptCard(Map<String, dynamic> dept) {
    final color = dept['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showDeptDetails(dept),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(dept['code'], style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dept['name'], style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('HOD: ${dept['hod']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: AppColors.card,
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    onSelected: (_) {},
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.text))),
                      const PopupMenuItem(value: 'hod', child: Text('Change HOD', style: TextStyle(color: AppColors.text))),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.background, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _deptStat(Icons.school_rounded, '${dept['students']} Students', color),
                  const SizedBox(width: 20),
                  _deptStat(Icons.people_rounded, '${dept['staff']} Staff', color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deptStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showDeptDetails(Map<String, dynamic> dept) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dept['name'], style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _detailRow('Code', dept['code']),
            _detailRow('HOD', dept['hod']),
            _detailRow('Students', '${dept['students']}'),
            _detailRow('Staff', '${dept['staff']}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit', style: TextStyle(color: Colors.white)),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.grey)),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(key, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAddDeptSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Department', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _inputField('Department Name', Icons.account_balance_rounded),
            const SizedBox(height: 12),
            _inputField('Department Code', Icons.tag_rounded),
            const SizedBox(height: 12),
            _inputField('HOD Name', Icons.person_rounded),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Add Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, IconData icon) {
    return TextField(
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