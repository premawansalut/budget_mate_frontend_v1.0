import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _typeTabController; // Income / Expense / Loan
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  String error = '';
  String label = '';

  Map<String, double> incomeData = {};
  Map<String, double> expenseData = {};
  Map<String, double> loanData = {};

  @override
  void initState() {
    super.initState();
    _typeTabController = TabController(length: 3, vsync: this);
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final year = selectedDate.year;
      final month = selectedDate.month;

      final data = await ApiService.getStatistics(year, month);
      print('📊 Raw backend data: $data');

      setState(() {
        label = data['label'] ?? '';
        incomeData = _parseCategoryData(data['income'] ?? data['categories']);
        expenseData = _parseCategoryData(data['expense']);
        loanData = _parseCategoryData(data['loan']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Failed to load statistics: $e";
      });
    }
  }

  Map<String, double> _parseCategoryData(dynamic data) {
    final result = <String, double>{};
    if (data is List) {
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          final cat = item['category']?.toString() ?? '';
          final val = double.tryParse(item['total'].toString()) ?? 0.0;
          result[cat] = val;
        }
      }
    }
    return result;
  }

  Future<void> pickMonthYear() async {
    int selectedYear = selectedDate.year;
    int selectedMonth = selectedDate.month;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 340,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Select Month & Year",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    dropdownColor: Theme.of(context).cardColor,
                    value: selectedMonth,
                    iconEnabledColor:
                    Theme.of(context).iconTheme.color ?? Colors.white,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.white),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child:
                        Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                      );
                    }),
                    onChanged: (value) {
                      setModalState(() => selectedMonth = value ?? selectedMonth);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<int>(
                    dropdownColor: Theme.of(context).cardColor,
                    value: selectedYear,
                    iconEnabledColor:
                    Theme.of(context).iconTheme.color ?? Colors.white,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.white),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setModalState(() => selectedYear = value ?? selectedYear);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(selectedYear, selectedMonth);
                      });
                      Navigator.pop(context);
                      fetchStatistics();
                    },
                    child: const Text("Apply",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBarChart(Map<String, double> data, Color color) {
    if (data.isEmpty) {
      return const Center(
        child: Text("No data available",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }

    final keys = data.keys.toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() < keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      keys[val.toInt()],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barGroups: data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final double value = entry.value.value; // ❌ Wrong earlier
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.value, // ❌ Wrong earlier
                color: color,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeView(
      Map<String, double> data, String title, String currency, Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(height: 250, child: _buildBarChart(data, color)),
          const SizedBox(height: 20),
          ...data.entries.map((e) => ListTile(
            title: Text(e.key,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            trailing: Text(
              "$currency ${e.value.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final settings = Provider.of<SettingsProvider>(context);
    final currency = settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickMonthYear,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(
          child: Text(error,
              style: const TextStyle(color: Colors.red, fontSize: 14)))
          : Column(
        children: [
          const SizedBox(height: 16),
          Text(
            label.isNotEmpty ? label : 'No label',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tabs for Income / Expense / Loan
          Material(
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _typeTabController,
              labelColor: accent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: accent,
              tabs: const [
                Tab(text: "Income"),
                Tab(text: "Expense"),
                Tab(text: "Loan"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _typeTabController,
              children: [
                _buildTypeView(incomeData, "Income Breakdown",
                    currency, accent),
                _buildTypeView(expenseData, "Expense Breakdown",
                    currency, Colors.redAccent),
                _buildTypeView(loanData, "Loan Breakdown", currency,
                    Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
