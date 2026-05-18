import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'academic_reports.dart';
import 'financial_reports.dart';
import 'performance_reports.dart';
import 'staff_reports.dart';

class PrincipalDashboard extends StatelessWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 28),
              _buildStatsRow(context),
              const SizedBox(height: 28),
              Text(
                'Modules',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDashboardGrid(context),
              const SizedBox(height: 28),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withOpacity(0.6),
                    ),
              ),
              Text(
                'Dr. Rajesh Kumar',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
              ),
              Text(
                'Principal • St. Xavier\'s College',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.notifications_outlined,
              color: AppColors.text.withOpacity(0.8), size: 22),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = [
      {'icon': Icons.school_outlined, 'value': '3,240', 'label': 'Students'},
      {'icon': Icons.people_outline, 'value': '128', 'label': 'Faculty'},
      {'icon': Icons.account_balance_outlined, 'value': '12', 'label': 'Depts'},
      {'icon': Icons.bar_chart_rounded, 'value': '91%', 'label': 'Attendance'},
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: s == stats.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s['icon'] as IconData,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  s['value'] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.text.withOpacity(0.5),
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    final modules = [
      {
        'icon': Icons.menu_book_outlined,
        'title': 'Academic Reports',
        'desc': 'CGPA, results & performance',
        'route': const AcademicReports(),
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Financial Reports',
        'desc': 'Fees, revenue & scholarships',
        'route': const FinancialReports(),
      },
      {
        'icon': Icons.insights_outlined,
        'title': 'Performance',
        'desc': 'Attendance & exam analytics',
        'route': const PerformanceReports(),
      },
      {
        'icon': Icons.badge_outlined,
        'title': 'Staff Reports',
        'desc': 'Faculty & department stats',
        'route': const StaffReports(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        return _DashboardCard(
          icon: m['icon'] as IconData,
          title: m['title'] as String,
          desc: m['desc'] as String,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => m['route'] as Widget),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      {'icon': Icons.check_circle_outline, 'text': 'Semester results published', 'time': '2h ago'},
      {'icon': Icons.person_add_outlined, 'text': 'New faculty onboarded — CS Dept', 'time': '5h ago'},
      {'icon': Icons.payment_outlined, 'text': 'Fee collection report ready', 'time': '1d ago'},
      {'icon': Icons.event_note_outlined, 'text': 'Board meeting scheduled', 'time': '2d ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.text.withOpacity(0.08),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final a = activities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a['icon'] as IconData,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        a['text'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.85),
                            ),
                      ),
                    ),
                    Text(
                      a['time'] as String,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.text.withOpacity(0.4),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      desc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.text.withOpacity(0.5),
                            fontSize: 11,
                          ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}