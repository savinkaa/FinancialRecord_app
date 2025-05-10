import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/transaction_db.dart';
import '../models/transaction_model.dart';
import 'profile_screen.dart';
import 'weekly_summary_screen.dart';
import '../summary_card.dart';

class TransactionHomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const TransactionHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _TransactionHomePageState createState() => _TransactionHomePageState();
}

class _TransactionHomePageState extends State<TransactionHomePage> {
  List<TransactionModel> transactions = [];
  late String selectedDate;
  late String selectedMonth;
  late String selectedYear;

  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = now.day.toString().padLeft(2, '0');
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await TransactionDatabase.instance.readAll();
    setState(() {
      transactions = data.where((txn) {
        final parts = txn.date.split('-');
        if (parts.length != 3) return false;
        final year = parts[0];
        final monthIndex = int.tryParse(parts[1]);
        final day = parts[2];
        final monthName = (monthIndex != null && monthIndex >= 1 && monthIndex <= 12)
            ? months[monthIndex - 1]
            : '';
        return year == selectedYear &&
            monthName == selectedMonth &&
            day == selectedDate;
      }).toList();
    });
  }

  void _onDateSelected(String date) {
    setState(() {
      selectedDate = date;
    });
    _loadTransactions();
  }

  void _addOrEditTransaction({TransactionModel? txn}) {
    final amountController = TextEditingController(text: txn?.amount.toString());
    final labelController = TextEditingController(text: txn?.label);
    String type = txn?.type ?? 'income';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(txn == null ? 'Add Transaction' : 'Edit Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButton<String>(
                  value: type,
                  onChanged: (val) {
                    setStateDialog(() => type = val!);
                  },
                  items: ['income', 'outcome']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = int.tryParse(amountController.text);
                  if (amount == null || labelController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Amount and Label cannot be empty!')),
                    );
                    return;
                  }

                  final monthIndex = months.indexOf(selectedMonth) + 1;
                  final monthStr = monthIndex.toString().padLeft(2, '0');
                  final model = TransactionModel(
                    id: txn?.id,
                    type: type,
                    amount: amount,
                    label: labelController.text,
                    date: '$selectedYear-$monthStr-$selectedDate',
                  );

                  if (txn == null) {
                    await TransactionDatabase.instance.create(model);
                  } else {
                    await TransactionDatabase.instance.update(model);
                  }

                  Navigator.pop(context);
                  _loadTransactions();
                },
                child: Text(txn == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTransaction(int id) async {
    await TransactionDatabase.instance.delete(id);
    _loadTransactions();
  }

  int _total(String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonthIndex = months.indexOf(selectedMonth) + 1;
    final selectedDay = int.parse(selectedDate);
    final selectedDateTime = DateTime(int.parse(selectedYear), selectedMonthIndex, selectedDay);
    final startOfWeek = selectedDateTime.subtract(Duration(days: selectedDateTime.weekday % 7));

    final isDark = widget.isDarkMode;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: const Text('FinancialRecords App'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklySummaryScreen(
                        selectedMonth: selectedMonth,
                        selectedYear: selectedYear,
                      ),
                    ),
                  );
                },
              ),
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
              const Icon(Icons.dark_mode),
            ],
          ),
          body: _buildBody(startOfWeek, bgColor, textColor, cardColor),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () => _addOrEditTransaction(),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(DateTime startOfWeek, Color bgColor, Color textColor, Color? cardColor) {
    final selectedMonthIndex = months.indexOf(selectedMonth) + 1;

    return Column(
      children: [
        Container(
          color: Colors.green[700]?.withOpacity(0.8),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedMonth,
                    dropdownColor: Colors.green[800],
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                      _loadTransactions();
                    },
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedYear,
                    dropdownColor: Colors.green[800],
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                      _loadTransactions();
                    },
                    items: List.generate(10, (index) {
                      final year = (2020 + index).toString();
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year, style: const TextStyle(color: Colors.white)),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final day = startOfWeek.add(Duration(days: index));
                  final dayStr = day.day.toString().padLeft(2, '0');
                  final isSelected = day.day.toString().padLeft(2, '0') == selectedDate &&
                      day.month == selectedMonthIndex &&
                      day.year.toString() == selectedYear;

                  return GestureDetector(
                    onTap: () => _onDateSelected(dayStr),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SummaryCard(label: 'Income', amount: _total('income'), icon: Icons.arrow_downward, color: Colors.green),
              SummaryCard(label: 'Outcome', amount: _total('outcome'), icon: Icons.arrow_upward, color: Colors.red),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? Center(
            child: Text('No transactions found.', style: TextStyle(color: textColor)),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    txn.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: txn.type == 'income' ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    'Rp. ${txn.amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(txn.label, style: TextStyle(color: textColor)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditTransaction(txn: txn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTransaction(txn.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
