import 'package:flutter/material.dart';
import '../db/transaction_db.dart';
import '../models/transaction_model.dart';

class WeeklySummaryScreen extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;

  const WeeklySummaryScreen({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  int totalIncome = 0;
  int totalOutcome = 0;

  @override
  void initState() {
    super.initState();
    _calculateWeeklySummary();
  }

  Future<void> _calculateWeeklySummary() async {
    final allTransactions = await TransactionDatabase.instance.readAll();
    final monthIndex = months.indexOf(widget.selectedMonth) + 1;
    final year = int.parse(widget.selectedYear);

    final firstDay = DateTime(year, monthIndex, 1);
    final lastDay = DateTime(year, monthIndex + 1, 0);

    final filteredTransactions = allTransactions.where((txn) {
      final txnDate = DateTime.tryParse(txn.date);
      return txnDate != null &&
          txnDate.year == year &&
          txnDate.month == monthIndex;
    }).toList();

    // Initialize total income and outcome
    totalIncome = 0;
    totalOutcome = 0;

    // Loop through all transactions in the selected month
    filteredTransactions.forEach((txn) {
      if (txn.type == 'income') {
        totalIncome += txn.amount;
      } else if (txn.type == 'outcome') {
        totalOutcome += txn.amount;
      }
    });

    setState(() {});
  }

  String _formatRupiah(int value) {
    return 'Rp. ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text('Weekly Summary - ${widget.selectedMonth} ${widget.selectedYear}'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Senin - Minggu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text(
                  'Total Income',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatRupiah(totalIncome)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text(
                  'Total Outcome',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatRupiah(totalOutcome)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
