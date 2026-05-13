import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}
class AppConstants {
  static const String appName = "College ERP";

  static const double defaultPadding = 20.0;

  static const double borderRadius = 20.0;
}
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primary,

    fontFamily: 'Poppins',

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    ),

    cardColor: AppColors.card,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 28,
        color: AppColors.text,
      ),

      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.text,
      ),

      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: AppColors.text,
      ),

      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.text,
      ),
    ),
  );
}