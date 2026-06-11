// lib/modules/analytics/campus_charts.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CampusAnalyticsChart extends StatelessWidget {
  const CampusAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Class Performance Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 4),
            const Text('Average marks tracked across current exams', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 25),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 11);
                          switch (value.toInt()) {
                            case 0: return const Padding(padding: EdgeInsets.only(top: 6), child: Text('BCA M1', style: style));
                            case 1: return const Padding(padding: EdgeInsets.only(top: 6), child: Text('BSc C2', style: style));
                            case 2: return const Padding(padding: EdgeInsets.only(top: 6), child: Text('BCom E3', style: style));
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 78, color: Colors.blueAccent, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 92, color: Colors.teal, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 64, color: Colors.deepOrangeAccent, width: 16, borderRadius: BorderRadius.circular(4))]),
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