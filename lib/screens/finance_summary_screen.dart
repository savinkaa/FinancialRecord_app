import 'package:flutter/material.dart';
import '../db/transaction_db.dart';
import '../models/transaction_model.dart';

class FinanceSummaryScreen extends StatelessWidget {
  final TransactionDatabase db = TransactionDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Summary'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: db.readAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];
          final totalIncome = _total('income', transactions);
          final totalOutcome = _total('outcome', transactions);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Income: Rp ${_formatAmount(totalIncome)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Outcome: Rp ${_formatAmount(totalOutcome)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Net Balance: Rp ${_formatAmount(totalIncome - totalOutcome)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _total(String type, List<TransactionModel> transactions) {
    return transactions
        .where((txn) => txn.type == type)
        .fold(0, (sum, txn) => sum + txn.amount);
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }
}
