import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:college_erp/utils/theme.dart';
import 'package:college_erp/widgets/custom_textfield.dart';
import 'package:college_erp/widgets/custom_button.dart';
import 'package:college_erp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill for easy testing
    _emailController.text = 'alice.brown@college.edu';
    _passwordController.text = 'password123';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      // Get user safely with null check
      final user = authProvider.user;
      
      if (user == null) {
        throw Exception('User data not available');
      }
      
      print('✅ Login successful! Role: ${user.role}');
      
      String navigateTo;
      
      // Navigation logic based on role
      switch (user?.role) {
        case 'admin':
          navigateTo = '/admin/home';
          break;
        case 'hod':
          navigateTo = '/hod/home';
          break;
        case 'teacher':
          navigateTo = '/hod/home'; // HODs see HOD dashboard
          break;
        case 'student':
          navigateTo = '/student/home';
          break;
        default:
          navigateTo = '/student/home'; // Fallback
          break;
      }
      
      print('🚀 Navigating to: $navigateTo');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back! Redirecting to $navigateTo...'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate after short delay
      Future.delayed(Duration(milliseconds: 1500), () {
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(
          context,
          navigateTo,
        );
      });
      
    } catch (error) {
      print('❌ Login error: $error');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${error.toString()}'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 32),
                
                Text(
                  'College ERP',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'Smart Campus Management',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                SizedBox(height: 48),
                
                // Login Form
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 16),
                        
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Email Field - ✅ FIXED
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Password Field - ✅ FIXED
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          suffixIcon: _obscurePassword 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Remember Me & Forgot Password Row - ✅ FIXED
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  // ✅ FIXED: Removed problematic onChanged
                                  activeColor: AppColors.primary,
                                  checkColor: AppColors.primary.withOpacity(0.3),
                                  onChanged: (bool? value) {  // ✅ ADDED ? to make nullable
                                    setState(() {
                                      _rememberMe = value ?? false;  // ✅ Use ?? for default
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement forgot password
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Login Button - ✅ WORKING
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CustomButton(
                            text: _isLoading ? 'Signing In...' : 'Login',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleLogin,
                            fullWidth: true,
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to registration
                              },
                              child: Text(
                                'Register Now',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Test Credentials Info
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔧 Test Credentials:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Student: student@college.edu / student123',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Admin: admin@college.edu / admin123',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}