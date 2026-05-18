import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/theme.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────
// SCREEN 1: Today's Class Schedule
// ─────────────────────────────────────────
class AttendanceEntry extends StatefulWidget {
  const AttendanceEntry({super.key});

  @override
  State<AttendanceEntry> createState() => _AttendanceEntryState();
}

class _AttendanceEntryState extends State<AttendanceEntry> {
  List<dynamic> _slots = [];
  String _today = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/attendance/today-schedule');
      setState(() {
        _today = data['day'] ?? '';
        _slots = data['slots'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _fetchSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Today — $_today",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your Classes Today',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text.withOpacity(0.8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _slots.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.event_busy_rounded, size: 48, color: AppColors.text.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text('No classes today', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _slots.length,
                              itemBuilder: (_, i) => _buildSlotCard(_slots[i]),
                            ),
                          ),
                  ],
                ),
    );
  }

  Widget _buildSlotCard(dynamic slot) {
    final bool taken = slot['attendanceTaken'] ?? false;

    return GestureDetector(
      onTap: taken
          ? null
          : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceMarkingScreen(slot: slot),
                ),
              );
              _fetchSchedule(); // refresh after marking
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: taken ? Colors.green.withOpacity(0.4) : AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: taken ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                taken ? Icons.check_circle_rounded : Icons.class_rounded,
                color: taken ? Colors.green : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot['subject'] ?? '',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dept: ${slot['department']} · Sem: ${slot['semester']}',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45)),
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(slot['time'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    const Icon(Icons.meeting_room_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Room ${slot['room'] ?? '-'}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary)),
                  ]),
                ],
              ),
            ),
            if (taken)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Text('Done', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
      const SizedBox(height: 12),
      Text('Failed to load schedule', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _fetchSchedule,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────
// SCREEN 2: Mark Attendance for a Class
// ─────────────────────────────────────────
class AttendanceMarkingScreen extends StatefulWidget {
  final dynamic slot;

  const AttendanceMarkingScreen({super.key, required this.slot});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  List<dynamic> _students = [];
  Map<String, bool> _attendance = {}; // studentId -> isPresent
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final dept = widget.slot['department'];
      final sem = widget.slot['semester'];
      final data = await ApiService.get('/attendance/students?department=$dept&semester=$sem');
      setState(() {
        _students = data;
        // Default all present
        for (final s in data) {
          _attendance[s['studentId']] = true;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    final today = DateTime.now().toIso8601String().split('T')[0];
    final records = _students.map((s) => {
      'studentId': s['studentId'],
      'studentName': s['name'],
      'email': s['email'] ?? '',
      'guardianPhone': s['guardianPhone'] ?? '',
      'status': (_attendance[s['studentId']] ?? true) ? 'Present' : 'Absent',
    }).toList();

    try {
      final result = await ApiService.post('/attendance/save', {
        'date': today,
        'subject': widget.slot['subject'],
        'department': widget.slot['department'],
        'semester': widget.slot['semester'],
        'records': records,
      });

      if (!mounted) return;

      final absentCount = records.where((r) => r['status'] == 'Absent').length;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Attendance saved! $absentCount absent — notifications sent.',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int get _presentCount => _attendance.values.where((v) => v).length;
  int get _absentCount => _attendance.values.where((v) => !v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.slot['subject'] ?? 'Attendance',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : Column(
                  children: [
                    // Stats bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statChip('Total', '${_students.length}', AppColors.primary),
                            _statChip('Present', '$_presentCount', Colors.green),
                            _statChip('Absent', '$_absentCount', Colors.redAccent),
                          ],
                        ),
                      ),
                    ),

                    // Mark all buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                for (final s in _students) {
                                  _attendance[s['studentId']] = true;
                                }
                              }),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('All Present', style: TextStyle(fontFamily: 'Poppins', color: Colors.green, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                for (final s in _students) {
                                  _attendance[s['studentId']] = false;
                                }
                              }),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('All Absent', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Student list
                    Expanded(
                      child: _students.isEmpty
                          ? Center(
                              child: Text(
                                'No students found for this class',
                                style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _students.length,
                              itemBuilder: (_, i) => _buildStudentCard(_students[i]),
                            ),
                    ),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  'Save & Notify Absent',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    final id = student['studentId'];
    final isPresent = _attendance[id] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPresent ? Colors.green.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isPresent ? Colors.green.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
            child: Text(
              (student['name'] ?? 'S')[0].toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: isPresent ? Colors.green : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? '',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                Text(
                  student['studentId'] ?? '',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45)),
                ),
              ],
            ),
          ),

          // Present / Absent toggle
          GestureDetector(
            onTap: () => setState(() => _attendance[id] = !isPresent),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isPresent ? Colors.green.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPresent ? Colors.green : Colors.redAccent,
                  width: 1,
                ),
              ),
              child: Text(
                isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPresent ? Colors.green : Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
    ]);
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
      const SizedBox(height: 12),
      Text('Failed to load students', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _fetchStudents,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ),
    ]),
  );
}