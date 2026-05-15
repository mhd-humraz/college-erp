import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() =>
      _StudentListPageState();
}

class _StudentListPageState
    extends State<StudentListPage> {

  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, String>> students = [
    {
      "name": "Arjun Kumar",
      "roll": "21CS001",
      "department": "Computer Science",
    },

    {
      "name": "Anjali Nair",
      "roll": "21CS002",
      "department": "Computer Science",
    },

    {
      "name": "Rahul Das",
      "roll": "21CS003",
      "department": "Electronics",
    },

    {
      "name": "Meera Joseph",
      "roll": "21CS004",
      "department": "Mechanical",
    },

    {
      "name": "Akash Roy",
      "roll": "21CS005",
      "department": "Civil",
    },
  ];

  List<Map<String, String>> filteredStudents =
      [];

  @override
  void initState() {
    super.initState();
    filteredStudents = students;
  }

  void searchStudent(String value) {
    setState(() {
      filteredStudents = students
          .where(
            (student) => student["name"]!
                .toLowerCase()
                .contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
    });
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
          "Student List",

          style: TextStyle(
            color: AppColors.text,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // SEARCH BAR

            TextField(
              controller: searchController,

              onChanged: searchStudent,

              style: const TextStyle(
                color: AppColors.text,
              ),

              decoration: InputDecoration(
                hintText: "Search Student",

                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),

                filled: true,
                fillColor: AppColors.card,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // STUDENT LIST

            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredStudents.length,

                itemBuilder:
                    (context, index) {

                  return Container(
                    margin:
                        const EdgeInsets.only(
                            bottom: 16),

                    padding:
                        const EdgeInsets.all(
                            18),

                    decoration: BoxDecoration(
                      color: AppColors.card,

                      borderRadius:
                          BorderRadius
                              .circular(18),
                    ),

                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 28,

                          backgroundColor:
                              AppColors.primary,

                          child: Text(
                            filteredStudents[
                                    index]
                                ["name"]![0],

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                filteredStudents[
                                        index]
                                    ["name"]!,

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
                                  height: 6),

                              Text(
                                filteredStudents[
                                        index]
                                    ["roll"]!,

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.grey,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                filteredStudents[
                                        index]
                                    [
                                    "department"]!,

                                style:
                                    const TextStyle(
                                  color:
                                      AppColors
                                          .primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {},

                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color:
                                AppColors
                                    .primary,
                            size: 18,
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