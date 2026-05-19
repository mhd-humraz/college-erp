import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  Map<String, List<dynamic>> timetable = {};
  bool _isLoading = true;
  String selectedDay = "Monday";

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/timetable');
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      
      // Assuming data is a list of timetables or a single timetable object
      Map<String, List<dynamic>> parsedTimetable = {};
      for (var day in days) {
        parsedTimetable[day] = [];
      }

      if (data is List) {
        for (var item in data) {
          if (item.containsKey('schedule')) {
            final schedule = item['schedule'] as Map<String, dynamic>;
            schedule.forEach((day, classes) {
              if (parsedTimetable.containsKey(day)) {
                parsedTimetable[day] = classes as List<dynamic>;
              }
            });
          }
        }
      } else if (data is Map && data.containsKey('schedule')) {
        final schedule = data['schedule'] as Map<String, dynamic>;
        schedule.forEach((day, classes) {
          if (parsedTimetable.containsKey(day)) {
            parsedTimetable[day] = classes as List<dynamic>;
          }
        });
      }

      setState(() {
        timetable = parsedTimetable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Timetable", style: TextStyle(color: AppColors.text))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: selectedDay == day ? AppColors.primary : AppColors.card, borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : timetable[selectedDay]!.isEmpty 
                      ? Center(child: Text("No classes on $selectedDay", style: TextStyle(color: AppColors.text.withOpacity(0.5))))
                      : ListView.builder(
                          itemCount: timetable[selectedDay]!.length,
                          itemBuilder: (context, index) {
                            final item = timetable[selectedDay]![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['time'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 16)),
                                  Text(item['subject'] ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}