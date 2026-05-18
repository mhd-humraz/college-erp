import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class AttendanceMonitoringPage extends StatefulWidget {
  const AttendanceMonitoringPage({super.key});
  @override
  State<AttendanceMonitoringPage> createState() => _AttendanceMonitoringPageState();
}

class _AttendanceMonitoringPageState extends State<AttendanceMonitoringPage> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  String _selectedDept = 'All';
  List<String> _departments = ['All'];

  @override
  void initState() { super.initState(); _fetchData(); }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/attendance/overview');
      final depts = <String>{'All'};
      for (final r in (data as List)) { if (r['department'] != null) depts.add(r['department']); }
      setState(() { _records = data; _departments = depts.toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  List<dynamic> get _filtered => _selectedDept == 'All' ? _records : _records.where((r) => r['department'] == _selectedDept).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Attendance Monitoring', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchData)],
      ),
      body: Column(children: [
        // Overview cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _overviewCard('Avg Attendance', '78.5%', AppColors.primary, Icons.trending_up_rounded),
            const SizedBox(width: 12),
            _overviewCard('Low Attendance', '42', Colors.redAccent, Icons.warning_rounded),
          ]),
        ),

        // Department filter
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _departments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = _departments[i];
              final sel = _selectedDept == d;
              return GestureDetector(
                onTap: () => setState(() => _selectedDept = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.card, borderRadius: BorderRadius.circular(20)),
                  child: Text(d, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: sel ? Colors.white : AppColors.text.withOpacity(0.6))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft,
          child: Text('Low Attendance Students (< 75%)', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text.withOpacity(0.7))))),
        const SizedBox(height: 8),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filtered.isEmpty
                  ? Center(child: Text('No low attendance records', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _studentCard(_filtered[i]),
                    ),
        ),
      ]),
    );
  }

  Widget _overviewCard(String label, String value, Color color, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.45))),
        ]),
      ]),
    ));
  }

  Widget _studentCard(dynamic record) {
    final percent = (record['percentage'] ?? 0).toDouble();
    final color = percent >= 75 ? Colors.green : percent >= 60 ? Colors.orange : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.15),
            child: Text((record['name'] ?? 'S')[0].toUpperCase(), style: TextStyle(fontFamily: 'Poppins', color: color, fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
            Text('${record['studentId'] ?? ''} · ${record['department'] ?? ''} · Sem ${record['semester'] ?? ''}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.text.withOpacity(0.45))),
          ])),
          Text('${percent.toStringAsFixed(1)}%', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
          value: percent / 100, minHeight: 6,
          backgroundColor: AppColors.background,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        )),
      ]),
    );
  }
}