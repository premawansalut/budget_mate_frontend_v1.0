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
  bool isLoading = false;
  bool isHidden = false;

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    setState(() => isLoading = true);
    final year = selectedDate.year;
    final month = selectedDate.month;
    final balance = await ApiService.getBalance(year, month);
    setState(() {
      totalBalance = balance ?? 0.0;
      isLoading = false;
    });
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
              height: 350,
              child: Column(
                children: [
                  const SizedBox(height: 10),
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
                    "Select Month & Year",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Month Picker
                  DropdownButton<int>(
                    dropdownColor: Theme.of(context).cardColor,
                    value: selectedMonth,
                    iconEnabledColor:
                    Theme.of(context).iconTheme.color ?? Colors.white,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white,
                    ),
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

                  // Year Picker
                  DropdownButton<int>(
                    dropdownColor: Theme.of(context).cardColor,
                    value: selectedYear,
                    iconEnabledColor:
                    Theme.of(context).iconTheme.color ?? Colors.white,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.white,
                    ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(selectedYear, selectedMonth);
                      });
                      Navigator.pop(context);
                      fetchBalance();
                    },
                    child: const Text(
                      "Apply",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencySymbol = settingsProvider.currency;
    final formattedMonthYear = DateFormat('MMMM yyyy').format(selectedDate);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final cardColor = Theme.of(context).cardColor;
    final accent = Theme.of(context).colorScheme.secondary;

    // ✅ Use NumberFormat with cents
    final balanceFormatted = NumberFormat('#,##0.00').format(totalBalance ?? 0);

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
            // Month Selector
            GestureDetector(
              onTap: pickMonthYear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Icon(Icons.arrow_forward_ios, color: textColor, size: 18),
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

            // Expenditure Section
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
                        "$currencySymbol 200.00",
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

            Text(
              "Sat, 27 September",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            // Example Transaction
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
                      Text(
                        "Food",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "food",
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
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
        color: selected
            ? accent
            : Theme.of(context).cardColor.withOpacity(0.5),
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
