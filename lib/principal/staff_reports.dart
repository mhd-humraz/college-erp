import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StaffReports extends StatelessWidget {
  const StaffReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Staff Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaffOverviewHeader(context),
            const SizedBox(height: 24),
            Text(
              'Staff Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            _buildDepartmentStaff(context),
            const SizedBox(height: 24),
            _buildStaffActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffOverviewHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Staff Strength',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text.withOpacity(0.6),
                        ),
                  ),
                  Text(
                    '128 Members',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StaffChip(label: 'AY 2024–25'),
              const SizedBox(width: 10),
              _StaffChip(label: '12 Departments'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {
        'icon': Icons.people_outline,
        'value': '128',
        'label': 'Total Faculty',
        'trend': '+6 new',
        'up': true,
      },
      {
        'icon': Icons.person_pin_outlined,
        'value': '114',
        'label': 'Active Teachers',
        'trend': '89.1%',
        'up': true,
      },
      {
        'icon': Icons.account_balance_outlined,
        'value': '12',
        'label': 'Departments',
        'trend': 'Stable',
        'up': true,
      },
      {
        'icon': Icons.person_add_outlined,
        'value': '6',
        'label': 'New Recruits',
        'trend': 'This year',
        'up': true,
      },
      {
        'icon': Icons.event_available_outlined,
        'value': '93.5%',
        'label': 'Staff Attendance',
        'trend': '+0.7%',
        'up': true,
      },
      {
        'icon': Icons.supervisor_account_outlined,
        'value': '12',
        'label': 'HOD Count',
        'trend': 'All assigned',
        'up': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final s = stats[index];
        return _StaffStatCard(
          icon: s['icon'] as IconData,
          value: s['value'] as String,
          label: s['label'] as String,
          trend: s['trend'] as String,
          isUp: s['up'] as bool,
        );
      },
    );
  }

  Widget _buildDepartmentStaff(BuildContext context) {
    final departments = [
      {'dept': 'Computer Science', 'hod': 'Dr. Meena Iyer', 'count': '18', 'rating': '4.8'},
      {'dept': 'Electronics', 'hod': 'Dr. Suresh Pillai', 'count': '14', 'rating': '4.5'},
      {'dept': 'Mechanical', 'hod': 'Dr. Rajan Thomas', 'count': '16', 'rating': '4.3'},
      {'dept': 'Civil', 'hod': 'Dr. Anitha Nair', 'count': '12', 'rating': '4.2'},
      {'dept': 'Mathematics', 'hod': 'Dr. Krishnan V.', 'count': '10', 'rating': '4.6'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department-wise Staff',
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
            itemCount: departments.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.text.withOpacity(0.07),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final d = departments[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          d['dept']![0],
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['dept']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            'HOD: ${d['hod']}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.text.withOpacity(0.45),
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${d['count']} staff',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              d['rating']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.text.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStaffActivity(BuildContext context) {
    final activities = [
      {
        'icon': Icons.person_add_outlined,
        'text': 'Dr. Kavya Menon joined CS Dept',
        'time': '3d ago',
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'text': 'Best Faculty Award — Dr. Suresh',
        'time': '1w ago',
      },
      {
        'icon': Icons.event_note_outlined,
        'text': 'Faculty development program scheduled',
        'time': '2w ago',
      },
      {
        'icon': Icons.school_outlined,
        'text': 'PhD completion — Dr. Anitha Nair',
        'time': '3w ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Activity',
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
              color: AppColors.text.withOpacity(0.07),
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

class _StaffStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool isUp;

  const _StaffStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isUp ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.text.withOpacity(0.5),
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffChip extends StatelessWidget {
  final String label;
  const _StaffChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}