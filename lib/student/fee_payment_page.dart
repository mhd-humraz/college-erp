import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// ================= APP ROOT =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College ERP',
      theme: AppTheme.darkTheme,
      home: const FeePaymentPage(),
    );
  }
}

/// ================= COLORS =================
class AppColors {
  static const Color primary = Color(0xFF00ADB5);
  static const Color background = Color(0xFF222831);
  static const Color card = Color(0xFF393E46);
  static const Color text = Color(0xFFEEEEEE);
}

/// ================= CONSTANTS =================
class AppConstants {
  static const String appName = "College ERP";

  static const double defaultPadding = 20.0;

  static const double borderRadius = 20.0;
}

/// ================= THEME =================
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Poppins',

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    ),

    cardColor: AppColors.card,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 28,
        color: AppColors.text,
      ),

      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.text,
      ),

      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: AppColors.text,
      ),

      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.text,
      ),
    ),
  );
}

/// ================= FEE PAYMENT PAGE =================
class FeePaymentPage extends StatefulWidget {
  const FeePaymentPage({super.key});

  @override
  State<FeePaymentPage> createState() => _FeePaymentPageState();
}

class _FeePaymentPageState extends State<FeePaymentPage> {
  String selectedPaymentMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fee Payment',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            const Text(
              'Pay Your Semester Fees',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Complete your payment securely using your preferred method.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 30),

            /// ================= STUDENT DETAILS =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Student Details',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  StudentInfoRow(
                    title: 'Name',
                    value: 'Rahul Krishna',
                  ),

                  StudentInfoRow(
                    title: 'Roll No',
                    value: 'CSE2025-101',
                  ),

                  StudentInfoRow(
                    title: 'Department',
                    value: 'Computer Science',
                  ),

                  StudentInfoRow(
                    title: 'Semester',
                    value: 'Semester 6',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= FEE SUMMARY =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Fee Summary',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  FeeRow(
                    title: 'Tuition Fee',
                    amount: '₹35,000',
                  ),

                  FeeRow(
                    title: 'Library Fee',
                    amount: '₹2,000',
                  ),

                  FeeRow(
                    title: 'Lab Fee',
                    amount: '₹5,000',
                  ),

                  Divider(
                    color: Colors.white24,
                    height: 30,
                  ),

                  FeeRow(
                    title: 'Total Amount',
                    amount: '₹42,000',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= PAYMENT METHOD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  PaymentMethodTile(
                    icon: Icons.account_balance_wallet,
                    title: 'UPI Payment',
                    value: 'UPI',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),

                  PaymentMethodTile(
                    icon: Icons.credit_card,
                    title: 'Credit / Debit Card',
                    value: 'CARD',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),

                  PaymentMethodTile(
                    icon: Icons.account_balance,
                    title: 'Net Banking',
                    value: 'BANK',
                    groupValue: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            /// ================= PAY BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primary,

                      content: Text(
                        'Processing payment using $selectedPaymentMethod',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },

                child: const Text(
                  'Pay ₹42,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// ================= STUDENT INFO ROW =================
class StudentInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const StudentInfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= FEE ROW =================
class FeeRow extends StatelessWidget {
  final String title;
  final String amount;
  final bool isTotal;

  const FeeRow({
    super.key,
    required this.title,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? AppColors.text : Colors.white70,
              fontSize: isTotal ? 18 : 15,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= PAYMENT TILE =================
class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),

      child: RadioListTile<String>(
        activeColor: AppColors.primary,

        value: value,
        groupValue: groupValue,
        onChanged: onChanged,

        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),

        secondary: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }
}