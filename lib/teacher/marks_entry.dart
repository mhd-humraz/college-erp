import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class MarkEntryPage extends StatefulWidget {
  const MarkEntryPage({super.key});

  @override
  State<MarkEntryPage> createState() =>
      _MarkEntryPageState();
}

class _MarkEntryPageState
    extends State<MarkEntryPage> {

  List<Map<String, dynamic>> students = [
    {
      "name": "Arjun Kumar",
      "roll": "21CS001",
      "mark": 85,
    },

    {
      "name": "Anjali Nair",
      "roll": "21CS002",
      "mark": 92,
    },

    {
      "name": "Rahul Das",
      "roll": "21CS003",
      "mark": 76,
    },

    {
      "name": "Meera Joseph",
      "roll": "21CS004",
      "mark": 88,
    },
  ];

  void editMark(int index) {
    TextEditingController controller =
        TextEditingController(
      text:
          students[index]["mark"].toString(),
    );

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,

          title: const Text(
            "Edit Mark",

            style: TextStyle(
              color: AppColors.text,
            ),
          ),

          content: TextField(
            controller: controller,

            keyboardType:
                TextInputType.number,

            style: const TextStyle(
              color: AppColors.text,
            ),

            decoration: InputDecoration(
              hintText: "Enter Mark",

              hintStyle:
                  const TextStyle(
                color: Colors.grey,
              ),

              filled: true,
              fillColor:
                  AppColors.background,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
              ),

              onPressed: () {

                setState(() {
                  students[index]["mark"] =
                      int.parse(
                    controller.text,
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Mark Updated",
                    ),
                  ),
                );
              },

              child: const Text(
                "Save",

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
          "Mark Entry",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          itemCount: students.length,

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

              child: Row(
                children: [

                  CircleAvatar(
                    backgroundColor:
                        AppColors.primary,

                    child: Text(
                      students[index]["name"]
                          [0],

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

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
                                AppColors.text,
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color:
                          AppColors.primary,

                      borderRadius:
                          BorderRadius
                              .circular(
                                  14),
                    ),

                    child: Text(
                      students[index]["mark"]
                          .toString(),

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton(
                    onPressed: () {
                      editMark(index);
                    },

                    icon: const Icon(
                      Icons.edit,
                      color:
                          AppColors.primary,
                    ),
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