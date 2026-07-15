import 'package:flutter/material.dart';

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() =>
      _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState
    extends State<StudyMaterialsScreen> {
  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _selectedSubject = 'Programming in C';
  String _selectedType = 'Notes';

  String? _selectedFileName;

  bool _uploading = false;

  final List<Map<String, dynamic>> _materials = [
    {
      'title': 'C Programming Unit 1',
      'subject': 'Programming in C',
      'type': 'Notes',
      'file': 'c_unit_1.pdf',
    },
    {
      'title': 'Important C Questions',
      'subject': 'Programming in C',
      'type': 'Question Paper',
      'file': 'c_questions.pdf',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _selectFile() {
    setState(() {
      _selectedFileName = 'selected_material.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File picker backend integration will be connected later.',
        ),
      ),
    );
  }

  Future<void> _uploadMaterial() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter material title',
          ),
        ),
      );

      return;
    }

    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a file',
          ),
        ),
      );

      return;
    }

    setState(() {
      _uploading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _materials.insert(
        0,
        {
          'title': title,
          'subject': _selectedSubject,
          'type': _selectedType,
          'file': _selectedFileName,
        },
      );

      _titleController.clear();
      _descriptionController.clear();

      _selectedFileName = null;
      _uploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Material added to frontend preview',
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'Video':
        return Icons.play_circle_outline;

      case 'Question Paper':
        return Icons.quiz_outlined;

      case 'Assignment':
        return Icons.assignment_outlined;

      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Materials',
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Upload Learning Resource',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Share notes and academic resources with students.',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 24),

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
            onChanged: _uploading
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedSubject = value;
                    });
                  },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              labelText: 'Material Type',
              prefixIcon: const Icon(
                Icons.category_outlined,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Notes',
                child: Text('Notes'),
              ),
              DropdownMenuItem(
                value: 'Assignment',
                child: Text('Assignment'),
              ),
              DropdownMenuItem(
                value: 'Question Paper',
                child: Text('Question Paper'),
              ),
              DropdownMenuItem(
                value: 'Video',
                child: Text('Video'),
              ),
            ],
            onChanged: _uploading
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedType = value;
                    });
                  },
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _titleController,
            enabled: !_uploading,
            decoration: InputDecoration(
              labelText: 'Material Title',
              prefixIcon: const Icon(
                Icons.title,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            enabled: !_uploading,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap:
                _uploading ? null : _selectFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.upload_file_outlined,
                    size: 34,
                    color: Colors.teal,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ??
                              'Choose Material File',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _selectedFileName == null
                              ? 'PDF, DOC, PPT or other resource'
                              : 'File ready for upload',
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
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
            onPressed:
                _uploading ? null : _uploadMaterial,
            icon: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.cloud_upload_outlined,
                  ),
            label: Text(
              _uploading
                  ? 'Uploading...'
                  : 'Upload Material',
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Materials',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${_materials.length} Resources',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ..._materials.map(
            (material) {
              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.teal.shade50,
                    child: Icon(
                      _getMaterialIcon(
                        material['type'],
                      ),
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(
                    material['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${material['subject']} • ${material['type']}\n${material['file']}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        setState(() {
                          _materials.remove(
                            material,
                          );
                        });
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}