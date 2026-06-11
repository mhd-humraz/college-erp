// lib/modules/student/portfolio_screen.dart
//
// FIXES applied vs original:
//   1. Replaced hardcoded http.get with ApiService.getPortfolioSummary()
//   2. Replaced 'YOUR_STUDENT_OBJECT_ID_HERE' with auth.userId from AuthProvider
//   3. Token is now passed from AuthProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/pdf_generator_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, dynamic>? _portfolioData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDataSummary();
  }

  Future<void> _loadDataSummary() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Guard: if userId is missing, there's nothing to load
    if (auth.userId == null || auth.token == null) {
      setState(() {
        _error = 'Not authenticated.';
        _loading = false;
      });
      return;
    }

    try {
      final summary = await ApiService.getPortfolioSummary(
        studentId: auth.userId!,
        token: auth.token!,
      );
      setState(() {
        _portfolioData = summary;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Network error. Check your connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _loadDataSummary();
                        },
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            PdfGeneratorService.generateAndPrintResumePortfolio(
                                _portfolioData!),
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Export Resume PDF'),
                      ),
                      const SizedBox(height: 24),
                      const Text('Achievements',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: (_portfolioData!['achievements']
                                  as List)
                              .length,
                          itemBuilder: (ctx, idx) {
                            final award = _portfolioData!['achievements']
                                [idx];
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.amber,
                                    size: 30),
                                title: Text(award['title'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'Verified by: ${award['issuer']}'),
                                trailing: Chip(
                                    label: Text(award['category'],
                                        style: const TextStyle(
                                            fontSize: 10))),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}