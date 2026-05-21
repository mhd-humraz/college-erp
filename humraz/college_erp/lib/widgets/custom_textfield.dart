import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  
  const CustomTextField({super.key, required this.controller, required this.label, required this.hint, this.prefixIcon, this.suffixIcon, this.onSuffixIconPressed, this.obscureText = false, this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
          suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon, color: AppColors.textSecondary), onPressed: onSuffixIconPressed) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}