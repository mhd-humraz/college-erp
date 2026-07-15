import 'package:flutter/material.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState
    extends State<CourseManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> courses = [
    {
      "name": "Bachelor of Computer Applications",
      "code": "BCA",
      "duration": "3 Years",
      "semesters": 6,
      "department": "Computer Applications",
      "students": 240,
      "status": "Active",
    },
    {
      "name": "Bachelor of Science Computer Science",
      "code": "BSc CS",
      "duration": "3 Years",
      "semesters": 6,
      "department": "Computer Science",
      "students": 180,
      "status": "Active",
    },
    {
      "name": "Master of Business Administration",
      "code": "MBA",
      "duration": "2 Years",
      "semesters": 4,
      "department": "Management",
      "students": 90,
      "status": "Inactive",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCourses = courses.where((course) {
      return course["name"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              ) ||
          course["code"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Management"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Add Course - Coming Soon",
              ),
            ),
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Course",
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredCourses.length,
                itemBuilder: (_, index) {
                  final course =
                      filteredCourses[index];

                  final active =
                      course["status"] ==
                          "Active";

                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.only(
                            bottom: 15),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                    ),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                      onTap: () {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "${course["code"]} selected",
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Row(
                              children: [

                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      Colors
                                          .redAccent
                                          .withOpacity(
                                              .15),
                                  child: Text(
                                    course["code"],
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .redAccent,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [

                                      Text(
                                        course[
                                            "name"],
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      Text(
                                        course[
                                            "department"],
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                                Chip(
                                  backgroundColor:
                                      active
                                          ? Colors.green
                                              .shade100
                                          : Colors.red
                                              .shade100,
                                  label: Text(
                                    course[
                                        "status"],
                                    style:
                                        TextStyle(
                                      color: active
                                          ? Colors
                                              .green
                                          : Colors
                                              .red,
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            const Divider(
                                height: 30),

                            Row(
                              children: [

                                Expanded(
                                  child: ListTile(
                                    leading:
                                        const Icon(
                                      Icons
                                          .schedule,
                                      color: Colors
                                          .blue,
                                    ),
                                    title:
                                        const Text(
                                            "Duration"),
                                    subtitle: Text(
                                      course[
                                          "duration"],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: ListTile(
                                    leading:
                                        const Icon(
                                      Icons
                                          .menu_book,
                                      color: Colors
                                          .orange,
                                    ),
                                    title:
                                        const Text(
                                            "Semesters"),
                                    subtitle: Text(
                                      "${course["semesters"]}",
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            ListTile(
                              leading:
                                  const Icon(
                                Icons.people,
                                color: Colors.teal,
                              ),
                              title: const Text(
                                  "Students"),
                              subtitle: Text(
                                "${course["students"]}",
                              ),
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
      ),
    );
  }
}