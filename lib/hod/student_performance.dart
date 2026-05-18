import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StudentPerformancePage extends StatelessWidget {
  const StudentPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.text,
        ),
        title: const Text(
          'Student Performance',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(
          AppConstants.defaultPadding,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    Color(0xFF02838A),
                  ],
                ),

                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius,
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Performance Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Track student marks, CGPA and academic progress.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SEARCH BAR
            TextField(
              style: const TextStyle(
                color: AppColors.text,
              ),

              decoration: InputDecoration(
                hintText: 'Search Student',
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),

                filled: true,
                fillColor: AppColors.card,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Top Students',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: const [

                  StudentCard(
                    name: 'Muhammed Ali',
                    course: 'MCA',
                    cgpa: '9.2',
                    attendance: '95%',
                  ),

                  SizedBox(height: 16),

                  StudentCard(
                    name: 'Fathima Noor',
                    course: 'BCA',
                    cgpa: '8.9',
                    attendance: '91%',
                  ),

                  SizedBox(height: 16),

                  StudentCard(
                    name: 'Ameen',
                    course: 'BTech CSE',
                    cgpa: '8.7',
                    attendance: '88%',
                  ),

                  SizedBox(height: 16),

                  StudentCard(
                    name: 'Shamil',
                    course: 'MCA',
                    cgpa: '9.5',
                    attendance: '97%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String course;
  final String cgpa;
  final String attendance;

  const StudentCard({
    super.key,
    required this.name,
    required this.course,
    required this.cgpa,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(
          AppConstants.borderRadius,
        ),
      ),

      child: Row(
        children: [

          // PROFILE ICON
          CircleAvatar(
            radius: 28,
            backgroundColor:
                AppColors.primary.withOpacity(0.2),

            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // STUDENT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  course,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(0.15),

                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                      child: Text(
                        'CGPA : $cgpa',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color:
                            Colors.green.withOpacity(0.15),

                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                      child: Text(
                        attendance,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MORE BUTTON
          PopupMenuButton(
            color: AppColors.card,

            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),

            itemBuilder: (context) => [

              const PopupMenuItem(
                child: Text(
                  'View Profile',
                  style: TextStyle(
                    color: AppColors.text,
                  ),
                ),
              ),

              const PopupMenuItem(
                child: Text(
                  'View Marks',
                  style: TextStyle(
                    color: AppColors.text,
                  ),
                ),
              ),

              const PopupMenuItem(
                child: Text(
                  'Send Warning',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}