import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/transaction_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TransactionApp());
}

class TransactionApp extends StatefulWidget {
  @override
  State<TransactionApp> createState() => _TransactionAppState();
}

class _TransactionAppState extends State<TransactionApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  // Load theme preference from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }
  // Save theme preference to shared preferences
  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transaction App',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'DMSerifText', // Custom font for light mode
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'DMSerifText', // Custom font for dark mode
        ),
      ),
      home: TransactionHomePage(
        isDarkMode: isDarkMode,
        onThemeChanged: (val) {
          setState(() {
            isDarkMode = val;
            _saveTheme(val);  // Save theme preference when changed
          });
        },
      ),
    );
  }
}
