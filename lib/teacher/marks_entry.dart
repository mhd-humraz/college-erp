import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class MarkEntryPage extends StatefulWidget {
  const MarkEntryPage({super.key});

  @override
  State<MarkEntryPage> createState() => _MarkEntryPageState();
}

class _MarkEntryPageState extends State<MarkEntryPage> {
  List<dynamic> students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/students');
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      setState(() {
        students = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> editMark(int index) async {
    final student = students[index];
    TextEditingController controller = TextEditingController(text: (student['mark'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text("Edit Mark", style: TextStyle(color: AppColors.text)),
          content: TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Enter Mark", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                try {
                  await ApiService.post('/marks/save', { // Adjust endpoint as needed
                    'studentId': student['studentId'] ?? student['_id'],
                    'mark': int.parse(controller.text),
                  });
                  setState(() => students[index]['mark'] = int.parse(controller.text));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mark Updated")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
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
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Mark Entry", style: TextStyle(color: AppColors.text))),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: AppColors.primary, child: Text((s['name'] ?? 'S')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['name'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(s['studentId'] ?? s['_id'] ?? '', style: const TextStyle(color: Colors.grey))])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)), child: Text((s['mark'] ?? 0).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                        const SizedBox(width: 12),
                        IconButton(onPressed: () => editMark(index), icon: const Icon(Icons.edit, color: AppColors.primary)),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}