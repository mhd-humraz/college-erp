// lib/main.dart
//
// Bootstraps all providers and wires named routes.
// On startup, attempts to restore a saved session so returning users
// don't have to log in again.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/admin_provider.dart';
<<<<<<< HEAD
=======
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
>>>>>>> 2eaa39c (Add HOD, teacher and internal marks modules)

import 'modules/auth/login_screen.dart';
import 'modules/student/student_dashboard.dart';
import 'modules/teacher/teacher_dashboard.dart';
import 'modules/admin/admin_dashboard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore token before the first frame
  final auth = AuthProvider();
  await auth.tryRestoreSession();

  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => AcademicProvider()),
          ChangeNotifierProvider(create: (_) => AiProvider()),
          ChangeNotifierProvider(create: (_) => TicketProvider()),
          ChangeNotifierProvider(create: (_) => TimetableProvider()),

          // ADD THIS
          ChangeNotifierProvider(create: (_) => AdminProvider()),
<<<<<<< HEAD
=======
          ChangeNotifierProvider(create: (_) => StudentProvider(),),
          ChangeNotifierProvider(create: (_) => TeacherProvider(),),
>>>>>>> 2eaa39c (Add HOD, teacher and internal marks modules)
        ],
      child: const EduSphereApp(),
    ),
  );
}

class EduSphereApp extends StatelessWidget {
  const EduSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'EduSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),

      // If a valid session exists, skip login
      initialRoute: auth.isLoggedIn ? _routeForRole(auth.userRole) : '/login',

      routes: {
        '/login':              (_) => const LoginScreen(),
        '/admin-dashboard':    (_) => const AdminDashboard(), // Default to login if no session exists
        '/student-dashboard':  (_) => const StudentDashboard(),
        '/teacher-dashboard':  (_) => const TeacherDashboard(),
        // Add admin dashboard route when that screen is built
      },
    );
  }

  String _routeForRole(String? role) {
    switch (role) {
      case 'Teacher':
      case 'HOD':
        return '/teacher-dashboard';
      case 'Admin':
        return '/admin-dashboard';  
      default:
        return '/student-dashboard';
    }
  }
}
