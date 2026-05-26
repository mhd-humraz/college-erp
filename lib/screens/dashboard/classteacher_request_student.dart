import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ClassTeacherRequestStudentScreen extends StatefulWidget {
  const ClassTeacherRequestStudentScreen({super.key});

  @override
  State<ClassTeacherRequestStudentScreen> createState() => _ClassTeacherRequestStudentScreenState();
}

class _ClassTeacherRequestStudentScreenState extends State<ClassTeacherRequestStudentScreen> {
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (_nameCtrl.text.isEmpty || _rollCtrl.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      await ApiService.post('/class-teacher/request-student', data: {
        'studentName': _nameCtrl.text,
        'rollNumber': _rollCtrl.text,
        'reason': _reasonCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request sent to HOD!'), 
          backgroundColor: AppColors.success
        ));
        
        _nameCtrl.clear();
        _rollCtrl.clear();
        _reasonCtrl.clear();
        Navigator.pop(context);
      }
    } catch (e) { 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), 
          backgroundColor: AppColors.error
        ));
      }
    } finally { 
      setState(() => _isSubmitting = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Request Add Student', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Card(
              color: AppColors.card,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: Color(0xFFA29BFE).withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(Icons.person_add, size: 30, color: Color(0xFFA29BFE)),
                    ),
                    SizedBox(height: 16),
                    Text('Request New Student', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                    SizedBox(height: 8),
                    Text('Submit a request to HOD to add a missing student', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(controller: _nameCtrl, style: TextStyle(color: AppColors.text), decoration: InputDecoration(labelText: 'Student Name *', prefixIcon: Icon(Icons.person), filled: true, fillColor: AppColors.background)),
            SizedBox(height: 12),
            TextField(controller: _rollCtrl, style: TextStyle(color: AppColors.text), decoration: InputDecoration(labelText: 'Roll Number *', prefixIcon: Icon(Icons.confirmation_number), filled: true, fillColor: AppColors.background)),
            SizedBox(height: 12),
            TextField(controller: _reasonCtrl, style: TextStyle(color: AppColors.text), maxLines: 3, decoration: InputDecoration(labelText: 'Reason (Optional)', prefixIcon: Icon(Icons.notes), filled: true, fillColor: AppColors.background)),
            SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _isSubmitting ? null : _submitRequest, icon: _isSubmitting ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.send), label: Text(_isSubmitting ? 'Sending...' : 'Send Request to HOD'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFA29BFE))))
          ],
        ),
      ),
    );
  }
}