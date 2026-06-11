// lib/modules/student/digital_id_card.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DigitalIDCard extends StatelessWidget {
  const DigitalIDCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Verification ID')),
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          width: 320,
          height: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 8))]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 45, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 15),
              const Text('Alex Mercer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Dept of Computer Applications', style: TextStyle(color: Colors.grey)),
              const Divider(height: 30, thickness: 1),
              
              // QR Matrix encoding the unique Database User Object ID reference parameter
              QrImageView(
                data: auth.token ?? 'AnonymousIdentityReferenceToken',
                version: QrVersions.auto,
                size: 180.0,
                gapless: false,
              ),
              
              const SizedBox(height: 15),
              const Text('SCAN FOR INSTITUTIONAL ACCESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey, letterSpacing: 1.5))
            ],
          ),
        ),
      ),
    );
  }
}