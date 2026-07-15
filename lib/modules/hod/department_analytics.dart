import 'package:flutter/material.dart';

class DepartmentAnalyticsScreen extends StatefulWidget {
  const DepartmentAnalyticsScreen({super.key});

  @override
  State<DepartmentAnalyticsScreen> createState() =>
      _DepartmentAnalyticsScreenState();
}

class _DepartmentAnalyticsScreenState
    extends State<DepartmentAnalyticsScreen> {
  String _selectedPeriod = 'This Semester';

  final List<Map<String, dynamic>> _semesterPerformance = [
    {
      'semester': 'Sem 1',
      'average': 82.0,
    },
    {
      'semester': 'Sem 2',
      'average': 76.0,
    },
    {
      'semester': 'Sem 3',
      'average': 88.0,
    },
    {
      'semester': 'Sem 4',
      'average': 71.0,
    },
    {
      'semester': 'Sem 5',
      'average': 91.0,
    },
    {
      'semester': 'Sem 6',
      'average': 84.0,
    },
  ];

  final List<Map<String, dynamic>> _facultyWorkload = [
    {
      'name': 'Rajina',
      'designation': 'Assistant Professor',
      'classes': 18,
      'maxClasses': 24,
    },
    {
      'name': 'Aneesh Kumar',
      'designation': 'Assistant Professor',
      'classes': 22,
      'maxClasses': 24,
    },
    {
      'name': 'Fathima N',
      'designation': 'Guest Lecturer',
      'classes': 14,
      'maxClasses': 20,
    },
    {
      'name': 'Rahul Menon',
      'designation': 'Associate Professor',
      'classes': 20,
      'maxClasses': 24,
    },
  ];

  final List<Map<String, dynamic>> _attendanceTrend = [
    {
      'month': 'Jan',
      'value': 76.0,
    },
    {
      'month': 'Feb',
      'value': 81.0,
    },
    {
      'month': 'Mar',
      'value': 79.0,
    },
    {
      'month': 'Apr',
      'value': 86.0,
    },
    {
      'month': 'May',
      'value': 84.0,
    },
    {
      'month': 'Jun',
      'value': 89.0,
    },
  ];

  Color _performanceColor(double value) {
    if (value >= 85) {
      return Colors.green;
    }

    if (value >= 70) {
      return Colors.orange;
    }

    return Colors.red;
  }

  Color _workloadColor(
    int classes,
    int maxClasses,
  ) {
    final percentage = classes / maxClasses;

    if (percentage >= 0.90) {
      return Colors.red;
    }

    if (percentage >= 0.75) {
      return Colors.orange;
    }

    return Colors.green;
  }

  void _showAnalyticsInfo({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
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
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          _showAnalyticsInfo(
            title: title,
            value: value,
            description: description,
            icon: icon,
            color: color,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTrend() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _attendanceTrend.map((data) {
                final value =
                    (data['value'] as num).toDouble();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: value / 100,
                              child: Container(
                                width: 28,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple
                                      .withValues(
                                    alpha: 0.75,
                                  ),
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['month'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.green.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Department attendance improved by 13% from January to June.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterPerformance() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: _semesterPerformance.map((semester) {
          final average =
              (semester['average'] as num).toDouble();

          final color =
              _performanceColor(average);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 17,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 55,
                      child: Text(
                        semester['semester'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: average / 100,
                          minHeight: 10,
                          backgroundColor:
                              Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${average.toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacultyWorkload() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: _facultyWorkload.map((faculty) {
          final classes =
              faculty['classes'] as int;

          final maxClasses =
              faculty['maxClasses'] as int;

          final workload =
              classes / maxClasses;

          final color = _workloadColor(
            classes,
            maxClasses,
          );

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
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
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        faculty['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        faculty['designation'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: workload,
                          minHeight: 7,
                          backgroundColor:
                              Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$classes/$maxClasses',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Classes',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRiskSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildRiskItem(
            title: 'Attendance Risk',
            subtitle:
                '12 students below 75% attendance',
            value: '12',
            icon: Icons.event_busy_outlined,
            color: Colors.orange,
          ),
          const Divider(height: 28),
          _buildRiskItem(
            title: 'Academic Risk',
            subtitle:
                '5 students with low academic performance',
            value: '5',
            icon: Icons.school_outlined,
            color: Colors.red,
          ),
          const Divider(height: 28),
          _buildRiskItem(
            title: 'Faculty Overload',
            subtitle:
                '1 faculty member above 90% workload',
            value: '1',
            icon: Icons.work_history_outlined,
            color: Colors.deepPurple,
          ),
          const Divider(height: 28),
          _buildRiskItem(
            title: 'Pending Approvals',
            subtitle:
                'Timetable and leave requests waiting',
            value: '4',
            icon: Icons.pending_actions_outlined,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Department Analytics',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BCA Department',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Academic performance overview',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(
                    value: 'This Semester',
                    child: Text('This Semester'),
                  ),
                  DropdownMenuItem(
                    value: 'This Year',
                    child: Text('This Year'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedPeriod = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _buildKpiCard(
                title: 'Students',
                value: '186',
                subtitle: '6 semesters',
                icon: Icons.groups_outlined,
                color: Colors.blue,
                description:
                    'The department currently has 186 active students distributed across six semesters.',
              ),
              const SizedBox(width: 10),
              _buildKpiCard(
                title: 'Faculty',
                value: '14',
                subtitle: '12 active today',
                icon: Icons.badge_outlined,
                color: Colors.deepPurple,
                description:
                    'There are 14 faculty members associated with the department.',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKpiCard(
                title: 'Attendance',
                value: '84%',
                subtitle: '+5% this month',
                icon: Icons
                    .assignment_turned_in_outlined,
                color: Colors.green,
                description:
                    'The current department average attendance is 84 percent.',
              ),
              const SizedBox(width: 10),
              _buildKpiCard(
                title: 'Avg Result',
                value: '82%',
                subtitle: 'Academic average',
                icon: Icons.insights_outlined,
                color: Colors.orange,
                description:
                    'The combined academic performance average across the department is 82 percent.',
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionHeader(
            title: 'Attendance Trend',
            subtitle:
                'Monthly department attendance',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 15),
          _buildAttendanceTrend(),
          const SizedBox(height: 30),
          _buildSectionHeader(
            title: 'Semester Performance',
            subtitle:
                'Average academic performance',
            icon: Icons.bar_chart_outlined,
          ),
          const SizedBox(height: 15),
          _buildSemesterPerformance(),
          const SizedBox(height: 30),
          _buildSectionHeader(
            title: 'Faculty Workload',
            subtitle:
                'Current teaching hour distribution',
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 15),
          _buildFacultyWorkload(),
          const SizedBox(height: 30),
          _buildSectionHeader(
            title: 'Department Risk Summary',
            subtitle:
                'Items requiring HOD attention',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 15),
          _buildRiskSummary(),
          const SizedBox(height: 35),
        ],
      ),
    );
  }
}