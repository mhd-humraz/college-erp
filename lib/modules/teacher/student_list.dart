import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';

import 'attendance_entry.dart';
import 'marks_entry.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}

class _StudentListScreenState
    extends State<StudentListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final token = auth.token;

      if (token != null && token.isNotEmpty) {
        Provider.of<TeacherProvider>(
          context,
          listen: false,
        ).loadStudents(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider =
        context.watch<TeacherProvider>();

    final students = teacherProvider.students;

    final filteredStudents = students.where((student) {
      final name =
          (student['name'] ?? '').toString().toLowerCase();

      final rollNumber =
          (student['rollNumber'] ?? '')
              .toString()
              .toLowerCase();

      final query = searchText.toLowerCase();

      return name.contains(query) ||
          rollNumber.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: teacherProvider.studentsLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final auth = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );

                if (auth.token != null) {
                  await Provider.of<TeacherProvider>(
                    context,
                    listen: false,
                  ).loadStudents(auth.token!);
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search name or roll number',
                        prefixIcon:
                            const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? const Center(
                            child: Text(
                              'No students found',
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            itemCount:
                                filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student =
                                  filteredStudents[index];

                              final name =
                                  student['name'] ??
                                      'Unknown Student';

                              final rollNumber =
                                  student['rollNumber'] ??
                                      'N/A';

                              final semester =
                                  student['semester'] ??
                                      'N/A';

                              final course =
                                  student['course'] ??
                                      'N/A';

                              final department =
                                  student['department'] ??
                                      'N/A';

                              return Card(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundColor:
                                                Colors.teal,
                                            foregroundColor:
                                                Colors.white,
                                            child: Icon(
                                              Icons.person,
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
                                                  name,
                                                  style:
                                                      const TextStyle(
                                                    fontSize:
                                                        17,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                Text(
                                                  rollNumber,
                                                  style:
                                                      TextStyle(
                                                    color: Colors
                                                        .grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Semester : $semester',
                                      ),
                                      Text(
                                        'Course : $course',
                                      ),
                                      Text(
                                        'Department : $department',
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child:
                                                ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const AttendanceEntryScreen(),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .assignment_turned_in_outlined,
                                              ),
                                              label: const Text(
                                                'Attendance',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child:
                                                ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        MarksEntryScreen(
                                                      subjectId:
                                                          '',
                                                      students: [
                                                        {
                                                          'studentId':
                                                              student[
                                                                  'studentId'],
                                                          'name':
                                                              name,
                                                        },
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .grade_outlined,
                                              ),
                                              label: const Text(
                                                'Marks',
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
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}