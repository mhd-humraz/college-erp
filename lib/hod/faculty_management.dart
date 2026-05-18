import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FacultyManagementPage extends StatelessWidget {
  const FacultyManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Faculty Management',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add),
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
              padding: const EdgeInsets.all(22),
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
                    'Faculty Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Manage faculty details, attendance and subjects.',
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
                hintText: 'Search Faculty',
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
              'Faculty Members',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // FACULTY LIST
            Expanded(
              child: ListView(
                children: const [

                  FacultyCard(
                    name: 'Dr. Ahmed',
                    subject: 'Data Structures',
                    status: 'Active',
                    statusColor: Colors.green,
                  ),

                  SizedBox(height: 16),

                  FacultyCard(
                    name: 'Mrs. Fathima',
                    subject: 'Operating Systems',
                    status: 'On Leave',
                    statusColor: Colors.orange,
                  ),

                  SizedBox(height: 16),

                  FacultyCard(
                    name: 'Mr. Farhan',
                    subject: 'DBMS',
                    status: 'Active',
                    statusColor: AppColors.primary,
                  ),

                  SizedBox(height: 16),

                  FacultyCard(
                    name: 'Ms. Ameena',
                    subject: 'Machine Learning',
                    status: 'Busy',
                    statusColor: Colors.redAccent,
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

class FacultyCard extends StatelessWidget {
  final String name;
  final String subject;
  final String status;
  final Color statusColor;

  const FacultyCard({
    super.key,
    required this.name,
    required this.subject,
    required this.status,
    required this.statusColor,
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

          // PROFILE
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

          // DETAILS
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
                  subject,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color:
                        statusColor.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(30),
                  ),

                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ACTION BUTTON
          PopupMenuButton(
            color: AppColors.card,
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text(
                  'View',
                  style: TextStyle(
                    color: AppColors.text,
                  ),
                ),
              ),

              const PopupMenuItem(
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.text,
                  ),
                ),
              ),

              const PopupMenuItem(
                child: Text(
                  'Remove',
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