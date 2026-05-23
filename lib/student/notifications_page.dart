import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Color get primary => const Color(0xFF222831);
  Color get secondary => const Color(0xFF393E46);
  Color get accent => const Color(0xFF00ADB5);
  Color get light => const Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: primary,

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,

        /// ✅ UPDATED BACK BUTTON: Mini rounded box with "<" chevron
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),

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
        ),

        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      /// ERROR FIXED HERE
      /// SingleChildScrollView prevents bottom overflow spacing issue

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            const Text(
              "Recent Updates",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            notificationCard(
              icon: Icons.assignment,
              title: "Assignment Uploaded",
              subtitle:
                  "DBMS assignment has been uploaded by your teacher.",
            ),

            const SizedBox(height: 15),

            notificationCard(
              icon: Icons.school,
              title: "Internal Exam",
              subtitle:
                  "Internal exams will start from next Monday.",
            ),

            const SizedBox(height: 15),

            notificationCard(
              icon: Icons.event_available,
              title: "Attendance Alert",
              subtitle:
                  "Your attendance is below 75%.",
            ),

            const SizedBox(height: 15),

            notificationCard(
              icon: Icons.account_balance_wallet,
              title: "Semester Fee Reminder",
              subtitle:
                  "Semester fee payment deadline is approaching.",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget notificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: accent,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: light,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: light.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}