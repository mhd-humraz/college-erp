import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class TimetableManagementPage extends StatefulWidget {
  const TimetableManagementPage({super.key});

  @override
  State<TimetableManagementPage> createState() => _TimetableManagementPageState();
}

class _TimetableManagementPageState extends State<TimetableManagementPage> {
  List<dynamic> _timetable = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedDay = 'Monday';

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/timetable');
      setState(() { _timetable = data; _isLoading = false; });
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

  void _showAddSlotDialog() {
    final subjectCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    String selectedDay = _selectedDay;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Timetable Slot',
              style: TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              dropdownColor: AppColors.background,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Day',
                labelStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5), fontSize: 13),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setDlg(() => selectedDay = v!),
            ),
            const SizedBox(height: 12),
            _dialogField(subjectCtrl, 'Subject', Icons.book_outlined),
            const SizedBox(height: 12),
            _dialogField(teacherCtrl, 'Teacher', Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField(timeCtrl, 'Time (e.g. 9:00 AM - 10:00 AM)', Icons.access_time_rounded),
            const SizedBox(height: 12),
            _dialogField(roomCtrl, 'Room No.', Icons.meeting_room_outlined),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiService.post('/timetable', {
                    'day': selectedDay,
                    'subject': subjectCtrl.text.trim(),
                    'teacher': teacherCtrl.text.trim(),
                    'time': timeCtrl.text.trim(),
                    'room': roomCtrl.text.trim(),
                  });
                  _showSnack('Slot added');
                  _fetchTimetable();
                } catch (e) {
                  _showSnack('Failed to add slot', isError: true);
                }
              },
              child: const Text('Add', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> get _filteredSlots =>
      _timetable.where((t) => (t['day'] ?? '') == _selectedDay).toList();

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
        title: const Text('Timetable',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchTimetable),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showAddSlotDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(children: [
        // Day tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final day = _days[i];
                final selected = _selectedDay == day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(day.substring(0, 3),
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.text.withOpacity(0.6),
                        )),
                  ),
                );
              },
            ),
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _error.isNotEmpty
                  ? _buildError()
                  : _filteredSlots.isEmpty
                      ? Center(child: Text('No classes on $_selectedDay',
                          style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSlots.length,
                          itemBuilder: (_, i) => _buildSlotCard(_filteredSlots[i]),
                        ),
        ),
      ]),
    );
  }

  Widget _buildSlotCard(dynamic slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(slot['subject'] ?? '',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 4),
          Text('${slot['teacher'] ?? ''} · Room ${slot['room'] ?? ''}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(slot['time'] ?? '',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary)),
          ]),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          onPressed: () async {
            try {
              await ApiService.delete('/timetable/${slot['_id'] ?? slot['id']}');
              _fetchTimetable();
              _showSnack('Slot deleted');
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
    Text('Failed to load timetable', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: _fetchTimetable,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
  ]));

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