import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  TransactionDetailScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Detail'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${transaction.type}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Amount: Rp ${transaction.amount}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Label: ${transaction.label}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
