import 'package:flutter/material.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Loan')),
      body: const Center(
        child: Text('Loan screen coming soon...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
