import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_button.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Your Role', style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your role to continue',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildRoleCard(
                    context,
                    icon: Icons.school_rounded,
                    title: 'Student',
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.person_rounded,
                    title: 'Teacher',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.business_center_rounded,
                    title: 'HOD',
                    color: Colors.red,
                    onTap: () {},
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.workspace_premium_rounded,
                    title: 'Principal',
                    color: Colors.amber,
                    onTap: () {},
                  ),
                  _buildRoleCard(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'Librarian',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}