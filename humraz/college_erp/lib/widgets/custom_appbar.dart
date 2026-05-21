import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we can pop
    final canPop = Navigator.canPop(context);
    
    return AppBar(
      title: Text(title, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton && canPop
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text),
              onPressed: onBackPress ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            )
          : null,
      actions: actions,
      iconTheme: IconThemeData(color: AppColors.text),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
} 