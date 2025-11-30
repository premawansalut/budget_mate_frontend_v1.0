import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanStatScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String currency;

  const LoanStatScreen({super.key, required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No loan data available'));
    }

    final total = data.fold<double>(0, (sum, e) => sum + (e['total'] ?? 0.0));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.amber),
            title: Text(item['category']),
            trailing: Text(
              "$currency ${NumberFormat('#,##0.00').format(item['total'])}",
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        );
      },
    );
  }
}
