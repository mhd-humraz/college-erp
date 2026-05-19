import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  State<LeaveManagementPage> createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> {
  List<dynamic> leaveRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/leave'); // Ensure this route exists
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      setState(() {
        leaveRequests = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLeaveStatus(String id, bool approved) async {
    try {
      await ApiService.put('/leave/$id', {'approved': approved});
      _fetchLeaves(); // Refresh
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approved ? "Leave Approved" : "Leave Rejected")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Leave Management", style: TextStyle(color: AppColors.text))),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  final req = leaveRequests[index];
                  bool isApproved = req['approved'] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CircleAvatar(backgroundColor: AppColors.primary, child: Text((req['name'] ?? 'U')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(req['name'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(req['date'] ?? '', style: const TextStyle(color: Colors.grey))])),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isApproved ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(20)), child: Text(isApproved ? "Approved" : "Pending", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ]),
                        const SizedBox(height: 18),
                        const Text("Reason", style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(req['reason'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 15, height: 1.5)),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () => _updateLeaveStatus(req['_id'], true), child: const Text("Approve", style: TextStyle(color: Colors.white)))),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)), onPressed: () => _updateLeaveStatus(req['_id'], false), child: const Text("Reject", style: TextStyle(color: Colors.white)))),
                        ]),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}