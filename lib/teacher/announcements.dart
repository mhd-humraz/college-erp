import 'package:flutter/material.dart';

 
import '../utils/theme.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() =>
      _AnnouncementsPageState();
}

class _AnnouncementsPageState
    extends State<AnnouncementsPage> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  List<Map<String, String>> announcements = [
    {
      "title": "Internal Exam",
      "message":
          "Internal examinations will begin next Monday.",
    },

    {
      "title": "Assignment Submission",
      "message":
          "Submit all pending assignments before Friday.",
    },
  ];

  void addAnnouncement() {
    if (titleController.text.isNotEmpty &&
        messageController.text.isNotEmpty) {

      setState(() {
        announcements.insert(0, {
          "title": titleController.text,
          "message": messageController.text,
        });
      });

      titleController.clear();
      messageController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Announcement Added"),
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
            "New Announcement",

            style: TextStyle(
              color: AppColors.text,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(
                  controller: titleController,

                  style: const TextStyle(
                    color: AppColors.text,
                  ),

                  decoration: InputDecoration(
                    hintText: "Title",

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
                  controller: messageController,

                  maxLines: 4,

                  style: const TextStyle(
                    color: AppColors.text,
                  ),

                  decoration: InputDecoration(
                    hintText: "Message",

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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
              ),

              onPressed: addAnnouncement,

              child: const Text(
                "Post",
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
          "Announcements",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          itemCount: announcements.length,

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
                        Icons.announcement,
                        color:
                            AppColors.primary,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          announcements[index]
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

                  const SizedBox(height: 15),

                  Text(
                    announcements[index]
                        ["message"]!,

                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
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

        onPressed: showAddDialog,
      ),
    );
  }
}