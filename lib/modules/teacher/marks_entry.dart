// lib/modules/teacher/marks_entry.dart
//
// FIXES applied vs original:
//   1. Replaced raw http.post (hardcoded localhost) with ApiService.submitMarks()
//   2. Token is read from AuthProvider — no unauthenticated requests
//   3. Hardcoded student/subject IDs removed — now read from widget params
//      (pass them in when navigating from the student list)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class MarksEntryScreen extends StatefulWidget {
  /// The MongoDB subject _id for the session being graded.
  final String subjectId;

  /// The list of students to grade: [{ 'studentId': '...', 'name': '...' }, ...]
  final List<Map<String, dynamic>> students;

  const MarksEntryScreen({
    super.key,
    required this.subjectId,
    required this.students,
  });

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String _examType = 'Internal_1';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final s in widget.students) {
      _controllers[s['studentId']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _submitGradeSheet() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final scores = widget.students
        .where((s) =>
            _controllers[s['studentId']]?.text.isNotEmpty ?? false)
        .map((s) => {
              'student': s['studentId'],
              'marksObtained':
                  int.tryParse(_controllers[s['studentId']]!.text) ?? 0,
            })
        .toList();

    if (scores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one score.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await ApiService.submitMarks(
        token: auth.token ?? '',
        payload: {
          'subjectId': widget.subjectId,
          'examType': _examType,
          'maxMarks': 100,
          'scores': scores,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks submitted successfully.')),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Marks'),
        backgroundColor: AppTheme.accentTeal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _examType,
              items: ['Internal_1', 'Internal_2', 'Semester_Final']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _examType = v!),
              decoration: const InputDecoration(
                  labelText: 'Exam Type',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.students.length,
                itemBuilder: (_, i) {
                  final s = widget.students[i];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(s['name'] ?? s['studentId'])),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller:
                                _controllers[s['studentId']],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '/100',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTeal,
                  foregroundColor: Colors.white),
              onPressed: _submitting ? null : _submitGradeSheet,
              child: _submitting
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text('Submit Marks'),
            )
          ],
        ),
      ),
    );
  }
}