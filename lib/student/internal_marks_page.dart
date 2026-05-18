// internal_mark_page.dart

import 'package:flutter/material.dart';
import 'student_dashboard.dart';

void main() {
  runApp(const MyApp());
}

/// MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Internal Marks",
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const InternalMarkPage(),
    );
  }
}

/// INTERNAL MARK PAGE
class InternalMarkPage extends StatelessWidget {
  const InternalMarkPage({super.key});

  @override
  Widget build(BuildContext context) {

    /// COLORS
    final Color primary = const Color(0xFF222831);
    final Color secondary = const Color(0xFF393E46);
    final Color accent = const Color(0xFF00ADB5);
    final Color light = const Color(0xFFEEEEEE);

    double width =
        MediaQuery.of(context).size.width;

    bool isMobile = width < 800;

    /// MARK VALUES
    double terminalExam = 40;
    double monthlyActivity = 18;
    double projectSubmission = 20;
    double noteSubmission = 17;

    double totalInternal =
        terminalExam +
        monthlyActivity +
        projectSubmission +
        noteSubmission;

    return Scaffold(
      backgroundColor: primary,

      body: SafeArea(
        child: SingleChildScrollView(

          padding:
              EdgeInsets.all(isMobile ? 15 : 30),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// TOP BAR
              Row(
                children: [

                  /// BACK BUTTON
                  InkWell(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StudentDashboard(),
                        ),
                      );
                    },

                    child: Container(
                      padding:
                          const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: secondary,

                        borderRadius:
                            BorderRadius.circular(
                                14),
                      ),

                      child: Icon(
                        Icons.arrow_back,
                        color: light,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  /// PAGE TITLE
                  Text(
                    "Internal Marks",

                    style: TextStyle(
                      color: light,
                      fontSize:
                          isMobile ? 24 : 30,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// TOTAL MARK CARD
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(28),

                  gradient: LinearGradient(
                    colors: [
                      accent,
                      secondary,
                    ],
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Total Internal Score",

                      style: TextStyle(
                        color: light,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "${totalInternal.toInt()} / 100",

                      style: TextStyle(
                        color: light,
                        fontSize: 40,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Based on exams, activities and submissions.",

                      style: TextStyle(
                        color:
                            light.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// RESPONSIVE SECTION
              isMobile

                  ? Column(
                      children: [

                        markCard(
                          "Terminal Exam",
                          terminalExam,
                          "/40",
                          accent,
                          light,
                          secondary,
                        ),

                        const SizedBox(height: 18),

                        markCard(
                          "Monthly Activity",
                          monthlyActivity,
                          "/20",
                          accent,
                          light,
                          secondary,
                        ),

                        const SizedBox(height: 18),

                        markCard(
                          "Project Submission",
                          projectSubmission,
                          "/20",
                          accent,
                          light,
                          secondary,
                        ),

                        const SizedBox(height: 18),

                        markCard(
                          "Note Submission",
                          noteSubmission,
                          "/20",
                          accent,
                          light,
                          secondary,
                        ),
                      ],
                    )

                  : Row(
                      children: [

                        Expanded(
                          child: markCard(
                            "Terminal Exam",
                            terminalExam,
                            "/40",
                            accent,
                            light,
                            secondary,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: markCard(
                            "Monthly Activity",
                            monthlyActivity,
                            "/20",
                            accent,
                            light,
                            secondary,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: markCard(
                            "Project Submission",
                            projectSubmission,
                            "/20",
                            accent,
                            light,
                            secondary,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: markCard(
                            "Note Submission",
                            noteSubmission,
                            "/20",
                            accent,
                            light,
                            secondary,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 35),

              /// GRAPH TITLE
              Text(
                "Internal Mark Analysis",

                style: TextStyle(
                  color: light,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              /// GRAPH CARD
              Container(
                width: double.infinity,
                height: 350,

                padding:
                    const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: secondary,

                  borderRadius:
                      BorderRadius.circular(28),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Performance Graph",

                      style: TextStyle(
                        color: light,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,

                        children: [

                          graphBar(
                            terminalExam * 4,
                            "Exam",
                            accent,
                            light,
                          ),

                          graphBar(
                            monthlyActivity * 7,
                            "Activity",
                            accent,
                            light,
                          ),

                          graphBar(
                            projectSubmission * 7,
                            "Project",
                            accent,
                            light,
                          ),

                          graphBar(
                            noteSubmission * 7,
                            "Notes",
                            accent,
                            light,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MARK CARD
  Widget markCard(
    String title,
    double mark,
    String total,
    Color accent,
    Color light,
    Color secondary,
  ) {

    return Container(
      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: secondary,

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            Icons.analytics,
            color: accent,
            size: 32,
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: TextStyle(
              color: light,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "${mark.toInt()} $total",

            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// GRAPH BAR
  Widget graphBar(
    double height,
    String label,
    Color accent,
    Color light,
  ) {

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.end,

      children: [

        Container(
          width: 45,
          height: height,

          decoration: BoxDecoration(
            color: accent,

            borderRadius:
                BorderRadius.circular(14),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          label,

          style: TextStyle(
            color: light,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

