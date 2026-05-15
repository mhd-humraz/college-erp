import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Profile',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF222831),
      ),
      home: const StudentProfilePage(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TYPOGRAPHY
// ═══════════════════════════════════════════════════════════════════════

class HeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign? align;

  const HeadingText(
    this.text, {
    super.key,
    this.fontSize = 20,
    this.color,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: color ?? const Color(0xFFEEEEEE),
      ),
    );
  }
}

class DashboardTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;

  const DashboardTitle(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        color: color ?? const Color(0xFFEEEEEE),
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  const BodyText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        color: color ?? const Color(0xFFEEEEEE),
      ),
    );
  }
}

class SmallLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign? align;

  const SmallLabel(
    this.text, {
    super.key,
    this.fontSize = 12,
    this.color,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
        color: color ?? const Color(0xFFEEEEEE),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// REUSABLE COMPONENTS
// ═══════════════════════════════════════════════════════════════════════

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallLabel(
          label,
          fontSize: 10,
          color: const Color(0xFF00ADB5),
        ),
        const SizedBox(height: 4),
        BodyText(
          value,
          fontSize: 12,
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x1A00ADB5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00ADB5),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallLabel(
                  label,
                  fontSize: 10,
                  color: const Color(0x99EEEEEE),
                ),
                const SizedBox(height: 3),
                BodyText(
                  value,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF393E46),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x14EEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTitle(
            title,
            fontSize: 15,
            color: const Color(0xFF00ADB5),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            children: [
              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(
                    Icons.arrow_back_ios_new_rounded,
                    () {
                      Navigator.pop(context);
                    },
                  ),
                  const HeadingText(
                    'Student Profile',
                    fontSize: 18,
                  ),
                  _navButton(
                    Icons.edit_outlined,
                    () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF393E46),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x14EEEEEE),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PROFILE IMAGE
                        Container(
                          width: 115,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF222831),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x5900ADB5),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 52,
                            color: Color(0xFF00ADB5),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const DashboardTitle(
                                'Arjun Mehta',
                                fontSize: 18,
                              ),

                              const SizedBox(height: 2),

                              const SmallLabel(
                                'Computer Science Student',
                                fontSize: 11,
                                color: Color(0xFF00ADB5),
                              ),

                              const SizedBox(height: 16),

                              _infoLine(
                                Icons.email_outlined,
                                'arjun.mehta@university.edu',
                              ),

                              const SizedBox(height: 10),

                              _infoLine(
                                Icons.phone_outlined,
                                '+91 98765 43210',
                              ),

                              const SizedBox(height: 10),

                              _infoLine(
                                Icons.cake_outlined,
                                '15 March 2003',
                              ),

                              const SizedBox(height: 10),

                              _infoLine(
                                Icons.location_on_outlined,
                                'Mumbai, Maharashtra',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Divider(
                        color: const Color(0x14EEEEEE),
                        thickness: 1,
                      ),
                    ),

                    const Row(
                      children: [
                        Expanded(
                          child: _InfoField(
                            label: 'Enrollment No',
                            value: 'CS2023/1058',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _InfoField(
                            label: 'Roll Number',
                            value: 'CS/23/58',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _InfoField(
                            label: 'Department',
                            value: 'Computer Science',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      children: [
                        Expanded(
                          child: _InfoField(
                            label: 'Semester',
                            value: '4th Semester',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _InfoField(
                            label: 'Academic Year',
                            value: '2023 - 2024',
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CONTACT SECTION
              _SectionCard(
                title: 'Contact Information',
                child: Column(
                  children: const [
                    _ContactRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: 'arjun.mehta@university.edu',
                    ),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: '+91 98765 43210',
                    ),
                    _ContactRow(
                      icon: Icons.phone_android_outlined,
                      label: 'Alternate Phone',
                      value: '+91 87654 32109',
                    ),
                    _ContactRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value:
                          'Room No. 204, Block B, Boys Hostel,\nUniversity Campus, Mumbai - 400001',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Widget _navButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF393E46),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFEEEEEE),
          size: 16,
        ),
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0x99EEEEEE),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: BodyText(
            text,
            fontSize: 11,
            color: const Color(0xCCEEEEEE),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}