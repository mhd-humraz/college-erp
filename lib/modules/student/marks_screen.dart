import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/loading_widget.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResult();
    });
  }

  Future<void> _loadResult() async {
    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    if (auth.studentId == null ||
        auth.studentId!.isEmpty) {
      debugPrint("Student ID not found");
      return;
    }

    if (auth.token == null ||
        auth.token!.isEmpty) {
      debugPrint("Authentication token not found");
      return;
    }

    await Provider.of<StudentProvider>(
      context,
      listen: false,
    ).fetchSemesterResult(
      studentId: auth.studentId!,
      semester: auth.semester ?? 1,
      token: auth.token!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(
      context,
    );

    final results = student.semesterResults;
    final summary = student.marksSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Grading Ledger',
        ),
      ),
      body: student.isLoading
          ? const LoadingWidget()
          : student.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppTheme.spaceMD,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          student.error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadResult,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : results.isEmpty
                  ? const Center(
                      child: Text(
                        'No semester results published yet.',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadResult,
                      child: ListView(
                        padding: const EdgeInsets.all(
                          AppTheme.spaceMD,
                        ),
                        children: [
                          if (summary != null)
                            Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  AppTheme.spaceMD,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Semester Result",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        _summaryItem(
                                          "Percentage",
                                          "${summary.overallPercentage.toStringAsFixed(2)}%",
                                        ),
                                        _summaryItem(
                                          "Status",
                                          summary.overallStatus,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        _summaryItem(
                                          "Passed",
                                          summary.passedSubjects
                                              .toString(),
                                        ),
                                        _summaryItem(
                                          "Failed",
                                          summary.failedSubjects
                                              .toString(),
                                        ),
                                        _summaryItem(
                                          "Total",
                                          summary.totalSubjects
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          ...results.map(
                            (item) => Card(
                              margin:
                                  const EdgeInsets.symmetric(
                                vertical: AppTheme.spaceXS,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    item.grade,
                                  ),
                                ),
                                title: Text(
                                  item.subjectName,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${item.subjectCode}\n${item.status} • ${item.percentage.toStringAsFixed(2)}%",
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  "${item.marksObtained} / ${item.maxMarks}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        AppTheme.primaryIndigo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _summaryItem(
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}