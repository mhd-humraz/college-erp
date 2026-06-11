// lib/core/app_theme.dart 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryIndigo,
        surface: surfaceLight,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      // 🚀 THE FIX: Swapped out 'CardTheme' for the correct 'CardThemeData' constructor token
      cardTheme: CardThemeData(
        elevation: 2,
        color: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryIndigo,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      // 🚀 THE FIX: Swapped out 'CardTheme' for the correct 'CardThemeData' constructor token
      cardTheme: CardThemeData(
        elevation: 2,
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }
  // Spacing System
static const double spaceXS = 8.0;
static const double spaceSM = 12.0;
static const double spaceMD = 16.0;
static const double spaceLG = 24.0;
static const double spaceXL = 32.0;

// Accent Colors
static const Color accentTeal = Color(0xFF009688);
static const Color adminAlertRed = Color(0xFFD32F2F);
static const Color successGreen = Color(0xFF2E7D32);
static const Color warningOrange = Color(0xFFF57C00);

// Border Radius
static BorderRadius radiusSM =
    BorderRadius.circular(6.0);

static BorderRadius radiusMD =
    BorderRadius.circular(12.0);

static BorderRadius radiusLG =
    BorderRadius.circular(18.0);
}