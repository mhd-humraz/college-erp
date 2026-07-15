import 'package:flutter/material.dart';

class FacultyAssignmentScreen extends StatefulWidget {
  const FacultyAssignmentScreen({super.key});

  @override
  State<FacultyAssignmentScreen> createState() =>
      _FacultyAssignmentScreenState();
}

class _FacultyAssignmentScreenState
    extends State<FacultyAssignmentScreen> {
  String _selectedSemester = 'Semester 1';

  String? _selectedSubject;

  String? _selectedFaculty;

  final List<String> _semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
  ];

  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 'SUB001',
      'name': 'Programming in C',
      'code': 'BCA101',
      'semester': 'Semester 1',
      'hours': 5,
    },
    {
      'id': 'SUB002',
      'name': 'Mathematics',
      'code': 'BCA102',
      'semester': 'Semester 1',
      'hours': 4,
    },
    {
      'id': 'SUB003',
      'name': 'Digital Electronics',
      'code': 'BCA103',
      'semester': 'Semester 1',
      'hours': 4,
    },
    {
      'id': 'SUB004',
      'name': 'Data Structures',
      'code': 'BCA201',
      'semester': 'Semester 2',
      'hours': 5,
    },
    {
      'id': 'SUB005',
      'name': 'Database Management',
      'code': 'BCA301',
      'semester': 'Semester 3',
      'hours': 5,
    },
    {
      'id': 'SUB006',
      'name': 'Computer Networks',
      'code': 'BCA302',
      'semester': 'Semester 3',
      'hours': 4,
    },
    {
      'id': 'SUB007',
      'name': 'Machine Learning',
      'code': 'BCA501',
      'semester': 'Semester 5',
      'hours': 5,
    },
  ];

  final List<Map<String, dynamic>> _faculty = [
    {
      'id': 'FAC001',
      'name': 'Rajina',
      'employeeId': 'EMP001',
      'designation': 'Assistant Professor',
      'maxHours': 20,
    },
    {
      'id': 'FAC002',
      'name': 'Aneesh Kumar',
      'employeeId': 'EMP002',
      'designation': 'Assistant Professor',
      'maxHours': 20,
    },
    {
      'id': 'FAC003',
      'name': 'Fathima N',
      'employeeId': 'EMP003',
      'designation': 'Guest Lecturer',
      'maxHours': 16,
    },
    {
      'id': 'FAC004',
      'name': 'Rahul Menon',
      'employeeId': 'EMP004',
      'designation': 'Associate Professor',
      'maxHours': 18,
    },
  ];

  final List<Map<String, dynamic>> _assignments = [
    {
      'subjectId': 'SUB001',
      'facultyId': 'FAC001',
    },
    {
      'subjectId': 'SUB002',
      'facultyId': 'FAC002',
    },
    {
      'subjectId': 'SUB003',
      'facultyId': 'FAC003',
    },
    {
      'subjectId': 'SUB005',
      'facultyId': 'FAC002',
    },
    {
      'subjectId': 'SUB006',
      'facultyId': 'FAC004',
    },
    {
      'subjectId': 'SUB007',
      'facultyId': 'FAC001',
    },
  ];

  List<Map<String, dynamic>>
      get _semesterSubjects {
    return _subjects.where((subject) {
      return subject['semester'] ==
          _selectedSemester;
    }).toList();
  }

  Map<String, dynamic>? _findSubject(
    String subjectId,
  ) {
    for (final subject in _subjects) {
      if (subject['id'] == subjectId) {
        return subject;
      }
    }

    return null;
  }

  Map<String, dynamic>? _findFaculty(
    String facultyId,
  ) {
    for (final faculty in _faculty) {
      if (faculty['id'] == facultyId) {
        return faculty;
      }
    }

    return null;
  }

  Map<String, dynamic>? _subjectAssignment(
    String subjectId,
  ) {
    for (final assignment in _assignments) {
      if (assignment['subjectId'] ==
          subjectId) {
        return assignment;
      }
    }

    return null;
  }

  int _facultyAssignedHours(
    String facultyId,
  ) {
    int totalHours = 0;

    for (final assignment in _assignments) {
      if (assignment['facultyId'] ==
          facultyId) {
        final subject = _findSubject(
          assignment['subjectId'],
        );

        if (subject != null) {
          totalHours +=
              subject['hours'] as int;
        }
      }
    }

    return totalHours;
  }

  Color _workloadColor(
    int currentHours,
    int maxHours,
  ) {
    final percentage =
        currentHours / maxHours;

    if (percentage > 1) {
      return Colors.red;
    }

    if (percentage >= 0.85) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _workloadStatus(
    int currentHours,
    int maxHours,
  ) {
    final percentage =
        currentHours / maxHours;

    if (percentage > 1) {
      return 'Overloaded';
    }

    if (percentage >= 0.85) {
      return 'High Workload';
    }

    return 'Available';
  }

  void _assignFaculty() {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select a subject',
          ),
        ),
      );

      return;
    }

    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select a faculty member',
          ),
        ),
      );

      return;
    }

    final subject = _findSubject(
      _selectedSubject!,
    );

    final faculty = _findFaculty(
      _selectedFaculty!,
    );

    if (subject == null || faculty == null) {
      return;
    }

    final currentHours =
        _facultyAssignedHours(
      _selectedFaculty!,
    );

    final subjectHours =
        subject['hours'] as int;

    final maxHours =
        faculty['maxHours'] as int;

    final newHours =
        currentHours + subjectHours;

    if (newHours > maxHours) {
      _showOverloadWarning(
        subject: subject,
        faculty: faculty,
        currentHours: currentHours,
        newHours: newHours,
      );

      return;
    }

    _saveAssignment(
      subject,
      faculty,
    );
  }

  void _saveAssignment(
    Map<String, dynamic> subject,
    Map<String, dynamic> faculty,
  ) {
    setState(() {
      _assignments.removeWhere(
        (assignment) =>
            assignment['subjectId'] ==
            subject['id'],
      );

      _assignments.add({
        'subjectId': subject['id'],
        'facultyId': faculty['id'],
      });

      _selectedSubject = null;
      _selectedFaculty = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${subject['name']} assigned to ${faculty['name']}',
        ),
      ),
    );
  }

  void _showOverloadWarning({
    required Map<String, dynamic> subject,
    required Map<String, dynamic> faculty,
    required int currentHours,
    required int newHours,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 42,
          ),
          title: const Text(
            'Faculty Workload Warning',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${faculty['name']} currently has '
                '$currentHours teaching hours.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Assigning ${subject['name']} will increase the workload to $newHours/${faculty['maxHours']} hours.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Text(
                  'This faculty member will exceed the recommended teaching workload.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                _saveAssignment(
                  subject,
                  faculty,
                );
              },
              child: const Text(
                'Assign Anyway',
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeAssignment(
    Map<String, dynamic> subject,
  ) {
    final assignment =
        _subjectAssignment(subject['id']);

    if (assignment == null) {
      return;
    }

    setState(() {
      _assignments.remove(assignment);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${subject['name']} assignment removed',
        ),
      ),
    );
  }

  void _showSubjectDetails(
    Map<String, dynamic> subject,
  ) {
    final assignment =
        _subjectAssignment(subject['id']);

    final faculty = assignment == null
        ? null
        : _findFaculty(
            assignment['facultyId'],
          );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            5,
            22,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Colors.indigo,
                  size: 29,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                subject['name'],
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '${subject['code']} • ${subject['semester']}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 22),

              _buildDetailRow(
                icon: Icons.schedule_outlined,
                title: 'Teaching Hours',
                value:
                    '${subject['hours']} Hours / Week',
              ),

              const SizedBox(height: 13),

              _buildDetailRow(
                icon: Icons.person_outline,
                title: 'Assigned Faculty',
                value: faculty == null
                    ? 'Not Assigned'
                    : faculty['name'],
              ),

              if (faculty != null) ...[
                const SizedBox(height: 13),

                _buildDetailRow(
                  icon: Icons.badge_outlined,
                  title: 'Employee ID',
                  value: faculty['employeeId'],
                ),

                const SizedBox(height: 25),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize:
                        const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      bottomSheetContext,
                    );

                    _removeAssignment(subject);
                  },
                  icon: const Icon(
                    Icons.link_off_outlined,
                  ),
                  label: const Text(
                    'Remove Faculty Assignment',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(
              alpha: 0.09,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 21,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacultyWorkloadCard(
    Map<String, dynamic> faculty,
  ) {
    final currentHours =
        _facultyAssignedHours(faculty['id']);

    final maxHours =
        faculty['maxHours'] as int;

    final color = _workloadColor(
      currentHours,
      maxHours,
    );

    final status = _workloadStatus(
      currentHours,
      maxHours,
    );

    final progress =
        currentHours / maxHours;

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    color.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  faculty['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      faculty['employeeId'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Text(
                '$currentHours/$maxHours Hours',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    Map<String, dynamic> subject,
  ) {
    final assignment =
        _subjectAssignment(subject['id']);

    final faculty = assignment == null
        ? null
        : _findFaculty(
            assignment['facultyId'],
          );

    final assigned = faculty != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: assigned
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showSubjectDetails(subject);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: assigned
                      ? Colors.green.withValues(
                          alpha: 0.10,
                        )
                      : Colors.orange.withValues(
                          alpha: 0.10,
                        ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  assigned
                      ? Icons.check_circle_outline
                      : Icons.person_add_alt_outlined,
                  color: assigned
                      ? Colors.green
                      : Colors.orange,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${subject['code']} • ${subject['hours']} Hours / Week',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      assigned
                          ? 'Faculty: ${faculty['name']}'
                          : 'Faculty not assigned',
                      style: TextStyle(
                        color: assigned
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semesterSubjects =
        _semesterSubjects;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Faculty Assignment',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Faculty Workload',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Monitor current teaching hour allocation',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _faculty.map(
                _buildFacultyWorkloadCard,
              ).toList(),
            ),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_outlined,
                      color: Colors.deepPurple,
                    ),

                    SizedBox(width: 10),

                    Text(
                      'Assign Subject',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: Icon(
                      Icons.school_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: _semesters.map((semester) {
                    return DropdownMenuItem(
                      value: semester,
                      child: Text(semester),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedSemester = value;
                      _selectedSubject = null;
                    });
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(
                      Icons.menu_book_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: semesterSubjects.map(
                    (subject) {
                      return DropdownMenuItem<String>(
                        value: subject['id'],
                        child: Text(
                          '${subject['code']} - ${subject['name']}',
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedFaculty,
                  decoration: const InputDecoration(
                    labelText: 'Faculty',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: _faculty.map((faculty) {
                    final hours =
                        _facultyAssignedHours(
                      faculty['id'],
                    );

                    return DropdownMenuItem<String>(
                      value: faculty['id'],
                      child: Text(
                        '${faculty['name']} • $hours/${faculty['maxHours']} hrs',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFaculty = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size.fromHeight(50),
                  ),
                  onPressed: _assignFaculty,
                  icon: const Icon(
                    Icons.add_link_outlined,
                  ),
                  label: const Text(
                    'Assign Faculty',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subject Allocation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedSemester,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (semesterSubjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'No subjects available for this semester',
                ),
              ),
            )
          else
            ...semesterSubjects.map(
              _buildSubjectCard,
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}