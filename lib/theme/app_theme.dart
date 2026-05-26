import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color primaryLight = Color(0xFF4DD4E3);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFE66D);
  static const Color info = Color(0xFF74B9FF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const String appName = "College ERP";
  static const double defaultPadding = 20.0;
  static const double borderRadius = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.card,
      error: AppColors.error,
    ),
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 28, color: AppColors.text),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.text),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.text),
      labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.text),
    ),
  );
}