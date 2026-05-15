import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class AssignmentUploadPage extends StatefulWidget {
  const AssignmentUploadPage({super.key});

  @override
  State<AssignmentUploadPage> createState() =>
      _AssignmentUploadPageState();
}

class _AssignmentUploadPageState
    extends State<AssignmentUploadPage> {

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  List<Map<String, String>> assignments = [
    {
      "subject": "Mathematics",
      "title": "Algebra Assignment",
      "description":
          "Complete problems from Chapter 5.",
    },

    {
      "subject": "Physics",
      "title": "Lab Report",
      "description":
          "Submit optics experiment report.",
    },
  ];

  void uploadAssignment() {
    if (subjectController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {

      setState(() {
        assignments.insert(0, {
          "subject": subjectController.text,
          "title": titleController.text,
          "description":
              descriptionController.text,
        });
      });

      subjectController.clear();
      titleController.clear();
      descriptionController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Assignment Uploaded",
          ),
        ),
      );
    }
  }

  void showUploadDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,

          title: const Text(
            "Upload Assignment",

            style: TextStyle(
              color: AppColors.text,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(
                  controller: subjectController,

                  style: const TextStyle(
                    color: AppColors.text,
                  ),

                  decoration: InputDecoration(
                    hintText: "Subject",

                    hintStyle:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                    filled: true,
                    fillColor:
                        AppColors.background,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: titleController,

                  style: const TextStyle(
                    color: AppColors.text,
                  ),

                  decoration: InputDecoration(
                    hintText: "Assignment Title",

                    hintStyle:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                    filled: true,
                    fillColor:
                        AppColors.background,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller:
                      descriptionController,

                  maxLines: 4,

                  style: const TextStyle(
                    color: AppColors.text,
                  ),

                  decoration: InputDecoration(
                    hintText:
                        "Assignment Description",

                    hintStyle:
                        const TextStyle(
                      color: Colors.grey,
                    ),

                    filled: true,
                    fillColor:
                        AppColors.background,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
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

              child: const Text(
                "Cancel",

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
              ),

              onPressed: uploadAssignment,

              child: const Text(
                "Upload",

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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
        backgroundColor:
            AppColors.background,

        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Assignment Upload",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          itemCount: assignments.length,

          itemBuilder: (context, index) {

            return Container(
              margin:
                  const EdgeInsets.only(
                      bottom: 16),

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: AppColors.card,

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      const Icon(
                        Icons.assignment,
                        color:
                            AppColors.primary,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          assignments[index]
                              ["title"]!,

                          style:
                              const TextStyle(
                            color:
                                AppColors.text,
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    assignments[index]
                        ["subject"]!,

                    style: const TextStyle(
                      color:
                          AppColors.primary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    assignments[index]
                        ["description"]!,

                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            AppColors.primary,

        child: const Icon(Icons.add),

        onPressed: showUploadDialog,
      ),
    );
  }
}