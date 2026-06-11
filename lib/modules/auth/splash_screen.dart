// lib/modules/auth/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _evaluateSessionState();
  }

  Future<void> _evaluateSessionState() async {
    await Future.delayed(const Duration(seconds: 2)); // System initialization loop simulation
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard_${auth.userRole?.toLowerCase()}');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 85, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'EDUSPHERE ERP', 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.indigo)
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(strokeWidth: 2.5, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}