import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PerformanceReports extends StatelessWidget {
  const PerformanceReports({super.key});

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
          'Performance Reports',
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
            _buildInstitutionalRating(context),
            const SizedBox(height: 24),
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            _buildProgressSection(context),
            const SizedBox(height: 24),
            _buildSubjectPerformance(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionalRating(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institutional Rating',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.text.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '4.6',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 42,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/ 5.0',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.5),
                            ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      color: AppColors.primary,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'NAAC Accreditation: A+',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                color: AppColors.primary, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {
        'icon': Icons.how_to_reg_outlined,
        'value': '91.2%',
        'label': 'Attendance Rate',
        'trend': '+1.8%',
        'up': true,
      },
      {
        'icon': Icons.assignment_turned_in_outlined,
        'value': '84.7%',
        'label': 'Assignment Done',
        'trend': '+3.2%',
        'up': true,
      },
      {
        'icon': Icons.quiz_outlined,
        'value': '78.9%',
        'label': 'Exam Performance',
        'trend': '+0.9%',
        'up': true,
      },
      {
        'icon': Icons.people_outline,
        'value': '3,012',
        'label': 'Active Students',
        'trend': '92.9%',
        'up': true,
      },
      {
        'icon': Icons.auto_graph_outlined,
        'value': '7.82',
        'label': 'Avg CGPA',
        'trend': '+0.3',
        'up': true,
      },
      {
        'icon': Icons.star_outline_rounded,
        'value': '4.6 / 5',
        'label': 'Institution Rating',
        'trend': 'NAAC A+',
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
        return _PerfStatCard(
          icon: s['icon'] as IconData,
          value: s['value'] as String,
          label: s['label'] as String,
          trend: s['trend'] as String,
          isUp: s['up'] as bool,
        );
      },
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final items = [
      {'label': 'Overall Attendance', 'value': 0.912},
      {'label': 'Assignment Completion', 'value': 0.847},
      {'label': 'Internal Exam Pass Rate', 'value': 0.889},
      {'label': 'Placement Achievement', 'value': 0.785},
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
          Text(
            'Progress Indicators',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 18),
          ...items.map((item) {
            final val = item['value'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.8),
                            ),
                      ),
                      Text(
                        '${(val * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: val,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance(BuildContext context) {
    final subjects = [
      {'name': 'Data Structures', 'avg': '82%', 'pass': '94%'},
      {'name': 'Mathematics III', 'avg': '74%', 'pass': '88%'},
      {'name': 'Database Systems', 'avg': '79%', 'pass': '91%'},
      {'name': 'Machine Learning', 'avg': '85%', 'pass': '96%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        ...subjects.map((s) => Container(
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
                    child: const Icon(Icons.book_outlined,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      s['name']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Avg: ${s['avg']}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                      Text(
                        'Pass: ${s['pass']}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.text.withOpacity(0.45),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _PerfStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool isUp;

  const _PerfStatCard({
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
                      fontSize: 20,
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