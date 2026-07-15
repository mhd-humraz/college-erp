import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../services/api_service.dart';

class MarksEntryScreen extends StatefulWidget {
  final String subjectId;

  final List<Map<String, dynamic>> students;

  const MarksEntryScreen({
    super.key,
    required this.subjectId,
    required this.students,
  });

  @override
  State<MarksEntryScreen> createState() =>
      _MarksEntryScreenState();
}

class _MarksEntryScreenState
    extends State<MarksEntryScreen> {
  final Map<String, TextEditingController>
      _controllers = {};

  List<Map<String, dynamic>> _students = [];

  String _examType = 'Internal_1';

  bool _submitting = false;
  bool _loadingStudents = true;

  String get _subjectId {
    if (widget.subjectId.isNotEmpty) {
      return widget.subjectId;
    }

    // Temporary Programming in C subject
    return '6a2a72a5f34ca89a24990018';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareStudents();
    });
  }

  Future<void> _prepareStudents() async {
    final auth = context.read<AuthProvider>();

    final teacherProvider =
        context.read<TeacherProvider>();

    if (widget.students.isNotEmpty) {
      _students = List<Map<String, dynamic>>.from(
        widget.students,
      );
    } else {
      if (teacherProvider.students.isEmpty &&
          auth.token != null) {
        await teacherProvider.loadStudents(
          auth.token!,
        );
      }

      _students = teacherProvider.students
          .map<Map<String, dynamic>>(
        (student) => {
          'studentId': student['studentId'],
          'name':
              student['name'] ?? 'Unknown Student',
          'rollNumber':
              student['rollNumber'] ?? 'N/A',
        },
      ).toList();
    }

    for (final student in _students) {
      final studentId =
          student['studentId'].toString();

      _controllers[studentId] =
          TextEditingController();
    }

    if (!mounted) return;

    setState(() {
      _loadingStudents = false;
    });
  }

  @override
  void dispose() {
    for (final controller
        in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _submitGradeSheet() async {
    final auth = context.read<AuthProvider>();

    if (auth.token == null ||
        auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teacher session missing',
          ),
        ),
      );

      return;
    }

    final scores = <Map<String, dynamic>>[];

    for (final student in _students) {
      final studentId =
          student['studentId'].toString();

      final controller =
          _controllers[studentId];

      final value =
          controller?.text.trim() ?? '';

      if (value.isEmpty) {
        continue;
      }

      final marks = int.tryParse(value);

      if (marks == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Invalid marks for ${student['name']}',
            ),
          ),
        );

        return;
      }

      if (marks < 0 || marks > 100) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Marks must be between 0 and 100 for ${student['name']}',
            ),
          ),
        );

        return;
      }

      scores.add({
        'student': studentId,
        'marksObtained': marks,
      });
    }

    if (scores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter at least one student mark',
          ),
        ),
      );

      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response =
          await ApiService.submitMarks(
        token: auth.token!,
        payload: {
          'subjectId': _subjectId,
          'examType': _examType,
          'maxMarks': 100,
          'passMarks': 40,
          'scores': scores,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ??
                'Marks submitted successfully',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marks submission failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Grading'),
        backgroundColor: AppTheme.accentTeal,
        foregroundColor: Colors.white,
      ),
      body: _loadingStudents
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Programming in C',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_students.length} students',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      DropdownButtonFormField<String>(
                    initialValue: _examType,
                    decoration: InputDecoration(
                      labelText: 'Exam Type',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Internal_1',
                        child: Text('Internal 1'),
                      ),
                      DropdownMenuItem(
                        value: 'Internal_2',
                        child: Text('Internal 2'),
                      ),
                      DropdownMenuItem(
                        value: 'Semester_Final',
                        child: Text(
                          'Semester Final',
                        ),
                      ),
                    ],
                    onChanged: _submitting
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _examType = value;
                            });
                          },
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? const Center(
                          child: Text(
                            'No students available',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student =
                                _students[index];

                            final studentId =
                                student['studentId']
                                    .toString();

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          AppTheme.accentTeal
                                              .withValues(
                                        alpha: 0.15,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            student['name'] ??
                                                'Unknown Student',
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            'Roll No: ${student['rollNumber'] ?? 'N/A'}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller:
                                            _controllers[
                                                studentId],
                                        enabled:
                                            !_submitting,
                                        keyboardType:
                                            TextInputType
                                                .number,
                                        decoration:
                                            const InputDecoration(
                                          labelText: 'Marks',
                                          suffixText: '/100',
                                          border:
                                              OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(52),
                      backgroundColor:
                          AppTheme.accentTeal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed:
                        _students.isEmpty || _submitting
                            ? null
                            : _submitGradeSheet,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.save_outlined,
                          ),
                    label: Text(
                      _submitting
                          ? 'Submitting...'
                          : 'Submit Marks',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}