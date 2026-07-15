 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_provider.dart';
import 'profile_screen.dart';
import 'digital_id_screen.dart';
import 'portfolio_screen.dart';
import 'raise_ticket_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'marks_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      print("AI USER ID: ${auth.userId}");
      print("AI STUDENT ID: ${auth.studentId}");
      print("AI TOKEN: ${auth.token}");

      Provider.of<AiProvider>(
        context,
        listen: false,
      ).fetchStudentPredictiveRisk(
        auth.studentId ?? '',
        auth.token ?? '',
      );
    });
    }
  


  @override
  Widget build(BuildContext context) {
    // FIX: auth moved here so it's in scope for the whole widget tree
    final auth    = Provider.of<AuthProvider>(context);
    final aiState = Provider.of<AiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Hub'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () {
              auth.terminateSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome header ───────────────────────────────────────────
            const Text('Welcome Back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(auth.userEmail ?? '',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // ── AI Predictive Risk card ──────────────────────────────────
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology,
                            color: Colors.indigo, size: 28),
                        const SizedBox(width: 10),
                        const Text('AI Risk Analysis',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (aiState.isLoading)
                          const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const Divider(height: 24),
                    if (aiState.error != null)
                      Text(aiState.error!,
                          style: const TextStyle(color: Colors.red)),
                    if (aiState.currentInsight != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniMetric('Attendance',
                              '${aiState.currentInsight!.currentAttendanceRate}%'),
                          _buildMiniMetric('Projected',
                              '${aiState.currentInsight!.predictedAttendance}%'),
                          _buildMiniMetric(
                              'Risk',
                              aiState.currentInsight!.riskLevel,
                              isRisk: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        aiState.currentInsight!.recommendation,
                        style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54),
                      ),
                    ] else if (!aiState.isLoading)
                      const Text('No analytics data yet.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Module grid ──────────────────────────────────────────────
            const Text('Campus Modules',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildModuleTile(
                  context,
                  icon: Icons.badge_outlined,
                  title: 'Digital ID',
                  subtitle: 'QR Verify',
                  color: Colors.blue.shade700,
                  destination: const DigitalIdScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'Student Info',
                  color: Colors.indigo,
                  destination: const ProfileScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.folder_shared_outlined,
                  title: 'My Portfolio',
                  subtitle: 'Achievements',
                  color: Colors.purple.shade700,
                  destination: const PortfolioScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.fact_check,
                  title: 'Attendance',
                  subtitle: 'View Attendance',
                  color: Colors.teal,
                  destination: const AttendanceScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.school,
                  title: 'Marks',
                  subtitle: 'Exam Results',
                  color: Colors.red,
                  destination: const MarksScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.confirmation_number_outlined,
                  title: 'Raise Ticket',
                  subtitle: 'Help Desk',
                  color: Colors.orange.shade800,
                  destination: const RaiseTicketScreen(),
                ),

                _buildModuleTile(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: 'Timetable',
                  subtitle: 'Schedule',
                  color: Colors.green.shade700,
                  destination: TimetableScreen(
                    courseId: auth.courseId,
                    semester: auth.semester ?? 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value,
      {bool isRisk = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isRisk
                  ? (value == 'High' ? Colors.red : Colors.orange)
                  : Colors.black87,
            )),
      ],
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => destination)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}