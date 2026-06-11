// lib/modules/principal/principal_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PrincipalDashboard extends StatelessWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Command Panel'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).terminateSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('College Operations Summary Ledger', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              color: Colors.blueGrey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.around,
                  children: [
                    _buildExecutiveSummaryItem('Total Revenue Collected', '₹12,45,000', Colors.green.shade700),
                    const VerticalDivider(),
                    _buildExecutiveSummaryItem('Active Grievances', '3 Open Tickets', Colors.orange.shade900),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Inter-Department Efficiency Ranking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRankRow('1', 'Computer Applications (BCA)', '92.4% Attendance'),
            _buildRankRow('2', 'Mechanical Engineering (MECH)', '86.1% Attendance'),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveSummaryItem(String label, String val, Color highlight) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: highlight)),
      ],
    );
  }

  Widget _buildRankRow(String rank, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.blueGrey, child: Text(rank, style: const TextStyle(color: Colors.white))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}