// lib/routes/app_router.dart snippet updates

  static const String login = '/login';
  static const String studentDashboard = '/dashboard_student';
  static const String teacherDashboard = '/dashboard_teacher';
  static const String adminDashboard = '/dashboard_admin'; // 🚀 Merged Landing Target View
  static const String hodDashboard = '/dashboard_hod';     // Isolated for Dept

  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    studentDashboard: (context) => const StudentDashboard(),
    teacherDashboard: (context) => const TeacherDashboard(),
    adminDashboard: (context) => const AdminDashboard(),     // Direct mapping hook
    hodDashboard: (context) => const HodDashboard(),
  };