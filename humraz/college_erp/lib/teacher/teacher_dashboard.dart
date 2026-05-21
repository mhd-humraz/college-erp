import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/teacher/dashboard');

      print('🌐 Teacher Dashboard Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _dashboardData = response.data['data'];
          _isLoading = false;
        });
        print('✅ Teacher dashboard loaded!');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Teacher Dashboard'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(),
                        SizedBox(height: 24),
                        _buildStatsGrid(),
                        SizedBox(height: 24),
                        _buildQuickActions(),
                        SizedBox(height: 24),
                        _buildUpcomingClasses(),
                        SizedBox(height: 24),
                        _buildRecentActivity(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeCard() {
    final profile = _dashboardData?['profile'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  '${profile['name']?.toString()[0] ?? 'T'}'.toUpperCase(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${profile['name'] ?? 'Teacher'}! 👋',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      profile['designation'] ?? 'Faculty Member',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              if (profile['isHOD'] == true)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('HOD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.email, profile['email'] ?? ''),
              _buildInfoItem(Icons.business, profile['department'] ?? ''),
              _buildInfoItem(Icons.badge, profile['employeeId'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = _dashboardData?['stats'] ?? {};

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('My Students', '${stats['totalStudents'] ?? 0}', Icons.people_rounded, AppColors.primary),
        _buildStatCard("Today's Classes", '${stats['todayClasses'] ?? 0}', Icons.class_rounded, Colors.orange),
        _buildStatCard('This Week', '${stats['thisWeekAttendance'] ?? 0}', Icons.fact_check_outlined, Colors.green),
        _buildStatCard('Subjects', '${stats['totalSubjects'] ?? 0}', Icons.menu_book, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = _dashboardData?['quickActions'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('⚡ Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        ...List.generate(actions.length, (index) {
          final action = actions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _handleActionNavigation(action['route']),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getActionIcon(action['icon']), color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: Text(action['title'], style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text))),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _handleActionNavigation(String? route) {
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coming soon!'), backgroundColor: AppColors.warning),
      );
      return;
    }

    Navigator.pushNamed(context, route);
  }

  IconData _getActionIcon(String? iconName) {
    switch (iconName) {
      case 'check_circle': return Icons.check_circle_outline;
      case 'edit_note': return Icons.edit_note;
      case 'people': return Icons.people_outline;
      case 'schedule': return Icons.schedule;
      default: return Icons.arrow_forward;
    }
  }

  Widget _buildUpcomingClasses() {
    final classes = _dashboardData?['upcomingClasses'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📅 Upcoming Classes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        ...List.generate(classes.length > 3 ? 3 : classes.length, (index) {
          final cls = classes[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: AppColors.info, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cls['subject'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                        SizedBox(height: 4),
                        Text(cls['course'] ?? '', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(cls['day'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.info)),
                      SizedBox(height: 4),
                      Text(cls['time'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = _dashboardData?['recentActivity'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📋 Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: activities.map<Widget>((activity) {
              return Padding(
                padding: EdgeInsets.only(bottom: activities.last == activity ? 0 : 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getActivityColor(activity['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getActivityIcon(activity['type']), color: _getActivityColor(activity['type']), size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['action'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text)),
                          Text(activity['time'], style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'attendance': return AppColors.success;
      case 'marks': return AppColors.warning;
      case 'enrollment': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'attendance': return Icons.check_circle_outline;
      case 'marks': return Icons.edit_note;
      case 'enrollment': return Icons.person_add;
      default: return Icons.info;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text('Failed to load dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
            SizedBox(height: 8),
            Text(_error ?? 'Unknown error', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDashboardData,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}