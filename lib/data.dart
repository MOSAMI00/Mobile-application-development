import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> accounts = [];
int accountIdCounter = 1;

// القوائم لتخزين العمليات مؤقتًا
List<Map<String, dynamic>> transactions = [];
int transactionIdCounter = 1;
// الحسابات


// التصنيفات
List<Map<String, dynamic>> categories = [
  {'id': 1, 'name': 'شخصي', 'enabled': true},
  {'id': 2, 'name': 'عمل', 'enabled': true},
  {'id': 3, 'name': 'مدخرات', 'enabled': true},
];
int categoryIdCounter = 4;

// Data persistence functions
class DataPersistence {
  static const String _transactionsKey = 'transactions';
  static const String _transactionCounterKey = 'transactionIdCounter';
  static const String _accountsKey = 'accounts';
  static const String _accountCounterKey = 'accountIdCounter';
  static const String _categoriesKey = 'categories';
  static const String _categoryCounterKey = 'categoryIdCounter';

  // Save transactions to SharedPreferences
  static Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((tx) {
      // Convert DateTime to string for JSON serialization
      final txCopy = Map<String, dynamic>.from(tx);
      if (txCopy['date'] is DateTime) {
        txCopy['date'] = (txCopy['date'] as DateTime).toIso8601String();
      }
      return txCopy;
    }).toList();
    
    await prefs.setString(_transactionsKey, jsonEncode(transactionsJson));
    await prefs.setInt(_transactionCounterKey, transactionIdCounter);
  }

  // Load transactions from SharedPreferences
  static Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = prefs.getString(_transactionsKey);
    
    if (transactionsString != null) {
      final List<dynamic> transactionsJson = jsonDecode(transactionsString);
      transactions = transactionsJson.map((tx) {
        final txMap = Map<String, dynamic>.from(tx);
        // Convert string back to DateTime
        if (txMap['date'] is String) {
          txMap['date'] = DateTime.parse(txMap['date']);
        }
        return txMap;
      }).toList();
    }
    
    transactionIdCounter = prefs.getInt(_transactionCounterKey) ?? 1;
  }

  // Save accounts to SharedPreferences
  static Future<void> saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
    await prefs.setInt(_accountCounterKey, accountIdCounter);
  }

  // Load accounts from SharedPreferences
  static Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsString = prefs.getString(_accountsKey);
    
    if (accountsString != null) {
      final List<dynamic> accountsJson = jsonDecode(accountsString);
      accounts = accountsJson.cast<Map<String, dynamic>>();
    }
    
    accountIdCounter = prefs.getInt(_accountCounterKey) ?? 1;
  }

  // Save categories to SharedPreferences
  static Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(categories));
    await prefs.setInt(_categoryCounterKey, categoryIdCounter);
  }

  // Load categories from SharedPreferences
  static Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString(_categoriesKey);
    
    if (categoriesString != null) {
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      categories = categoriesJson.cast<Map<String, dynamic>>();
    } else {
      // Initialize with default categories if none exist
      categories = [
        {'id': 1, 'name': 'شخصي', 'enabled': true},
        {'id': 2, 'name': 'عمل', 'enabled': true},
        {'id': 3, 'name': 'مدخرات', 'enabled': true},
      ];
    }
    
    categoryIdCounter = prefs.getInt(_categoryCounterKey) ?? 4;
  }

  // Load all data
  static Future<void> loadAllData() async {
    await loadCategories();
    await loadAccounts();
    await loadTransactions();
  }

  // Save all data
  static Future<void> saveAllData() async {
    await saveCategories();
    await saveAccounts();
    await saveTransactions();
  }
}