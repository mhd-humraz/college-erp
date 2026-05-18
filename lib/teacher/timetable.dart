import 'package:flutter/material.dart';
import '../utils/theme.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  final Map<String, List<Map<String, String>>> timetable = {
    "Monday": [
      {"time": "9:00 - 10:00", "subject": "Maths"},
      {"time": "10:00 - 11:00", "subject": "Physics"},
    ],
    "Tuesday": [
      {"time": "9:00 - 10:00", "subject": "Chemistry"},
      {"time": "10:00 - 11:00", "subject": "English"},
    ],
    "Wednesday": [
      {"time": "9:00 - 10:00", "subject": "CS"},
      {"time": "10:00 - 11:00", "subject": "Lab"},
    ],
    "Thursday": [
      {"time": "9:00 - 10:00", "subject": "Maths"},
      {"time": "10:00 - 11:00", "subject": "Physics"},
    ],
    "Friday": [
      {"time": "9:00 - 10:00", "subject": "Project"},
      {"time": "10:00 - 11:00", "subject": "Seminar"},
    ],
    "Saturday": [
      {"time": "9:00 - 10:00", "subject": "Revision"},
    ],
  };

  String selectedDay = "Monday";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Timetable",
          style: TextStyle(color: AppColors.text),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // DAY SELECTOR
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedDay == day
                            ? AppColors.primary
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // TIMETABLE LIST
            Expanded(
              child: ListView.builder(
                itemCount: timetable[selectedDay]!.length,
                itemBuilder: (context, index) {
                  final item = timetable[selectedDay]![index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item["time"]!,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          item["subject"]!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}