class Income {
  final double amount;
  final String type; // Income / Expenses / Loan
  final String category;
  final String note;
  final String timestamp; // ISO string

  Income({
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'type': type,
    'category': category,
    'note': note,
    'timestamp': timestamp,
  };
}
