// exam_result_page.dart
import 'package:flutter/material.dart';

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
      title: "ERP Exam Result",
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const ExamResultPage(),
    );
  }
}

/// EXAM RESULT PAGE
class ExamResultPage extends StatelessWidget {
  const ExamResultPage({super.key});

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

                  /// BACK BUTTON (Updated to match your app style & pop correctly)
                  GestureDetector(
                    onTap: () {
                      // ✅ FIXED: Pops back to the already opened dashboard list
                      Navigator.pop(context);
                    },

                    child: Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFEEEEEE),
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  /// TITLE
                  Text(
                    "Exam Results",

                    style: TextStyle(
                      color: light,
                      fontSize:
                          isMobile ? 24 : 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// STUDENT INFO CARD
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: secondary,

                  borderRadius:
                      BorderRadius.circular(25),
                ),

                child: isMobile

                    ? Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          studentInfo(
                              "Student Name",
                              "Ameena"),

                          const SizedBox(height: 15),

                          studentInfo(
                              "Department",
                              "BCA"),

                          const SizedBox(height: 15),

                          studentInfo(
                              "Semester",
                              "Semester 4"),
                        ],
                      )

                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          studentInfo(
                              "Student Name",
                              "Ameena"),

                          studentInfo(
                              "Department",
                              "BCA"),

                          studentInfo(
                              "Semester",
                              "Semester 4"),
                        ],
                      ),
              ),

              const SizedBox(height: 30),

              /// RESULT TABLE
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: secondary,

                  borderRadius:
                      BorderRadius.circular(25),
                ),

                child: Column(
                  children: [

                    /// TABLE HEADER
                    resultRow(
                      "Subject",
                      "Marks",
                      "Grade",
                      true,
                      light,
                      accent,
                    ),

                    const SizedBox(height: 15),

                    resultRow(
                      "Mathematics",
                      "92",
                      "A+",
                      false,
                      light,
                      secondary,
                    ),

                    resultRow(
                      "Flutter",
                      "89",
                      "A",
                      false,
                      light,
                      secondary,
                    ),

                    resultRow(
                      "Python",
                      "95",
                      "A+",
                      false,
                      light,
                      secondary,
                    ),

                    resultRow(
                      "DBMS",
                      "84",
                      "B+",
                      false,
                      light,
                      secondary,
                    ),

                    resultRow(
                      "Networking",
                      "80",
                      "B",
                      false,
                      light,
                      secondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// RESULT SUMMARY
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: secondary,

                  borderRadius:
                      BorderRadius.circular(25),
                ),

                child: isMobile

                    ? Column(
                        children: [

                          summaryCard(
                            "CGPA",
                            "8.9",
                            accent,
                            light,
                          ),

                          const SizedBox(height: 20),

                          summaryCard(
                            "Percentage",
                            "89%",
                            accent,
                            light,
                          ),

                          const SizedBox(height: 20),

                          summaryCard(
                            "Status",
                            "PASS",
                            Colors.green,
                            light,
                          ),
                        ],
                      )

                    : Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        children: [

                          summaryCard(
                            "CGPA",
                            "8.9",
                            accent,
                            light,
                          ),

                          summaryCard(
                            "Percentage",
                            "89%",
                            accent,
                            light,
                          ),

                          summaryCard(
                            "Status",
                            "PASS",
                            Colors.green,
                            light,
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

  /// STUDENT INFO
  Widget studentInfo(
    String title,
    String value,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// RESULT ROW
  Widget resultRow(
    String subject,
    String marks,
    String grade,
    bool header,
    Color textColor,
    Color bgColor,
  ) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),

      decoration: BoxDecoration(
        color: bgColor.withOpacity(
            header ? 0.25 : 0.05),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Expanded(
            flex: 2,

            child: Text(
              subject,

              style: TextStyle(
                color: textColor,
                fontWeight: header
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              marks,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: textColor,
                fontWeight: header
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              grade,
              textAlign: TextAlign.end,

              style: TextStyle(
                color: textColor,
                fontWeight: header
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SUMMARY CARD
  Widget summaryCard(
    String title,
    String value,
    Color color,
    Color light,
  ) {

    return Container(
      width: 150,
      padding:
          const EdgeInsets.symmetric(
        vertical: 22,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Column(
        children: [

          Text(
            title,

            style: TextStyle(
              color: light.withOpacity(0.8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: TextStyle(
              color: light,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}