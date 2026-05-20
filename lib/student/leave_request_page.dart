// lib/student/leave_request_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/leave_model.dart';

/// LEAVE REQUEST PAGE
class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  /// COLORS
  final Color primary = const Color(0xFF222831);
  final Color secondary = const Color(0xFF393E46);
  final Color accent = const Color(0xFF00ADB5);
  final Color light = const Color(0xFFEEEEEE);

  /// CONTROLLERS
  final TextEditingController reasonController = TextEditingController();

  /// DATE VARIABLES
  DateTime? startDate;
  DateTime? endDate;

  /// TIME VARIABLES
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  /// STORE REQUESTS FROM BACKEND
  List<LeaveRequest> myLeaves = [];
  
  /// LOADING STATES
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  /// FETCH LEAVES FROM BACKEND (CLEANED UP)
  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      // Calls GET /api/leave -> Backend returns only this student's leaves
      final data = await ApiService.getLeaves();
      setState(() {
        myLeaves = data.map((e) => LeaveRequest.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load leaves: $e")),
        );
      }
    }
  }

  /// PICK DATE
  Future<void> pickDate(bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  /// PICK TIME
  Future<void> pickTime(bool isStart) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  /// SUBMIT FUNCTION TO BACKEND (CLEANED UP)
  Future<void> submitLeave() async {
    if (startDate == null || endDate == null || startTime == null || endTime == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Format: "YYYY-MM-DD HH:MM AM/PM"
      final fromString = "${startDate.toString().split(" ")[0]} ${startTime!.format(context)}";
      final toString = "${endDate.toString().split(" ")[0]} ${endTime!.format(context)}";

      // Calls POST /api/leave/apply -> Backend sets approverRole to 'Teacher'
      await ApiService.applyLeave(
        fromDate: fromString,
        toDate: toString,
        reason: reasonController.text,
      );

      /// CLEAR FORM
      setState(() {
        startDate = null;
        endDate = null;
        startTime = null;
        endTime = null;
        reasonController.clear();
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: accent,
          content: const Text("Leave Request Submitted to Teacher"),
        ),
      );

      _fetchLeaves(); // Refresh the list below
      
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 800;

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 15 : 30),
          child: Column(
            children: [
              /// TOP BAR
              Row(
                children: [
                  /// BACK BUTTON
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: light),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Leave Request",
                    style: TextStyle(
                      color: light,
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// MAIN FORM CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 30),
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP TABS (Visual Only)
                    Row(
                      children: [
                        tabButton("Apply Leave", Icons.note_add, true),
                        const SizedBox(width: 15),
                        tabButton("Leave Details", Icons.list_alt, false),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// DATE FIELDS
                    isMobile
                        ? Column(
                            children: [
                              buildDateField("Start Date", startDate, true),
                              const SizedBox(height: 20),
                              buildDateField("End Date", endDate, false),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: buildDateField("Start Date", startDate, true)),
                              const SizedBox(width: 20),
                              Expanded(child: buildDateField("End Date", endDate, false)),
                            ],
                          ),

                    const SizedBox(height: 25),

                    /// TIME FIELDS
                    isMobile
                        ? Column(
                            children: [
                              buildTimeField("Start Time", startTime, true),
                              const SizedBox(height: 20),
                              buildTimeField("End Time", endTime, false),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: buildTimeField("Start Time", startTime, true)),
                              const SizedBox(width: 20),
                              Expanded(child: buildTimeField("End Time", endTime, false)),
                            ],
                          ),

                    const SizedBox(height: 30),

                    /// REASON LABEL
                    Text("Reason", style: TextStyle(color: light, fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),

                    /// REASON FIELD
                    TextField(
                      controller: reasonController,
                      maxLines: 5,
                      style: TextStyle(color: light),
                      decoration: InputDecoration(
                        hintText: "Enter leave reason...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: primary.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: 180,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: _isSubmitting ? null : submitLeave,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "SUBMIT",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              /// STORED REQUEST TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Requested Leaves",
                  style: TextStyle(color: light, fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 20),

              /// REQUEST LIST
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: accent))
                  : myLeaves.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: secondary,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text("No Leave Requests Yet", style: TextStyle(color: light.withOpacity(0.7))),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myLeaves.length,
                          itemBuilder: (context, index) {
                            final leave = myLeaves[index];

                            // Determine status color
                            Color statusColor = Colors.orange; // Pending
                            if (leave.status == 'Approved') statusColor = Colors.green;
                            if (leave.status == 'Rejected') statusColor = Colors.redAccent;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status Badge
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        leave.status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("From : ${leave.fromDate}", style: TextStyle(color: light, fontSize: 15)),
                                  const SizedBox(height: 10),
                                  Text("To : ${leave.toDate}", style: TextStyle(color: light, fontSize: 15)),
                                  const SizedBox(height: 10),
                                  Text("Reason : ${leave.reason}", style: TextStyle(color: light, fontSize: 15)),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  /// DATE FIELD
  Widget buildDateField(String title, DateTime? date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: light, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => pickDate(isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date == null ? "Select Date" : date.toString().split(" ")[0], style: TextStyle(color: light, fontSize: 14)),
                Icon(Icons.calendar_month, color: accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// TIME FIELD
  Widget buildTimeField(String title, TimeOfDay? time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: light, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => pickTime(isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time == null ? "Select Time" : time.format(context), style: TextStyle(color: light, fontSize: 14)),
                Icon(Icons.access_time, color: accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// TAB BUTTON
  Widget tabButton(String title, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: active ? accent : primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}