import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Color? color;
  final IconData? icon;
  
  const CustomButton({super.key, required this.text, this.onPressed, this.isLoading = false, this.fullWidth = false, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 8)],
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
      ),
    );
  }
}