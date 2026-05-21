import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/dashboard_card.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';
import 'package:college_erp/models/user_model.dart';
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      final response = await apiService.get('/api/admin/dashboard');  // ✅ CORRECT!

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _dashboardData = response.data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
      }
    } catch (e) {
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
      appBar: CustomAppBar(title: 'Admin Dashboard'),
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
                        // Welcome Section
                        _buildWelcomeSection(),
                        
                        SizedBox(height: 24),
                        
                        // Overview Cards Grid
                        _buildOverviewCards(),
                        
                        SizedBox(height: 24),
                        
                        // Revenue Section
                        _buildRevenueSection(),
                        
                        SizedBox(height: 24),
                        
                        // Quick Actions
                        _buildQuickActions(),
                        
                        SizedBox(height: 24),
                        
                        // Department Stats
                        _buildDepartmentStats(),
                        
                        SizedBox(height: 24),
                        
                        // Recent Activity
                        _buildRecentActivity(),
                        
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
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
            Text(
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
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

  Widget _buildWelcomeSection() {
    final overview = _dashboardData?['overview'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, size: 32, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchDashboardData,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Welcome back, Administrator! 👋',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
          SizedBox(height: 8),
          Text(
            'You have ${overview['recentUsers'] ?? 0} new registrations this week',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final overview = _dashboardData?['overview'] ?? {};
    
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        DashboardCard(
          title: 'Total Students',
          value: '${overview['totalStudents'] ?? 0}',
          icon: Icons.school_rounded,
          color: AppColors.primary,
          subtitle: 'Enrolled students',
        ),
        DashboardCard(
          title: 'Total Teachers',
          value: '${overview['totalTeachers'] ?? 0}',
          icon: Icons.person_rounded,
          color: Colors.orange,
          subtitle: 'Active faculty',
        ),
        DashboardCard(
          title: 'Departments',
          value: '${overview['totalDepartments'] ?? 0}',
          icon: Icons.business_rounded,
          color: Colors.purple,
          subtitle: 'Academic depts',
        ),
        DashboardCard(
          title: 'Courses',
          value: '${overview['totalCourses'] ?? 0}',
          icon: Icons.menu_book_rounded,
          color: Colors.teal,
          subtitle: 'Programs offered',
        ),
      ],
    );
  }

  Widget _buildRevenueSection() {
    final revenue = _dashboardData?['revenue'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💰 Revenue Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${revenue['collectionRate'] ?? 0}% Collected',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRevenueItem('Total Expected', '₹${_formatNumber(revenue['totalExpected'] ?? 0)}', Icons.account_balance_wallet, AppColors.info),
              _buildRevenueItem('Collected', '₹${_formatNumber(revenue['totalRevenue'] ?? 0)}', Icons.check_circle, AppColors.success),
              _buildRevenueItem('Pending', '₹${_formatNumber(revenue['pendingRevenue'] ?? 0)}', Icons.pending, AppColors.warning),
            ],
          ),
          
          SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: (revenue['collectionRate'] ?? 0) / 100,
            minHeight: 8,
            backgroundColor: AppColors.textSecondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
          
          SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${revenue['studentsPaid'] ?? 0} students paid', style: TextStyle(fontSize: 12, color: AppColors.success)),
              Text('${revenue['studentsPending'] ?? 0} pending', style: TextStyle(fontSize: 12, color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = _dashboardData?['quickActions'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚡ Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        SizedBox(height: 16),
        
        // ⭐ NEW: User Management Button (Prominent!)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // ✅ NAVIGATE TO USER MANAGEMENT PAGE!
                Navigator.pushNamed(context, '/admin/users');
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded, size: 32, color: Colors.white),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Upload CSV • Manage Staff • Set Roles',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded, size: 24, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Other Action Buttons (Grid Layout)
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: List.generate(actions.length, (index) {
            final action = actions[index];
            
            // Skip first two actions (we replaced them with User Management)
            if (index < 2) return SizedBox.shrink();
            
            return Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
              ),
              child: InkWell(
                onTap: () {
                  // Handle other actions based on title
                  _handleQuickAction(action);
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_getIcon(action['icon']), color: AppColors.primary, size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(child: Text(action['title'], style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 13))),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _handleQuickAction(Map<String, dynamic> action) {
    final title = action['title']?.toString().toLowerCase() ?? '';
    
    switch (title) {
      case 'add student':
      case 'add teacher':
        // Navigate to user management for adding users
        Navigator.pushNamed(context, '/admin/users');
        break;
        
      case 'create notice':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📢 Notification center coming soon!'), backgroundColor: AppColors.info),
        );
        break;
        
      case 'view reports':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📊 Reports & analytics coming soon!'), backgroundColor: AppColors.info),
        );
        break;
        
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ ${action['title']} - Coming soon!'), backgroundColor: AppColors.warning),
        );
    }
  }
  
  Widget _buildDepartmentStats() {
    final departments = _dashboardData?['departments'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏛️ Department Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        SizedBox(height: 16),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: List.generate(departments.length > 6 ? 6 : departments.length, (index) {
              final dept = departments[index];
              final maxStudents = departments.isNotEmpty
                  ? departments.map((d) => d['studentCount'] ?? 0).reduce((a, b) => a > b ? a : b)
                  : 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: index < departments.length - 1 ? 16 : 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dept['departmentName'] ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                        Text(
                          '${dept['studentCount'] ?? 0} Students',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxStudents > 0 ? (dept['studentCount'] ?? 0) / maxStudents : 0,
                        minHeight: 6,
                        backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = _dashboardData?['recentActivity'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📋 Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getActivityColor(activity['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_getActivityIcon(activity['type']), color: _getActivityColor(activity['type']), size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['action'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
                          Text(activity['time'], style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'person_add': return Icons.person_add;
      case 'notification_add': return Icons.add_alert;
      case 'assessment': return Icons.assessment;
      default: return Icons.arrow_forward;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'user': return AppColors.primary;
      case 'payment': return AppColors.success;
      case 'attendance': return AppColors.warning;
      case 'notification': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'user': return Icons.person_add;
      case 'payment': return Icons.payment;
      case 'attendance': return Icons.check_circle;
      case 'notification': return Icons.notifications;
      default: return Icons.info;
    }
  }

  String _formatNumber(dynamic number) {
    if (number is int) {
      return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } else if (number is double) {
      return number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }
    return number.toString();
  }
}