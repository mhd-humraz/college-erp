import 'package:flutter/material.dart';

class TimetableApprovalScreen extends StatefulWidget {
  const TimetableApprovalScreen({super.key});

  @override
  State<TimetableApprovalScreen> createState() =>
      _TimetableApprovalScreenState();
}

class _TimetableApprovalScreenState
    extends State<TimetableApprovalScreen> {
  String _selectedFilter = 'Pending';

  final List<Map<String, dynamic>> _timetables = [
    {
      'id': 'TT001',
      'title': 'BCA Semester 1 Timetable',
      'semester': 1,
      'course': 'BCA',
      'submittedBy': 'Rajina',
      'submittedDate': '12 Jul 2026',
      'status': 'Pending',
      'schedule': [
        {
          'day': 'Monday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Programming in C',
              'faculty': 'Rajina',
            },
            {
              'hour': 2,
              'subject': 'Mathematics',
              'faculty': 'Aneesh Kumar',
            },
            {
              'hour': 3,
              'subject': 'Digital Electronics',
              'faculty': 'Fathima N',
            },
          ],
        },
        {
          'day': 'Tuesday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Data Structures',
              'faculty': 'Rajina',
            },
            {
              'hour': 2,
              'subject': 'Mathematics',
              'faculty': 'Aneesh Kumar',
            },
            {
              'hour': 3,
              'subject': 'Programming Lab',
              'faculty': 'Rajina',
            },
          ],
        },
        {
          'day': 'Wednesday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Digital Electronics',
              'faculty': 'Fathima N',
            },
            {
              'hour': 2,
              'subject': 'Programming in C',
              'faculty': 'Rajina',
            },
          ],
        },
      ],
    },
    {
      'id': 'TT002',
      'title': 'BCA Semester 3 Timetable',
      'semester': 3,
      'course': 'BCA',
      'submittedBy': 'Rahul Menon',
      'submittedDate': '10 Jul 2026',
      'status': 'Approved',
      'schedule': [
        {
          'day': 'Monday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Database Management',
              'faculty': 'Aneesh Kumar',
            },
            {
              'hour': 2,
              'subject': 'Computer Networks',
              'faculty': 'Rahul Menon',
            },
          ],
        },
        {
          'day': 'Tuesday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Web Technology',
              'faculty': 'Fathima N',
            },
            {
              'hour': 2,
              'subject': 'Database Lab',
              'faculty': 'Aneesh Kumar',
            },
          ],
        },
      ],
    },
    {
      'id': 'TT003',
      'title': 'BCA Semester 5 Timetable',
      'semester': 5,
      'course': 'BCA',
      'submittedBy': 'Aneesh Kumar',
      'submittedDate': '09 Jul 2026',
      'status': 'Rejected',
      'schedule': [
        {
          'day': 'Monday',
          'periods': [
            {
              'hour': 1,
              'subject': 'Machine Learning',
              'faculty': 'Aneesh Kumar',
            },
            {
              'hour': 2,
              'subject': 'Cloud Computing',
              'faculty': 'Rahul Menon',
            },
          ],
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredTimetables {
    if (_selectedFilter == 'All') {
      return _timetables;
    }

    return _timetables.where((timetable) {
      return timetable['status'] == _selectedFilter;
    }).toList();
  }

  int _statusCount(String status) {
    return _timetables.where((timetable) {
      return timetable['status'] == status;
    }).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;

      case 'Rejected':
        return Colors.red;

      case 'Pending':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_outline;

      case 'Rejected':
        return Icons.cancel_outlined;

      case 'Pending':
        return Icons.pending_actions_outlined;

      default:
        return Icons.schedule_outlined;
    }
  }

  void _updateTimetableStatus(
    Map<String, dynamic> timetable,
    String status,
  ) {
    setState(() {
      timetable['status'] = status;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${timetable['title']} $status',
        ),
      ),
    );
  }

  void _showRejectDialog(
    Map<String, dynamic> timetable,
  ) {
    final reasonController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Timetable',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a reason for rejecting this timetable.',
              ),

              const SizedBox(height: 15),

              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Example: Faculty hour conflict...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (reasonController.text
                    .trim()
                    .isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter rejection reason',
                      ),
                    ),
                  );

                  return;
                }

                timetable['rejectionReason'] =
                    reasonController.text.trim();

                Navigator.pop(dialogContext);

                _updateTimetableStatus(
                  timetable,
                  'Rejected',
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    ).whenComplete(
      reasonController.dispose,
    );
  }

  void _showTimetableDetails(
    Map<String, dynamic> timetable,
  ) {
    final schedule =
        timetable['schedule'] as List<dynamic>;

    final status =
        timetable['status'].toString();

    final statusColor =
        _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (
            context,
            scrollController,
          ) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                30,
              ),
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _statusIcon(status),
                        color: statusColor,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            timetable['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${timetable['course']} • Semester ${timetable['semester']}',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submitted by',
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),

                            Text(
                              timetable['submittedBy'],
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        timetable['submittedDate'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                ...schedule.map((daySchedule) {
                  return _buildDaySchedule(
                    daySchedule,
                  );
                }),

                if (timetable['rejectionReason'] !=
                    null) ...[
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rejection Reason',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                timetable[
                                    'rejectionReason'],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (status == 'Pending') ...[
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                Colors.red,
                            minimumSize:
                                const Size.fromHeight(
                              50,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              bottomSheetContext,
                            );

                            _showRejectDialog(
                              timetable,
                            );
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                          label: const Text(
                            'Reject',
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green,
                            foregroundColor:
                                Colors.white,
                            minimumSize:
                                const Size.fromHeight(
                              50,
                            ),
                          ),
                          onPressed: () {
                            _updateTimetableStatus(
                              timetable,
                              'Approved',
                            );
                          },
                          icon: const Icon(
                            Icons.check,
                          ),
                          label: const Text(
                            'Approve',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDaySchedule(
    Map<String, dynamic> daySchedule,
  ) {
    final periods =
        daySchedule['periods'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              daySchedule['day'],
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          ...periods.map((period) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                13,
                16,
                13,
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${period['hour']}',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          period['subject'],
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          period['faculty'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'Hour ${period['hour']}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(
    Map<String, dynamic> timetable,
  ) {
    final status =
        timetable['status'].toString();

    final statusColor =
        _statusColor(status);

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
          _showTimetableDetails(timetable);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  _statusIcon(status),
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      timetable['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Submitted by ${timetable['submittedBy']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildFilterChip(
    String filter,
  ) {
    final selected =
        _selectedFilter == filter;

    return ChoiceChip(
      label: Text(
        filter == 'Pending'
            ? 'Pending (${_statusCount('Pending')})'
            : filter,
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
          _selectedFilter = filter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetables =
        _filteredTimetables;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Timetable Approval',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected'),
                  const SizedBox(width: 8),
                  _buildFilterChip('All'),
                ],
              ),
            ),
          ),

          Expanded(
            child: timetables.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .calendar_month_outlined,
                          size: 55,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'No timetable requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Department Timetables',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '${timetables.length} Requests',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      ...timetables.map(
                        _buildTimetableCard,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}