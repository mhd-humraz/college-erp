import 'package:flutter/material.dart';
import '../utils/theme.dart';  // ✅ correct

class CourseManagement extends StatefulWidget {
  const CourseManagement({super.key});
  @override
  State<CourseManagement> createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDept = 'BCA';

  final List<String> _depts = ['BCA', 'BBA', 'BCom', 'Physics', 'Chemistry', 'Maths'];

  final Map<String, List<Map<String, dynamic>>> _subjects = {
    'BCA': [
      {'name': 'C Programming', 'code': 'BCA101', 'credits': 4, 'semester': 1, 'teacher': 'Prof. Rao', 'type': 'Core'},
      {'name': 'Digital Systems', 'code': 'BCA102', 'credits': 3, 'semester': 1, 'teacher': 'Dr. Meena', 'type': 'Core'},
      {'name': 'Data Structures', 'code': 'BCA201', 'credits': 4, 'semester': 2, 'teacher': 'Prof. Kumar', 'type': 'Core'},
      {'name': 'Web Technologies', 'code': 'BCA202', 'credits': 3, 'semester': 2, 'teacher': 'Dr. Arun', 'type': 'Core'},
      {'name': 'Database Systems', 'code': 'BCA301', 'credits': 4, 'semester': 3, 'teacher': 'Prof. Nair', 'type': 'Core'},
      {'name': 'Python Prog.', 'code': 'BCA302E', 'credits': 3, 'semester': 3, 'teacher': 'Dr. Patel', 'type': 'Elective'},
    ],
    'BBA': [
      {'name': 'Principles of Mgmt', 'code': 'BBA101', 'credits': 4, 'semester': 1, 'teacher': 'Prof. Das', 'type': 'Core'},
      {'name': 'Business Economics', 'code': 'BBA102', 'credits': 3, 'semester': 1, 'teacher': 'Dr. Verma', 'type': 'Core'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentSubjects => _subjects[_selectedDept] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Course Management', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.text),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Subjects'), Tab(text: 'Academic Year')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddSubjectSheet(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubjectsTab(),
          _buildAcademicYearTab(),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    Map<int, List<Map<String, dynamic>>> bySemester = {};
    for (var s in _currentSubjects) {
      int sem = s['semester'];
      bySemester.putIfAbsent(sem, () => []).add(s);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _depts.length,
              itemBuilder: (_, i) {
                final d = _depts[i];
                final selected = _selectedDept == d;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDept = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(d, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: bySemester.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text('Semester ${entry.key}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        Text('${entry.value.length} subjects', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  ...entry.value.map((s) => _buildSubjectTile(s)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectTile(Map<String, dynamic> s) {
    final isElective = s['type'] == 'Elective';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: isElective ? Border.all(color: const Color(0xFFFF9800).withOpacity(0.4)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isElective ? const Color(0xFFFF9800).withOpacity(0.15) : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isElective ? Icons.star_rounded : Icons.book_rounded,
              color: isElective ? const Color(0xFFFF9800) : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(s['name'], style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14))),
                    if (isElective)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Elective', style: TextStyle(color: Color(0xFFFF9800), fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${s['code']} • ${s['credits']} Credits', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Faculty: ${s['teacher']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.card,
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: AppColors.text))),
              const PopupMenuItem(value: 'assign', child: Text('Assign Teacher', style: TextStyle(color: AppColors.text))),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicYearTab() {
    final years = [
      {'year': '2024–25', 'status': 'Current', 'semesters': 2, 'start': 'Jun 2024', 'end': 'Apr 2025'},
      {'year': '2023–24', 'status': 'Completed', 'semesters': 2, 'start': 'Jun 2023', 'end': 'Apr 2024'},
      {'year': '2022–23', 'status': 'Completed', 'semesters': 2, 'start': 'Jun 2022', 'end': 'Apr 2023'},
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Academic Year', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('2024 – 2025', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        ...years.map((y) {
          final isCurrent = y['status'] == 'Current';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(y['year'] as String, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('${y['start']} → ${y['end']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(y['status'] as String, style: TextStyle(color: isCurrent ? AppColors.primary : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAddSubjectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Subject', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _field('Subject Name', Icons.book_rounded),
            const SizedBox(height: 12),
            _field('Subject Code', Icons.tag_rounded),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field('Credits', Icons.star_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _field('Semester', Icons.looks_one_rounded)),
            ]),
            const SizedBox(height: 12),
            _field('Assign Faculty', Icons.person_rounded),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Add Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon) {
    return TextField(
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}