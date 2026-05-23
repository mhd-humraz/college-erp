
import 'package:flutter/material.dart';

class StudyMaterialPage extends StatelessWidget {
  const StudyMaterialPage({super.key});

  final Color primary = const Color(0xFF222831);
  final Color secondary = const Color(0xFF393E46);
  final Color accent = const Color(0xFF00ADB5);
  final Color light = const Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,

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
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: light,
                  size: 16,
                ),
              ),
            ),
          ),
        ),

        title: const Text(
          "Study Materials",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "BCA Materials",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Access your semester study materials and resources.",
              style: TextStyle(
                color: light.withOpacity(0.7),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: [

                  materialCard(
                    icon: Icons.computer,
                    subject: "Programming in C",
                    material: "Unit 1 - Introduction to C",
                  ),

                  const SizedBox(height: 16),

                  materialCard(
                    icon: Icons.code,
                    subject: "Data Structures",
                    material: "Stacks and Queues PDF",
                  ),

                  const SizedBox(height: 16),

                  materialCard(
                    icon: Icons.storage,
                    subject: "Database Management System",
                    material: "SQL Queries Notes",
                  ),

                  const SizedBox(height: 16),

                  materialCard(
                    icon: Icons.language,
                    subject: "Web Technology",
                    material: "HTML & CSS Tutorial",
                  ),

                  const SizedBox(height: 16),

                  materialCard(
                    icon: Icons.security,
                    subject: "Cyber Security",
                    material: "Network Security Basics",
                  ),

                  const SizedBox(height: 16),

                  materialCard(
                    icon: Icons.cloud,
                    subject: "Cloud Computing",
                    material: "AWS Introduction PPT",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget materialCard({
    required IconData icon,
    required String subject,
    required String material,
  }) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: secondary,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              color: accent,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  subject,
                  style: TextStyle(
                    color: light,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  material,
                  style: TextStyle(
                    color: light.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.download,
            color: accent,
          ),
        ],
      ),
    );
  }
}
