import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String currency;

  const IncomeStatScreen({super.key, required this.data, required this.currency});

  Color _catColor(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Colors.greenAccent;
      case 'investment':
        return Colors.blueAccent;
      case 'business':
        return Colors.orangeAccent;
      default:
        return Colors.tealAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No income data available'));
    }

    final total = data.fold<double>(0, (sum, e) => sum + (e['total'] ?? 0.0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: data.map((it) {
                  final color = _catColor(it['category']);
                  return PieChartSectionData(
                    color: color,
                    value: it['total'],
                    title:
                    "${it['category']}\n${NumberFormat('#,##0.0').format(it['total'])}",
                    radius: 70,
                    titleStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ...data.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e['category'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text("$currency ${NumberFormat('#,##0.00').format(e['total'])}",
                          style: const TextStyle(color: Colors.greenAccent)),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$currency ${NumberFormat('#,##0.00').format(total)}",
                        style: const TextStyle(color: Colors.greenAccent)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
