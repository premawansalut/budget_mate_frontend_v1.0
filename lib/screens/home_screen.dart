import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  double? totalBalance;
  double? totalExpenses;
  bool isLoading = false;
  bool isHidden = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final year = selectedDate.year;
    final month = selectedDate.month;

    try {
      final balance = await ApiService.getBalance(year, month);
      final expenses = await ApiService.getTotalExpenses(year, month);
      setState(() {
        totalBalance = balance ?? 0.0;
        totalExpenses = expenses ?? 0.0;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ Modern Month-Year Picker
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
                // 🔹 Month dropdown
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
                      child: Text(
                        DateFormat.MMMM().format(DateTime(0, index + 1)),
                      ),
                    );
                  }),
                  onChanged: (value) =>
                      setState(() => tempMonth = value ?? tempMonth),
                ),
                const SizedBox(height: 10),
                // 🔹 Year dropdown
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
                      value: year,
                      child: Text(year.toString()),
                    );
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
              child: const Text("Cancel"),
            ),
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
    final expenseFormatted =
    NumberFormat('#,##0.00').format(totalExpenses ?? 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            // ✅ Month Selector
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
                    Text(
                      formattedMonthYear,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.calendar_month, color: textColor, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Animated Balance Section
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            isLoading
                                ? "Loading..."
                                : isHidden
                                ? "$currencySymbol ${'*' * (balanceFormatted.length)}"
                                : "$currencySymbol $balanceFormatted",
                            key: ValueKey(isHidden),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Total balance",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        isHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        key: ValueKey(isHidden),
                        color: accent,
                        size: 30,
                      ),
                    ),
                    onPressed: () {
                      setState(() => isHidden = !isHidden);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Category Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton("Expenses", true, accent),
                _buildCategoryButton("Income", false, accent),
                _buildCategoryButton("Loan", false, accent),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ Total Expenditure Section
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total expenditure",
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLoading
                            ? "$currencySymbol 0.00"
                            : "$currencySymbol $expenseFormatted",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.savings_outlined, color: textColor, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Example transaction
            Text(
              "Sat, 27 September",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.fastfood, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Food",
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold)),
                      Text("Lunch",
                          style:
                          TextStyle(color: textColor.withOpacity(0.6))),
                    ],
                  ),
                ),
                Text(
                  "-$currencySymbol 200.00",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, bool selected, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color:
        selected ? accent : Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
