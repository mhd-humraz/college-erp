import 'dart:async';
import 'package:flutter/material.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/services/auth_service.dart';
import 'package:college_erp/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _fadeController.forward());
    
    // Start navigation after splash
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    try {
      final isLoggedIn = await AuthService().isLoggedIn();
      
      if (isLoggedIn) {
        final user = await AuthService().getCurrentUser();
        
        if (user != null && mounted) {
          // Navigate based on user role using standard Navigator
          switch (user.role) {
            case 'student':
              Navigator.pushReplacementNamed(context, '/student/home');
              break;
            case 'teacher':
              Navigator.pushReplacementNamed(context, '/teacher/home');
              break;
            case 'admin':
              Navigator.pushReplacementNamed(context, '/admin/home');
              break;
            case 'hod':
              Navigator.pushReplacementNamed(context, '/admin/home'); // HOD uses admin for now
              break;
            default:
              Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
      }
      
      // Not logged in - go to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Splash navigation error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _controller.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Fade-in Text
            FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  Text(
                    'College ERP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Smart Campus Management',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}