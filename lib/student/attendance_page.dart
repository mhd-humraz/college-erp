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
      title: 'Attendance ERP',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF222831),
      ),
      home: const AttendancePage(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ATTENDANCE PAGE
// ═══════════════════════════════════════════════════════════════

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {

    // SAMPLE DATA

    int totalWorkingDays = 92;
    int currentDays = 68;
    int presentDays = 58;
    int absentDays = currentDays - presentDays;

    double percentage =
        (presentDays / currentDays) * 100;

    bool belowLimit = percentage < 75;

    // LEAVE CALCULATION

    int safeLeaves =
        ((presentDays / 0.75) - currentDays).floor();

    if (safeLeaves < 0) {
      safeLeaves = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF222831),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ═══════════════════════════════════
              // TOP BAR
              // ═══════════════════════════════════

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  // BACK BUTTON

                  GestureDetector(
                    onTap: () {
                      // MODIFIED: Pop to previous dashboard instance
                      Navigator.pop(context);
                    },

                    child: Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: const Color(0xFF393E46),

                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFEEEEEE),
                        size: 18,
                      ),
                    ),
                  ),

                  const HeadingText(
                    "Attendance",
                    fontSize: 20,
                  ),

                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: const Color(0xFF393E46),

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Color(0xFF00ADB5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════
              // ATTENDANCE PERCENTAGE CARD
              // ═══════════════════════════════════

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xFF393E46),

                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: Column(
                  children: [

                    const SmallLabel(
                      "Current Attendance",
                      color: Color(0x99EEEEEE),
                    ),

                    const SizedBox(height: 16),

                    Stack(
                      alignment: Alignment.center,

                      children: [

                        SizedBox(
                          width: 180,
                          height: 180,

                          child:
                              CircularProgressIndicator(
                            value:
                                percentage / 100,

                            strokeWidth: 14,

                            backgroundColor:
                                const Color(
                                    0xFF222831),

                            valueColor:
                                AlwaysStoppedAnimation(
                              belowLimit
                                  ? Colors.red
                                  : const Color(
                                      0xFF00ADB5),
                            ),
                          ),
                        ),

                        Column(
                          children: [

                            HeadingText(
                              "${percentage.toStringAsFixed(1)}%",

                              fontSize: 34,

                              color: belowLimit
                                  ? Colors.red
                                  : const Color(
                                      0xFF00ADB5),
                            ),

                            const SizedBox(height: 4),

                            BodyText(
                              belowLimit
                                  ? "Below Limit"
                                  : "Good Standing",

                              color: belowLimit
                                  ? Colors.red
                                  : const Color(
                                      0xFFEEEEEE),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: belowLimit
                            ? Colors.red
                                .withOpacity(0.12)
                            : const Color(
                                    0xFF00ADB5)
                                .withOpacity(0.12),

                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          Icon(
                            belowLimit
                                ? Icons.warning_amber
                                : Icons.check_circle,

                            color: belowLimit
                                ? Colors.red
                                : const Color(
                                    0xFF00ADB5),

                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          BodyText(
                            belowLimit
                                ? "Attendance below 75%"
                                : "Attendance is safe",

                            fontSize: 13,

                            color: belowLimit
                                ? Colors.red
                                : const Color(
                                    0xFF00ADB5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ═══════════════════════════════════
              // SUMMARY GRID
              // ═══════════════════════════════════

              Row(
                children: [

                  Expanded(
                    child: summaryCard(
                      "Working Days",
                      totalWorkingDays.toString(),
                      Icons.calendar_month_outlined,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: summaryCard(
                      "Current Days",
                      currentDays.toString(),
                      Icons.today_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [

                  Expanded(
                    child: summaryCard(
                      "Present Days",
                      presentDays.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: summaryCard(
                      "Absent Days",
                      absentDays.toString(),
                      Icons.cancel_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════
              // LEAVE STATUS
              // ═══════════════════════════════════

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF393E46),

                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const DashboardTitle(
                      "Leave Analysis",
                      fontSize: 17,
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: safeLeaves > 0
                                ? const Color(
                                        0xFF00ADB5)
                                    .withOpacity(0.15)
                                : Colors.red
                                    .withOpacity(0.15),

                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),

                          child: Icon(
                            safeLeaves > 0
                                ? Icons
                                    .beach_access_outlined
                                : Icons.warning_amber,

                            color: safeLeaves > 0
                                ? const Color(
                                    0xFF00ADB5)
                                : Colors.red,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              HeadingText(
                                safeLeaves > 0
                                    ? "$safeLeaves Safe Leaves Available"
                                    : "No Safe Leave Remaining",

                                fontSize: 15,

                                color: safeLeaves > 0
                                    ? const Color(
                                        0xFFEEEEEE)
                                    : Colors.red,
                              ),

                              const SizedBox(
                                  height: 4),

                              BodyText(
                                safeLeaves > 0
                                    ? "You can still take leave safely."
                                    : "Warning: Don't take leave now.",

                                fontSize: 12,

                                color: const Color(
                                    0x99EEEEEE),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════
              // MONTHLY GRAPH
              // ═══════════════════════════════════

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF393E46),

                  borderRadius:
                      BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const DashboardTitle(
                      "Monthly Attendance Graph",
                      fontSize: 17,
                    ),

                    const SizedBox(height: 24),

                    attendanceBar(
                      "Jan",
                      0.88,
                    ),

                    attendanceBar(
                      "Feb",
                      0.80,
                    ),

                    attendanceBar(
                      "Mar",
                      0.72,
                    ),

                    attendanceBar(
                      "Apr",
                      0.91,
                    ),

                    attendanceBar(
                      "May",
                      percentage / 100,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
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
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF393E46),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            color: const Color(0xFF00ADB5),
            size: 26,
          ),

          const SizedBox(height: 12),

          HeadingText(
            value,
            fontSize: 24,
          ),

          const SizedBox(height: 6),

          SmallLabel(
            title,
            color: const Color(0x99EEEEEE),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BAR GRAPH
  // ═══════════════════════════════════════════════════════════════

  Widget attendanceBar(
    String month,
    double value,
  ) {

    bool low = value < 0.75;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),

      child: Row(
        children: [

          SizedBox(
            width: 40,

            child: SmallLabel(
              month,
            ),
          ),

          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),

              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,

                backgroundColor:
                    const Color(0xFF222831),

                valueColor:
                    AlwaysStoppedAnimation(
                  low
                      ? Colors.red
                      : const Color(
                          0xFF00ADB5),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 45,

            child: SmallLabel(
              "${(value * 100).toInt()}%",

              color: low
                  ? Colors.red
                  : const Color(
                      0xFFEEEEEE),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TEXT STYLES
// ═══════════════════════════════════════════════════════════════

class HeadingText extends StatelessWidget {

  final String text;
  final double fontSize;
  final Color? color;

  const HeadingText(
    this.text, {
    super.key,
    this.fontSize = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Text(
      text,

      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: fontSize,

        color:
            color ??
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
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        color: const Color(0xFFEEEEEE),
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
        fontWeight: FontWeight.w400,
        fontSize: fontSize,

        color:
            color ??
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
        fontWeight: FontWeight.w500,
        fontSize: fontSize,

        color:
            color ??
                const Color(0xFFEEEEEE),
      ),
    );
  }
}