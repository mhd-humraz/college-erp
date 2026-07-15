// lib/modules/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AdminProvider>(context, listen: false).fetchGlobalMetrics(auth.token ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminWatch = Provider.of<AdminProvider>(context);
    final stats = adminWatch.metricsCache;

    return Scaffold(
      appBar: AppBar(title: const Text('EduSphere Command Matrix'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: adminWatch.isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
              ? const Center(child: Text('Operational telemetry offline.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Grid layout tracking metrics baseline variables
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildKpiCard('Total Students', stats['totalStudents'].toString(), Icons.people, Colors.blue),
                          _buildKpiCard('Total Faculty', stats['totalFaculty'].toString(), Icons.badge, Colors.teal),
                          _buildKpiCard('Departments', stats['totalDepartments'].toString(), Icons.corporate_fare, Colors.orange),
                          _buildKpiCard('Attendance Avg', '${stats['globalAttendance']}%', Icons.analytics, Colors.deepPurple),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text('Campus Distribution Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 16),
                      
                      // Interactive Bar Chart visualization block mapping stats parameters
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: [stats['totalStudents'], stats['totalFaculty'], stats['totalDepartments']].reduce((curr, next) => curr > next ? curr : next).toDouble() + 10,
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: stats['totalStudents'].toDouble(), color: Colors.blue, width: 22)]),
                                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: stats['totalFaculty'].toDouble(), color: Colors.teal, width: 22)]),
                                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: stats['totalDepartments'].toDouble(), color: Colors.orange, width: 22)]),
                                ],
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                                        switch (value.toInt()) {
                                          case 0: return const Text('Students', style: style);
                                          case 1: return const Text('Faculty', style: style);
                                          case 2: return const Text('Depts', style: style);
                                          default: return const Text('');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}