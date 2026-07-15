import 'package:flutter/material.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() =>
      _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState
    extends State<LeaveApprovalScreen> {
  String _selectedFilter = 'Pending';

  final List<Map<String, dynamic>> _leaveRequests = [
    {
      'id': 'LV001',
      'faculty': 'Rajina',
      'employeeId': 'EMP001',
      'designation': 'Assistant Professor',
      'leaveType': 'Casual Leave',
      'fromDate': '15 Jul 2026',
      'toDate': '16 Jul 2026',
      'days': 2,
      'reason': 'Personal family requirement.',
      'appliedDate': '12 Jul 2026',
      'status': 'Pending',
      'affectedClasses': [
        {
          'subject': 'Programming in C',
          'semester': 1,
          'hour': 1,
        },
        {
          'subject': 'Data Structures',
          'semester': 1,
          'hour': 2,
        },
      ],
    },
    {
      'id': 'LV002',
      'faculty': 'Fathima N',
      'employeeId': 'EMP003',
      'designation': 'Guest Lecturer',
      'leaveType': 'Medical Leave',
      'fromDate': '10 Jul 2026',
      'toDate': '12 Jul 2026',
      'days': 3,
      'reason': 'Medical consultation and recovery.',
      'appliedDate': '09 Jul 2026',
      'status': 'Approved',
      'affectedClasses': [
        {
          'subject': 'Web Technology',
          'semester': 3,
          'hour': 3,
        },
      ],
    },
    {
      'id': 'LV003',
      'faculty': 'Aneesh Kumar',
      'employeeId': 'EMP002',
      'designation': 'Assistant Professor',
      'leaveType': 'Duty Leave',
      'fromDate': '20 Jul 2026',
      'toDate': '20 Jul 2026',
      'days': 1,
      'reason':
          'Participation in university academic workshop.',
      'appliedDate': '11 Jul 2026',
      'status': 'Pending',
      'affectedClasses': [
        {
          'subject': 'Database Management',
          'semester': 3,
          'hour': 1,
        },
        {
          'subject': 'Database Lab',
          'semester': 3,
          'hour': 4,
        },
      ],
    },
    {
      'id': 'LV004',
      'faculty': 'Rahul Menon',
      'employeeId': 'EMP004',
      'designation': 'Associate Professor',
      'leaveType': 'Casual Leave',
      'fromDate': '08 Jul 2026',
      'toDate': '08 Jul 2026',
      'days': 1,
      'reason': 'Personal requirement.',
      'appliedDate': '07 Jul 2026',
      'status': 'Rejected',
      'rejectionReason':
          'Department review meeting scheduled on the same day.',
      'affectedClasses': [
        {
          'subject': 'Computer Networks',
          'semester': 3,
          'hour': 2,
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedFilter == 'All') {
      return _leaveRequests;
    }

    return _leaveRequests.where((request) {
      return request['status'] == _selectedFilter;
    }).toList();
  }

  int _statusCount(String status) {
    return _leaveRequests.where((request) {
      return request['status'] == status;
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
        return Icons.event_note_outlined;
    }
  }

  void _approveRequest(
    Map<String, dynamic> request,
  ) {
    setState(() {
      request['status'] = 'Approved';
      request.remove('rejectionReason');
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${request['faculty']} leave approved',
        ),
      ),
    );
  }

  void _showRejectDialog(
    Map<String, dynamic> request,
  ) {
    final reasonController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Leave Request',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Add a rejection reason for ${request['faculty']}.',
              ),

              const SizedBox(height: 15),

              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Example: Faculty availability required...',
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
                final reason =
                    reasonController.text.trim();

                if (reason.isEmpty) {
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

                setState(() {
                  request['status'] = 'Rejected';
                  request['rejectionReason'] =
                      reason;
                });

                Navigator.pop(dialogContext);
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${request['faculty']} leave rejected',
                    ),
                  ),
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

  void _showLeaveDetails(
    Map<String, dynamic> request,
  ) {
    final status =
        request['status'].toString();

    final statusColor =
        _statusColor(status);

    final affectedClasses =
        request['affectedClasses'] as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
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
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Colors.deepPurple.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        request['faculty']
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 22,
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
                            request['faculty'],
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${request['employeeId']} • ${request['designation']}',
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

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(status),
                            color: statusColor,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Text(
                      request['leaveType'],
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildLeaveDateCard(request),

                const SizedBox(height: 20),

                const Text(
                  'Leave Reason',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Text(
                    request['reason'],
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Affected Classes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
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
                        '${affectedClasses.length} Classes',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (affectedClasses.isEmpty)
                  const Text(
                    'No scheduled classes affected',
                  )
                else
                  ...affectedClasses.map(
                    _buildAffectedClassCard,
                  ),

                if (request['rejectionReason'] !=
                    null) ...[
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
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

                              const SizedBox(height: 5),

                              Text(
                                request[
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
                  const SizedBox(height: 26),

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
                            _showRejectDialog(
                              request,
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
                            _approveRequest(
                              request,
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

  Widget _buildLeaveDateCard(
    Map<String, dynamic> request,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(
          alpha: 0.07,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.date_range_outlined,
            color: Colors.deepPurple,
            size: 28,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${request['fromDate']} → ${request['toDate']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${request['days']} Leave Day${request['days'] == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
                'Applied',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                request['appliedDate'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAffectedClassCard(
    dynamic classData,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${classData['hour']}',
                style: const TextStyle(
                  color: Colors.orange,
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
                  classData['subject'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Semester ${classData['semester']} • Hour ${classData['hour']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(
    Map<String, dynamic> request,
  ) {
    final status =
        request['status'].toString();

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
          _showLeaveDetails(request);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    statusColor.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  request['faculty']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
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
                      request['faculty'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      request['leaveType'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${request['fromDate']} • ${request['days']} Day${request['days'] == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
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

    String label = filter;

    if (filter == 'Pending') {
      label =
          'Pending (${_statusCount('Pending')})';
    }

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
          _selectedFilter = filter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Leave Approval',
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
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 58,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'No leave requests',
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
                              'Faculty Leave Requests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '${requests.length} Requests',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      ...requests.map(
                        _buildLeaveCard,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}