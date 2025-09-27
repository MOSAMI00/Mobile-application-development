import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;
  
  // تسميات العمليات المالية القابلة للتخصيص
  String _incomeLabel = 'وارد';
  String _expenseLabel = 'صادر';

  ThemeProvider() {
    _loadPreferences();
  }

  // Getters للوصول للقيم
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  String get incomeLabel => _incomeLabel;
  String get expenseLabel => _expenseLabel;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
    
    // تحميل تسميات العمليات المخصصة
    _incomeLabel = prefs.getString('incomeLabel') ?? 'وارد';
    _expenseLabel = prefs.getString('expenseLabel') ?? 'صادر';
    
    notifyListeners();
  }


  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

 
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  Future<void> setIncomeLabel(String label) async {
    if (label.trim().isNotEmpty) {
      final oldLabel = _incomeLabel; // حفظ التسمية القديمة
      _incomeLabel = label.trim();
      
      // تحديث جميع العمليات السابقة التي تستخدم التسمية القديمة
      await _updateTransactionLabels(oldLabel, _incomeLabel);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('incomeLabel', _incomeLabel);
      notifyListeners();
    }
  }

 
  Future<void> setExpenseLabel(String label) async {
    if (label.trim().isNotEmpty) {
      final oldLabel = _expenseLabel; // حفظ التسمية القديمة
      _expenseLabel = label.trim();
      
      // تحديث جميع العمليات السابقة التي تستخدم التسمية القديمة
      await _updateTransactionLabels(oldLabel, _expenseLabel);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('expenseLabel', _expenseLabel);
      notifyListeners();
    }
  }

  Future<void> resetLabelsToDefault() async {
    final oldIncomeLabel = _incomeLabel;
    final oldExpenseLabel = _expenseLabel;
    
    _incomeLabel = 'وارد';
    _expenseLabel = 'صادر';
    
    // تحديث جميع العمليات السابقة بالتسميات الجديدة
    await _updateTransactionLabels(oldIncomeLabel, _incomeLabel);
    await _updateTransactionLabels(oldExpenseLabel, _expenseLabel);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('incomeLabel', _incomeLabel);
    await prefs.setString('expenseLabel', _expenseLabel);
    notifyListeners();
  }

  
  Future<void> _updateTransactionLabels(String oldLabel, String newLabel) async {
    try {
      int updatedCount = 0;
      
      // البحث عن جميع العمليات التي تستخدم التسمية القديمة وتحديثها
      for (var transaction in transactions) {
        if (transaction['type'] == oldLabel) {
          transaction['type'] = newLabel;
          updatedCount++;
        }
      }
      
      // حفظ التغييرات في التخزين المحلي
      if (updatedCount > 0) {
        await DataPersistence.saveTransactions();
        print('تم تحديث $updatedCount عملية تلقائياً من "$oldLabel" إلى "$newLabel"');
      } else {
        print('لا توجد عمليات تحتاج لتحديث من "$oldLabel"');
      }
    } catch (e) {
      print('خطأ في تحديث تسميات العمليات: $e');
    }
  }


  Future<void> resetAllSettings() async {
    final oldIncomeLabel = _incomeLabel;
    final oldExpenseLabel = _expenseLabel;
    
    _themeMode = ThemeMode.system;
    _primaryColor = Colors.blue;
    _incomeLabel = 'وارد';
    _expenseLabel = 'صادر';
    
    // تحديث جميع العمليات السابقة بالتسميات الجديدة
    await _updateTransactionLabels(oldIncomeLabel, _incomeLabel);
    await _updateTransactionLabels(oldExpenseLabel, _expenseLabel);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setString('incomeLabel', _incomeLabel);
    await prefs.setString('expenseLabel', _expenseLabel);
    notifyListeners();
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _themeMode = ThemeMode.system;
    _primaryColor = Colors.blue;
    _incomeLabel = 'وارد';
    _expenseLabel = 'صادر';
    notifyListeners();
  }
}