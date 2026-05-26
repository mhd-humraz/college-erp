import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PdfReportsScreen extends StatefulWidget {
  const PdfReportsScreen({super.key});

  @override
  State<PdfReportsScreen> createState() => _PdfReportsScreenState();
}

class _PdfReportsScreenState extends State<PdfReportsScreen> {
  bool _isGenerating = false;
  double _progress = 0;
  String? _generatingReport;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PDF Reports',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.error.withOpacity(0.15), AppColors.card]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.error.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.picture_as_pdf,
                      color: AppColors.error, size: 30),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generate Reports',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text)),
                      SizedBox(height: 6),
                      Text('Download professional PDF reports instantly',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 28),

          Text('AVAILABLE REPORTS',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          SizedBox(height: 14),

          // Report Cards
          _reportCard(
            icon: Icons.fact_check_outlined,
            title: 'Attendance Report',
            subtitle: 'Monthly/Yearly attendance summary',
            color: AppColors.success,
            onTap: () => _generateAttendanceReport(user),
          ),

          _reportCard(
            icon: Icons.grade_outlined,
            title: 'Marksheet / Report Card',
            subtitle: 'All subjects with grades',
            color: AppColors.info,
            onTap: () => _generateMarksheet(user),
          ),

          _reportCard(
            icon: Icons.calendar_view_day_outlined,
            title: 'Timetable',
            subtitle: 'Weekly class schedule',
            color: AppColors.warning,
            onTap: () => _generateTimetable(user),
          ),

          _reportCard(
            icon: Icons.receipt_long_outlined,
            title: 'Fee Receipt',
            subtitle: 'Payment history & dues',
            color: AppColors.primary,
            onTap: () => _generateFeeReceipt(user),
          ),

          if (_isGenerating) ...[
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primary))),
                      SizedBox(width: 14),
                      Text('Generating $_generatingReport...',
                          style: TextStyle(
                              color: AppColors.text, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: Colors.white10,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.primary)),
                  ),
                  SizedBox(height: 8),
                  Text('${(_progress * 100).toInt()}% complete',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],

          SizedBox(height: 30),

          // Tips Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.info.withOpacity(0.1), AppColors.card]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pro Tip',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                              fontSize: 14)),
                      SizedBox(height: 4),
                      Text(
                          'Generated PDFs can be printed or shared directly from your device.',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isGenerating ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                          fontSize: 16)),
                  SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  // ==================== PDF GENERATION FUNCTIONS ====================

  Future<void> _generateAttendanceReport(dynamic user) async {
    setState(() {
      _isGenerating = true;
      _progress = 0;
      _generatingReport = 'Attendance Report';
    });

    try {
      final pdf = pw.Document();

      final response = await ApiService.get('/student/attendance');
      final data = response.data['data'];

      setState(() => _progress = 0.3);

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader('Attendance Report'),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildStudentInfoSection(user),
          pw.SizedBox(height: 20),
          _buildAttendanceTable(data['records'] ?? []),
          pw.SizedBox(height: 20),
          _buildSummarySection(data['subjectWise'] ?? []),
        ],
      ));

      setState(() => _progress = 1.0);
      await _printPdf(pdf, 'attendance_report_${user['name']}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateMarksheet(dynamic user) async {
    setState(() {
      _isGenerating = true;
      _progress = 0;
      _generatingReport = 'Marksheet';
    });

    try {
      final pdf = pw.Document();
      final response = await ApiService.get('/student/marks');
      final data = response.data['data'];

      setState(() => _progress = 0.4);

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader('Academic Marksheet'),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildStudentInfoSection(user),
          pw.SizedBox(height: 20),
          _buildMarksTable(data),
          pw.SizedBox(height: 20),
          _buildGradeSummary(data),
        ],
      ));

      setState(() => _progress = 1.0);
      await _printPdf(pdf, 'marksheet_${user['name']}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateTimetable(dynamic user) async {
    setState(() {
      _isGenerating = true;
      _progress = 0;
      _generatingReport = 'Timetable';
    });

    try {
      final pdf = pw.Document();
      final response = await ApiService.get('/student/timetable');
      final data = response.data['data'];

      setState(() => _progress = 0.5);

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPdfHeader('Class Timetable'),
            pw.SizedBox(height: 20),
            _buildStudentInfoSection(user),
            pw.SizedBox(height: 20),
            _buildTimetableTable(data),
          ],
        ),
      ));

      setState(() => _progress = 1.0);
      await _printPdf(pdf, 'timetable_${user['name']}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateFeeReceipt(dynamic user) async {
    setState(() {
      _isGenerating = true;
      _progress = 0;
      _generatingReport = 'Fee Receipt';
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(50),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPdfHeader('Fee Payment Receipt'),
            pw.SizedBox(height: 30),
            _buildStudentInfoSection(user),
            pw.SizedBox(height: 30),
            _buildFeeTable(),
            pw.SizedBox(height: 30),
            pw.Center(
                child: pw.Text('Thank you for your payment!',
                    style: pw.TextStyle(
                        fontSize: 14, color: PdfColors.grey700))),
          ],
        ),
      ));

      setState(() => _progress = 1.0);
      await _printPdf(pdf, 'fee_receipt_${user['name']}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  // ==================== PDF HELPER WIDGETS ====================

  pw.Widget _buildPdfHeader(String title) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('College ERP System',
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800)),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800)),
              pw.SizedBox(height: 4),
              pw.Text(
                  'Generated: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 10),
      child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
    );
  }

  pw.Widget _buildStudentInfoSection(dynamic user) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _infoRow('Name:', user['name']?.toString() ?? ''),
              _infoRow('Email:', user['email']?.toString() ?? ''),
            ],
          )),
          pw.SizedBox(width: 40),
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _infoRow('Roll No:', user['rollNumber']?.toString() ?? 'N/A'),
              _infoRow('Department:', user['departmentName']?.toString() ?? 'N/A'),
            ],
          )),
        ],
      ),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700)),
        pw.SizedBox(width: 8),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey900)),
      ]),
    );
  }

  pw.Widget _buildAttendanceTable(List records) {
    if (records.isEmpty) return pw.Text('No attendance records found');

    var headers = ['Date', 'Subject', 'Status', 'Marked By'];
    var dataRows = records.take(30).map((r) => [
      r['date']?.toString().substring(0, 10) ?? '',
      r['subjectId']?['name']?.toString() ?? '',
      r['status']?.toString().toUpperCase() ?? '',
      r['teacherId']?['name']?.toString() ?? '',
    ]).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.teal),
          children: headers.map((h) => pw.Padding(
            padding: pw.EdgeInsets.all(8),
            child: pw.Text(h,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 9)),
          )).toList(),
        ),
        // Data Rows
        ...dataRows.map((row) => pw.TableRow(
          children: row.map((cell) => pw.Padding(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(cell.toString(),
                style: pw.TextStyle(fontSize: 8)),
          )).toList(),
        )),
      ],
    );
  }
  pw.Widget _buildSummarySection(List subjectWise) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.teal200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Summary',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800)),
          pw.SizedBox(height: 8),
          ...subjectWise.map((s) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(s['subjectName']?.toString() ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: (s['percentage'] ?? 0) >= 75
                          ? PdfColors.green100
                          : PdfColors.red100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                        '${s['percentage']?.toStringAsFixed(1) ?? 0}%',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  pw.Widget _buildMarksTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(children: [
          _tableCell('Subject', isHeader: true),
          _tableCell('Exam Type', isHeader: true),
          _tableCell('Score', isHeader: true),
          _tableCell('Max', isHeader: true),
          _tableCell('%', isHeader: true),
        ]),
        ...data.entries.map((entry) => pw.TableRow(children: [
              _tableCell(entry.value['subjectId']?['name']?.toString() ?? ''),
              _tableCell(entry.key.toUpperCase()),
              _tableCell(entry.value
                  .map((m) => m['score'])
                  .reduce((a, b) => a + b, 0)
                  .toString()),
              _tableCell(entry.value
                  .map((m) => m['maxScore'])
                  .reduce((a, b) => a + b, 0)
                  .toString()),
              _tableCell(
                  '${(entry.value.map((m) => m['score'] * 100 / m['maxScore']).reduce((a, b) => a + b, 0) / entry.value.length).toStringAsFixed(1)}%'),
            ])),
      ],
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight:
                isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.white : PdfColors.black,
          )),
    );
  }

  pw.Widget _buildGradeSummary(Map<String, dynamic> data) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
            colors: [PdfColors.blue50, PdfColors.blue100]),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(children: [
        pw.Text('Overall Performance',
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900)),
        pw.SizedBox(height: 12),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
          _gradeStat('Total Exams', '${data.length}'),
          _gradeStat('Avg Score', '${data.values.fold<double>(0, (sum, list) => sum + list.map((m) => m['score']).fold<double>(0, (a, b) => a + b) / list.length).toStringAsFixed(1)}'),
          _gradeStat('Status', data.values.every((list) => list.every((m) => m['score'] >= m['maxScore'] * 0.4)) ? 'PASS' : 'NEEDS IMPROVEMENT'),
        ]),
      ]),
    );
  }

  pw.Widget _gradeStat(String label, String value) {
    return pw.Column(children: [
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
      pw.Text(label,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.blue600)),
    ]);
  }

  pw.Widget _buildTimetableTable(dynamic data) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.teal),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('Period',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white)),
            ),
            ...days.map((d) => pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(d,
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white)),
            )).toList(),
          ],
        ),
        // Data Rows
        ...List.generate(7, (period) {
          return pw.TableRow(children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('P${period + 1}',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
            ...days.map((day) {
              final entries = data[day] ?? [];
              final entry = entries.firstWhere(
                (e) => e['period'] == period + 1,
                orElse: () => {},
              );
              return pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Text(
                  entry['subjectId']?['name']?.toString() ?? '-',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              );
            }).toList(),
          ]);
        }),
      ],
    );
  }

  pw.Widget _buildFeeTable() {
    var feeData = [
      ['Tuition Fee', '45,000'],
      ['Library Fee', '2,000'],
      ['Lab Fee', '3,000'],
      ['Exam Fee', '1,500'],
      ['Miscellaneous', '500'],
      ['', ''],
      ['TOTAL', '52,000'],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.teal),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Particulars',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Amount (\u{20B9})',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
          ],
        ),
        // Data Rows
        ...feeData.map((item) {
          final isTotal = item[0] == 'TOTAL';
          return pw.TableRow(children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(item[0],
                  style: pw.TextStyle(
                      fontSize: isTotal ? 11 : 10,
                      fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(item[1],
                  style: pw.TextStyle(
                      fontSize: isTotal ? 11 : 10,
                      fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ),
          ]);
        }),
      ],
    );
  }

  Future<void> _printPdf(pw.Document pdf, String filename) async {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: '$filename.pdf');
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF Error: $error'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}