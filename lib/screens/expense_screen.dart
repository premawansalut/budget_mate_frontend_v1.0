import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Food';
  bool _isSaving = false;
  String _type = 'Expenses';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': FontAwesomeIcons.utensils},
    {'name': 'Social', 'icon': FontAwesomeIcons.peopleGroup},
    {'name': 'Traffic', 'icon': FontAwesomeIcons.car},
    {'name': 'Shopping', 'icon': FontAwesomeIcons.bagShopping},
    {'name': 'Grocery', 'icon': FontAwesomeIcons.cartShopping},
    {'name': 'Education', 'icon': FontAwesomeIcons.graduationCap},
    {'name': 'Bills', 'icon': FontAwesomeIcons.receipt},
    {'name': 'Rental', 'icon': FontAwesomeIcons.houseChimney},
    {'name': 'Medical', 'icon': FontAwesomeIcons.suitcaseMedical},
    {'name': 'Investment', 'icon': FontAwesomeIcons.chartLine},
    {'name': 'Gift', 'icon': FontAwesomeIcons.gift},
    {'name': 'Other', 'icon': FontAwesomeIcons.ellipsis},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Widget _categoryTile(String cat, IconData icon) {
    final selected = _selectedCategory == cat;
    final accent = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: selected ? accent : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : Colors.grey.withOpacity(0.3),
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Icon(
              icon,
              color: selected ? Colors.white : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 78,
            child: Text(
              cat,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _segmentButton(String label) {
    final active = _type == label;
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ✅ Save expense with animated popup
  Future<void> _saveExpense() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      "amount": amount,
      "category": _selectedCategory,
      "note": _noteController.text.trim(),
      "year": _selectedDate.year,
      "month": _selectedDate.month,
    };

    try {
      final success = await ApiService.createExpense(data);
      setState(() => _isSaving = false);

      if (success) {
        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Success',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
          transitionBuilder: (context, anim, _, __) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(anim.value),
              child: Opacity(
                opacity: anim.value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 30),
                      SizedBox(width: 8),
                      Text("Success",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  content: const Text("Expense added successfully!"),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed, please try again.')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveExpense,
            child: Text('Save', style: TextStyle(color: accent)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _segmentButton('Expenses'),
                _segmentButton('Income'),
                _segmentButton('Loan'),
              ],
            ),
            const SizedBox(height: 22),
            // Amount
            Text('Amount',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              onTap: () {
                if (_amountController.text == '0') _amountController.clear();
              },
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor),
              decoration: InputDecoration(
                hintText: '0',
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                  BorderSide(color: accent.withOpacity(0.6), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Category
            Text('Category',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 14,
              children: categories
                  .map((c) => _categoryTile(c['name'], c['icon']))
                  .toList(),
            ),
            const SizedBox(height: 30),

            // Note
            Text('Note',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a description (optional)',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 20),

            // Date and Time
            Row(
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 10),
                        Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Text(_selectedTime.format(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Save Expense',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
