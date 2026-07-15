import 'package:flutter/material.dart';

class DepartmentAnnouncementsScreen
    extends StatefulWidget {
  const DepartmentAnnouncementsScreen({
    super.key,
  });

  @override
  State<DepartmentAnnouncementsScreen>
      createState() =>
          _DepartmentAnnouncementsScreenState();
}

class _DepartmentAnnouncementsScreenState
    extends State<DepartmentAnnouncementsScreen> {
  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  String _selectedAudience = 'Everyone';

  bool _isUrgent = false;

  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Internal Examination Schedule',
      'message':
          'Internal examination timetable has been published. Students are requested to check the academic portal.',
      'audience': 'Students',
      'urgent': true,
      'date': '14 Jul 2026',
      'time': '10:30 AM',
    },
    {
      'title': 'Department Faculty Meeting',
      'message':
          'All faculty members are requested to attend the department meeting in Seminar Hall at 2:30 PM.',
      'audience': 'Faculty',
      'urgent': false,
      'date': '13 Jul 2026',
      'time': '04:15 PM',
    },
    {
      'title': 'Academic Project Exhibition',
      'message':
          'The BCA department project exhibition will be conducted next Friday. Students and faculty are invited.',
      'audience': 'Everyone',
      'urgent': false,
      'date': '11 Jul 2026',
      'time': '09:20 AM',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Color _audienceColor(String audience) {
    switch (audience) {
      case 'Students':
        return Colors.blue;

      case 'Faculty':
        return Colors.deepPurple;

      default:
        return Colors.green;
    }
  }

  IconData _audienceIcon(String audience) {
    switch (audience) {
      case 'Students':
        return Icons.school_outlined;

      case 'Faculty':
        return Icons.badge_outlined;

      default:
        return Icons.groups_outlined;
    }
  }

  void _clearForm() {
    _titleController.clear();
    _messageController.clear();

    setState(() {
      _selectedAudience = 'Everyone';
      _isUrgent = false;
    });
  }

  bool _validateAnnouncement() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter announcement title',
          ),
        ),
      );

      return false;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter announcement message',
          ),
        ),
      );

      return false;
    }

    return true;
  }

  void _previewAnnouncement() {
    if (!_validateAnnouncement()) {
      return;
    }

    final title = _titleController.text.trim();

    final message = _messageController.text.trim();

    final audienceColor =
        _audienceColor(_selectedAudience);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 5,
            bottom:
                MediaQuery.of(bottomSheetContext)
                        .viewInsets
                        .bottom +
                    30,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Announcement Preview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Review before publishing',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: _isUrgent
                          ? Colors.red.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _isUrgent
                                  ? Colors.red.withValues(
                                      alpha: 0.12,
                                    )
                                  : audienceColor
                                      .withValues(
                                      alpha: 0.12,
                                    ),
                              borderRadius:
                                  BorderRadius.circular(
                                13,
                              ),
                            ),
                            child: Icon(
                              _isUrgent
                                  ? Icons
                                      .campaign_outlined
                                  : _audienceIcon(
                                      _selectedAudience,
                                    ),
                              color: _isUrgent
                                  ? Colors.red
                                  : audienceColor,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPreviewChip(
                            icon: _audienceIcon(
                              _selectedAudience,
                            ),
                            label: _selectedAudience,
                            color: audienceColor,
                          ),

                          if (_isUrgent)
                            _buildPreviewChip(
                              icon: Icons
                                  .priority_high_rounded,
                              label: 'Urgent',
                              color: Colors.red,
                            ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'BCA Department • HOD',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(
                            50,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            bottomSheetContext,
                          );
                        },
                        child: const Text('Edit'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size.fromHeight(
                            50,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(
                            bottomSheetContext,
                          );

                          _publishAnnouncement();
                        },
                        icon: const Icon(
                          Icons.send_outlined,
                        ),
                        label: const Text(
                          'Publish',
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

  void _publishAnnouncement() {
    final now = DateTime.now();

    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;

    final minute =
        now.minute.toString().padLeft(2, '0');

    final period =
        now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      _announcements.insert(
        0,
        {
          'title':
              _titleController.text.trim(),
          'message':
              _messageController.text.trim(),
          'audience': _selectedAudience,
          'urgent': _isUrgent,
          'date':
              '${now.day} Jul ${now.year}',
          'time': '$hour:$minute $period',
        },
      );
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Announcement published successfully',
        ),
      ),
    );
  }

  void _showAnnouncementDetails(
    Map<String, dynamic> announcement,
  ) {
    final audience =
        announcement['audience'].toString();

    final audienceColor =
        _audienceColor(audience);

    final urgent =
        announcement['urgent'] == true;

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
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: urgent
                        ? Colors.red.withValues(
                            alpha: 0.12,
                          )
                        : audienceColor.withValues(
                            alpha: 0.12,
                          ),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: Icon(
                    urgent
                        ? Icons.campaign_outlined
                        : _audienceIcon(audience),
                    color: urgent
                        ? Colors.red
                        : audienceColor,
                    size: 29,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  announcement['title'],
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPreviewChip(
                      icon: _audienceIcon(audience),
                      label: audience,
                      color: audienceColor,
                    ),

                    if (urgent)
                      _buildPreviewChip(
                        icon:
                            Icons.priority_high_rounded,
                        label: 'Urgent',
                        color: Colors.red,
                      ),
                  ],
                ),

                const SizedBox(height: 22),

                Text(
                  announcement['message'],
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 25),

                const Divider(),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'BCA Department • HOD',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          announcement['date'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          announcement['time'],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  Widget _buildPreviewChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),

          const SizedBox(width: 5),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceOption(
    String audience,
  ) {
    final selected =
        _selectedAudience == audience;

    final color =
        _audienceColor(audience);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _selectedAudience = audience;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(
                    alpha: 0.10,
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? color
                  : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _audienceIcon(audience),
                color: selected
                    ? color
                    : Colors.grey,
              ),

              const SizedBox(height: 7),

              Text(
                audience,
                style: TextStyle(
                  color: selected
                      ? color
                      : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    Map<String, dynamic> announcement,
  ) {
    final audience =
        announcement['audience'].toString();

    final audienceColor =
        _audienceColor(audience);

    final urgent =
        announcement['urgent'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: urgent
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showAnnouncementDetails(
            announcement,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: urgent
                      ? Colors.red.withValues(
                          alpha: 0.12,
                        )
                      : audienceColor.withValues(
                          alpha: 0.12,
                        ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  urgent
                      ? Icons.campaign_outlined
                      : _audienceIcon(audience),
                  color: urgent
                      ? Colors.red
                      : audienceColor,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement['title'],
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        if (urgent)
                          const Icon(
                            Icons.priority_high_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      announcement['message'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _buildPreviewChip(
                          icon: _audienceIcon(audience),
                          label: audience,
                          color: audienceColor,
                        ),

                        const Spacer(),

                        Text(
                          announcement['date'],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text(
          'Department Announcements',
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                      Icons.edit_notifications_outlined,
                      color: Colors.deepPurple,
                    ),

                    SizedBox(width: 10),

                    Text(
                      'Create Announcement',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Title',
                    hintText:
                        'Example: Internal Exam Schedule',
                    prefixIcon: Icon(
                      Icons.title,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText:
                        'Write the announcement message...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Select Audience',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 11),

                Row(
                  children: [
                    _buildAudienceOption(
                      'Students',
                    ),

                    const SizedBox(width: 9),

                    _buildAudienceOption(
                      'Faculty',
                    ),

                    const SizedBox(width: 9),

                    _buildAudienceOption(
                      'Everyone',
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Mark as Urgent',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Highlight this announcement for recipients',
                  ),
                  secondary: Icon(
                    Icons.priority_high_rounded,
                    color: _isUrgent
                        ? Colors.red
                        : Colors.grey,
                  ),
                  value: _isUrgent,
                  activeThumbColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      _isUrgent = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(
                            50,
                          ),
                        ),
                        onPressed: _clearForm,
                        child: const Text('Clear'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size.fromHeight(
                            50,
                          ),
                        ),
                        onPressed:
                            _previewAnnouncement,
                        icon: const Icon(
                          Icons.visibility_outlined,
                        ),
                        label: const Text(
                          'Preview',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sent Announcements',
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
                  color: Colors.deepPurple.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_announcements.length}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ..._announcements.map(
            _buildAnnouncementCard,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}