import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/auth/splash_screen.dart';
import 'package:college_erp/auth/login_page.dart';
import 'package:college_erp/auth/role_selection.dart';
import 'package:college_erp/student/student_dashboard.dart';
import 'package:college_erp/admin/admin_dashboard.dart';
import 'package:college_erp/providers/auth_provider.dart';
import 'package:college_erp/providers/theme_provider.dart';
import 'package:college_erp/admin/user_management_page.dart';
import 'package:college_erp/teacher/mark_attendance_page.dart';
import 'package:college_erp/teacher/enter_marks_page.dart';
import 'package:college_erp/teacher/student_list_page.dart';
import 'package:college_erp/teacher/schedule_page.dart';
import 'package:college_erp/teacher/teacher_dashboard.dart';
import 'package:college_erp/hod/hod_dashboard.dart'; // ✅ ADD THIS LINE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF222831),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  const CollegeERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'College ERP',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            initialRoute: '/',
            routes: {
               '/': (context) => const SplashScreen(),
               '/login': (context) => const LoginPage(),
               '/role-selection': (context) => const RoleSelectionPage(),
               '/hod/home': (context) => const HODDashboard(),
               '/student/home': (context) => const StudentDashboard(),
               '/teacher/home': (context) => const TeacherDashboard(),
               '/admin/home': (context) => const AdminDashboard(), // ✅ Admin Dashboard
               '/admin/users': (context) => const UserManagementPage(), // ✅ NEW! User Management
               // Teacher Routes
              '/teacher/home': (context) => const TeacherDashboard(),
              '/teacher/attendance': (context) => const MarkAttendancePage(),
              '/teacher/marks': (context) => const EnterMarksPage(),
              '/teacher/students': (context) => const StudentListPage(),
              '/teacher/schedule': (context) => const SchedulePage(),
            },
          );
        },
      ),
    );
  }

  static Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.background),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              '$title',
              style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}