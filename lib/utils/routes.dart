import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {

    '/login': (context) => const LoginPage(),

  };
}