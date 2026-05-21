import 'package:flutter/material.dart';

class RoleSelectionDialog extends StatefulWidget {
  final String currentRole;
  
  const RoleSelectionDialog({required this.currentRole});
  
  @override
  State<RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change User Role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            SizedBox(height: 12),
            
            Text(
              'Current role: $_selectedRole',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 20),
            
            ...['admin', 'teacher', 'hod', 'student'].map((role) =>
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => Navigator.pop(context, role),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _selectedRole == role 
                          ? AppColors.primary.withOpacity(0.15) 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedRole == role 
                            ? AppColors.primary 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedRole == role 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: _selectedRole == role 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 12),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: _selectedRole == role 
                                ? AppColors.primary 
                                : AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (role == 'hod') ...[
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            child: Text(
                              'HEAD OF DEPT',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  )
}