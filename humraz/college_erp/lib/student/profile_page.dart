import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_button.dart';
import 'package:college_erp/widgets/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Muhammed Humraz');
  final _emailController = TextEditingController(text: 'muhammed@college.edu');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _rollNumberController = TextEditingController(text: 'CS2021001');
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: AppColors.primary),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          'MH',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Personal Information
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: _isEditing,
              ),
              
              const SizedBox(height: 24),
              
              // Academic Information
              _buildSectionTitle('Academic Information'),
              const SizedBox(height: 16),
              _buildInfoRow('Roll Number', 'CS2021001'),
              _buildInfoRow('Department', 'Computer Science & Engineering'),
              _buildInfoRow('Course', 'B.Tech CSE'),
              _buildInfoRow('Semester', '5th Semester'),
              _buildInfoRow('Section', 'A'),
              _buildInfoRow('Batch', '2021-2025'),
              
              const SizedBox(height: 24),
              
              // Guardian Information
              _buildSectionTitle('Guardian Information'),
              const SizedBox(height: 16),
              _buildInfoRow('Guardian Name', 'Mr. Abdul Humraz'),
              _buildInfoRow('Phone', '+91 98765 12345'),
              
              const SizedBox(height: 30),
              
              if (_isEditing)
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  fullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
          Expanded(child: Text(value, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save profile changes
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success),
      );
    }
  }
}