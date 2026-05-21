import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';

class HODDashboard extends StatefulWidget {
  const HODDashboard({super.key});

  @override
  State<HODDashboard> createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/hod/dashboard');

      print('🌐 HOD Dashboard Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _dashboardData = response.data['data'];
          _isLoading = false;
        });
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
      appBar: CustomAppBar(title: 'HOD Dashboard'),
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
                        _buildDepartmentInfo(),
                        SizedBox(height: 24),
                        _buildRecentStudents(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeCard() {
    final profile = _dashboardData?['profile'] ?? {};
    final isHOD = profile['isHOD'] == true;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHOD ? [Colors.purple, Colors.purple.withOpacity(0.8)] : [AppColors.info, AppColors.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: isHOD ? Colors.purple.withOpacity(0.3) : AppColors.info.withOpacity(0.3),
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
                  '${profile['name']?.toString()[0] ?? 'H'}'.toUpperCase(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${profile['name'] ?? 'HOD'}! 👋',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          profile['designation'] ?? 'Faculty Member',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        ),
                        SizedBox(width: 8),
                        if (isHOD)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
        _buildStatCard('Dept Students', '${stats['totalStudents'] ?? 0}', Icons.people_rounded, Colors.purple),
        _buildStatCard('Dept Teachers', '${stats['totalTeachers'] ?? 0}', Icons.group, Colors.orange),
        _buildStatCard('Active Courses', '${stats['activeCourses'] ?? 0}', Icons.menu_book, Colors.green),
        _buildStatCard('Current Sem', '${stats['thisSemester'] ?? 0}', Icons.calendar_today, Colors.teal),
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
        Text('⚡ HOD Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        ...List.generate(actions.length, (index) {
          final action = actions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to respective pages
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening: ${action['title']}...'), backgroundColor: AppColors.info),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.purple, Colors.purple.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getActionIcon(action['icon']), color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: Text(action['title'], style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text))),
                    Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 16),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  IconData _getActionIcon(String? iconName) {
    switch (iconName) {
      case 'upload_file': return Icons.upload_file;
      case 'people': return Icons.people;
      case 'group': return Icons.group;
      case 'assessment': return Icons.assessment;
      default: return Icons.arrow_forward;
    }
  }

  Widget _buildDepartmentInfo() {
    final deptInfo = _dashboardData?['departmentInfo'] ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🏛️ Department Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border(left: BorderSide(color: Colors.purple, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deptInfo['name'] ?? 'Department', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              SizedBox(height: 8),
              Text('Code: ${deptInfo['code'] ?? 'N/A'}', style: TextStyle(color: AppColors.textSecondary)),
              SizedBox(height: 4),
              Text('HOD: ${deptInfo['hodName'] ?? 'N/A'}', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentStudents() {
    final students = _dashboardData?['recentStudents'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('👥 Recent Students in Department', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: students.map<Widget>((student) {
              return Padding(
                padding: EdgeInsets.only(bottom: students.last == student ? 0 : 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(student['name']?.toString()[0] ?? 'S'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                          Text(student['email'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(student['joinedAt'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.info)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
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
            Text('Failed to load HOD dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
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