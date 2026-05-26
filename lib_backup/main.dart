import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'auth/splash_screen.dart';

void main() {
  runApp(const CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  const CollegeERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}