import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({super.key});

  @override
  State<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends State<StudyMaterialPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  List<dynamic> materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/materials'); // Ensure this route exists
      final data = response is Map && response.containsKey('data') ? response['data'] : response;
      setState(() {
        materials = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> addMaterial() async {
    if (titleController.text.isNotEmpty && subjectController.text.isNotEmpty && linkController.text.isNotEmpty) {
      try {
        await ApiService.post('/materials', {
          'title': titleController.text,
          'subject': subjectController.text,
          'link': linkController.text,
        });

        titleController.clear();
        subjectController.clear();
        linkController.clear();
        Navigator.pop(context);
        _fetchMaterials();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Study Material Added")));
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
          title: const Text("Add Study Material", style: TextStyle(color: AppColors.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Title", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: subjectController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "Subject", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: linkController, style: const TextStyle(color: AppColors.text), decoration: InputDecoration(hintText: "File/Link URL", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), onPressed: addMaterial, child: const Text("Add", style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Study Materials", style: TextStyle(color: AppColors.text))),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final mat = materials[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mat['title'] ?? '', style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(mat['subject'] ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(mat['link'] ?? '', style: const TextStyle(color: Colors.blueAccent, fontSize: 14)),
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