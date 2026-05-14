import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ApiService.get('/courses');
      setState(() { _courses = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _deleteCourse(String id) async {
    try {
      await ApiService.delete('/courses/$id');
      _fetchCourses();
      _showSnack('Course deleted');
    } catch (e) {
      _showSnack('Failed to delete course', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: isError ? Colors.redAccent : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showCourseDialog({dynamic course}) {
    final nameCtrl = TextEditingController(text: course?['name'] ?? '');
    final codeCtrl = TextEditingController(text: course?['code'] ?? '');
    final creditsCtrl = TextEditingController(text: course?['credits']?.toString() ?? '');
    final isEdit = course != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Course' : 'Add Course',
            style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Course Name', Icons.book_outlined),
            const SizedBox(height: 12),
            _dialogField(codeCtrl, 'Course Code', Icons.tag_rounded),
            const SizedBox(height: 12),
            _dialogField(creditsCtrl, 'Credits', Icons.star_outline_rounded, type: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(context);
              final body = {
                'name': nameCtrl.text.trim(),
                'code': codeCtrl.text.trim(),
                'credits': int.tryParse(creditsCtrl.text) ?? 0,
              };
              try {
                if (isEdit) {
                  await ApiService.put('/courses/${course['_id'] ?? course['id']}', body);
                  _showSnack('Course updated');
                } else {
                  await ApiService.post('/courses', body);
                  _showSnack('Course added');
                }
                _fetchCourses();
              } catch (e) {
                _showSnack('Operation failed', isError: true);
              }
            },
            child: Text(isEdit ? 'Update' : 'Add',
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Course Management',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), onPressed: _fetchCourses),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCourseDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? _buildError()
              : _courses.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _courses.length,
                      itemBuilder: (_, i) => _buildCourseCard(_courses[i]),
                    ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.book_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course['name'] ?? '',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              const SizedBox(height: 3),
              Text('Code: ${course['code'] ?? ''} · Credits: ${course['credits'] ?? ''}',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.text.withOpacity(0.45))),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            onPressed: () => _showCourseDialog(course: course),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _deleteCourse(course['_id'] ?? course['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.wifi_off_rounded, color: AppColors.text.withOpacity(0.3), size: 48),
    const SizedBox(height: 12),
    Text('Failed to load courses', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.5))),
    const SizedBox(height: 12),
    ElevatedButton(onPressed: _fetchCourses,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', color: Colors.white))),
  ]));

  Widget _buildEmpty() => Center(
    child: Text('No courses found', style: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.4))),
  );

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: type,
      style: const TextStyle(fontFamily: 'Poppins', color: AppColors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.text.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}