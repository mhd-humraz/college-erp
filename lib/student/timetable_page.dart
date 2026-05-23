import 'package:flutter/material.dart';

class TimeTablePage extends StatelessWidget {
  final String department;

  const TimeTablePage({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> timetable = [];

    /// ================= BCA TIMETABLE =================
    if (department == "BCA") {
      timetable = [
        {
          "day": "Monday",
          "time": "9:00 AM - 10:00 AM",
          "subject": "Programming in C"
        },
        {
          "day": "Monday",
          "time": "10:00 AM - 11:00 AM",
          "subject": "Database Management"
        },
        {
          "day": "Tuesday",
          "time": "9:00 AM - 10:00 AM",
          "subject": "Computer Networks"
        },
        {
          "day": "Tuesday",
          "time": "11:00 AM - 12:00 PM",
          "subject": "Data Structures"
        },
        {
          "day": "Wednesday",
          "time": "1:00 PM - 2:00 PM",
          "subject": "Web Development"
        },
      ];
    }

    /// ================= BCOM TIMETABLE =================
    else if (department == "BCOM") {
      timetable = [
        {
          "day": "Monday",
          "time": "9:00 AM - 10:00 AM",
          "subject": "Financial Accounting"
        },
        {
          "day": "Tuesday",
          "time": "10:00 AM - 11:00 AM",
          "subject": "Business Law"
        },
      ];
    }

    /// ================= BBA TIMETABLE =================
    else if (department == "BBA") {
      timetable = [
        {
          "day": "Monday",
          "time": "11:00 AM - 12:00 PM",
          "subject": "Marketing"
        },
        {
          "day": "Wednesday",
          "time": "1:00 PM - 2:00 PM",
          "subject": "Human Resource Management"
        },
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFF222831),

      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        elevation: 0,

        /// ✅ Rounded rectangle box — matches Student Profile page
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),

            child: Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color: const Color(0xFF393E46),
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

        title: Text(
          "$department Time Table",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: timetable.isEmpty
          ? const Center(
              child: Text(
                "No timetable available",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: timetable.length,

              itemBuilder: (context, index) {
                final item = timetable[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF393E46),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["day"]!,
                        style: const TextStyle(
                          color: Color(0xFF00ADB5),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            item["time"]!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.book,
                            color: Colors.white70,
                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            item["subject"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}