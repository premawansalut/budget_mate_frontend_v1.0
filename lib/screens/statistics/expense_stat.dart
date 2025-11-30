import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class ExpenseStatScreen extends StatefulWidget {
  const ExpenseStatScreen({super.key});

  @override
  State<ExpenseStatScreen> createState() => _ExpenseStatScreenState();
}

class _ExpenseStatScreenState extends State<ExpenseStatScreen> {
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  double totalExpense = 0;
  List<Map<String, dynamic>> categorySummary = [];
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpenseStats();
  }

  Future<void> fetchExpenseStats() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.getExpenseStatistics(
        selectedDate.year,
        selectedDate.month,
      );

      if (res.isNotEmpty) {
        setState(() {
          totalExpense = double.tryParse(res['total_expense'].toString()) ?? 0.0;
          categorySummary =
          List<Map<String, dynamic>>.from(res['category_summary'] ?? []);
          expenses = List<Map<String, dynamic>>.from(res['expenses'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error loading expense stats: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _catColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.redAccent;
      case 'grocery':
        return Colors.greenAccent;
      case 'bills':
        return Colors.orangeAccent;
      case 'shopping':
        return Colors.purpleAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Future<void> _pickMonthYear() async {
    int y = selectedDate.year;
    int m = selectedDate.month;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(height: 20),
              Text('Select Month & Year',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 15),
              DropdownButton<int>(
                value: m,
                items: List.generate(
                  12,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                  ),
                ),
                onChanged: (v) => setModal(() => m = v ?? m),
              ),
              DropdownButton<int>(
                value: y,
                items: List.generate(10, (i) {
                  final yy = DateTime.now().year - 5 + i;
                  return DropdownMenuItem(value: yy, child: Text('$yy'));
                }),
                onChanged: (v) => setModal(() => y = v ?? y),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => selectedDate = DateTime(y, m));
                  await fetchExpenseStats();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (categorySummary.isEmpty) {
      return const Center(child: Text("No category data"));
    }

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v >= categorySummary.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categorySummary[v.toInt()]['category'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(categorySummary.length, (i) {
            final cat = categorySummary[i];
            final total = double.tryParse(cat['total'].toString()) ?? 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: _catColor(cat['category']),
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
    if (categorySummary.isEmpty) {
      return const Center(child: Text("No category data"));
    }

    return SizedBox(
      height: 280,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: categorySummary.map((cat) {
            final total = double.tryParse(cat['total'].toString()) ?? 0.0;
            final color = _catColor(cat['category']);
            return PieChartSectionData(
              color: color,
              value: total,
              title:
              "${cat['category']}\n${NumberFormat('#,##0.0').format(total)}",
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              radius: 70,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseList(String currency) {
    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses found"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final exp = expenses[i];
        final date =
        DateFormat('MMM dd, yyyy').format(DateTime.parse(exp['created_at']));
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _catColor(exp['category']).withOpacity(0.2),
              child: Icon(Icons.category, color: _catColor(exp['category'])),
            ),
            title: Text(exp['category']),
            subtitle: Text(date),
            trailing: Text(
              "-$currency ${NumberFormat('#,##0.00').format(double.parse(exp['amount']))}",
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = '€'; // or get from your settings provider
    final monthLabel = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Statistics - $monthLabel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonthYear,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Expenses: $currency ${totalExpense.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildBarChart(),
            const SizedBox(height: 30),
            _buildPieChart(),
            const SizedBox(height: 30),
            Text("Expense Details",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildExpenseList(currency),
          ],
        ),
      ),
    );
  }
}
