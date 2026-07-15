import 'package:flutter/material.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState
    extends State<SubjectManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> subjects = [
    {
      "name": "Programming in C",
      "code": "BCA101",
      "department": "Computer Applications",
      "semester": 1,
      "credits": 4,
      "teacher": "Rajina",
      "status": "Active",
    },
    {
      "name": "Database Management System",
      "code": "BCA201",
      "department": "Computer Applications",
      "semester": 2,
      "credits": 4,
      "teacher": "Anjali",
      "status": "Active",
    },
    {
      "name": "Computer Networks",
      "code": "BCA301",
      "department": "Computer Applications",
      "semester": 3,
      "credits": 3,
      "teacher": "Rahul",
      "status": "Inactive",
    },
  ];
void _showSubjectDetails(
  Map<String, dynamic> subject,
) {
  final bool active =
      subject["status"] == "Active";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            CircleAvatar(
              radius: 42,
              backgroundColor:
                  Colors.redAccent.withOpacity(.15),
              child: const Icon(
                Icons.menu_book,
                color: Colors.redAccent,
                size: 35,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              subject["name"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              subject["code"],
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            _detailTile(
              Icons.business,
              "Department",
              subject["department"],
            ),

            _detailTile(
              Icons.school,
              "Semester",
              "${subject["semester"]}",
            ),

            _detailTile(
              Icons.star,
              "Credits",
              "${subject["credits"]}",
            ),

            _detailTile(
              Icons.person,
              "Teacher",
              subject["teacher"],
            ),

            _detailTile(
              active
                  ? Icons.check_circle
                  : Icons.cancel,
              "Status",
              subject["status"],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Edit Subject - Next",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label:
                        const Text("Teacher"),
                    onPressed: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Change Teacher - Next",
                          ),
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete),
                label:
                    const Text("Delete Subject"),
                onPressed: () {

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title:
                            const Text("Delete"),
                        content: Text(
                          "Delete ${subject["name"]} ?",
                        ),
                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:
                                const Text("Cancel"),
                          ),

                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red,
                            ),
                            onPressed: () {

                              setState(() {
                                subjects.remove(subject);
                              });

                              Navigator.pop(context);

                            },
                            child:
                                const Text("Delete"),
                          ),

                        ],
                      );
                    },
                  );

                },
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      );
    },
  );
}
Widget _detailTile(
  IconData icon,
  String title,
  String value,
) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor:
          Colors.redAccent.withOpacity(.12),
      child: Icon(
        icon,
        color: Colors.redAccent,
      ),
    ),
    title: Text(title),
    subtitle: Text(value),
  );
}
  @override
  Widget build(BuildContext context) {
    final filteredSubjects = subjects.where((subject) {
      return subject["name"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              ) ||
          subject["code"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject Management"),
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
                "Add Subject - Coming Next",
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
                hintText: "Search Subject",
                prefixIcon: const Icon(Icons.search),
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

Row(
  children: [

    Expanded(
      child: _statCard(
        "Total",
        subjects.length.toString(),
        Colors.blue,
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: _statCard(
        "Active",
        subjects
            .where((e) => e["status"] == "Active")
            .length
            .toString(),
        Colors.green,
      ),
    ),

    const SizedBox(width: 10),

    Expanded(
      child: _statCard(
        "Inactive",
        subjects
            .where((e) => e["status"] != "Active")
            .length
            .toString(),
        Colors.orange,
      ),
    ),

  ],
),

const SizedBox(height: 20),
 


            Expanded(
              child: ListView.builder(
                itemCount: filteredSubjects.length,
                itemBuilder: (_, index) {

                  final subject =
                      filteredSubjects[index];

                  final active =
                      subject["status"] == "Active";

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
                    child: ListTile(

                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.redAccent
                                .withOpacity(.15),
                        child: const Icon(
                          Icons.menu_book,
                          color:
                              Colors.redAccent,
                        ),
                      ),

                      title: Text(
                        subject["name"],
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            "Code : ${subject["code"]}",
                          ),

                          Text(
                            "Department : ${subject["department"]}",
                          ),

                          Text(
                            "Semester : ${subject["semester"]}",
                          ),

                          Text(
                            "Credits : ${subject["credits"]}",
                          ),

                          Text(
                            "Teacher : ${subject["teacher"]}",
                          ),

                        ],
                      ),

                      trailing: Chip(
                        label: Text(
                          subject["status"],
                        ),
                        backgroundColor:
                            active
                                ? Colors.green
                                    .shade100
                                : Colors.orange
                                    .shade100,
                      ),

                      onTap: () {
                        _showSubjectDetails(subject);
                      },
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
  Widget _statCard(
  String title,
  String value,
  Color color,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    ),
  );
}
}