import 'package:flutter/material.dart';

class BatchManagementScreen extends StatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  State<BatchManagementScreen> createState() =>
      _BatchManagementScreenState();
}

class _BatchManagementScreenState
    extends State<BatchManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> batches = [
    {
      "batchName": "2024 - 2027",
      "course": "BCA",
      "semester": 5,
      "students": 62,
      "status": "Active",
    },
    {
      "batchName": "2025 - 2028",
      "course": "BSc CS",
      "semester": 3,
      "students": 54,
      "status": "Active",
    },
    {
      "batchName": "2022 - 2025",
      "course": "BCom",
      "semester": 6,
      "students": 0,
      "status": "Completed",
    },
  ];
  void _showBatchDetails(
    Map<String, dynamic> batch,
  ) {
    final bool active =
        batch["status"] == "Active";

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
                  Icons.groups,
                  size: 35,
                  color: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                batch["batchName"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                batch["course"],
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              _detailTile(
                Icons.school,
                "Course",
                batch["course"],
              ),

              _detailTile(
                Icons.menu_book,
                "Semester",
                "${batch["semester"]}",
              ),

              _detailTile(
                Icons.people,
                "Students",
                "${batch["students"]}",
              ),

              _detailTile(
                active
                    ? Icons.check_circle
                    : Icons.flag,
                "Status",
                batch["status"],
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
                            content:
                                Text("Edit Batch - Next"),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_upward),
                      label:
                          const Text("Promote"),
                      onPressed: () {

                        Navigator.pop(context);

                        setState(() {

                          if (batch["semester"] < 6) {
                            batch["semester"]++;
                          }

                        });

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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.people,
                  ),
                  label:
                      const Text("View Students"),
                  onPressed: () {

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text("Student List - Next"),
                      ),
                    );

                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.delete,
                  ),
                  label:
                      const Text("Delete Batch"),
                  onPressed: () {

                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title:
                              const Text("Delete"),
                          content: Text(
                            "Delete ${batch["batchName"]} ?",
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
                                  batches.remove(batch);
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
    final filtered = batches.where((batch) {
      return batch["batchName"]
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          batch["course"]
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Management"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Add Batch - Coming Next"),
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
                hintText: "Search Batch",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                    batches.length.toString(),
                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Active",
                    batches
                        .where((e) => e["status"] == "Active")
                        .length
                        .toString(),
                    Colors.green,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Completed",
                    batches
                        .where((e) => e["status"] == "Completed")
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
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final batch = filtered[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.redAccent.withOpacity(.15),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.redAccent,
                        ),
                      ),

                      title: Text(
                        batch["batchName"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Course : ${batch["course"]}",
                          ),
                          Text(
                            "Semester : ${batch["semester"]}",
                          ),
                          Text(
                            "Students : ${batch["students"]}",
                          ),
                        ],
                      ),

                      trailing: Chip(
                        label: Text(
                          batch["status"],
                        ),
                        backgroundColor:
                            batch["status"] == "Active"
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                      ),

                      onTap: () {
                        _showBatchDetails(batch);
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
      Color color) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          children: [

            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
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