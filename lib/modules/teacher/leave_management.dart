import 'package:flutter/material.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState
    extends State<LeaveManagementScreen> {
  String _selectedFilter = 'Pending';

  final List<Map<String, dynamic>> _leaveRequests = [
    {
      'id': 'LEAVE001',
      'studentName': 'Muhammed Humraz',
      'rollNumber': 'BCA001',
      'leaveType': 'Medical Leave',
      'fromDate': '14 Jul 2026',
      'toDate': '15 Jul 2026',
      'days': 2,
      'reason': 'Fever and doctor advised rest for two days.',
      'status': 'Pending',
    },
    {
      'id': 'LEAVE002',
      'studentName': 'Arya',
      'rollNumber': 'BCA002',
      'leaveType': 'Personal Leave',
      'fromDate': '10 Jul 2026',
      'toDate': '10 Jul 2026',
      'days': 1,
      'reason': 'Family function at home.',
      'status': 'Approved',
    },
    {
      'id': 'LEAVE003',
      'studentName': 'Rahul',
      'rollNumber': 'BCA003',
      'leaveType': 'Other',
      'fromDate': '08 Jul 2026',
      'toDate': '09 Jul 2026',
      'days': 2,
      'reason': 'Personal travel requirement.',
      'status': 'Rejected',
    },
  ];

  List<Map<String, dynamic>> get _filteredRequests {
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

      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_outline;

      case 'Rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.schedule_outlined;
    }
  }

  Future<void> _updateLeaveStatus(
    Map<String, dynamic> request,
    String newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final color = _statusColor(newStatus);

        return AlertDialog(
          title: Text(
            '$newStatus Leave Request?',
          ),
          content: Text(
            'Do you want to ${newStatus.toLowerCase()} '
            '${request['studentName']}\'s leave request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(newStatus),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      request['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Leave request $newStatus',
        ),
      ),
    );
  }

  void _showLeaveDetails(
    Map<String, dynamic> request,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        final status =
            request['status'].toString();

        final color = _statusColor(status);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Colors.teal.shade50,
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['studentName'],
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            request['rollNumber'],
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  Icons.category_outlined,
                  'Leave Type',
                  request['leaveType'],
                ),
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  'Duration',
                  '${request['fromDate']} - ${request['toDate']}',
                ),
                _buildDetailRow(
                  Icons.timelapse_outlined,
                  'Total Days',
                  '${request['days']} Days',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Reason',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    request['reason'],
                  ),
                ),
                if (status == 'Pending') ...[
                  const SizedBox(height: 24),
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
                              48,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              bottomSheetContext,
                            );

                            _updateLeaveStatus(
                              request,
                              'Rejected',
                            );
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                          label:
                              const Text('Reject'),
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
                              48,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              bottomSheetContext,
                            );

                            _updateLeaveStatus(
                              request,
                              'Approved',
                            );
                          },
                          icon: const Icon(
                            Icons.check,
                          ),
                          label:
                              const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: Colors.teal,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Management',
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              10,
            ),
            child: Row(
              children: [
                _buildSummaryCard(
                  'Pending',
                  _statusCount('Pending'),
                  Icons.schedule_outlined,
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard(
                  'Approved',
                  _statusCount('Approved'),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard(
                  'Rejected',
                  _statusCount('Rejected'),
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              scrollDirection: Axis.horizontal,
              children: [
                'Pending',
                'Approved',
                'Rejected',
              ].map((filter) {
                final selected =
                    _selectedFilter == filter;

                return Padding(
                  padding:
                      const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '$filter (${_statusCount(filter)})',
                    ),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .event_available_outlined,
                          size: 55,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No $_selectedFilter leave requests',
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request =
                          requests[index];

                      final status =
                          request['status'].toString();

                      final color =
                          _statusColor(status);

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(12),
                          onTap: () {
                            _showLeaveDetails(
                              request,
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Colors
                                              .teal.shade50,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            request[
                                                'studentName'],
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            request[
                                                'rollNumber'],
                                            style: TextStyle(
                                              color: Colors
                                                  .grey
                                                  .shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      _statusIcon(status),
                                      color: color,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  request['leaveType'],
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${request['fromDate']} - ${request['toDate']}',
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: color
                                            .withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${request['days']} Days',
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}