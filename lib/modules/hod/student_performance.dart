import 'package:flutter/material.dart';

class StudentPerformanceScreen extends StatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  State<StudentPerformanceScreen> createState() =>
      _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState
    extends State<StudentPerformanceScreen> {
  String _selectedSemester = 'All';

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Muhammed Humraz',
      'rollNumber': 'BCA001',
      'semester': 1,
      'attendance': 92,
      'cgpa': 8.6,
      'internalAverage': 86,
    },
    {
      'name': 'Arya Nair',
      'rollNumber': 'BCA002',
      'semester': 1,
      'attendance': 68,
      'cgpa': 7.4,
      'internalAverage': 72,
    },
    {
      'name': 'Rahul Menon',
      'rollNumber': 'BCA003',
      'semester': 2,
      'attendance': 84,
      'cgpa': 6.8,
      'internalAverage': 66,
    },
    {
      'name': 'Anjali K',
      'rollNumber': 'BCA004',
      'semester': 3,
      'attendance': 72,
      'cgpa': 8.1,
      'internalAverage': 81,
    },
    {
      'name': 'Fahad P',
      'rollNumber': 'BCA005',
      'semester': 4,
      'attendance': 88,
      'cgpa': 5.2,
      'internalAverage': 48,
    },
    {
      'name': 'Niya Thomas',
      'rollNumber': 'BCA006',
      'semester': 5,
      'attendance': 95,
      'cgpa': 9.1,
      'internalAverage': 93,
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    if (_selectedSemester == 'All') {
      return _students;
    }

    return _students.where((student) {
      return student['semester'].toString() ==
          _selectedSemester;
    }).toList();
  }

  List<Map<String, dynamic>> get _topPerformers {
    final students = List<Map<String, dynamic>>.from(
      _filteredStudents,
    );

    students.sort(
      (a, b) => (b['cgpa'] as num).compareTo(
        a['cgpa'] as num,
      ),
    );

    return students.take(3).toList();
  }

  List<Map<String, dynamic>> get _riskStudents {
    return _filteredStudents.where((student) {
      final attendance =
          student['attendance'] as int;

      final cgpa =
          (student['cgpa'] as num).toDouble();

      final internalAverage =
          student['internalAverage'] as int;

      return attendance < 75 ||
          cgpa < 6 ||
          internalAverage < 50;
    }).toList();
  }

  double get _averageCgpa {
    final students = _filteredStudents;

    if (students.isEmpty) return 0;

    final total = students.fold<double>(
      0,
      (value, student) =>
          value +
          (student['cgpa'] as num).toDouble(),
    );

    return total / students.length;
  }

  double get _averageAttendance {
    final students = _filteredStudents;

    if (students.isEmpty) return 0;

    final total = students.fold<int>(
      0,
      (value, student) =>
          value + student['attendance'] as int,
    );

    return total / students.length;
  }

  String _studentStatus(
    Map<String, dynamic> student,
  ) {
    final attendance =
        student['attendance'] as int;

    final cgpa =
        (student['cgpa'] as num).toDouble();

    final internalAverage =
        student['internalAverage'] as int;

    if (attendance < 75) {
      return 'Attendance Risk';
    }

    if (cgpa < 6 || internalAverage < 50) {
      return 'Academic Risk';
    }

    if (cgpa >= 8.5 &&
        internalAverage >= 85) {
      return 'Top Performer';
    }

    return 'Good';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Top Performer':
        return Colors.green;

      case 'Attendance Risk':
        return Colors.orange;

      case 'Academic Risk':
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  void _showStudentPerformance(
    Map<String, dynamic> student,
  ) {
    final status = _studentStatus(student);

    final statusColor =
        _statusColor(status);

    final attendance =
        student['attendance'] as int;

    final cgpa =
        (student['cgpa'] as num).toDouble();

    final internalAverage =
        student['internalAverage'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            5,
            22,
            30,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor:
                        Colors.deepPurple.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      student['name']
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: Text(
                    student['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Center(
                  child: Text(
                    '${student['rollNumber']} • Semester ${student['semester']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _buildPerformanceProgress(
                  title: 'Attendance',
                  value: attendance / 100,
                  displayValue: '$attendance%',
                  color: attendance >= 75
                      ? Colors.green
                      : Colors.orange,
                ),

                const SizedBox(height: 18),

                _buildPerformanceProgress(
                  title: 'CGPA',
                  value: cgpa / 10,
                  displayValue:
                      cgpa.toStringAsFixed(1),
                  color: cgpa >= 6
                      ? Colors.blue
                      : Colors.red,
                ),

                const SizedBox(height: 18),

                _buildPerformanceProgress(
                  title: 'Internal Average',
                  value: internalAverage / 100,
                  displayValue:
                      '$internalAverage%',
                  color: internalAverage >= 50
                      ? Colors.deepPurple
                      : Colors.red,
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        status.contains('Risk')
                            ? Icons
                                .warning_amber_rounded
                            : Icons
                                .insights_outlined,
                        color: statusColor,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HOD Insight',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              _buildInsight(student),
                              style: TextStyle(
                                color:
                                    Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildInsight(
    Map<String, dynamic> student,
  ) {
    final attendance =
        student['attendance'] as int;

    final cgpa =
        (student['cgpa'] as num).toDouble();

    final internalAverage =
        student['internalAverage'] as int;

    if (attendance < 75) {
      return 'Attendance is below the required level. Academic intervention and attendance monitoring may be required.';
    }

    if (cgpa < 6) {
      return 'The student has a low CGPA. Review semester performance and identify difficult subjects.';
    }

    if (internalAverage < 50) {
      return 'Internal assessment performance is low. Faculty mentoring may improve academic progress.';
    }

    if (cgpa >= 8.5 &&
        internalAverage >= 85) {
      return 'Strong academic performance. The student is currently among the department top performers.';
    }

    return 'Academic performance is stable with no major risk indicators.';
  }

  Widget _buildPerformanceProgress({
    required String title,
    required double value,
    required String displayValue,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 9,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),

            const SizedBox(height: 13),

            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final status = _studentStatus(student);

    final statusColor =
        _statusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showStudentPerformance(student);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    statusColor.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  student['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${student['rollNumber']} • Sem ${student['semester']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    (student['cgpa'] as num)
                        .toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'CGPA',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

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

  Widget _buildSemesterFilter(
    String semester,
  ) {
    final selected =
        _selectedSemester == semester;

    return ChoiceChip(
      label: Text(
        semester == 'All'
            ? 'All'
            : 'Sem $semester',
      ),
      selected: selected,
      selectedColor:
          Colors.deepPurple.withValues(
        alpha: 0.15,
      ),
      labelStyle: TextStyle(
        color: selected
            ? Colors.deepPurple
            : Colors.grey.shade700,
        fontWeight: selected
            ? FontWeight.bold
            : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _selectedSemester = semester;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Student Performance',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSemesterFilter('All'),
                const SizedBox(width: 7),
                _buildSemesterFilter('1'),
                const SizedBox(width: 7),
                _buildSemesterFilter('2'),
                const SizedBox(width: 7),
                _buildSemesterFilter('3'),
                const SizedBox(width: 7),
                _buildSemesterFilter('4'),
                const SizedBox(width: 7),
                _buildSemesterFilter('5'),
                const SizedBox(width: 7),
                _buildSemesterFilter('6'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _buildSummaryCard(
                title: 'Average CGPA',
                value:
                    _averageCgpa.toStringAsFixed(1),
                icon: Icons.grade_outlined,
                color: Colors.blue,
              ),

              const SizedBox(width: 10),

              _buildSummaryCard(
                title: 'Avg Attendance',
                value:
                    '${_averageAttendance.toStringAsFixed(0)}%',
                icon: Icons
                    .assignment_turned_in_outlined,
                color: Colors.green,
              ),

              const SizedBox(width: 10),

              _buildSummaryCard(
                title: 'Risk Students',
                value:
                    '${_riskStudents.length}',
                icon:
                    Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 13),

          if (_topPerformers.isEmpty)
            const Text(
              'No student data available',
            )
          else
            ..._topPerformers.map(
              _buildStudentCard,
            ),

          const SizedBox(height: 26),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Students Requiring Attention',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${_riskStudents.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          if (_riskStudents.isEmpty)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No students currently have major risk indicators.',
                    ),
                  ),
                ],
              ),
            )
          else
            ..._riskStudents.map(
              _buildStudentCard,
            ),

          const SizedBox(height: 26),

          const Text(
            'All Student Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 13),

          if (students.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'No students found',
                ),
              ),
            )
          else
            ...students.map(
              _buildStudentCard,
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}