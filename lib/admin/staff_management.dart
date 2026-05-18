import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});
  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<dynamic> _staff = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _fetchStaff(); }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/users?role=Teacher');
      setState(() { _staff = data; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  List<dynamic> get _filtered => _search.isEmpty ? _staff
      : _staff.where((s) => (s['name'] ?? '').toLowerCase().contains(_search.toLowerCase()) || (s['teacherId'] ?? '').toLowerCase().contains(_search.toLowerCase())).toList();

  void _showSnack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
    backgroundColor: isError ? Colors.redAccent : AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  void _showStaffDetail(dynamic staff) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.text.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          CircleAvatar(radius: 36, backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text((staff['name'] ?? 'T')[0].toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary))),
          const SizedBox(height: 14),
          Text(staff['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
          Text(staff['teacherId'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.primary.withOpacity(0.8))),
          const SizedBox(height: 20),
          _detailRow('Email', staff['email'] ?? '-', Icons.email_outlined),
          _detailRow('Phone', staff['phone'] ?? '-', Icons.phone_outlined),
          _detailRow('Department', staff['department'] ?? '-', Icons.account_tree_rounded),
          _detailRow('Subject', staff['subject'] ?? '-', Icons.book_rounded),
          _detailRow('Designation', staff['designation'] ?? '-', Icons.badge_rounded),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.text.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Close', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.6))),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(context); _showSnack('Password reset sent'); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Reset Password', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 10),
      Text('$label: ', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text.withOpacity(0.5))),
      Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Staff Management', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchStaff)],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
              hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              filled: true, fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _statBadge('Total Staff', '${_staff.length}', AppColors.primary),
            const SizedBox(width: 10),
            _statBadge('Active', '${_staff.where((s) => s['isActive'] == true).length}', Colors.green),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filtered.isEmpty
                  ? Center(child: Text('No staff found', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _staffCard(_filtered[i]),
                    ),
        ),
      ]),
    );
  }

  Widget _statBadge(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
    child: Text('$label: $value', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: color)));

  Widget _staffCard(dynamic staff) => GestureDetector(
    onTap: () => _showStaffDetail(staff),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text((staff['name'] ?? 'T')[0].toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(staff['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          Text('${staff['teacherId'] ?? ''} · ${staff['department'] ?? ''}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
          Text(staff['designation'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary)),
        ])),
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: staff['isActive'] == true ? Colors.green : Colors.grey),
        ),
      ]),
    ),
  );
}