import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({super.key});

  @override
  State<StudyMaterialPage> createState() =>
      _StudyMaterialPageState();
}

class _StudyMaterialPageState
    extends State<StudyMaterialPage> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController linkController =
      TextEditingController();

  List<Map<String, String>> materials = [
    {
      "title": "Unit 1 Notes",
      "subject": "Mathematics",
      "link": "https://example.com/math1",
    },
    {
      "title": "Physics Formula Sheet",
      "subject": "Physics",
      "link": "https://example.com/physics",
    },
  ];

  void addMaterial() {
    if (titleController.text.isNotEmpty &&
        subjectController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {

      setState(() {
        materials.insert(0, {
          "title": titleController.text,
          "subject": subjectController.text,
          "link": linkController.text,
        });
      });

      titleController.clear();
      subjectController.clear();
      linkController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Study Material Added"),
        ),
      );
    }
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            "Add Study Material",
            style: TextStyle(color: AppColors.text),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: titleController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: subjectController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Subject",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: linkController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "File/Link URL",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: addMaterial,
              child: const Text("Add",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Study Materials",
          style: TextStyle(color: AppColors.text),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    materials[index]["title"]!,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    materials[index]["subject"]!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    materials[index]["link"]!,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: showAddDialog,
      ),
    );
  }
}