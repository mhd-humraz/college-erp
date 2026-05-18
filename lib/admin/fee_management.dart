import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class FeeManagementPage extends StatefulWidget {
  const FeeManagementPage({super.key});
  @override
  State<FeeManagementPage> createState() => _FeeManagementPageState();
}

class _FeeManagementPageState extends State<FeeManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _fees = [];
  bool _isLoading = true;
  String _filter = 'All';
  final List<String> _filters = ['All', 'Paid', 'Pending', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFees();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _fetchFees() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/fees');
      setState(() { _fees = data; _isLoading = false; });
    } catch (e) {
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

  void _showAddFeeDialog() {
    final studentIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String status = 'Pending';

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Fee Record', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(studentIdCtrl, 'Student ID', Icons.person_outline),
        const SizedBox(height: 12),
        _field(amountCtrl, 'Amount (₹)', Icons.currency_rupee_rounded, type: TextInputType.number),
        const SizedBox(height: 12),
        _field(descCtrl, 'Description', Icons.description_outlined),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: status,
          dropdownColor: AppColors.background,
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
          decoration: _dropDeco('Status'),
          items: ['Pending', 'Paid', 'Overdue'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setDlg(() => status = v!),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              await ApiService.post('/fees', {'studentId': studentIdCtrl.text.trim(), 'amount': double.tryParse(amountCtrl.text) ?? 0, 'description': descCtrl.text.trim(), 'status': status});
              _fetchFees(); _showSnack('Fee record added');
            } catch (e) { _showSnack('Failed', isError: true); }
          },
          child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        ),
      ],
    )));
  }

  List<dynamic> get _filtered => _filter == 'All' ? _fees : _fees.where((f) => f['status'] == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Fee Management', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchFees)],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.primary, onPressed: _showAddFeeDialog, child: const Icon(Icons.add, color: Colors.white)),
      body: Column(children: [
        // Summary cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _summaryCard('Total Collected', '₹12.4L', Colors.green),
            const SizedBox(width: 12),
            _summaryCard('Pending', '₹3.2L', Colors.orange),
            const SizedBox(width: 12),
            _summaryCard('Overdue', '₹0.8L', Colors.redAccent),
          ]),
        ),

        // Filter chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final sel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.card, borderRadius: BorderRadius.circular(20)),
                  child: Text(f, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: sel ? Colors.white : AppColors.text.withOpacity(0.6))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filtered.isEmpty
                  ? Center(child: Text('No records', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _feeCard(_filtered[i]),
                    ),
        ),
      ]),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.text.withOpacity(0.45)), textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _feeCard(dynamic fee) {
    final status = fee['status'] ?? 'Pending';
    final color = status == 'Paid' ? Colors.green : status == 'Overdue' ? Colors.redAccent : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.receipt_rounded, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fee['studentId'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          Text(fee['description'] ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${fee['amount'] ?? 0}', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) =>
    TextField(controller: ctrl, keyboardType: type,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18), filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5))));

  InputDecoration _dropDeco(String label) => InputDecoration(labelText: label,
    labelStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5), fontSize: 13),
    filled: true, fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none));
}