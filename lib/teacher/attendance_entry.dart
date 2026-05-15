import 'package:flutter/material.dart';
import '../utils/theme.dart';
 

class AttendanceEntry extends StatefulWidget {
  const AttendanceEntry({super.key});

  @override
  State<AttendanceEntry> createState() =>
      _AttendanceEntryState();
}

class _AttendanceEntryState
    extends State<AttendanceEntry> {

  List<Map<String, dynamic>> students = [
    {
      "name": "Arjun Kumar",
      "roll": "21CS001",
      "present": true,
    },

    {
      "name": "Anjali Nair",
      "roll": "21CS002",
      "present": false,
    },

    {
      "name": "Rahul Das",
      "roll": "21CS003",
      "present": true,
    },

    {
      "name": "Meera Joseph",
      "roll": "21CS004",
      "present": false,
    },

    {
      "name": "Akash Roy",
      "roll": "21CS005",
      "present": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    int presentCount = students
        .where((student) => student["present"])
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Attendance Entry",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // TOP CARD

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Today's Attendance",

                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Present: $presentCount / ${students.length}",

                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STUDENT LIST

            Expanded(
              child: ListView.builder(
                itemCount: students.length,

                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        const EdgeInsets.only(
                            bottom: 15),

                    padding:
                        const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: AppColors.card,

                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),

                    child: Row(
                      children: [

                        // PROFILE

                        CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              AppColors.primary,

                          child: Text(
                            students[index]["name"]
                                [0],

                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        // STUDENT DETAILS

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                students[index]
                                    ["name"],

                                style:
                                    const TextStyle(
                                  color:
                                      AppColors
                                          .text,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                students[index]
                                    ["roll"],

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SWITCH

                        Switch(
                          value: students[index]
                              ["present"],

                          activeColor:
                              AppColors.primary,

                          onChanged: (value) {
                            setState(() {
                              students[index]
                                  ["present"] = value;
                            });
                          },
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

      // SAVE BUTTON

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: AppColors.primary,

        icon: const Icon(Icons.save),

        label: const Text(
          "Save",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Attendance Saved Successfully",
              ),
            ),
          );
        },
      ),
    );
  }
}