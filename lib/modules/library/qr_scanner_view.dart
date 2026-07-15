// lib/modules/library/qr_scanner_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CampusQRScannerView extends StatefulWidget {
  const CampusQRScannerView({super.key});

  @override
  State<CampusQRScannerView> createState() => _CampusQRScannerViewState();
}

class _CampusQRScannerViewState extends State<CampusQRScannerView> {
  bool _isProcessingScan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EduSphere Infrastructure Scanner')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isProcessingScan) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                setState(() => _isProcessingScan = true);
                final String scannedIdentityPayload = barcodes.first.rawValue!;
                
                // Show completion feedback to user
                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.all(24),
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Identity Verified Successfully', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Data Payload payload: $scannedIdentityPayload', style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _isProcessingScan = false);
                          }, 
                          child: const Text('Acknowledge Data Stream')
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          // Scanner Overlay Mask
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}