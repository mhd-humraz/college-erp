import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AssignmentUploadScreen extends StatefulWidget {
  const AssignmentUploadScreen({super.key});

  @override
  State<AssignmentUploadScreen> createState() =>
      _AssignmentUploadScreenState();
}

class _AssignmentUploadScreenState
    extends State<AssignmentUploadScreen> {
  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _selectedSubject = 'Programming in C';
  String _selectedSemester = 'Semester 1';

  DateTime _dueDate = DateTime.now().add(
    const Duration(days: 7),
  );

  String? _selectedFileName;

  final List<Map<String, dynamic>> _assignments = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDueDate(
    StateSetter setSheetState,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year + 2,
      ),
    );

    if (selectedDate == null) return;

    setState(() {
      _dueDate = selectedDate;
    });

    setSheetState(() {});
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(
          2,
          '0',
        );

    final month = date.month.toString().padLeft(
          2,
          '0',
        );

    return '$day/$month/${date.year}';
  }

  void _selectDemoFile(
    StateSetter setSheetState,
  ) {
    setSheetState(() {
      _selectedFileName =
          'programming_assignment.pdf';
    });
  }

  void _createAssignment(
    BuildContext bottomSheetContext,
  ) {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter assignment title',
          ),
        ),
      );

      return;
    }

    setState(() {
      _assignments.insert(
        0,
        {
          'title': title,
          'description':
              _descriptionController.text.trim(),
          'subject': _selectedSubject,
          'semester': _selectedSemester,
          'dueDate': _dueDate,
          'fileName': _selectedFileName,
        },
      );
    });

    _titleController.clear();
    _descriptionController.clear();
    _selectedFileName = null;

    Navigator.pop(bottomSheetContext);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Assignment published',
        ),
      ),
    );
  }

  void _deleteAssignment(
    Map<String, dynamic> assignment,
  ) {
    setState(() {
      _assignments.remove(assignment);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Assignment removed',
        ),
      ),
    );
  }

  void _showCreateAssignmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Assignment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Publish academic work for your students.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Assignment Title',
                        prefixIcon: const Icon(
                          Icons.assignment_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller:
                          _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        hintText:
                            'Explain the assignment task...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(
                          Icons.menu_book_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Programming in C',
                          child: Text(
                            'Programming in C',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          _selectedSubject = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedSemester,
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: List.generate(
                        6,
                        (index) {
                          final semester = index + 1;

                          return DropdownMenuItem(
                            value:
                                'Semester $semester',
                            child: Text(
                              'Semester $semester',
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          _selectedSemester = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () {
                        _selectDueDate(
                          setSheetState,
                        );
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: const Icon(
                            Icons
                                .calendar_today_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _formatDate(_dueDate),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () {
                        _selectDemoFile(
                          setSheetState,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _selectedFileName == null
                                  ? Icons
                                      .cloud_upload_outlined
                                  : Icons
                                      .description_outlined,
                              size: 38,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFileName ??
                                  'Select Assignment File',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedFileName == null
                                  ? 'PDF, DOC or ZIP'
                                  : 'File ready to upload',
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size.fromHeight(52),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _createAssignment(
                          bottomSheetContext,
                        );
                      },
                      icon: const Icon(
                        Icons.publish_outlined,
                      ),
                      label: const Text(
                        'Publish Assignment',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssignmentCard(
    Map<String, dynamic> assignment,
  ) {
    final dueDate =
        assignment['dueDate'] as DateTime;

    final fileName = assignment['fileName'];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['title'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment['subject'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteAssignment(
                        assignment,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete Assignment',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (assignment['description']
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                assignment['description'],
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.school_outlined,
                  assignment['semester'],
                ),
                _buildInfoChip(
                  Icons.calendar_today_outlined,
                  'Due ${_formatDate(dueDate)}',
                ),
              ],
            ),

            if (fileName != null) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.cloud_done_outlined,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: _showCreateAssignmentSheet,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: _assignments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        size: 45,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Assignments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and publish assignments for your students.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          _showCreateAssignmentSheet,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Create Assignment',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                100,
              ),
              children: [
                const Text(
                  'Published Assignments',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_assignments.length} assignments published',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 18),
                ..._assignments.map(
                  _buildAssignmentCard,
                ),
              ],
            ),
    );
  }
}