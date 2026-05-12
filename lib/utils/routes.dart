import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../student/student_dashboard.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),

    '/student-dashboard': (context) =>
        const StudentDashboard(),
  };
}
