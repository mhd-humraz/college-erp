import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_appbar.dart';
import 'package:college_erp/services/api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _scheduleData;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final response = await apiService.get('/api/teacher/schedule');

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _scheduleData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Color> _getSubjectColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final colors = _getSubjectColors();
    final today = DateTime.now().weekday; // 1=Monday, 7=Sunday

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'My Schedule'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchSchedule,
              color: AppColors.primary,
              child: ListView.builder(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final classes = _scheduleData?[day] ?? [];
                  final isToday = (index + 1) == today;

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day Header
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: isToday 
                                      ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)])
                                      : LinearGradient(colors: [AppColors.textSecondary.withOpacity(0.2), AppColors.textSecondary.withOpacity(0.1)]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  day.substring(0, 3).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    if (isToday)
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('TODAY', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '${classes.length} classes',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),

                          // Classes List
                          if (classes.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text('No classes scheduled', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          else
                            ...List.generate(classes.length, (idx) {
                              final cls = classes[idx];
                              final color = colors[idx % colors.length];

                              return Container(
                                margin: EdgeInsets.only(bottom: idx < classes.length - 1 ? 10 : 0),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(left: BorderSide(color: color, width: 4)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.menu_book, color: color, size: 22),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cls['subject'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 15)),
                                          SizedBox(height: 2),
                                          Text(cls['course'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(cls['time'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                                        SizedBox(height: 2),
                                        Text(cls['room'] ?? 'TBA', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}