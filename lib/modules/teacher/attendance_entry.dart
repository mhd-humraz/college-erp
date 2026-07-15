import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AttendanceEntryScreen extends StatefulWidget {
  const AttendanceEntryScreen({super.key});

  @override
  State<AttendanceEntryScreen> createState() =>
      _AttendanceEntryScreenState();
}

class _AttendanceEntryScreenState
    extends State<AttendanceEntryScreen> {
  final List<Map<String, dynamic>> _studentRoster = [];

  bool _rosterCreated = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();

      final teacherProvider =
          context.read<TeacherProvider>();

      if (teacherProvider.students.isEmpty &&
          auth.token != null) {
        await teacherProvider.loadStudents(
          auth.token!,
        );
      }

      if (!mounted) return;

      _createRoster(
        teacherProvider.students,
      );
    });
  }

  void _createRoster(List<dynamic> students) {
    if (_rosterCreated) return;

    _studentRoster.clear();

    for (final student in students) {
      _studentRoster.add({
        'id': student['studentId'],
        'name':
            student['name'] ?? 'Unknown Student',
        'rollNumber':
            student['rollNumber'] ?? 'N/A',
        'isPresent': true,
      });
    }

    _rosterCreated = true;

    setState(() {});
  }

  Future<void> _submitAttendance() async {
    final auth = context.read<AuthProvider>();

    final teacherProvider =
        context.read<TeacherProvider>();

    final token = auth.token;

    final facultyId =
        teacherProvider.facultyId;

    if (token == null || facultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teacher session or faculty profile missing',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final records = _studentRoster
          .map<Map<String, dynamic>>(
        (student) => {
          'student': student['id'],
          'isPresent':
              student['isPresent'],
        },
      ).toList();

      final response =
          await ApiService.submitAttendance(
        token: token,

        // Temporary subject for testing
        subjectId:
            '6a2a72a5f34ca89a24990018',

        facultyId: facultyId,

        // Temporary hour for testing
        hour: 3,

        date: DateTime.now()
            .toIso8601String(),

        records: records,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ??
                'Attendance submitted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider =
        context.watch<TeacherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Entry'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: teacherProvider.studentsLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Session',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Programming in C • Hour 3',
                          ),
                        ],
                      ),
                      Text(
                        '${_studentRoster.length} Students',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _studentRoster.isEmpty
                      ? const Center(
                          child: Text(
                            'No students available',
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              _studentRoster.length,
                          itemBuilder: (context, index) {
                            final student =
                                _studentRoster[index];

                            final isPresent =
                                student['isPresent']
                                    as bool;

                            return SwitchListTile(
                              title: Text(
                                student['name'],
                              ),
                              subtitle: Text(
                                'Roll No: ${student['rollNumber']}',
                              ),
                              value: isPresent,
                              secondary: CircleAvatar(
                                backgroundColor: isPresent
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  isPresent
                                      ? Icons.check
                                      : Icons.close,
                                  color: isPresent
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) {
                                      setState(() {
                                        student[
                                                'isPresent'] =
                                            value;
                                      });
                                    },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(50),
                    ),
                    onPressed:
                        _studentRoster.isEmpty ||
                                _isSubmitting
                            ? null
                            : _submitAttendance,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Commit Current Log Entry',
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}