import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_service.dart';
import 'income_stat.dart';
import 'expense_stat.dart';
import 'loan_stat.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  List<Map<String, dynamic>> incomeData = [];
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> loanData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() => isLoading = true);
    try {
      final year = selectedDate.year;
      final month = selectedDate.month;
      final res = await ApiService.getStatistics(year, month);

      if (res.isNotEmpty && res['categories'] != null) {
        final parsed = (res['categories'] as List)
            .map<Map<String, dynamic>>((e) => {
          'category': e['category'],
          'total': double.tryParse(e['total'].toString()) ?? 0.0,
        })
            .toList();

        setState(() {
          incomeData = parsed;
          expenseData = parsed;
          loanData = parsed;
        });
      }
    } catch (e) {
      debugPrint('statistics fetch error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickMonthYear() async {
    int y = selectedDate.year;
    int m = selectedDate.month;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SizedBox(
          height: 340,
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Month & Year',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: y,
                items: List.generate(
                  10,
                      (i) {
                    final yy = DateTime.now().year - 5 + i;
                    return DropdownMenuItem(value: yy, child: Text('$yy'));
                  },
                ),
                onChanged: (v) => setModal(() => y = v ?? y),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  setState(() => selectedDate = DateTime(y, m));
                  Navigator.pop(context);
                  await fetchStatistics();
                },
                child: const Text('Apply',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currency = settings.currency;
    final monthLabel = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics - $monthLabel'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Loan'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickMonthYear,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          IncomeStatScreen(data: incomeData, currency: currency),
          ExpenseStatScreen(),
          LoanStatScreen(data: loanData, currency: currency),
        ],
      ),
    );
  }
}
