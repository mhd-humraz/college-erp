import 'package:flutter/material.dart';

class TimetableManagementScreen extends StatefulWidget {
  const TimetableManagementScreen({super.key});

  @override
  State<TimetableManagementScreen> createState() =>
      _TimetableManagementScreenState();
}

class _TimetableManagementScreenState
    extends State<TimetableManagementScreen> {
  String selectedDepartment = "Computer Applications";
  String selectedCourse = "BCA";
  String selectedBatch = "2024 - 2027";
  int selectedSemester = 5;
  String selectedDay = "Monday";

  final List<String> departments = [
    "Computer Applications",
    "Computer Science",
    "Management",
  ];

  final List<String> courses = [
    "BCA",
    "BSc CS",
    "MBA",
  ];

  final List<String> batches = [
    "2024 - 2027",
    "2025 - 2028",
    "2026 - 2029",
  ];

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  final List<Map<String, dynamic>> timetable = [
    {
      "day": "Monday",
      "subject": "Programming in C",
      "code": "BCA101",
      "teacher": "Rajina",
      "room": "B201",
      "startTime": "09:00 AM",
      "endTime": "10:00 AM",
      "type": "Lecture",
    },
    {
      "day": "Monday",
      "subject": "Database Management System",
      "code": "BCA201",
      "teacher": "Anjali",
      "room": "B202",
      "startTime": "10:00 AM",
      "endTime": "11:00 AM",
      "type": "Lecture",
    },
    {
      "day": "Monday",
      "subject": "DBMS Lab",
      "code": "BCAL201",
      "teacher": "Anjali",
      "room": "Computer Lab",
      "startTime": "11:00 AM",
      "endTime": "01:00 PM",
      "type": "Lab",
    },
    {
      "day": "Tuesday",
      "subject": "Computer Networks",
      "code": "BCA301",
      "teacher": "Rahul",
      "room": "B203",
      "startTime": "09:00 AM",
      "endTime": "10:00 AM",
      "type": "Lecture",
    },
  ];

  void _showClassDetails(
    Map<String, dynamic> lecture,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor:
                      Colors.redAccent.withOpacity(.15),
                  child: Icon(
                    lecture["type"] == "Lab"
                        ? Icons.computer
                        : Icons.menu_book,
                    size: 34,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  lecture["subject"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecture["code"],
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _detailTile(
                  Icons.person,
                  "Teacher",
                  lecture["teacher"],
                ),
                _detailTile(
                  Icons.meeting_room,
                  "Room",
                  lecture["room"],
                ),
                _detailTile(
                  Icons.calendar_today,
                  "Day",
                  lecture["day"],
                ),
                _detailTile(
                  Icons.schedule,
                  "Time",
                  "${lecture["startTime"]} - ${lecture["endTime"]}",
                ),
                _detailTile(
                  Icons.category,
                  "Class Type",
                  lecture["type"],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Edit Class - Coming Next",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Online Class Setup - Later",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.videocam),
                        label: const Text("Meeting"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      _confirmDelete(lecture);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete Class"),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _classDialog({
    Map<String, dynamic>? lecture,
  }) {
    final isEditing = lecture != null;

    final subjectController = TextEditingController(
      text: lecture?["subject"] ?? "",
    );

    final codeController = TextEditingController(
      text: lecture?["code"] ?? "",
    );

    final teacherController = TextEditingController(
      text: lecture?["teacher"] ?? "",
    );

    final roomController = TextEditingController(
      text: lecture?["room"] ?? "",
    );

    String day = lecture?["day"] ?? selectedDay;
    String type = lecture?["type"] ?? "Lecture";

    TimeOfDay startTime = _parseTime(
      lecture?["startTime"] ?? "09:00 AM",
    );

    TimeOfDay endTime = _parseTime(
      lecture?["endTime"] ?? "10:00 AM",
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(
                isEditing ? "Edit Class" : "Add Class",
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: "Subject",
                          prefixIcon: Icon(Icons.menu_book),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: "Subject Code",
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: teacherController,
                        decoration: const InputDecoration(
                          labelText: "Teacher",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: roomController,
                        decoration: const InputDecoration(
                          labelText: "Room",
                          prefixIcon: Icon(
                            Icons.meeting_room,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: day,
                        decoration: const InputDecoration(
                          labelText: "Day",
                          border: OutlineInputBorder(),
                        ),
                        items: days.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          dialogSetState(() {
                            day = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: "Class Type",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Lecture",
                            child: Text("Lecture"),
                          ),
                          DropdownMenuItem(
                            value: "Lab",
                            child: Text("Lab"),
                          ),
                        ],
                        onChanged: (value) {
                          dialogSetState(() {
                            type = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text("Start Time"),
                        subtitle: Text(
                          startTime.format(context),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final value = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );

                          if (value != null) {
                            dialogSetState(() {
                              startTime = value;
                            });
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text("End Time"),
                        subtitle: Text(
                          endTime.format(context),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final value = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );

                          if (value != null) {
                            dialogSetState(() {
                              endTime = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (subjectController.text.trim().isEmpty ||
                        codeController.text.trim().isEmpty ||
                        teacherController.text.trim().isEmpty ||
                        roomController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please complete all fields",
                          ),
                        ),
                      );

                      return;
                    }

                    final startMinutes =
                        startTime.hour * 60 + startTime.minute;

                    final endMinutes =
                        endTime.hour * 60 + endTime.minute;

                    if (endMinutes <= startMinutes) {
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "End time must be after start time",
                          ),
                        ),
                      );

                      return;
                    }

                    final hasConflict = timetable.any((item) {
                      if (identical(item, lecture)) {
                        return false;
                      }

                      if (item["day"] != day) {
                        return false;
                      }

                      final itemStart =
                          _parseTimeToMinutes(item["startTime"]);

                      final itemEnd =
                          _parseTimeToMinutes(item["endTime"]);

                      final overlaps =
                          startMinutes < itemEnd &&
                          endMinutes > itemStart;

                      final sameTeacher =
                          item["teacher"]
                                  .toString()
                                  .toLowerCase() ==
                              teacherController.text
                                  .trim()
                                  .toLowerCase();

                      final sameRoom =
                          item["room"]
                                  .toString()
                                  .toLowerCase() ==
                              roomController.text
                                  .trim()
                                  .toLowerCase();

                      return overlaps &&
                          (sameTeacher || sameRoom);
                    });

                    if (hasConflict) {
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Conflict detected: Teacher or room is already occupied.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );

                      return;
                    }

                    final classData = {
                      "day": day,
                      "subject": subjectController.text.trim(),
                      "code": codeController.text.trim(),
                      "teacher": teacherController.text.trim(),
                      "room": roomController.text.trim(),
                      "startTime": _formatTime(startTime),
                      "endTime": _formatTime(endTime),
                      "type": type,
                    };

                    setState(() {
                      if (isEditing) {
                        lecture
                          ..clear()
                          ..addAll(classData);
                      } else {
                        timetable.add(classData);
                      }

                      selectedDay = day;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    isEditing ? "Update" : "Add Class",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(" ");

    final timeParts = parts[0].split(":");

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final period = parts[1].toUpperCase();

    if (period == "PM" && hour != 12) {
      hour += 12;
    }

    if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  int _parseTimeToMinutes(String value) {
    final time = _parseTime(value);

    return time.hour * 60 + time.minute;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, "0");

    final period =
        time.period == DayPeriod.am ? "AM" : "PM";

    return "${hour.toString().padLeft(2, "0")}:$minute $period";
  }

  void _confirmDelete(
    Map<String, dynamic> lecture,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Class"),
          content: Text(
            "Delete ${lecture["subject"]} from the timetable?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  timetable.remove(lecture);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Class removed from timetable",
                    ),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Colors.redAccent.withOpacity(.12),
        child: Icon(
          icon,
          color: Colors.redAccent,
        ),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayClasses = timetable
        .where(
          (lecture) =>
              lecture["day"] == selectedDay,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Timetable Management",
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Add Class Dialog - Coming Next",
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Class"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Academic Schedule",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Configure weekly lecture and lab schedules.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Classes",
                    timetable.length.toString(),
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "Teachers",
                    timetable
                        .map(
                          (e) => e["teacher"],
                        )
                        .toSet()
                        .length
                        .toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "Rooms",
                    timetable
                        .map(
                          (e) => e["room"],
                        )
                        .toSet()
                        .length
                        .toString(),
                    Icons.meeting_room,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              "Weekly Schedule",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final day = days[index];
                  final selected =
                      selectedDay == day;

                  return ChoiceChip(
                    label: Text(day),
                    selected: selected,
                    selectedColor:
                        Colors.redAccent.shade100,
                    onSelected: (_) {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (dayClasses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                child: const Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No classes scheduled",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: dayClasses.length,
                itemBuilder: (_, index) {
                  final lecture =
                      dayClasses[index];

                  return _classCard(lecture);
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: const InputDecoration(
                labelText: "Department",
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              items: departments.map((department) {
                return DropdownMenuItem(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child:
                      DropdownButtonFormField<String>(
                    value: selectedCourse,
                    decoration: const InputDecoration(
                      labelText: "Course",
                      border: OutlineInputBorder(),
                    ),
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourse = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      DropdownButtonFormField<int>(
                    value: selectedSemester,
                    decoration: const InputDecoration(
                      labelText: "Semester",
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      6,
                      (index) {
                        final semester = index + 1;

                        return DropdownMenuItem(
                          value: semester,
                          child: Text(
                            "Semester $semester",
                          ),
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedSemester = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedBatch,
              decoration: const InputDecoration(
                labelText: "Batch",
                prefixIcon: Icon(Icons.groups),
                border: OutlineInputBorder(),
              ),
              items: batches.map((batch) {
                return DropdownMenuItem(
                  value: batch,
                  child: Text(batch),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBatch = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(
    Map<String, dynamic> lecture,
  ) {
    final isLab = lecture["type"] == "Lab";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _showClassDetails(lecture);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 65,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: isLab
                      ? Colors.purple.withOpacity(.12)
                      : Colors.redAccent.withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      lecture["startTime"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_downward,
                      size: 15,
                    ),
                    Text(
                      lecture["endTime"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture["subject"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lecture["code"],
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _infoText(
                          Icons.person_outline,
                          lecture["teacher"],
                        ),
                        _infoText(
                          Icons.meeting_room_outlined,
                          lecture["room"],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  lecture["type"],
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
                backgroundColor: isLab
                    ? Colors.purple.shade100
                    : Colors.blue.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}