import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ChartView { bar, pie }

class IncomeStatScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String currency;
  final String monthLabel;

  const IncomeStatScreen({
    super.key,
    required this.data,
    required this.currency,
    required this.monthLabel,
  });

  @override
  State<IncomeStatScreen> createState() => _IncomeStatScreenState();
}

class _IncomeStatScreenState extends State<IncomeStatScreen> {
  ChartView _chartView = ChartView.bar;

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

  Widget _buildChartToggle() {
    final selectedColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ToggleButtons(
        isSelected: [
          _chartView == ChartView.bar,
          _chartView == ChartView.pie,
        ],
        onPressed: (index) {
          setState(() {
            _chartView = index == 0 ? ChartView.bar : ChartView.pie;
          });
        },
        constraints: const BoxConstraints(minHeight: 44, minWidth: 120),
        borderRadius: BorderRadius.circular(10),
        selectedBorderColor: selectedColor,
        borderColor: selectedColor.withOpacity(0.4),
        fillColor: selectedColor.withOpacity(0.15),
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart),
              SizedBox(width: 8),
              Text("Bar Chart"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart),
              SizedBox(width: 8),
              Text("Pie Chart"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    final colors = Theme.of(context).colorScheme;
    final formattedTotal = NumberFormat('#,##0.00').format(total);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Income",
                  style: TextStyle(
                    color: colors.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.currency} $formattedTotal",
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: colors.onPrimary.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.monthLabel,
                      style: TextStyle(
                        color: colors.onPrimary.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (widget.data.isEmpty) {
      return const Center(child: Text("No income data available"));
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= widget.data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.data[value.toInt()]['category'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(widget.data.length, (i) {
            final it = widget.data[i];
            final total = (it['total'] is num)
                ? (it['total'] as num).toDouble()
                : double.tryParse(it['total'].toString()) ?? 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: _catColor(it['category']),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No income data available'));
    }

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: widget.data.map((it) {
            final color = _catColor(it['category']);
            final total = (it['total'] is num)
                ? (it['total'] as num).toDouble()
                : double.tryParse(it['total'].toString()) ?? 0.0;
            return PieChartSectionData(
              color: color,
              value: total,
              title:
                  "${it['category']}\n${NumberFormat('#,##0.0').format(total)}",
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIncomeList() {
    if (widget.data.isEmpty) {
      return const Center(child: Text("No income data available"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length,
      itemBuilder: (context, i) {
        final item = widget.data[i];
        final amount = (item['total'] is num)
            ? (item['total'] as num).toDouble()
            : double.tryParse(item['total'].toString()) ?? 0.0;
        final color = _catColor(item['category']);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(Icons.trending_up, color: color),
            ),
            title: Text(item['category']),
            trailing: Text(
              "+${widget.currency} ${NumberFormat('#,##0.00').format(amount)}",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No income data available'));
    }

    final total = widget.data.fold<double>(
      0,
      (sum, e) =>
          sum +
          ((e['total'] is num)
              ? (e['total'] as num).toDouble()
              : double.tryParse(e['total'].toString()) ?? 0.0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCard(total),
          const SizedBox(height: 24),
          _buildChartToggle(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _chartView == ChartView.bar
                ? Padding(
                    key: const ValueKey('bar'),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildBarChart(),
                  )
                : Padding(
                    key: const ValueKey('pie'),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPieChart(),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            "Income Details",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _buildIncomeList(),
        ],
      ),
    );
  }
}
