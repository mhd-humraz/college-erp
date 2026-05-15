import 'package:flutter/material.dart';

// IMPORT DASHBOARD PAGE
import 'student_dashboard.dart';

void main() {
  runApp(const MyApp());
}

// ═══════════════════════════════════════════════════════════════
// MAIN APP
// ═══════════════════════════════════════════════════════════════

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignments',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF222831),
      ),
      home: const AssignmentPage(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════

class Assignment {
  String title;
  String subject;
  String description;
  String date;
  String time;
  bool submitted;

  Assignment({
    required this.title,
    required this.subject,
    required this.description,
    required this.date,
    required this.time,
    this.submitted = true,
  });
}

// ═══════════════════════════════════════════════════════════════
// ASSIGNMENT PAGE
// ═══════════════════════════════════════════════════════════════

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() =>
      _AssignmentPageState();
}

class _AssignmentPageState
    extends State<AssignmentPage> {

  final List<Assignment> assignments = [

    Assignment(
      title: "Data Structure Assignment",
      subject: "Computer Science",
      description:
          "Implement Stack using Linked List.",
      date: "15 May 2026",
      time: "10:30 AM",
    ),

    Assignment(
      title: "DBMS Record",
      subject: "Database Management",
      description:
          "Normalization and ER Diagram.",
      date: "14 May 2026",
      time: "04:15 PM",
    ),
  ];

  // CONTROLLERS

  final TextEditingController
      titleController =
      TextEditingController();

  final TextEditingController
      subjectController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  // ═══════════════════════════════════════════════════════════════
  // ADD ASSIGNMENT
  // ═══════════════════════════════════════════════════════════════

  void addAssignment() {

    if (titleController.text.isEmpty ||
        subjectController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      return;
    }

    final now = DateTime.now();

    setState(() {

      assignments.insert(
        0,

        Assignment(
          title: titleController.text,
          subject:
              subjectController.text,
          description:
              descriptionController.text,

          date:
              "${now.day}-${now.month}-${now.year}",

          time:
              "${now.hour}:${now.minute}",
        ),
      );
    });

    titleController.clear();
    subjectController.clear();
    descriptionController.clear();

    Navigator.pop(context);
  }

  // ═══════════════════════════════════════════════════════════════
  // DELETE ASSIGNMENT
  // ═══════════════════════════════════════════════════════════════

  void deleteAssignment(int index) {

    setState(() {
      assignments.removeAt(index);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // EDIT ASSIGNMENT
  // ═══════════════════════════════════════════════════════════════

  void editAssignment(int index) {

    titleController.text =
        assignments[index].title;

    subjectController.text =
        assignments[index].subject;

    descriptionController.text =
        assignments[index].description;

    showModalBottomSheet(

      context: context,

      backgroundColor:
          const Color(0xFF393E46),

      isScrollControlled: true,

      builder: (context) {

        return Padding(

          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,

            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),

          child: SingleChildScrollView(
            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const HeadingText(
                  "Edit Assignment",
                  fontSize: 20,
                ),

                const SizedBox(height: 20),

                customField(
                  "Assignment Title",
                  titleController,
                ),

                const SizedBox(height: 15),

                customField(
                  "Subject",
                  subjectController,
                ),

                const SizedBox(height: 15),

                customField(
                  "Description",
                  descriptionController,
                  maxLines: 4,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF00ADB5),

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                    ),

                    onPressed: () {

                      setState(() {

                        assignments[index]
                                .title =
                            titleController
                                .text;

                        assignments[index]
                                .subject =
                            subjectController
                                .text;

                        assignments[index]
                                .description =
                            descriptionController
                                .text;
                      });

                      Navigator.pop(
                          context);
                    },

                    child: const Text(
                      "Save Changes",

                      style: TextStyle(
                        fontFamily:
                            'Poppins',

                        fontWeight:
                            FontWeight.w600,

                        color: Color(
                            0xFF222831),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD SHEET
  // ═══════════════════════════════════════════════════════════════

  void showAddAssignmentSheet() {

    titleController.clear();
    subjectController.clear();
    descriptionController.clear();

    showModalBottomSheet(

      context: context,

      backgroundColor:
          const Color(0xFF393E46),

      isScrollControlled: true,

      builder: (context) {

        return Padding(

          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,

            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),

          child: SingleChildScrollView(
            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const HeadingText(
                  "Upload Assignment",
                  fontSize: 20,
                ),

                const SizedBox(height: 20),

                customField(
                  "Assignment Title",
                  titleController,
                ),

                const SizedBox(height: 15),

                customField(
                  "Subject",
                  subjectController,
                ),

                const SizedBox(height: 15),

                customField(
                  "Description",
                  descriptionController,
                  maxLines: 4,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF00ADB5),

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                    ),

                    onPressed:
                        addAssignment,

                    child: const Text(
                      "Submit Assignment",

                      style: TextStyle(
                        fontFamily:
                            'Poppins',

                        fontWeight:
                            FontWeight.w600,

                        color: Color(
                            0xFF222831),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UI
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF222831),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFF00ADB5),

        onPressed:
            showAddAssignmentSheet,

        child: const Icon(
          Icons.add,
          color: Color(0xFF222831),
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(16),

          child: Column(
            children: [

              // HEADER

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  // BACK BUTTON

                  GestureDetector(

                    onTap: () {

                      Navigator.pushReplacement(

                        context,

                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const StudentDashboard(),
                        ),
                      );
                    },

                    child: Container(

                      width: 42,
                      height: 42,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFF393E46),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                      ),

                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,

                        color: Color(
                            0xFFEEEEEE),

                        size: 18,
                      ),
                    ),
                  ),

                  const HeadingText(
                    "Assignments",
                    fontSize: 20,
                  ),

                  Container(

                    width: 42,
                    height: 42,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFF393E46),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),

                    child: const Icon(
                      Icons
                          .assignment_outlined,

                      color:
                          Color(0xFF00ADB5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SUMMARY CARDS

              Row(
                children: [

                  Expanded(
                    child: summaryCard(
                      "Total",
                      assignments.length
                          .toString(),

                      Icons
                          .library_books_outlined,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: summaryCard(

                      "Submitted",

                      assignments
                          .where(
                              (e) =>
                                  e.submitted)
                          .length
                          .toString(),

                      Icons
                          .check_circle_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ASSIGNMENT LIST

              Expanded(

                child:
                    assignments.isEmpty

                        ? const Center(
                            child:
                                BodyText(
                              "No Assignments Uploaded",

                              color: Color(
                                  0x99EEEEEE),
                            ),
                          )

                        : ListView.builder(

                            itemCount:
                                assignments
                                    .length,

                            itemBuilder:
                                (context,
                                    index) {

                              final item =
                                  assignments[
                                      index];

                              return Container(

                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 16,
                                ),

                                padding:
                                    const EdgeInsets
                                        .all(18),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                          0xFF393E46),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              18),

                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                            0x2200ADB5),
                                  ),
                                ),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Row(
                                      children: [

                                        Expanded(
                                          child:
                                              DashboardTitle(
                                            item
                                                .title,

                                            fontSize:
                                                16,
                                          ),
                                        ),

                                        PopupMenuButton(

                                          color:
                                              const Color(
                                                  0xFF393E46),

                                          icon:
                                              const Icon(
                                            Icons
                                                .more_vert,

                                            color:
                                                Color(
                                                    0xFFEEEEEE),
                                          ),

                                          itemBuilder:
                                              (context) =>
                                                  [

                                            const PopupMenuItem(
                                              value:
                                                  "edit",

                                              child:
                                                  Text(
                                                "Edit",
                                              ),
                                            ),

                                            const PopupMenuItem(
                                              value:
                                                  "delete",

                                              child:
                                                  Text(
                                                "Delete",
                                              ),
                                            ),
                                          ],

                                          onSelected:
                                              (
                                            value,
                                          ) {

                                            if (value ==
                                                "edit") {
                                              editAssignment(
                                                  index);
                                            }

                                            if (value ==
                                                "delete") {
                                              deleteAssignment(
                                                  index);
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 8),

                                    SmallLabel(
                                      item.subject,

                                      color:
                                          const Color(
                                              0xFF00ADB5),
                                    ),

                                    const SizedBox(
                                        height: 12),

                                    BodyText(
                                      item
                                          .description,

                                      fontSize:
                                          13,

                                      color:
                                          const Color(
                                              0xCCEEEEEE),
                                    ),

                                    const SizedBox(
                                        height: 18),

                                    Row(
                                      children: [

                                        const Icon(
                                          Icons
                                              .calendar_today_outlined,

                                          size: 15,

                                          color:
                                              Color(
                                                  0xFF00ADB5),
                                        ),

                                        const SizedBox(
                                            width:
                                                6),

                                        SmallLabel(
                                          item.date,
                                          fontSize:
                                              11,
                                        ),

                                        const SizedBox(
                                            width:
                                                18),

                                        const Icon(
                                          Icons
                                              .access_time_outlined,

                                          size: 15,

                                          color:
                                              Color(
                                                  0xFF00ADB5),
                                        ),

                                        const SizedBox(
                                            width:
                                                6),

                                        SmallLabel(
                                          item.time,
                                          fontSize:
                                              11,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            const Color(0xFF393E46),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color:
                const Color(0xFF00ADB5),
            size: 26,
          ),

          const SizedBox(height: 10),

          DashboardTitle(
            value,
            fontSize: 20,
          ),

          const SizedBox(height: 4),

          SmallLabel(
            title,

            color:
                const Color(0x99EEEEEE),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TEXT FIELD
  // ═══════════════════════════════════════════════════════════════

  Widget customField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {

    return TextField(

      controller: controller,
      maxLines: maxLines,

      style: const TextStyle(
        color: Color(0xFFEEEEEE),
        fontFamily: 'Poppins',
      ),

      decoration: InputDecoration(

        hintText: hint,

        hintStyle: const TextStyle(
          color: Color(0x88EEEEEE),
          fontFamily: 'Poppins',
        ),

        filled: true,

        fillColor:
            const Color(0xFF222831),

        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
                  14),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TEXT WIDGETS
// ═══════════════════════════════════════════════════════════════

class HeadingText extends StatelessWidget {

  final String text;
  final double fontSize;

  const HeadingText(
    this.text, {
    super.key,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      text,

      style: TextStyle(
        fontFamily: 'Poppins',

        fontWeight:
            FontWeight.w600,

        fontSize: fontSize,

        color:
            const Color(0xFFEEEEEE),
      ),
    );
  }
}

class DashboardTitle extends StatelessWidget {

  final String text;
  final double fontSize;

  const DashboardTitle(
    this.text, {
    super.key,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      text,

      style: TextStyle(
        fontFamily: 'Poppins',

        fontWeight:
            FontWeight.w700,

        fontSize: fontSize,

        color:
            const Color(0xFFEEEEEE),
      ),
    );
  }
}

class BodyText extends StatelessWidget {

  final String text;
  final double fontSize;
  final Color? color;

  const BodyText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      text,

      style: TextStyle(
        fontFamily: 'Poppins',

        fontWeight:
            FontWeight.w400,

        fontSize: fontSize,

        color: color ??
            const Color(0xFFEEEEEE),
      ),
    );
  }
}

class SmallLabel extends StatelessWidget {

  final String text;
  final double fontSize;
  final Color? color;

  const SmallLabel(
    this.text, {
    super.key,
    this.fontSize = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      text,

      style: TextStyle(
        fontFamily: 'Poppins',

        fontWeight:
            FontWeight.w500,

        fontSize: fontSize,

        color: color ??
            const Color(0xFFEEEEEE),
      ),
    );
  }
}