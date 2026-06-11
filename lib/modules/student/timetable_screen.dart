// lib/modules/student/timetable_screen.dart
//
// FIX: Replaced 'YOUR_COURSE_OBJECT_ID_HERE' placeholder.
// The screen now accepts courseId + semester as constructor parameters,
// so the parent (StudentDashboard or navigation) passes the real values.
// If no courseId is available yet, it shows an informative empty state.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/timetable_provider.dart';

class TimetableScreen extends StatefulWidget {
  /// Pass the student's enrolled course ID and current semester.
  /// These come from StudentProfile data (fetched post-login).
  final String? courseId;
  final int semester;

  const TimetableScreen({
    super.key,
    this.courseId,
    this.semester = 1,
  });

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'Monday';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.courseId == null || widget.courseId!.isEmpty) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TimetableProvider>(context, listen: false)
          .fetchClassSchedule(
            widget.courseId!,
            widget.semester,
            auth.token ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final timetable = Provider.of<TimetableProvider>(context);
    final filteredSlots = timetable.currentSchedule
        .where((slot) => slot['dayOfWeek'] == _selectedDay)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: widget.courseId == null || widget.courseId!.isEmpty
          ? const Center(
              child: Text(
                'Course data not available.\nComplete profile setup first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Day selector
                Container(
                  height: 60,
                  color: Colors.indigo.shade50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday'
                    ].map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 8.0),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: _selectedDay == day,
                          labelStyle: TextStyle(
                            color: _selectedDay == day
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedDay = day);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Schedule list
                Expanded(
                  child: timetable.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : timetable.error != null
                          ? Center(
                              child: Text(timetable.error!,
                                  style: const TextStyle(
                                      color: Colors.red)))
                          : filteredSlots.isEmpty
                              ? const Center(
                                  child: Text(
                                      'No classes scheduled today.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredSlots.length,
                                  itemBuilder: (context, index) {
                                    final slot = filteredSlots[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.indigo.shade100,
                                          child: Text(
                                            '#${slot['hour']}',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors.indigo),
                                          ),
                                        ),
                                        title: Text(
                                          slot['subject']?['name'] ??
                                              'Subject',
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'Room: ${slot['roomNumber'] ?? '-'}'),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
    );
  }
}