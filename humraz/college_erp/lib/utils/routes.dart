import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:college_erp/auth/splash_screen.dart';
import 'package:college_erp/auth/login_page.dart';
import 'package:college_erp/auth/role_selection.dart';
import 'package:college_erp/student/student_dashboard.dart';

// Global navigator key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      
      // Student Routes
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const StudentDashboard(),
      ),
      
      // Teacher Routes (placeholder)
      GoRoute(
        path: '/teacher/home',
        builder: (context, state) => Scaffold(
          backgroundColor: Color(0xFF222831),
          body: Center(child: Text('Teacher Dashboard', style: TextStyle(color: Color(0xFFEEEEEE)))),
        ),
      ),
      
      // Admin Routes (placeholder)
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => Scaffold(
          backgroundColor: Color(0xFF222831),
          body: Center(child: Text('Admin Dashboard', style: TextStyle(color: Color(0xFFEEEEEE)))),
        ),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Color(0xFF222831),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6B6B)),
            SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEEEEEE)),
            ),
            SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00ADB5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Go Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );

  // Static navigation methods
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }
  
  static void goToStudentHome(BuildContext context) {
    context.go('/student/home');
  }
  
  static void goToTeacherHome(BuildContext context) {
    context.go('/teacher/home');
  }
  
  static void goToAdminHome(BuildContext context) {
    context.go('/admin/home');
  }

  static void goToRoleSelection(BuildContext context) {
    context.go('/role-selection');
  }
}