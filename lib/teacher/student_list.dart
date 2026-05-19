import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/students');
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      setState(() {
        students = data is List ? data : [];
        filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void searchStudent(String value) {
    setState(() {
      filteredStudents = students.where((student) => (student['name'] ?? '').toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Student List", style: TextStyle(color: AppColors.text))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: searchController, onChanged: searchStudent, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Search Student", hintStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.search, color: AppColors.primary), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filteredStudents.isEmpty 
                      ? Center(child: Text("No students found", style: TextStyle(color: AppColors.text.withOpacity(0.5))))
                      : ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final s = filteredStudents[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Text((s['name'] ?? 'S')[0], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 16),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['name'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(s['studentId'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 4), Text(s['department'] ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 14))])),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 18)),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}