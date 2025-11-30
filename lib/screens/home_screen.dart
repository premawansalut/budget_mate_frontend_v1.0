import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  double? totalBalance;
  double? totalExpenses;
  List<dynamic> expenses = [];
  List<dynamic> incomes = [];
  bool isLoading = false;
  bool isHidden = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final year = selectedDate.year;
    final month = selectedDate.month;

    try {
      final balance = await ApiService.getBalance(year, month);
      final expenseData = await ApiService.getExpenses(year, month);
      final incomeData = await ApiService.getIncome(year, month); // ✅ new API call

      setState(() {
        totalBalance = balance ?? 0.0;
        totalExpenses = expenseData['total_expense'] ?? 0.0;
        expenses = expenseData['expenses'] ?? [];
        incomes = incomeData['incomes'] ?? []; // expects backend to return {"incomes": [...]}
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> pickMonthYear() async {
    int tempMonth = selectedDate.month;
    int tempYear = selectedDate.year;

    await showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : Colors.grey.shade100,
          title: const Text(
            "Select Month & Year",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            height: 160,
            child: Column(
              children: [
                DropdownButton<int>(
                  dropdownColor:
                  isDark ? const Color(0xFF1E1E2A) : Colors.white,
                  value: tempMonth,
                  isExpanded: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child:
                      Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                    );
                  }),
                  onChanged: (value) =>
                      setState(() => tempMonth = value ?? tempMonth),
                ),
                const SizedBox(height: 10),
                DropdownButton<int>(
                  dropdownColor:
                  isDark ? const Color(0xFF1E1E2A) : Colors.white,
                  value: tempYear,
                  isExpanded: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  items: List.generate(10, (index) {
                    final year = DateTime.now().year - 5 + index;
                    return DropdownMenuItem(
                        value: year, child: Text(year.toString()));
                  }),
                  onChanged: (value) =>
                      setState(() => tempYear = value ?? tempYear),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  selectedDate = DateTime(tempYear, tempMonth);
                });
                Navigator.pop(context);
                fetchData();
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Social':
        return Icons.people_alt_rounded;
      case 'Traffic':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Grocery':
        return Icons.local_grocery_store_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Rental':
        return Icons.home_work_rounded;
      case 'Medical':
        return Icons.medical_services_rounded;
      case 'Investment':
        return Icons.trending_up_rounded;
      case 'Gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  IconData getIncomeIcon(String category) {
    switch (category) {
      case 'Salary':
        return Icons.work_rounded;
      case 'Business':
        return Icons.store_rounded;
      case 'Investment':
        return Icons.show_chart_rounded;
      case 'Gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  Color getIncomeColor(String category) {
    switch (category) {
      case 'Salary':
        return Colors.blueAccent;
      case 'Business':
        return Colors.orangeAccent;
      case 'Investment':
        return Colors.green;
      case 'Gift':
        return Colors.pinkAccent;
      default:
        return Colors.teal;
    }
  }

  Future<void> _updateExpense(String id, double amount, String note) async {
    try {
      final success = await ApiService.updateExpense(id, amount, note);
      if (success) {
        _showSnackBar("Expense updated successfully", Colors.green, Icons.check_circle);
        fetchData();
      }
    } catch (e) {
      _showSnackBar("Failed to update expense", Colors.red, Icons.error);
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      final success = await ApiService.deleteExpense(id);
      if (success) {
        _showSnackBar("Expense deleted successfully", Colors.orange, Icons.delete_forever);
        fetchData();
      }
    } catch (e) {
      _showSnackBar("Failed to delete expense", Colors.red, Icons.error);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showExpenseActions(Map<String, dynamic> expense) {
    final TextEditingController amountController =
    TextEditingController(text: expense['amount'].toString());
    final TextEditingController noteController =
    TextEditingController(text: expense['note'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        final accent = Theme.of(context).colorScheme.secondary;
        final cardColor = Theme.of(context).cardColor;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Icon(getCategoryIcon(expense['category']), color: accent, size: 42),
                    const SizedBox(height: 10),
                    Text(expense['category'],
                        style: TextStyle(
                            color: accent, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixIcon:
                        Icon(Icons.attach_money_rounded, color: accent),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: "Note",
                        prefixIcon: Icon(Icons.note_alt_rounded, color: accent),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _updateExpense(
                                expense['id'],
                                double.tryParse(amountController.text.trim()) ?? 0.0,
                                noteController.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14)),
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Update"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _deleteExpense(expense['id']);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14)),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text("Delete"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currency;
    final formattedMonthYear = DateFormat('MMMM yyyy').format(selectedDate);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final cardColor = Theme.of(context).cardColor;
    final accent = Theme.of(context).colorScheme.secondary;

    final balanceFormatted =
    NumberFormat('#,##0.00').format(totalBalance ?? 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: pickMonthYear,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedMonthYear,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Icon(Icons.calendar_month, color: textColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$currencySymbol $balanceFormatted",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          Text("Total Balance",
                              style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 14)),
                        ]),
                  ),
                  Icon(Icons.account_balance_wallet, color: accent, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TabBar(
              controller: _tabController,
              labelColor: accent,
              unselectedLabelColor: textColor.withOpacity(0.6),
              indicatorColor: accent,
              tabs: const [
                Tab(text: "Expenses"),
                Tab(text: "Income"),
                Tab(text: "Loan"),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpenseTab(currencySymbol, textColor, cardColor, accent),
                  _buildIncomeTab(currencySymbol, textColor, cardColor),
                  const Center(child: Text("Loan details coming soon...")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTab(
      String currencySymbol, Color textColor, Color cardColor, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 220),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (expenses.isEmpty)
            Center(
                child: Text("No expenses found",
                    style: TextStyle(color: textColor.withOpacity(0.6))))
          else
            ...expenses.map((exp) {
              final icon = getCategoryIcon(exp['category']);
              final amount = NumberFormat('#,##0.00')
                  .format(double.tryParse(exp['amount'].toString()) ?? 0);
              final date = DateFormat('MMM dd')
                  .format(DateTime.parse(exp['created_at']).toLocal());
              return FadeInUp(
                child: GestureDetector(
                  onTap: () => _showExpenseActions(exp),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ]),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: accent.withOpacity(0.15),
                        child: Icon(icon, color: accent),
                      ),
                      title: Text(exp['category'],
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold)),
                      subtitle: Text(exp['note'] ?? "",
                          style:
                          TextStyle(color: textColor.withOpacity(0.6))),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("-$currencySymbol $amount",
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold)),
                          Text(date,
                              style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildIncomeTab(
      String currencySymbol, Color textColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 220),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (incomes.isEmpty)
            Center(
                child: Text("No income found",
                    style: TextStyle(color: textColor.withOpacity(0.6))))
          else
            ...incomes.map((inc) {
              final icon = getIncomeIcon(inc['category']);
              final color = getIncomeColor(inc['category']);
              final amount = NumberFormat('#,##0.00')
                  .format(double.tryParse(inc['amount'].toString()) ?? 0);
              final date = DateFormat('MMM dd')
                  .format(DateTime.parse(inc['created_at']).toLocal());
              return FadeInUp(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3))
                      ]),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(inc['category'],
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text(inc['note'] ?? "",
                        style: TextStyle(color: textColor.withOpacity(0.6))),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("+$currencySymbol $amount",
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold)),
                        Text(date,
                            style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
