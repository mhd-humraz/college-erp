import 'package:flutter/material.dart';
import 'attendance_entry.dart';
import 'announcements.dart';
import 'assignment_upload.dart';
import 'leave_management.dart';
import 'marks_entry.dart';
import 'student_list.dart';
import 'study_materials.dart';
import 'timetable.dart';


void main() {
  runApp(const MyApp());
}

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor:
            AppColors.background,
        fontFamily: 'Poppins',
      ),

      home: const TeacherDashboard(),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    String today =
        DateTime.now().weekday == 1
            ? "Monday"
            : DateTime.now().weekday == 2
                ? "Tuesday"
                : DateTime.now().weekday == 3
                    ? "Wednesday"
                    : DateTime.now().weekday == 4
                        ? "Thursday"
                        : DateTime.now().weekday == 5
                            ? "Friday"
                            : DateTime.now().weekday == 6
                                ? "Saturday"
                                : "Sunday";

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Teacher Dashboard",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: AppColors.card,

        child: ListView(
          children: const [
            DrawerHeader(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  CircleAvatar(
                    radius: 35,

                    backgroundColor:
                        AppColors.primary,

                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Teacher Panel",

                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            DrawerItem(
              title: "Timetable",
              icon: Icons.calendar_month,
              page: const TimetablePage(),
            ),

            DrawerItem(
              title: "Attendance",
              icon: Icons.check_circle,
              page: const AttendanceEntry(),
            ),

            DrawerItem(
              title: "Assignments",
              icon: Icons.assignment,
                page: const AssignmentUploadPage(),

            ),

            DrawerItem(
              title: "Leave Letter",
              icon: Icons.edit_document,
              page: const LeaveManagementPage(),
            ),

            DrawerItem(
              title: "Mark Entry",
              icon: Icons.grade,
              page: const MarkEntryPage(),
            ),

            DrawerItem(
              title: "Study Materials",
              icon: Icons.menu_book,
              page: const StudyMaterialPage(),
            ),

            DrawerItem(
              title: "Student List",
              icon: Icons.people,
              page: const StudentListPage(),
            ),

            DrawerItem(
              title: "Announcements",
              icon: Icons.announcement,
              page: const AnnouncementsPage(),

            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              today,

              style: const TextStyle(
                color: AppColors.text,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Welcome Teacher 👋",

                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "This dashboard helps teachers manage attendance, assignments, timetable, leave letters, marks, study materials, and announcements easily. Open the side menu to access all features.",

                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    "Today's Tasks",

                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  TaskTile(
                    text:
                        "Upload today's assignment",
                  ),

                  TaskTile(
                    text:
                        "Complete attendance entry",
                  ),

                  TaskTile(
                    text:
                        "Update internal marks",
                  ),

                  TaskTile(
                    text:
                        "Check leave requests",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? page;

  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),

      title: Text(
        title,

        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
        ),
      ),

      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page!,
            ),
          );
        }
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  final String text;

  const TaskTile({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}