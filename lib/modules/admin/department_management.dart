import 'package:flutter/material.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() =>
      _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState
    extends State<DepartmentManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> departments = [
    {
      "name": "Computer Applications",
      "code": "BCA",
      "hod": "Rajina",
      "faculty": 18,
      "students": 240,
      "status": "Active",
    },
    {
      "name": "Computer Science",
      "code": "CS",
      "hod": "Ameena",
      "faculty": 15,
      "students": 180,
      "status": "Active",
    },
    {
      "name": "Commerce",
      "code": "BCom",
      "hod": "Rahul",
      "faculty": 20,
      "students": 300,
      "status": "Inactive",
    },
  ];
  void _departmentDialog({
    Map<String, dynamic>? department,
  }) {
    final nameController = TextEditingController(
      text: department?["name"] ?? "",
    );

    final codeController = TextEditingController(
      text: department?["code"] ?? "",
    );

    final hodController = TextEditingController(
      text: department?["hod"] ?? "",
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            department == null
                ? "Add Department"
                : "Edit Department",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Department Name",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Department Code",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: hodController,
                  decoration: const InputDecoration(
                    labelText: "HOD Name",
                  ),
                ),

              ],
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {

                setState(() {

                  if (department == null) {

                    departments.add({
                      "name": nameController.text,
                      "code": codeController.text,
                      "hod": hodController.text,
                      "faculty": 0,
                      "students": 0,
                      "status": "Active",
                    });

                  } else {

                    department["name"] =
                        nameController.text;

                    department["code"] =
                        codeController.text;

                    department["hod"] =
                        hodController.text;

                  }

                });

                Navigator.pop(context);

              },
              child: Text(
                department == null
                    ? "Add"
                    : "Save",
              ),
            ),

          ],
        );
      },
    );
  }
  void _showDepartmentDetails(
    Map<String, dynamic> dept,
  ) {
    final bool active =
        dept["status"] == "Active";

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
                child: Text(
                  dept["code"],
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                dept["name"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                dept["code"],
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              _detailTile(
                Icons.person,
                "Head of Department",
                dept["hod"],
              ),

              _detailTile(
                Icons.badge_outlined,
                "Faculty Members",
                "${dept["faculty"]}",
              ),

              _detailTile(
                Icons.school_outlined,
                "Students",
                "${dept["students"]}",
              ),

              _detailTile(
                active
                    ? Icons.check_circle
                    : Icons.cancel,
                "Status",
                dept["status"],
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

                        _departmentDialog(
                          department: dept,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.swap_horiz,
                      ),
                      label: const Text(
                        "Change HOD",
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        final controller = TextEditingController(
                          text: dept["hod"],
                        );

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("Assign HOD"),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: "HOD Name",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      dept["hod"] = controller.text;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
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
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    "Delete Department",
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text("Delete Department"),
                          content: Text(
                            "Delete ${dept["name"]}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  departments.remove(dept);
                                });

                                Navigator.pop(context);
                              },
                              child: const Text("Delete"),
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
    final filteredDepartments = departments.where((dept) {
      return dept["name"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              ) ||
          dept["code"]
              .toLowerCase()
              .contains(
                _searchController.text.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Department Management"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          _departmentDialog();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Department",
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

            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredDepartments.length,
                itemBuilder: (_, index) {
                  final dept =
                      filteredDepartments[index];

                  final active =
                      dept["status"] == "Active";

                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.only(
                      bottom: 15,
                    ),
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
                        _showDepartmentDetails(dept);
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
                                    dept["code"],
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
                                        dept["name"],
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
                                        dept["code"],
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .grey,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        10,
                                    vertical: 6,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: active
                                        ? Colors
                                            .green
                                            .withOpacity(
                                                .15)
                                        : Colors
                                            .red
                                            .withOpacity(
                                                .15),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),
                                  child: Text(
                                    dept[
                                        "status"],
                                    style:
                                        TextStyle(
                                      color: active
                                          ? Colors
                                              .green
                                          : Colors
                                              .red,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            const Divider(
                                height: 30),

                            Row(
                              children: [

                                const Icon(
                                  Icons
                                      .person_outline,
                                  size: 20,
                                  color: Colors
                                      .blue,
                                ),

                                const SizedBox(
                                    width: 8),

                                Text(
                                  "HOD : ${dept["hod"]}",
                                ),

                              ],
                            ),

                            const SizedBox(
                                height: 10),

                            Row(
                              children: [

                                Expanded(
                                  child: Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .badge_outlined,
                                        color: Colors
                                            .teal,
                                      ),

                                      const SizedBox(
                                          width:
                                              8),

                                      Text(
                                        "${dept["faculty"]} Faculty",
                                      ),

                                    ],
                                  ),
                                ),

                                Expanded(
                                  child: Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .school_outlined,
                                        color: Colors
                                            .orange,
                                      ),

                                      const SizedBox(
                                          width:
                                              8),

                                      Text(
                                        "${dept["students"]} Students",
                                      ),

                                    ],
                                  ),
                                ),

                              ],
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