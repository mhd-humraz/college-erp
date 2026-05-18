import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class ExamManagementPage extends StatefulWidget {
  const ExamManagementPage({super.key});
  @override
  State<ExamManagementPage> createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends State<ExamManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _exams = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); _fetchExams(); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/exams');
      setState(() { _exams = data; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); }
  }

  void _showSnack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
    backgroundColor: isError ? Colors.redAccent : AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  void _showAddExamDialog() {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final semCtrl = TextEditingController();

    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Exam', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(nameCtrl, 'Exam Name', Icons.assignment_rounded),
        const SizedBox(height: 12),
        _field(dateCtrl, 'Date (YYYY-MM-DD)', Icons.calendar_today_rounded),
        const SizedBox(height: 12),
        _field(deptCtrl, 'Department', Icons.account_tree_rounded),
        const SizedBox(height: 12),
        _field(semCtrl, 'Semester', Icons.numbers_rounded, type: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            Navigator.pop(context);
            try {
              await ApiService.post('/exams', {'name': nameCtrl.text.trim(), 'date': dateCtrl.text.trim(), 'department': deptCtrl.text.trim(), 'semester': semCtrl.text.trim()});
              _fetchExams(); _showSnack('Exam added');
            } catch (e) { _showSnack('Failed', isError: true); }
          },
          child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Examination', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Exams'), Tab(text: 'Hall Tickets'), Tab(text: 'Results')],
        ),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.primary, onPressed: _showAddExamDialog, child: const Icon(Icons.add, color: Colors.white)),
      body: TabBarView(controller: _tabController, children: [
        // Exams tab
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _exams.isEmpty
                ? Center(child: Text('No exams yet', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exams.length,
                    itemBuilder: (_, i) => _examCard(_exams[i]),
                  ),

        // Hall Tickets tab
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.badge_rounded, size: 48, color: AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Hall ticket generation', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showSnack('Hall tickets generated'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
            label: const Text('Generate Hall Tickets', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ])),

        // Results tab
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.grade_rounded, size: 48, color: AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Publish exam results', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showSnack('Results published'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.publish_rounded, color: Colors.white, size: 18),
            label: const Text('Publish Results', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ])),
      ]),
    );
  }

  Widget _examCard(dynamic exam) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(exam['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        Text('${exam['department'] ?? ''} · Sem ${exam['semester'] ?? ''} · ${exam['date'] ?? ''}',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
      ])),
      IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
        onPressed: () async {
          try { await ApiService.delete('/exams/${exam['_id'] ?? exam['id']}'); _fetchExams(); _showSnack('Exam deleted'); }
          catch (e) { _showSnack('Failed', isError: true); }
        }),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) =>
    TextField(controller: ctrl, keyboardType: type,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18), filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5))));
}