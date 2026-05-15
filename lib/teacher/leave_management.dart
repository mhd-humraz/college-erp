import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  State<LeaveManagementPage> createState() =>
      _LeaveManagementPageState();
}

class _LeaveManagementPageState
    extends State<LeaveManagementPage> {

  List<Map<String, dynamic>> leaveRequests = [
    {
      "name": "Arjun Kumar",
      "date": "12 May 2026",
      "reason": "Medical Leave",
      "approved": false,
    },

    {
      "name": "Anjali Nair",
      "date": "14 May 2026",
      "reason": "Family Function",
      "approved": true,
    },

    {
      "name": "Rahul Das",
      "date": "15 May 2026",
      "reason": "Personal Leave",
      "approved": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,

        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Leave Management",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          itemCount: leaveRequests.length,

          itemBuilder: (context, index) {

            return Container(
              margin:
                  const EdgeInsets.only(
                      bottom: 16),

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: AppColors.card,

                borderRadius:
                    BorderRadius.circular(
                        18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      CircleAvatar(
                        backgroundColor:
                            AppColors.primary,

                        child: Text(
                          leaveRequests[index]
                              ["name"][0],

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              leaveRequests[index]
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
                              leaveRequests[index]
                                  ["date"],

                              style:
                                  const TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              leaveRequests[index]
                                      [
                                      "approved"]
                                  ? Colors.green
                                  : Colors.orange,

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),

                        child: Text(
                          leaveRequests[index]
                                  [
                                  "approved"]
                              ? "Approved"
                              : "Pending",

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Reason",

                    style: TextStyle(
                      color:
                          AppColors.primary,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    leaveRequests[index]
                        ["reason"],

                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                          ),

                          onPressed: () {
                            setState(() {
                              leaveRequests[index]
                                      [
                                      "approved"] =
                                  true;
                            });
                          },

                          child: const Text(
                            "Approve",

                            style:
                                TextStyle(
                              color: Colors
                                  .white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.red,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                          ),

                          onPressed: () {
                            setState(() {
                              leaveRequests[index]
                                      [
                                      "approved"] =
                                  false;
                            });
                          },

                          child: const Text(
                            "Reject",

                            style:
                                TextStyle(
                              color: Colors
                                  .white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}