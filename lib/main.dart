import 'package:flutter/material.dart';

import 'utils/theme.dart';
import 'utils/routes.dart';

void main() {
  runApp(const CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  const CollegeERPApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'College ERP',

      // Theme
      theme: AppTheme.darkTheme,

      // First Screen
      initialRoute: '/login',

      // Routes
      routes: AppRoutes.routes,
    );
  }
}