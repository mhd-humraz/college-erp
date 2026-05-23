// student_dashboard.dart

import 'package:flutter/material.dart';

import '../student/fee_payment_page.dart';

// IMPORT PAGES

import '../student/profile_page.dart';
import '../student/assignments_page.dart';
import '../student/attendance_page.dart';
import '../student/notifications_page.dart';
import '../student/notes_page.dart';
import '../student/timetable_page.dart';
import '../student/leave_request_page.dart';
import '../student/internal_marks_page.dart';
import '../student/exam_results_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'College ERP',

  theme: ThemeData(
    fontFamily: 'Poppins',

    scaffoldBackgroundColor: const Color(0xFF222831),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF222831),
      elevation: 0,
    ),
  ),

  home: const StudentDashboard(),
);
    
      
  }
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState
    extends State<StudentDashboard> {

  bool isDrawerOpen = false;

  final Color primary = const Color(0xFF222831);
  final Color secondary = const Color(0xFF393E46);
  final Color accent = const Color(0xFF00ADB5);
  final Color light = const Color(0xFFEEEEEE);

  final List<Map<String, dynamic>> dashboardItems = [

    {
      "title": "Profile",
      "icon": Icons.person,
    },

    {
      "title": "Notification",
      "icon": Icons.notifications,
    },

    {
      "title": "Study Material",
      "icon": Icons.menu_book,
    },

    {
      "title": "Assignments",
      "icon": Icons.assignment,
    },

    {
      "title": "Attendance",
      "icon": Icons.how_to_reg,
    },

    {
      "title": "Internal Score",
      "icon": Icons.school,
    },

    {
      "title": "Timetable",
      "icon": Icons.schedule,
    },

    {
      "title": "Exam Result",
      "icon": Icons.bar_chart,
    },

    {
      "title": "Leave Request",
      "icon": Icons.event_note,
    },

    {
      "title": "Semester Fee",
      "icon": Icons.account_balance_wallet,
    },
  ];

  // ═══════════════════════════════════════════════════════════════
  // PAGE NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  void openPage(String title) {

    Widget? page;

    switch (title) {

      case "Profile":
        page = const StudentProfilePage();
        break;

      case "Assignments":
        page = const AssignmentPage();
        break;

      case "Attendance":
        page = const AttendancePage();
        break;
      case "Semester Fee":
        page = const FeePaymentPage();
        break;
      case "Notification":
        page = const NotificationPage();
        break;

      case "Study Material":
        page = const StudyMaterialPage();
        break;
      case "Timetable":
        page = const TimeTablePage(department: "BCA"); // Replace "BCA" with the actual department
        break;
      case "Leave Request":
        page = const LeaveRequestPage();
        break;
      case "Internal Score":
        page = const InternalMarkPage();
        break;
      case "Exam Result":
        page = const ExamResultPage();  
        break;
    }

    if (page != null) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth =
        MediaQuery.of(context).size.width;

    bool isMobile = screenWidth < 700;

    return Scaffold(

      backgroundColor: primary,

      body: SafeArea(
        child: Stack(
          children: [

            // ═══════════════════════════════════
            // MAIN CONTENT
            // ═══════════════════════════════════

            Row(
              children: [

                Expanded(
                  child: Container(

                    padding:
                        EdgeInsets.all(
                            isMobile ? 15 : 25),

                    color: primary,

                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          // TOP BAR

                          Row(
                            children: [

                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(10),

                                decoration:
                                    BoxDecoration(
                                  color: secondary,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              14),
                                ),

                                child: InkWell(
                                  onTap: () {

                                    setState(() {
                                      isDrawerOpen =
                                          !isDrawerOpen;
                                    });
                                  },

                                  child: Icon(
                                    Icons.menu,
                                    color: light,
                                    size: 28,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              // SEARCH BAR

                              Expanded(
                                child: Container(
                                  height: 55,

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        secondary,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                18),
                                  ),

                                  child: TextField(
                                    style:
                                        TextStyle(
                                      color: light,
                                    ),

                                    decoration:
                                        InputDecoration(
                                      border:
                                          InputBorder
                                              .none,

                                      hintText:
                                          "Search...",

                                      hintStyle:
                                          const TextStyle(
                                        color: Colors
                                            .white54,
                                      ),

                                      prefixIcon:
                                          Icon(
                                        Icons.search,
                                        color:
                                            accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              // NOTIFICATION

                              Stack(
                                children: [

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .all(12),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          secondary,

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  14),
                                    ),

                                    child: Icon(
                                      Icons
                                          .notifications_none,

                                      color:
                                          light,
                                    ),
                                  ),

                                  Positioned(
                                    right: 7,
                                    top: 7,

                                    child: Container(
                                      height: 10,
                                      width: 10,

                                      decoration:
                                          const BoxDecoration(
                                        color:
                                            Colors
                                                .red,

                                        shape:
                                            BoxShape
                                                .circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  width: 15),

                              // PROFILE

                              CircleAvatar(
                                radius: 24,

                                backgroundColor:
                                    accent,

                                child: Icon(
                                  Icons.person,
                                  color: light,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 30),

                          // WELCOME CARD

                          Container(
                            width: double.infinity,

                            padding:
                                EdgeInsets.all(
                                    isMobile
                                        ? 20
                                        : 30),

                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius
                                      .circular(28),

                              gradient:
                                  LinearGradient(
                                colors: [
                                  accent,
                                  secondary,
                                ],
                              ),
                            ),

                            child: Row(
                              children: [

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        "Welcome Back 👋",

                                        style:
                                            TextStyle(
                                          color:
                                              light,

                                          fontSize:
                                              isMobile
                                                  ? 24
                                                  : 32,

                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              12),

                                      Text(
                                        "Track your assignments, attendance and academic updates easily.",

                                        style:
                                            TextStyle(
                                          color: light
                                              .withOpacity(
                                                  0.85),

                                          fontSize:
                                              isMobile
                                                  ? 13
                                                  : 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Icon(
                                  Icons.school_rounded,

                                  color: light
                                      .withOpacity(
                                          0.9),

                                  size: isMobile
                                      ? 70
                                      : 100,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 30),

                          // DASHBOARD CARDS

                          isMobile

                              ? Column(
                                  children: [

                                    performanceCard(),

                                    const SizedBox(
                                        height:
                                            20),

                                    attendanceCard(),

                                    const SizedBox(
                                        height:
                                            20),

                                    teacherAnnouncementCard(),
                                  ],
                                )

                              : Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Expanded(
                                      child:
                                          performanceCard(),
                                    ),

                                    const SizedBox(
                                        width:
                                            20),

                                    Expanded(
                                      child:
                                          attendanceCard(),
                                    ),

                                    const SizedBox(
                                        width:
                                            20),

                                    Expanded(
                                      child:
                                          teacherAnnouncementCard(),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ═══════════════════════════════════
            // SIDE DRAWER
            // ═══════════════════════════════════

            AnimatedPositioned(

              duration:
                  const Duration(
                      milliseconds: 300),

              left: isDrawerOpen
                  ? 0
                  : -260,

              top: 0,
              bottom: 0,

              child: Container(

                width: 250,
                color: secondary,

                child: Column(
                  children: [

                    const SizedBox(
                        height: 40),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 20,
                          ),

                          child: Text(
                            "Dashboard",

                            style:
                                TextStyle(
                              color: light,

                              fontSize: 22,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {

                            setState(() {
                              isDrawerOpen =
                                  false;
                            });
                          },

                          icon: Icon(
                            Icons.close,
                            color: light,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 25),

                    Expanded(
                      child: ListView.builder(

                        itemCount:
                            dashboardItems
                                .length,

                        itemBuilder:
                            (context, index) {

                          return Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            child: InkWell(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          16),

                              onTap: () {

                                openPage(
                                  dashboardItems[
                                          index]
                                      ["title"],
                                );
                              },

                              child: Container(

                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          0.05),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              16),
                                ),

                                child: ListTile(

                                  leading: Icon(
                                    dashboardItems[
                                            index]
                                        ["icon"],

                                    color:
                                        accent,
                                  ),

                                  title: Text(
                                    dashboardItems[
                                            index]
                                        ["title"],

                                    style:
                                        TextStyle(
                                      color:
                                          light,

                                      fontSize:
                                          14,

                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                                  ),

                                  trailing:
                                      Icon(
                                    Icons
                                        .arrow_forward_ios,

                                    size: 15,

                                    color: light
                                        .withOpacity(
                                            0.6),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PERFORMANCE CARD
  // ═══════════════════════════════════════════════════════════════

  Widget performanceCard() {

    return dashboardCard(

      title: "Student Performance",

      child: Column(
        children: [

          const SizedBox(height: 15),

          SizedBox(
            height: 200,

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [

                graphBar(70, "10"),
                graphBar(110, "20"),
                graphBar(90, "30"),
                graphBar(140, "40"),
                graphBar(100, "50"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: const [

              Text(
                "Y : Assignments",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              Text(
                "X : Internal Score",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ATTENDANCE CARD
  // ═══════════════════════════════════════════════════════════════

  Widget attendanceCard() {

    return dashboardCard(

      title: "Attendance",

      child: Column(
        children: [

          const SizedBox(height: 10),

          Stack(
            alignment: Alignment.center,

            children: [

              SizedBox(
                height: 120,
                width: 120,

                child:
                    CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 12,

                  backgroundColor:
                      Colors.white12,

                  valueColor:
                      AlwaysStoppedAnimation(
                          accent),
                ),
              ),

              Text(
                "85%",

                style: TextStyle(
                  color: light,
                  fontSize: 26,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            "Overall Attendance",

            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ANNOUNCEMENT CARD
  // ═══════════════════════════════════════════════════════════════

  Widget teacherAnnouncementCard() {

    return dashboardCard(

      title: "Teacher Announcement",

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          announcementTile(
            "Assignment submission deadline is Friday.",
          ),

          const SizedBox(height: 15),

          announcementTile(
            "Internal exam starts next week.",
          ),

          const SizedBox(height: 15),

          announcementTile(
            "Attendance below 75% must meet class tutor.",
          ),
        ],
      ),
    );
  }

  Widget announcementTile(String text) {

    return Container(

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Icon(
            Icons.campaign,
            color: accent,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,

              style: TextStyle(
                color: light,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COMMON CARD
  // ═══════════════════════════════════════════════════════════════

  Widget dashboardCard({
    required String title,
    required Widget child,
  }) {

    return Container(

      width: double.infinity,

      constraints:
          const BoxConstraints(
        minHeight: 320,
      ),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: secondary,

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Text(
            title,

            style: TextStyle(
              color: light,
              fontSize: 20,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // GRAPH BAR
  // ═══════════════════════════════════════════════════════════════

  Widget graphBar(
    double height,
    String label,
  ) {

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.end,

      children: [

        Container(
          width: 28,
          height: height,

          decoration: BoxDecoration(
            color: accent,

            borderRadius:
                BorderRadius.circular(
                    12),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,

          style: TextStyle(
            color: light,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

