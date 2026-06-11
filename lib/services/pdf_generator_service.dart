// lib/services/pdf_generator_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGeneratorService {
  static Future<void> generateAndPrintResumePortfolio(Map<String, dynamic> rawSummaryDatasetData) async {
    final pdfDocument = pw.Document();
    
    final profile = rawSummaryDatasetData['profile'];
    final List achievementsList = rawSummaryDatasetData['achievements'];

    pdfDocument.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Block Section Matrix
                pw.Text('STUDENT VERIFIED DOSSIER PORTFOLIO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                pw.SizedBox(height: 4),
                pw.Text('EduSphere ERP Authentic Verification Document System', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                pw.Divider(thickness: 1.5, color: PdfColors.indigo900),
                pw.SizedBox(height: 16),
                
                // Profile Information Grid Block
                pw.Text('ACADEMIC METADATA CODES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
                pw.SizedBox(height: 6),
                pw.Text('Registration Identification Code: ${profile['rollNumber']}'),
                pw.Text('Academic Branch Cluster: ${profile['department']}'),
                pw.Text('Enrolled Course Track: ${profile['course']}'),
                pw.Text('Current Structural Semester: Sem ${profile['semester']}'),
                pw.SizedBox(height: 24),
                
                // Timeline Array Block Loops
                pw.Text('VERIFIED CREDENTIALS & ACHIEVEMENTS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo700)),
                pw.SizedBox(height: 8),
                pw.ListView.builder(
                  itemCount: achievementsList.length,
                  itemBuilder: (pw.Context ctx, int targetIdx) {
                    final item = achievementsList[targetIdx];
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 1), borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(item['title'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text('[${item['category']}]', style: pw.TextStyle(color: PdfColors.indigo900, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Authorized Authority Issuer: ${item['issuer']}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey900)),
                          pw.SizedBox(height: 4),
                          pw.Text(item['description'] ?? '', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );

    // Hands off document configuration directly to native hardware printer frameworks
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfDocument.save());
  }
}