import 'package:flutter/material.dart';

class FacultyManagementScreen extends StatefulWidget {
  const FacultyManagementScreen({super.key});

  @override
  State<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends State<FacultyManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _facultyMembers = [
    {
      'name': 'Rajina',
      'employeeId': 'EMP001',
      'email': 'teacher1@edusphere.edu',
      'designation': 'Assistant Professor',
      'status': 'Active',
      'subjects': [
        'Programming in C',
        'Data Structures',
      ],
    },
    {
      'name': 'Aneesh Kumar',
      'employeeId': 'EMP002',
      'email': 'aneesh@edusphere.edu',
      'designation': 'Assistant Professor',
      'status': 'Active',
      'subjects': [
        'Database Management',
      ],
    },
    {
      'name': 'Fathima N',
      'employeeId': 'EMP003',
      'email': 'fathima@edusphere.edu',
      'designation': 'Guest Lecturer',
      'status': 'On Leave',
      'subjects': [
        'Web Technology',
      ],
    },
    {
      'name': 'Rahul Menon',
      'employeeId': 'EMP004',
      'email': 'rahul@edusphere.edu',
      'designation': 'Associate Professor',
      'status': 'Active',
      'subjects': [
        'Computer Networks',
        'Operating Systems',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<Map<String, dynamic>>
      get _filteredFaculty {
    final search =
        _searchController.text.trim().toLowerCase();

    return _facultyMembers.where((faculty) {
      final name =
          faculty['name'].toString().toLowerCase();

      final employeeId = faculty['employeeId']
          .toString()
          .toLowerCase();

      final matchesSearch =
          name.contains(search) ||
              employeeId.contains(search);

      final matchesFilter =
          _selectedFilter == 'All' ||
              faculty['status'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;

      case 'On Leave':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  void _showFacultyDetails(
    Map<String, dynamic> faculty,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final subjects =
            faculty['subjects'] as List<dynamic>;

        final status =
            faculty['status'].toString();

        final statusColor =
            _statusColor(status);

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
                    radius: 42,
                    backgroundColor:
                        Colors.deepPurple.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      faculty['name']
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
                    faculty['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    faculty['designation'],
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
                  Icons.badge_outlined,
                  'Employee ID',
                  faculty['employeeId'],
                ),

                _buildDetailRow(
                  Icons.email_outlined,
                  'Email',
                  faculty['email'],
                ),

                _buildDetailRow(
                  Icons.apartment_outlined,
                  'Department',
                  'Computer Applications',
                ),

                const SizedBox(height: 20),

                const Text(
                  'Assigned Subjects',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subjects.map((subject) {
                    return Chip(
                      avatar: const Icon(
                        Icons.menu_book_outlined,
                        size: 17,
                      ),
                      label: Text(
                        subject.toString(),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(
                            this.context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Faculty timetable frontend is next',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                        ),
                        label: const Text(
                          'Timetable',
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          _toggleFacultyStatus(
                            faculty,
                          );
                        },
                        icon: Icon(
                          status == 'Active'
                              ? Icons.block_outlined
                              : Icons
                                  .check_circle_outline,
                        ),
                        label: Text(
                          status == 'Active'
                              ? 'Set Leave'
                              : 'Set Active',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFacultyStatus(
    Map<String, dynamic> faculty,
  ) {
    setState(() {
      faculty['status'] =
          faculty['status'] == 'Active'
              ? 'On Leave'
              : 'Active';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${faculty['name']} status updated',
        ),
      ),
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
              color: Colors.deepPurple.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
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

  Widget _buildFacultyCard(
    Map<String, dynamic> faculty,
  ) {
    final subjects =
        faculty['subjects'] as List<dynamic>;

    final status = faculty['status'].toString();

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
          _showFacultyDetails(faculty);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Colors.deepPurple.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  faculty['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            faculty['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                statusColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      faculty['designation'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${faculty['employeeId']} • ${subjects.length} Subjects',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

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
    final faculty = _filteredFaculty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Faculty Management',
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
                        'Search faculty or employee ID',
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
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('On Leave'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: faculty.isEmpty
                ? const Center(
                    child: Text(
                      'No faculty members found',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Department Faculty',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '${faculty.length} Members',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ...faculty.map(
                        _buildFacultyCard,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final selected =
        _selectedFilter == filter;

    return ChoiceChip(
      label: Text(filter),
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
          _selectedFilter = filter;
        });
      },
    );
  }
}