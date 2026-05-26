import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TeacherShareMaterialsScreen extends StatefulWidget {
  const TeacherShareMaterialsScreen({super.key});

  @override
  State<TeacherShareMaterialsScreen> createState() => _TeacherShareMaterialsScreenState();
}

class _TeacherShareMaterialsScreenState extends State<TeacherShareMaterialsScreen> {
  List<dynamic> _materials = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() { 
    super.initState(); 
    _fetchMaterials(); 
  }

  Future<void> _fetchMaterials() async {
    try {
      final res = await ApiService.get('/assignments/materials');
      setState(() { 
        _materials = res.data['data'] ?? []; 
        _isLoading = false; 
      });
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png', 'zip']
    );
    
    if (result == null) return;

    setState(() => _isUploading = true);
    try {
      final res = await ApiService.postWithFile('/teacher/upload-material', result.files.single.path!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.data['message'] ?? 'Material uploaded!'),
          backgroundColor: AppColors.success,
        ));
        _fetchMaterials();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally { 
      setState(() => _isUploading = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Share Materials', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadMaterial,
        backgroundColor: AppColors.primary,
        icon: _isUploading 
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(Icons.upload_file),
        label: Text(_isUploading ? 'Uploading...' : 'Upload Material'),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _materials.isEmpty 
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                  SizedBox(height: 16),
                  Text('No materials shared yet', style: TextStyle(color: AppColors.textSecondary)),
                  Text('Tap + to upload study materials', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: _materials.length,
              itemBuilder: (ctx, index) {
                final m = _materials[index];
                return Card(
                  color: AppColors.card,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        m['fileType'] == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
                        color: AppColors.info,
                      ),
                    ),
                    title: Text(m['title'] ?? m['fileName'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                    subtitle: Text('${m['subject'] ?? ''} • ${(m['fileSize'] ?? 0 / 1024 / 1024).toStringAsFixed(1)} MB', style: TextStyle(color: AppColors.textSecondary)),
                    trailing: Text('${m['downloads'] ?? 0} ↓', style: TextStyle(color: AppColors.primary)),
                  ),
                );
              },
            ),
    );
  }
}