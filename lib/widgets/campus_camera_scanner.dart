// lib/widgets/campus_camera_scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CampusCameraScanner extends StatefulWidget {
  final String scanningModeType; // Supports classification context tokens: 'LIBRARY' or 'ATTENDANCE'
  final String userAuthToken;

  const CampusCameraScanner({super.key, required this.scanningModeType, required this.userAuthToken});

  @override
  State<CampusCameraScanner> createState() => _CampusCameraScannerState();
}

class _CampusCameraScannerState extends State<CampusCameraScanner> {
  bool _isProcessingScanPayload = false;
  final MobileScannerController _cameraController = MobileScannerController();

  Future<void> _handleBarcodeDetection(String profileTokenDataId) async {
    setState(() => _isProcessingScanPayload = true);

    final String endpointUrlPath = widget.scanningModeType == 'LIBRARY' 
        ? 'http://localhost:5000/api/qr-ops/scan-library-issue'
        : 'http://localhost:5000/api/qr-ops/scan-event-attendance';

    try {
      final response = await http.post(
        Uri.parse(endpointUrlPath),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userAuthToken}',
        },
        body: jsonEncode({
          'scannedStudentToken': profileTokenDataId,
          'bookIsbn': '978-3-16-148410-0', // Simulated book ISBN scan variable mapping code injection
          'subjectId': '65f1abcd23456789012345ab', // Simulated classroom module payload
          'hour': 1
        }),
      );

      if (!mounted) return;

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Render interactive feedback modal summary to terminal monitor workspace
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(24),
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(response.statusCode == 200 || response.statusCode == 201 ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: Colors.indigo, size: 28),
                  const SizedBox(width: 10),
                  const Text('Scan Event Processed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(responseData['message'] ?? responseData['error'] ?? 'Execution connection timed out.', style: const TextStyle(color: Colors.blueGrey)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isProcessingScanPayload = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                child: const Text('Reset Scanner Device'),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessingScanPayload = false);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.scanningModeType} Hardware Console'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Stack(
        children: [
          // Live Video Camera Feed Array Node
          MobileScanner(
            controller: _cameraController,
            onDetect: (barcodeCapture) {
              if (_isProcessingScanPayload) return;
              
              final List<Barcode> barcodesList = barcodeCapture.barcodes;
              if (barcodesList.isNotEmpty && barcodesList.first.rawValue != null) {
                _handleBarcodeDetection(barcodesList.first.rawValue!);
              }
            },
          ),
          
          // Visual Scanning Target Mask Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 3.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isProcessingScanPayload 
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}