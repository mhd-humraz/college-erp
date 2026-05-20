import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../models/leave_model.dart';

class LeaveManagementHOD extends StatefulWidget {
  const LeaveManagementHOD({super.key});

  @override
  State<LeaveManagementHOD> createState() => _LeaveManagementHODState();
}

class _LeaveManagementHODState extends State<LeaveManagementHOD> {
  List<LeaveRequest> pendingTeacherLeaves = [];
  List<LeaveRequest> myLeaveHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      // This is the EXACT SAME API call the Teacher makes!
      // But because the HOD is logged in, the backend returns Teacher leaves.
      final data = await ApiService.getLeaves();
      
      List<LeaveRequest> pending = [];
      List<LeaveRequest> history = [];

      for (var item in data) {
        final leave = LeaveRequest.fromJson(item);
        // HOD approves Teacher leaves
        if (leave.approverRole == 'HOD' && leave.status == 'Pending') {
          pending.add(leave);
        } 
        // HOD's own leave history (if they apply to Principal)
        else if (leave.applicantRole == 'HOD' || leave.applicantRole == 'Teacher') {
           // We also show already approved/rejected teacher leaves in history if needed,
           // but for now let's just show the HOD's own applications
           if (leave.applicantRole == 'HOD') {
             history.add(leave);
           }
        }
      }

      setState(() {
        pendingTeacherLeaves = pending;
        myLeaveHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLeaveStatus(String id, String status) async {
    try {
      await ApiService.updateLeaveStatus(leaveId: id, status: status);
      _fetchLeaves(); // Refresh
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Leave $status")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showApplyDialog() {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text("Apply for Leave (to Principal)", style: TextStyle(color: AppColors.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: fromController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "From Date (YYYY-MM-DD)", hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: toController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "To Date (YYYY-MM-DD)", hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: reasonController, maxLines: 3, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Reason", hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                try {
                  await ApiService.applyLeave(fromDate: fromController.text, toDate: toController.text, reason: reasonController.text);
                  Navigator.pop(context);
                  _fetchLeaves();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Applied to Principal")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("HOD Leave Management", style: TextStyle(color: AppColors.text)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: _showApplyDialog, // HOD applying for own leave
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchLeaves,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── SECTION 1: PENDING TEACHER REQUESTS ──
                  const Text("Pending Teacher Requests", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (pendingTeacherLeaves.isEmpty)
                    const Text("No pending requests", style: TextStyle(color: Colors.white38))
                  else
                    ...pendingTeacherLeaves.map((leave) => _buildApprovalCard(leave)),

                  const SizedBox(height: 30),

                  // ── SECTION 2: MY LEAVE HISTORY ──
                  const Text("My Leave History", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (myLeaveHistory.isEmpty)
                    const Text("No leave history", style: TextStyle(color: Colors.white38))
                  else
                    ...myLeaveHistory.map((leave) => _buildHistoryCard(leave)),
                ],
              ),
            ),
    );
  }

  // Card for Approving Teacher Leaves
  Widget _buildApprovalCard(LeaveRequest leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(leave.applicantName, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Dept: ${leave.department}", style: const TextStyle(color: Colors.grey)),
          const Divider(color: Colors.white24),
          Text("From: ${leave.fromDate}", style: const TextStyle(color: AppColors.text)),
          Text("To: ${leave.toDate}", style: const TextStyle(color: AppColors.text)),
          const SizedBox(height: 8),
          Text("Reason: ${leave.reason}", style: const TextStyle(color: AppColors.text, fontSize: 15, height: 1.5)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => _updateLeaveStatus(leave.id, 'Approved'), child: const Text("Approve", style: TextStyle(color: Colors.white)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => _updateLeaveStatus(leave.id, 'Rejected'), child: const Text("Reject", style: TextStyle(color: Colors.white)))),
          ]),
        ],
      ),
    );
  }

  // Card for HOD's Own Leave History
  Widget _buildHistoryCard(LeaveRequest leave) {
    Color statusColor = leave.status == 'Approved' ? Colors.green : leave.status == 'Rejected' ? Colors.red : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: statusColor.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("From: ${leave.fromDate}", style: const TextStyle(color: AppColors.text)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(leave.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text("To: ${leave.toDate}", style: const TextStyle(color: AppColors.text)),
          const SizedBox(height: 8),
          Text("Reason: ${leave.reason}", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}