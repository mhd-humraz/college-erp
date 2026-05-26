import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final role = context.read<AuthProvider>().role;
      String endpoint;

      switch (role) {
        case 'admin':
          endpoint = '/analytics/admin';
          break;
        case 'hod':
          endpoint = '/analytics/hod';
          break;
        default:
          endpoint = '/analytics/student';
      }

      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        setState(() => _analyticsData = response.data['data']);
      }
    } catch (e) {
      print('Analytics Error: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Analytics Dashboard',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Attendance'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: AppColors.primary,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(role ?? 'student'),
                  _buildAttendanceTab(),
                  _buildPerformanceTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewTab(String role) {
    final data = _analyticsData;
    if (data == null) return _emptyState('No data available');

    return ListView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        // Stats Cards Row
        if (role == 'admin') ...[
          _statCard('Total Users', '${data['overview']?['totalUsers'] ?? 0}',
              Icons.people, AppColors.info),
          SizedBox(height: 12),
          _statCard('Departments', '${data['overview']?['totalDepartments'] ?? 0}',
              Icons.business, AppColors.success),
          SizedBox(height: 12),
          _statCard('Students', '${data['overview']?['totalStudents'] ?? 0}',
              Icons.school, AppColors.warning),
          SizedBox(height: 12),
          _statCard('Teachers', '${data['overview']?['totalTeachers'] ?? 0}',
              Icons.person, AppColors.primary),
        ],

        if (role == 'hod') ...[
          _statCard('Students', '${data['overview']?['students'] ?? 0}',
              Icons.school, AppColors.info),
          SizedBox(height: 12),
          _statCard('Teachers', '${data['overview']?['teachers'] ?? 0}',
              Icons.person, AppColors.success),
          SizedBox(height: 12),
          _statCard('Classes', '${data['overview']?['classes'] ?? 0}',
              Icons.class_, AppColors.warning),
        ],

        if (role == 'student') ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                (data['overallAttendance'] ?? 0) < 75
                    ? AppColors.error.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
                AppColors.card,
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Overall Attendance',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                SizedBox(height: 8),
                Text(
                  '${data['overallAttendance']?.toStringAsFixed(1) ?? 0}%',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: (data['overallAttendance'] ?? 0) < 75
                          ? AppColors.error
                          : AppColors.success),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ((data['overallAttendance'] ?? 0) / 100)
                      .clamp(0.0, 1.0),
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(
                      (data['overallAttendance'] ?? 0) < 75
                          ? AppColors.error
                          : AppColors.success),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _statCard('Average Score', '${data['averageScore'] ?? 0}%',
              Icons.grade, AppColors.info),
        ],

        SizedBox(height: 25),

        // Alerts Section
        if (data['alerts'] != null && (data['alerts'] as List).isNotEmpty) ...[
          Text('⚠️ Alerts', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),
          ...(data['alerts'] as List).map((alert) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: alert['type'] == 'danger'
                      ? AppColors.error.withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: alert['type'] == 'danger'
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                        alert['type'] == 'danger'
                            ? Icons.warning_amber
                            : Icons.info,
                        color: alert['type'] == 'danger'
                            ? AppColors.error
                            : AppColors.warning),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(alert['message'],
                            style: TextStyle(
                                color: AppColors.text, fontSize: 13))),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildAttendanceTab() {
    final data = _analyticsData;
    if (data == null) return _emptyState('No attendance data');

    return ListView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        // Monthly Bar Chart
        Container(
          height: 280,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Attendance Trend',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      fontSize: 16)),
              SizedBox(height: 20),
              Expanded(child: _buildBarChart()),
            ],
          ),
        ),

        SizedBox(height: 25),

        // Pie Chart for Status Distribution
        Container(
          height: 260,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance Distribution',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      fontSize: 16)),
              SizedBox(height: 15),
              Expanded(child: _buildPieChart()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    final data = _analyticsData;
    if (data == null) return _emptyState('No performance data');

    return ListView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        // Line Chart for Trends
        Container(
          height: 300,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Performance Trend',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      fontSize: 16)),
              SizedBox(height: 15),
              Expanded(child: _buildLineChart()),
            ],
          ),
        ),

        SizedBox(height: 25),

        // Subject Performance List
        if (data['subjectPerformance'] != null) ...[
          Text('Subject-wise Performance',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 15),
          ...(data['subjectPerformance'] as List).map((subj) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subj['subjectName'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.text)),
                        Text('${subj['average']?.toStringAsFixed(1) ?? 0}%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(subj['average']))),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                          value:
                              ((subj['average'] ?? 0) / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(
                              _getScoreColor(subj['average']))),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  // CHART WIDGETS
  Widget _buildBarChart() {
    final monthlyData = _analyticsData?['monthlyData'] ?? [];
    if (monthlyData.isEmpty)
      return Center(child: Text('No data', style: TextStyle(color: AppColors.textSecondary)));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(monthlyData[index]['month'] ?? '',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11));
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white10, strokeWidth: 1)),
        barGroups: List.generate(monthlyData.length, (index) {
          final item = monthlyData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: double.tryParse(item['percentage']?.toString() ?? '0') ?? 0,
                color: AppColors.primary,
                width: 22,
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart() {
    final stats = _analyticsData?['attendanceStats'];
    if (stats == null)
      return Center(child: Text('No data', style: TextStyle(color: AppColors.textSecondary)));

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 45,
        sections: [
          PieChartSectionData(
              value: double.tryParse(stats['present']?.toString() ?? '0') ?? 0,
              title: 'Present',
              color: AppColors.success,
              radius: 55,
              titleStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(
              value: double.tryParse(stats['absent']?.toString() ?? '0') ?? 0,
              title: 'Absent',
              color: AppColors.error,
              radius: 55,
              titleStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(
              value: double.tryParse(stats['late']?.toString() ?? '0') ?? 0,
              title: 'Late',
              color: AppColors.warning,
              radius: 55,
              titleStyle: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final trendData = _analyticsData?['trendData'] ?? [];
    if (trendData.isEmpty)
      return Center(child: Text('No trend data', style: TextStyle(color: AppColors.textSecondary)));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(trendData.length, (i) => FlSpot(
                i.toDouble(), (trendData[i]['status'] ?? 0).toDouble())),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 4, color: AppColors.primary),
            ),
            belowBarData:
                BarAreaData(show: true, color: AppColors.primary.withOpacity(0.15)),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0)
                  return Text('Day ${value.toInt()}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10));
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return value.toInt() == 1
                    ? Text('Present',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 10))
                    : Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white10)),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (trendData.length - 1).toDouble().clamp(0, 30),
        minY: 0,
        maxY: 1.2,
      ),
    );
  }

  Color _getScoreColor(double? score) {
    if (score == null) return AppColors.textSecondary;
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.info;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 70, color: AppColors.textSecondary.withOpacity(0.3)),
            SizedBox(height: 20),
            Text(message, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}