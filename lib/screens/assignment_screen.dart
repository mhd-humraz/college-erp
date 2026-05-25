import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _assignments = [];
  List<dynamic> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final role = context.read<AuthProvider>().role;
      
      if (role == 'student') {
        final assignRes = await ApiService.get('/assignments/my');
        final matRes = await ApiService.get('/assignments/materials');
        setState(() {
          _assignments = assignRes.data['data'] ?? [];
          _materials = matRes.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        final res = await ApiService.get('/assignments/my-assignments');
        setState(() {
          _assignments = res.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndSubmit(String assignmentId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      );

      if (result != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Assignment submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));

        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: (role == 'teacher' || role == 'class_teacher')
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              backgroundColor: AppColors.primary,
              icon: Icon(Icons.add),
              label: Text('New Assignment'),
            )
          : null,
      appBar: AppBar(
        title: Text(
          role == 'student' ? 'Assignments & Materials' : 'Manage Assignments',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: role == 'student' ? 'Pending' : 'All'),
            Tab(text: role == 'student' ? 'Submitted' : 'Materials'),
            if (role != 'student') Tab(text: 'Submissions'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAssignmentsList(isSubmitted: false),
                  role == 'student'
                      ? _buildAssignmentsList(isSubmitted: true)
                      : _buildMaterialsList(),
                  if (role != 'student') _buildSubmissionsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignmentsList({required bool isSubmitted}) {
    var filtered =
        _assignments.where((a) => isSubmitted ? a['submitted'] : !a['submitted']).toList();

    if (filtered.isEmpty) {
      return _emptyState(
        Icons.assignment_turned_in_outlined,
        isSubmitted ? 'No submitted assignments' : 'No pending assignments',
        "You're all caught up!",
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _assignmentCard(filtered[index]),
    );
  }

  Widget _assignmentCard(dynamic assignment) {
    final isOverdue = assignment['isOverdue'] ?? false;
    final daysLeft = assignment['daysLeft'] ?? 0;
    final dueDate = DateTime.tryParse(assignment['dueDate'] ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isOverdue ? AppColors.error.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child:
                      Icon(Icons.description_outlined, color: AppColors.info, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['title'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                            fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${assignment['subjectId']?['name'] ?? ''} • ${assignment['teacherId']?['name'] ?? ''}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (assignment['submitted'])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Submitted',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                else if (isOverdue)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                        SizedBox(width: 4),
                        Text(
                          'Overdue!',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 14),

            // Description
            if (assignment['description'] != null &&
                assignment['description'].toString().isNotEmpty) ...[
              Text(
                assignment['description'],
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
            ],

            // Due Date Bar
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16,
                          color: isOverdue ? AppColors.error : AppColors.warning),
                      SizedBox(width: 8),
                      Text(
                        dueDate != null
                            ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
                            : 'No due date',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  if (!assignment['submitted'])
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: daysLeft > 0
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        daysLeft > 0 ? '$daysLeft days left' : 'Due today',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: daysLeft > 0 ? AppColors.success : AppColors.error),
                      ),
                    ),
                ],
              ),
            ),

            // Submit Button for Students
            if (!assignment['submitted'] &&
                context.read<AuthProvider>().role == 'student') ...[
              SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _pickAndSubmit(assignment['_id']),
                  icon: Icon(Icons.upload_file, size: 18),
                  label: Text(
                    'Submit Assignment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Max Marks Info
            if (assignment['maxMarks'] != null) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Max Marks: ${assignment['maxMarks']}',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    if (_materials.isEmpty) {
      return _emptyState(
          Icons.folder_open, 'No study materials',
          "Your teachers haven't uploaded any materials yet");
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _materials.length,
      itemBuilder: (context, index) => _materialCard(_materials[index]),
    );
  }

  Widget _materialCard(dynamic material) {
    final fileSize = material['fileSize'] != null
        ? (material['fileSize'] / 1024 / 1024).toStringAsFixed(1)
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getFileColor(material['fileType']).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getFileIcon(material['fileType']),
                color: _getFileColor(material['fileType']), size: 26),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'] ?? material['fileName'] ?? 'Untitled',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      material['subjectId']?['name'] ?? '',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Spacer(),
                    if (fileSize.isNotEmpty)
                      Text('$fileSize MB',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    SizedBox(width: 8),
                    Text(
                      '${material['downloads'] ?? 0} downloads',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              icon: Icon(Icons.download, color: AppColors.primary),
              onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 60, color: AppColors.textSecondary.withOpacity(0.3)),
          SizedBox(height: 16),
          Text('Select an assignment to view submissions',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();
    final marksCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create New Assignment',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Title Field
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Assignment Title *',
                      prefixIcon: Icon(Icons.title),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Description Field
                  TextField(
                    controller: descCtrl,
                    style: TextStyle(color: AppColors.text),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Subject Field
                  TextField(
                    controller: subjectCtrl,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.book),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Due Date Field
                  TextField(
                    controller: dueDateCtrl,
                    style: TextStyle(color: AppColors.text),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        dueDateCtrl.text = date.toString().split(' ')[0];
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Due Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon:
                          Icon(Icons.calendar_month, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Max Marks Field
                  TextField(
                    controller: marksCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Max Marks',
                      prefixIcon: Icon(Icons.grade),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        );
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Assignment created!'),
                          backgroundColor: AppColors.success,
                        ));
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Create Assignment',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Color _getFileColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getFileIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                  color: AppColors.card, shape: BoxShape.circle),
              child: Icon(icon,
                  size: 42, color: AppColors.textSecondary.withOpacity(0.35)),
            ),
            SizedBox(height: 24),
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}