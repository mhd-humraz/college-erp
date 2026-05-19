import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  
  List<dynamic> announcements = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final response = await ApiService.get('/notifications');
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      setState(() {
        announcements = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> addAnnouncement() async {
    if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
      try {
        await ApiService.post('/notifications', {
          'title': titleController.text,
          'message': messageController.text,
          'targetRole': 'All', // Or select role
        });
        
        titleController.clear();
        messageController.clear();
        Navigator.pop(context);
        _fetchAnnouncements(); // Refresh list

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Announcement Added")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text("New Announcement", style: TextStyle(color: AppColors.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Title", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 15),
                TextField(controller: messageController, maxLines: 4, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Message", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: addAnnouncement, child: const Text("Post", style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Announcements", style: TextStyle(color: AppColors.text))),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : announcements.isEmpty 
              ? Center(child: Text("No announcements", style: TextStyle(color: AppColors.text.withOpacity(0.5))))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final ann = announcements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [const Icon(Icons.announcement, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(ann['title'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)))]),
                            const SizedBox(height: 15),
                            Text(ann['message'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 16, height: 1.5)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.primary, child: const Icon(Icons.add), onPressed: showAddDialog),
    );
  }
}