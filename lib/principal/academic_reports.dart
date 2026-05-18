import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FinancialReports extends StatelessWidget {
  const FinancialReports({super.key});

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
          'Financial Reports',
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
            _buildRevenueSummary(context),
            const SizedBox(height: 24),
            Text(
              'Financial Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            _buildMonthlyRevenue(context),
            const SizedBox(height: 24),
            _buildScholarshipSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(BuildContext context) {
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
          Text(
            'Total Revenue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.text.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹ 4,82,50,000',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: Colors.greenAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                '+8.4% vs last academic year',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryChip(label: 'FY 2024–25'),
              const SizedBox(width: 10),
              _SummaryChip(label: 'All Depts Included'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {
        'icon': Icons.payments_outlined,
        'value': '₹4.82 Cr',
        'label': 'Fees Collected',
        'trend': '+8.4%',
        'up': true,
      },
      {
        'icon': Icons.pending_actions_outlined,
        'value': '₹38.5 L',
        'label': 'Pending Fees',
        'trend': '-12%',
        'up': false,
      },
      {
        'icon': Icons.bar_chart_rounded,
        'value': '₹40.2 L',
        'label': 'Monthly Revenue',
        'trend': '+3.1%',
        'up': true,
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'value': '₹18.6 L',
        'label': 'Scholarships',
        'trend': '142 students',
        'up': true,
      },
      {
        'icon': Icons.how_to_reg_outlined,
        'value': '2,876',
        'label': 'Paid Students',
        'trend': '88.8%',
        'up': true,
      },
      {
        'icon': Icons.warning_amber_outlined,
        'value': '364',
        'label': 'Due Payments',
        'trend': '11.2%',
        'up': false,
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
        return _FinStatCard(
          icon: s['icon'] as IconData,
          value: s['value'] as String,
          label: s['label'] as String,
          trend: s['trend'] as String,
          isUp: s['up'] as bool,
        );
      },
    );
  }

  Widget _buildMonthlyRevenue(BuildContext context) {
    final months = [
      {'month': 'Aug', 'amount': 0.65},
      {'month': 'Sep', 'amount': 0.88},
      {'month': 'Oct', 'amount': 0.72},
      {'month': 'Nov', 'amount': 0.95},
      {'month': 'Dec', 'amount': 0.60},
      {'month': 'Jan', 'amount': 1.0},
      {'month': 'Feb', 'amount': 0.82},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Revenue Trend',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
              ),
              Text(
                'In Lakhs (₹)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.text.withOpacity(0.4),
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((m) {
              final pct = m['amount'] as double;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 90 * pct,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m['month'] as String,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.5),
                              fontSize: 9,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipSection(BuildContext context) {
    final scholarships = [
      {'name': 'Merit Scholarship', 'students': '64', 'amount': '₹8.2 L'},
      {'name': 'Govt. Scholarship', 'students': '48', 'amount': '₹6.4 L'},
      {'name': 'Management Waiver', 'students': '30', 'amount': '₹4.0 L'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scholarship Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        ...scholarships.map(
          (s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.card_giftcard_outlined,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '${s['students']} students',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.45),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  s['amount']!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FinStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool isUp;

  const _FinStatCard({
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
                      fontSize: 18,
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

class _SummaryChip extends StatelessWidget {
  final String label;
  const _SummaryChip({required this.label});

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