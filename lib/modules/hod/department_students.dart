import 'package:flutter/material.dart';

class DepartmentStudentsScreen extends StatefulWidget {
  const DepartmentStudentsScreen({super.key});

  @override
  State<DepartmentStudentsScreen> createState() =>
      _DepartmentStudentsScreenState();
}

class _DepartmentStudentsScreenState
    extends State<DepartmentStudentsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedSemester = 'All';

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Muhammed Humraz',
      'rollNumber': 'BCA001',
      'email': 'student1@edusphere.edu',
      'semester': 1,
      'attendance': 92,
      'cgpa': 8.6,
      'status': 'Good',
    },
    {
      'name': 'Arya Nair',
      'rollNumber': 'BCA002',
      'email': 'arya@edusphere.edu',
      'semester': 1,
      'attendance': 68,
      'cgpa': 7.4,
      'status': 'Attendance Risk',
    },
    {
      'name': 'Rahul Menon',
      'rollNumber': 'BCA003',
      'email': 'rahul.student@edusphere.edu',
      'semester': 2,
      'attendance': 84,
      'cgpa': 6.8,
      'status': 'Good',
    },
    {
      'name': 'Anjali K',
      'rollNumber': 'BCA004',
      'email': 'anjali@edusphere.edu',
      'semester': 3,
      'attendance': 72,
      'cgpa': 8.1,
      'status': 'Attendance Risk',
    },
    {
      'name': 'Fahad P',
      'rollNumber': 'BCA005',
      'email': 'fahad@edusphere.edu',
      'semester': 4,
      'attendance': 88,
      'cgpa': 5.2,
      'status': 'Academic Risk',
    },
    {
      'name': 'Niya Thomas',
      'rollNumber': 'BCA006',
      'email': 'niya@edusphere.edu',
      'semester': 5,
      'attendance': 95,
      'cgpa': 9.1,
      'status': 'Good',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStudents {
    final search =
        _searchController.text.trim().toLowerCase();

    return _students.where((student) {
      final name =
          student['name'].toString().toLowerCase();

      final rollNumber = student['rollNumber']
          .toString()
          .toLowerCase();

      final matchesSearch =
          name.contains(search) ||
              rollNumber.contains(search);

      final matchesSemester =
          _selectedSemester == 'All' ||
              student['semester'].toString() ==
                  _selectedSemester;

      return matchesSearch && matchesSemester;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Good':
        return Colors.green;

      case 'Attendance Risk':
        return Colors.orange;

      case 'Academic Risk':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void _showStudentDetails(
    Map<String, dynamic> student,
  ) {
    final attendance =
        student['attendance'] as int;

    final cgpa =
        (student['cgpa'] as num).toDouble();

    final status = student['status'].toString();

    final statusColor = _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            8,
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
                    radius: 43,
                    backgroundColor:
                        Colors.teal.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      student['name']
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 31,
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

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    student['rollNumber'],
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                _buildDetailRow(
                  Icons.email_outlined,
                  'Email',
                  student['email'],
                ),

                _buildDetailRow(
                  Icons.apartment_outlined,
                  'Department',
                  'Computer Applications',
                ),

                _buildDetailRow(
                  Icons.school_outlined,
                  'Semester',
                  'Semester ${student['semester']}',
                ),

                const SizedBox(height: 18),

                const Text(
                  'Academic Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Attendance',
                        value: '$attendance%',
                        icon: Icons
                            .assignment_turned_in_outlined,
                        color: attendance >= 75
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildMetricCard(
                        title: 'CGPA',
                        value: cgpa.toStringAsFixed(1),
                        icon: Icons.grade_outlined,
                        color: cgpa >= 6
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        bottomSheetContext,
                      );

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${student['name']} performance details frontend is next',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.insights_outlined,
                    ),
                    label: const Text(
                      'View Full Performance',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.teal,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

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
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final attendance =
        student['attendance'] as int;

    final status = student['status'].toString();

    final statusColor = _statusColor(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showStudentDetails(student);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Colors.teal.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  student['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${student['rollNumber']} • Semester ${student['semester']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .assignment_turned_in_outlined,
                          size: 16,
                          color: attendance >= 75
                              ? Colors.green
                              : Colors.orange,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '$attendance% Attendance',
                          style: TextStyle(
                            color: attendance >= 75
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            status,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSemesterFilter(
    String semester,
  ) {
    final selected =
        _selectedSemester == semester;

    final label = semester == 'All'
        ? 'All'
        : 'Sem $semester';

    return ChoiceChip(
      label: Text(label),
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
          'Department Students',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              14,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search student or roll number',
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();

                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),

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
              ],
            ),
          ),

          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'No students found',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'BCA Students',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '${students.length} Students',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ...students.map(
                        _buildStudentCard,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}