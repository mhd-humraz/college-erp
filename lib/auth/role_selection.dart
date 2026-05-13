import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'login_page.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedRole;

  final List<Map<String, dynamic>> roles = [
    {
      'title': 'Student',
      'icon': Icons.school_rounded,
      'subtitle': 'Access courses & results',
    },
    {
      'title': 'Teacher',
      'icon': Icons.cast_for_education_rounded,
      'subtitle': 'Manage classes & grades',
    },
    {
      'title': 'HOD',
      'icon': Icons.supervisor_account_rounded,
      'subtitle': 'Department oversight',
    },
    {
      'title': 'Principal',
      'icon': Icons.account_balance_rounded,
      'subtitle': 'Full institution control',
    },
    {
      'title': 'Admin',
      'icon': Icons.admin_panel_settings_rounded,
      'subtitle': 'System administration',
    },
    {
      'title': 'Library',
      'icon': Icons.local_library_rounded,
      'subtitle': 'Books & resources',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRoleSelected(String role) {
    setState(() => _selectedRole = role);
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => LoginPage(role: role),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background accent
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.07),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: AppColors.text.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your role to continue',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: AppColors.text.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Role grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: roles.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        final isSelected = _selectedRole == role['title'];

                        final itemAnim = Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              0.1 + index * 0.08,
                              0.5 + index * 0.08,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        );

                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) => FadeTransition(
                            opacity: itemAnim,
                            child: ScaleTransition(
                              scale: itemAnim,
                              child: _RoleCard(
                                title: role['title'],
                                icon: role['icon'],
                                subtitle: role['subtitle'],
                                isSelected: isSelected,
                                onTap: () => _onRoleSelected(role['title']),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.text.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}