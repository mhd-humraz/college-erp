// lib/modules/student/fee_screen.dart
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class FeeScreen extends StatelessWidget {
  const FeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Statements & Invoices')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Column(
                  children: [
                    const Text('Outstanding Invoice Dues', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: AppTheme.spaceSM),
                    const Text('₹35,000', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.adminAlertRed)),
                    const Divider(height: AppTheme.spaceXL),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {},
                      child: const Text('Pay Dues via UPI Payment Gateway'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}